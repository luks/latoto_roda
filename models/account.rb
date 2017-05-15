class Account < Sequel::Model

  many_to_many :roles, join_table: :role_members, class: :Role

  one_to_many :authorities, key: :owner_id, class: :Role

  many_to_many :members, join_table: :roles, right_key: :id, right_primary_key: :role_id, left_key: :owner_id, class: :RoleMember

  one_to_many :role_members

end