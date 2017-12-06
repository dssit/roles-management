# Group shares many attributes with entity.
class Group < Entity
  has_many :memberships, class_name: 'GroupMembership', dependent: :destroy
  has_many :members, through: :memberships, source: :entity
  has_many :role_assignments, foreign_key: 'entity_id', dependent: :destroy
  has_many :roles, through: :role_assignments, dependent: :destroy
  has_many :group_ownerships, dependent: :destroy
  has_many :owners, through: :group_ownerships, source: 'entity', dependent: :destroy
  has_many :application_ownerships, foreign_key: 'entity_id', dependent: :destroy
  has_many :application_operatorships, foreign_key: 'entity_id', dependent: :destroy
  has_many :group_operatorships, dependent: :destroy
  has_many :operators, through: :group_operatorships, source: 'entity', dependent: :destroy
  has_many :rules, foreign_key: 'group_id', class_name: 'GroupRule', dependent: :destroy

  validates_presence_of :name

  accepts_nested_attributes_for :rules, allow_destroy: true
  accepts_nested_attributes_for :memberships, allow_destroy: true

  after_create do |group|
    ActivityLog.info!("Created group #{group.name}.", ["group_#{group.id}", 'system'])
  end

  before_destroy :allow_group_membership_destruction, prepend: true
  after_destroy do |group|
    GroupMembership.can_destroy_calculated_group_membership(false)
    ActivityLog.info!("Deleted group #{group.name}.", ['system'])
  end

  def as_json(_options = {})
    { id: id, name: name, type: 'Group', description: description,
      owners: owners.map { |o| { id: o.id, loginid: o.loginid, name: o.name } },
      operators: operators.map { |o| { id: o.id, loginid: o.loginid, name: o.name } },
      memberships: memberships.includes(:entity).map { |m| { id: m.id, entity_id: m.entity.id, name: m.entity.name, loginid: m.entity.loginid, calculated: m.calculated } },
      rules: rules.map { |r| { id: r.id, column: r.column, condition: r.condition, value: r.value } } }
  end

  # Returns identifying string for logging purposes. Other classes implement this too.
  # Format: (Class name:id,identifying fields)
  def log_identifier
    "(Group:#{id},#{name})"
  end

  # Returns all members, both explicitly assigned and calculated via rules.
  # Recurses groups all the way down to return a list of _only_people_.
  def flattened_members
    members.to_a.map { |e| e.type == 'Group' ? e.flattened_members.flatten : e }.reject { |m| m == [] }.uniq(&:id)
  end

  # Calculates (and resets) all group_members based on rules.
  # Will delete any *_member_assignment flagged as calculated and rebuild
  # from rules.
  # This algorithm starts with an empty set, then runs all 'is'
  # rules, intersecting those sets, then makes a second pass and
  # removes anyone who fails a 'is not' rule.
  def update_members
    Rails.logger.tagged "Group #{id}" do
      results = []

      recalculate_start = Time.now

      logger.debug 'Re-assembling group members using rule result set cache ...'

      # Step One: Build groups out of each 'is' rule,
      #           grouping rules of similar type together via OR
      #           Note: we ignore the 'loginid' column as it is calculated separately
      Rails.logger.tagged 'Step One' do
        # Produce an array of arrays: outer array items represent each column type used, inner arrays are all group rule IDs for that specific column type
        # e.g. id: 1 "organization is", id: 2 "organization is", id: 3 "department is" produces: [ [1,2] , [3] ]
        step_one_rule_set_ids = GroupRule.select(:group_rule_set_id, :column)
                                         .where(group_id: id)
                                         .where(condition: 'is')
                                         .where.not(column: 'loginid')
                                         .group_by(&:column)
                                         .map { |set| set[1].map(&:group_rule_set_id) }

        step_one_rule_set_ids.each do |rule_set_id|
          results << GroupRuleResult.select(:entity_id)
                                    .joins(:group_rule_set)
                                    .where(group_rule_set_id: rule_set_id)
                                    .map(&:entity_id)
        end

        logger.debug "Ending step one with #{results.length} results"
      end

      # Step Two: AND all groups from step one together
      Rails.logger.tagged 'Step Two' do
        results = results.inject(results.first) { |sum, n| sum &= n }
        results = [] unless results # reduce/inject may return nil
        logger.debug "ANDing all results together yields #{results.length} results"
      end

      # Step Three: Pass over the result from step two and
      # remove anybody who violates an 'is not' rule
      # TODO: Optimize this step!
      Rails.logger.tagged 'Step Three' do
        step_three_rule_set_ids = GroupRule.select(:group_rule_set_id, :column)
                                           .where(group_id: id)
                                           .where(condition: 'is not')
                                           .group_by(&:column)
                                           .map { |set| set[1].map(&:group_rule_set_id) }

        negative_results = []

        step_three_rule_set_ids.each do |rule_set_id|
          negative_results << GroupRuleResult.select(:entity_id)
                                             .joins(:group_rule_set)
                                             .where(group_rule_set_id: rule_set_id)
                                             .map(&:entity_id)
        end

        results -= negative_results.flatten.uniq

        logger.debug "Removing any 'is not' violates yielded #{results.length} results"
      end

      # Step Four: Process any 'loginid is' rules
      Rails.logger.tagged 'Step Four' do
        rules.select { |r| r.condition == 'is' && r.column == 'loginid' }.each do |rule|
          logger.debug "Processing loginid is rule #{rule.value}..."
          results << rule.result_set.results.map(&:entity_id)
        end

        logger.debug "'Login ID is' additions yields #{results.length} results"
      end

      results.flatten!
      logger.debug "Results flattened, count now at #{results.length} results"

      # Look for memberships which need to be removed
      GroupMembership.where(group_id: id, calculated: true).each do |membership|
        # Note: Array.delete returns nil iff result is not in array
        next unless results.delete(membership.entity_id).nil?

        GroupMembership.destroying_calculated_group_membership do
          GroupMembership.recalculating_membership do
            membership.destroy
          end
        end
      end

      # Look for memberships to add
      # Whatever's left in 'results' are memberships which don't already exist
      # and need to be created.
      results.each do |r|
        GroupMembership.recalculating_membership do
          memberships << GroupMembership.new(entity_id: r, calculated: true)
        end
      end

      logger.debug "Calculated #{results.length} results. Membership now at #{memberships.length} members. Took #{Time.now - recalculate_start}s."
      logger.debug "Completed update_members(). Total elapsed time was #{Time.now - recalculate_start}s."
    end
  end

  # Records all IDs found while traversing up the parent graph.
  # Algorithm ends either when a duplicate ID is found (indicates a loop)
  # or no more parents exist (indicates no loops).
  def no_loops_in_group_membership_graph(seen_ids = [])
    return false if seen_ids.include?(id)

    seen_ids << id

    memberships.each do |membership|
      if membership.group.no_loops_in_group_membership_graph(seen_ids.dup) == false
        errors[:base] << 'Group membership cannot be cyclical'
        return false
      end
    end

    return true # rubocop:disable Style/RedundantReturn
  end

  private

  def allow_group_membership_destruction
    # Destroying a person may involve the valid case of destroying
    # calculated group memberships.
    GroupMembership.can_destroy_calculated_group_membership(true)
  end
end
