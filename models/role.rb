class Role < Sequel::Model

  one_to_many :role_members
  one_to_many :role_permissions

  many_to_one :parent, class: self
  one_to_many :children, key: :parent_id, class: self

  many_to_one :owner, key: :owner_id, class: :Account

end