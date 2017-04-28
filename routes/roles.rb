module Latoto
  class App

    plugin :autoforme

    Forme.register_config(:mine, :base=>:default, :labeler=>:explicit, :wrapper=>:div)
    Forme.default_config = :mine
    require 'forme/bs3'

    setup_autoforme(:bootstrap3) do
      form_options(:config=>:bs3)
      mtm_associations :all
      model Role
      model RolePermission
      model RolePower
      model RoleResource
      model RoleResourceType
      model AccountRole
      model RoleMember
    end

    route 'roles' do |r|
      r.on do
        r.get do
          autoforme(:bootstrap3)
        end
      end
    end
  end
end
