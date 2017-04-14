# Let's say you were stupid and used the postgres account for something you
# shouldn't have, so you have a database owned by postgres, with all objects
# inside owned by postgres.  You regain sanity and want to transfer the
# ownership to an account that isn't a database superuser.
#
# In most cases, reassigning ownership is as simple as using
# REASSIGNED OWNED.  However, that does not work if you are using the
# postgres account, so you have to alter the ownership manually.
#
# First, make sure you connect to the database using the postgres account.
# Then, load the extension into your database:
#
#   # if stored as sequel/extensions/switch_postgres_owner.rb
#   DB.extension(:switch_postgres_owner)
#   # or the long way:
#   require '/path/to/switch_postgres_owner'
#   DB.extend SwitchPostgresOwner
#
# Then, switch the ownership:
#
#   DB.switch_owner_to('new_owner')
#
# This changes the ownership of the database itself, as well as the ownership of
# the tables, views, sequences, and functions in the public schema in the database.

module SwitchPostgresOwner
  def switch_owner_to(to)
    postgres_oid = from(:pg_roles).where(:rolname=>'postgres').get(:oid)
    public_oid = from(:pg_namespace).where(:nspname=>'public').get(:oid)
    to = quote_identifier(to)

    tables = tables(:schema=>:public)
    views = views(:schema=>:public)
    sequences = from(:pg_class).where(:relowner=>postgres_oid, :relnamespace=>public_oid, :relkind=>'S').select_map(:relname)
    functions = from(:pg_proc).where(:proowner=>postgres_oid, :pronamespace=>public_oid).select_map{[:proname, Sequel.function('pg_catalog.pg_get_function_arguments', :pg_proc__oid).as(:c)]}

    transaction do
      tables.each{|t| run "ALTER TABLE public.#{quote_identifier(t)} OWNER TO #{to}"}
      views.each{|t| run "ALTER VIEW public.#{quote_identifier(t)} OWNER TO #{to}"}
      sequences.each{|t| run "ALTER SEQUENCE public.#{quote_identifier(t)} OWNER TO #{to}"}
      functions.each{|t, a| run "ALTER FUNCTION public.#{quote_identifier(t)}(#{a}) OWNER TO #{to}"}
      run "ALTER DATABASE #{quote_identifier(get{current_database{}})} OWNER TO #{to}"
    end
  end
end
Sequel::Database.register_extension(:switch_postgres_owner, SwitchPostgresOwner)