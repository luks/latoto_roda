class RoleMember < Sequel::Model

  many_to_one :role

  many_to_one :account

  one_through_one :owner, join_table: :roles, left_key: :id, left_primary_key: :account_id, right_key: :owner_id, class: :Account

end