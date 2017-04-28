class RoleResource < Sequel::Model
  one_to_many :role_permissions
  many_to_one :role_resource_type
end