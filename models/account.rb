class Account < Sequel::Model

  one_to_many :role_members

  many_to_many :roles, join_table: :role_members, class: :Role

  one_to_many :authorities, key: :owner_id, class: :Role



end