class RoleMember < Sequel::Model
  many_to_one :role
  many_to_one :account

end