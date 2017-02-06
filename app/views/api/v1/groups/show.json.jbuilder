json.cache! ['api_v1_groups_show', @cache_key] do
  json.extract! @group, :id, :name

  json.memberships @group.memberships.select{ |m| m.entity.active == true } do |membership|
    json.extract! membership, :id, :calculated, :entity_id
  end

  json.members @group.members.select{ |m| m.active == true } do |member|
    json.extract! member, :id, :name, :type

    if member.type == 'Person'
      json.email member.email
      json.first member.first
      json.last member.last
      json.loginid member.loginid
    end
  end
end
