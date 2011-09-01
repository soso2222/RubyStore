class PermissionsController < ApplicationController
    def index
        # Make sure that all methods of all controllers exist in the databas;
        populate_controller_methods()

        @roles = Role.all
        @roles.sort! { |a,b| a.name.downcase <=> b.name.downcase }
        @permissions = Permission.all

        @custom_permissions = Array.new
        @permissions.each do |permission|
            @returned_permission = exist(permission, @custom_permissions)
            if @returned_permission == nil
                @custom_permission = CustomPermissions.new
                @custom_permission.controller = permission.controller
                @custom_permission.methods = Array.new
                @custom_permission.methods << permission.method
                @custom_permissions << @custom_permission
            else
                @returned_permission.methods << permission.method
            end
            
            # Sort the list of methods;
            @returned_permission.methods.sort!
        end

        # Sort the list of controllers;
        @custom_permissions.sort! { |a,b| a.controller.downcase <=> b.controller.downcase }

        respond_to do |format|
            format.html # index.html.erb
            format.xml  { render :xml => @groups }
        end
    end

    # POST /permissions/update
    def update
        # Get a collection of all permissions matching them by controller name and method name;
        @permissions = Permission.first(:conditions=>{:controller=>params[:controllerName], :method=>params[:methodName]})

        # Ensure that the requested for addition permission is not already in the list;
        @permissions.role_ids.delete_if{ |roleId| roleId == params[:role]}

        # Add the permission to the list only if the value of the `value` parameter is true;
        if params[:value] == "true"
            @permissions.role_ids << params[:role]
        end

        # Popupate changes to database;
        @permissions.save

        respond_to do |format|
            format.json { render :json => '{}' }
        end
    end

    private

    def exist(permission, list)
        list.each do |custom_permission|
            if custom_permission.controller == permission.controller
            return custom_permission
            end
        end
        return nil
    end

    private

    def populate_controller_methods
        # As a templorary solution we will keep the controllers in a hard coded list;
        classnames = ['GroupsController', 'RolesController', 'PermissionsController']

        classnames.each do |classname|

            method_list = Kernel.const_get(classname).public_instance_methods(false)
            method_list.each do |method|

                permission = Permission.new
                permission.controller = classname
                permission.method = method
                permission.role_ids = []

                save_check = Permission.all(:conditions=>{:controller=>classname, :method=>permission.method})

                if save_check.empty?
                permission.save
                end
            end
        end
    end
end