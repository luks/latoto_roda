Sequel.migration do
  change do

    create_table(:role_powers, :ignore_index_errors=>true) do
      primary_key :id
      Integer :power, :null=>false
      String :description, :null=>false

      index [:power], :name=>:power_index
      index [:power], :name=>:power_unique, :unique=>true
    end

    create_table(:role_resource_types) do
      primary_key :id
      String :type, :text=>true, :null=>false
    end

    create_table(:role_resources, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :null=>false
      foreign_key :role_resource_type_id, :role_resource_types, :null=>false, :key=>[:id]

      index [:name], :name=>:name_index
      index [:name], :name=>:name_unique, :unique=>true
    end

    create_table(:roles) do
      primary_key :id
      String :name, :null=>false
      foreign_key :parent_id, :roles, :key=>[:id], :on_delete=>:cascade
      foreign_key :owner_id, :accounts, :type=>:Bignum, :key=>[:id], :on_delete=>:cascade
    end

    create_table(:role_members, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :role_id, :roles, :type=>:Bignum, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :account_id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id], :on_delete=>:cascade

      index [:role_id, :account_id], :name=>:role_account_unique, :unique=>true
    end

    create_table(:role_permissions, :ignore_index_errors=>true) do
      foreign_key :role_resource_id, :role_resources, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :role_power_id, :role_powers, :null=>false, :key=>[:id], :on_delete=>:cascade
      primary_key :id, :keep_order=>true
      foreign_key :role_id, :roles, :type=>:Bignum, :null=>false, :key=>[:id], :on_delete=>:cascade

      index [:role_id, :role_resource_id], :name=>:account_resource_account_role, :unique=>true
    end
  end
end
