# This file renders both people and groups (and OUs, which are a special form of groups)

object @entity

attribute :uid => :id
attributes :created_at, :name

if ((defined? @entity.members) != nil)
  child @entity.members => :members do
    attributes :id, :loginid, :name
  end
end

if ((defined? @entity.owners) != nil)
  child @entity.owners => :owners do
    attributes :uid, :loginid, :name
  end
end

if ((defined? @entity.operators) != nil)
  child @entity.operators => :operators do
    attributes :uid, :loginid, :name
  end
end

if ((defined? @entity.rules) != nil)
  child @entity.rules => :rules do
    attributes :id, :column, :condition, :value
  end
end