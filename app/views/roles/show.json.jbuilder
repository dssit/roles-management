json.cache! ['roles_show', @cache_key] do
  json.extract! @role, :id, :token, :name, :application_id, :description
  json.assignments @role.role_assignments.select{ |a| a.entity.active == true } do |assignment|
    json.extract! assignment, :id, :entity_id
    json.type assignment.entity.type
    json.name assignment.entity.name
    json.calculated assignment.parent_id != nil
  end
end
