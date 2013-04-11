authorization do
  role :admin do
    # For creating/deleting applications
    has_permission_on :applications, :to => [:create, :delete]
    has_permission_on :application_owner_assignments, :to => [:create, :delete]
    has_permission_on :roles, :to => [:create, :delete]
  end
  
  role :access do
    # Allow access to the main page
    has_permission_on :applications, :to => :index
    
    # Operators can read applications
    has_permission_on :applications, :to => :read do
      if_attribute :operators => contains { user }
    end
    # Owners can read and update their own applications
    has_permission_on :applications, :to => [:read, :update] do
      if_attribute :owners => contains { user }
    end
    # NOTE: 'access' role cannot create or destroy applications
    
    # Allow creating/updating/reading of roles which belong to an application they own
    has_permission_on :roles, :to => [:read, :update, :create, :delete] do
      if_attribute :application => { :owners => contains { user } }
    end
    
    # Owning/operating applications requires reading :entities
    # Create/delete role_assignments for applications they own
    has_permission_on :role_assignments, :to => [:create, :delete] do
      if_attribute :role => { :application => { :owners => contains { user } } }
    end
    # Create/delete role_assignments for applications they operate
    has_permission_on :role_assignments, :to => [:create, :delete] do
      if_attribute :role => { :application => { :operators => contains { user } } }
    end
    
    # Allow viewing/searching of individuals
    has_permission_on :entities, :to => [:index, :show]
    
    has_permission_on :people, :to => :read
    # You can only update your own details
    has_permission_on :people, :to => :update do
      if_attribute :id => is { user.id }
    end
    # We need this duplicated permission due to entities/people being polymorphic
    has_permission_on :entities, :to => :update do
      if_attribute :id => is { user.id }
    end
    
    # Allow managing of their own favorites
    has_permission_on :person_favorite_assignments, :to => [:create, :delete] do
      if_attribute :owner_id => is { user.id }
    end
    
    # Allow creating groups
    has_permission_on :entities, :to => :create do
      if_attribute :type => is { 'Group' }
    end
    has_permission_on :groups, :to => :create
    has_permission_on :group_owner_assignments, :to => :create do
      if_attribute :entity_id => is { user.id }
    end
    # Allow deleting groups they own
    has_permission_on :entities, :to => [:update, :delete] do
      if_attribute :owners => contains { user }
    end
    has_permission_on :groups, :to => [:update, :delete] do
      if_attribute :owners => contains { user }
    end
    has_permission_on :group_owner_assignments, :to => [:create, :update, :delete] do
      if_attribute :group => { :owners => contains { user } }
    end
    
    # Allow searching/importing of people
    has_permission_on :people, :to => [:search, :import]
  end
end

privileges do
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
