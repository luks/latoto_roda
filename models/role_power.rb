class RolePower < Sequel::Model
  one_to_many :role_permissions
end