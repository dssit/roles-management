class PpsAssociation < ApplicationRecord
  belongs_to :person
  belongs_to :title
  belongs_to :department

  validates_presence_of :association_rank
  validates_presence_of :position_type_code

  after_save do
    GroupRuleSet.update_results_for(:pps_unit, person_id)
    GroupRuleSet.update_results_for(:pps_position_type, person_id)
    GroupRuleSet.update_results_for(:title, person_id)
    GroupRuleSet.update_results_for(:business_office_unit, person_id)
    GroupRuleSet.update_results_for(:department, person_id)
  end
  after_destroy do
    GroupRuleSet.update_results_for(:pps_unit, person_id)
    GroupRuleSet.update_results_for(:pps_position_type, person_id)
    GroupRuleSet.update_results_for(:title, person_id)
    GroupRuleSet.update_results_for(:business_office_unit, person_id)
    GroupRuleSet.update_results_for(:department, person_id)
  end

  def position_type_label
    case position_type_code
    when 1
      'Contract'
    when 2
      'Regular/Career'
    when 3
      'Limited, Formerly Casual'
    when 4
      'Casual/RESTRICTED-Students'
    when 5
      'Academic'
    when 6
      'Per Diem'
    when 7
      'Regular/Career Partial YEAR'
    when 8
      'Floater'
    else
      'Unknown'
    end
  end
end