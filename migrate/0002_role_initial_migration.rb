Sequel.migration do
  change do
    
    create_table(:role_powers, :ignore_index_errors=>true) do
      primary_key :id
      Integer :power, :null=>false
      String :description, :null=>false
      
      index [:power], :name=>:role_power_index, :unique=>true
    end
    
    create_table(:role_resource_types) do
      Integer :id, :null=>false
      String :type, :text=>true, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:roles, :ignore_index_errors=>true) do
      Integer :id, :null=>false
      String :role, :null=>false
      
      primary_key [:id]
      
      index [:role], :name=>:role_name
    end
    
    create_table(:account_roles, :ignore_index_errors=>true) do
      Bignum :id, :null=>false
      foreign_key :account_id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :role_id, :roles, :null=>false, :key=>[:id], :on_delete=>:cascade
      
      primary_key [:id]
      
      index [:account_id, :role_id], :name=>:unique_account_id_role_id, :unique=>true
    end
    
    create_table(:role_resources, :ignore_index_errors=>true) do
      Integer :id, :null=>false
      String :name, :null=>false
      foreign_key :type_id, :role_resource_types, :null=>false, :key=>[:id]
      
      primary_key [:id]
      
      index [:name], :name=>:role_resource_name
    end
    
    create_table(:account_role_members, :ignore_index_errors=>true) do
      Bignum :id, :null=>false
      foreign_key :account_role_id, :account_roles, :type=>:Bignum, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :account_id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id], :on_delete=>:cascade
      
      primary_key [:id]
      
      index [:account_role_id, :account_id], :name=>:unique_role_id_account_id, :unique=>true
    end
    
    create_table(:role_permissions, :ignore_index_errors=>true) do
      foreign_key :role_resource_id, :role_resources, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :role_power_id, :role_powers, :null=>false, :key=>[:id], :on_delete=>:cascade
      Bignum :id, :null=>false
      foreign_key :account_role_id, :account_roles, :type=>:Bignum, :null=>false, :key=>[:id], :on_delete=>:cascade
      
      primary_key [:id]
      
      index [:account_role_id, :role_resource_id], :name=>:account_resource_account_role, :unique=>true
    end
  end
end
