class RolePermission < Sequel::Model
  many_to_one :role
  many_to_one :role_power
  many_to_one :role_resource

end