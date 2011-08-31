class PermissionsController < ApplicationController

  
  def index
    check_permissions()
    @roles = Role.all
    @permissions = Permission.all
    
    
    
    @custompermissions = Array.new
    @permissions.each do |permission|
      @returned_permission = exist(permission, @custompermissions)
      if @returned_permission == nil
        @custom_permission = CustomPermissions.new
        @custom_permission.controller = permission.controller
        @custom_permission.methods = Array.new
        @custom_permission.methods << permission.method
        @custompermissions << @custom_permission
      else
        @returned_permission.methods << permission.method
      end
    end
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end
  
  # POST /permissions/update
  def update
    @permissions = Permission.first(:conditions=>{:controller=>params[:controllerName], :method=>params[:methodName]})
    
    # Make sure that there is no such role in the list;
    @permissions.role_ids.delete_if{ |roleId| roleId == params[:role]}
    
    # Add the role only ...
    if params[:value] == "true"
        @permissions.role_ids << params[:role] 
    end
    
    @permissions.save
    
    respond_to do |format|
      format.json { render :json => '{"result":' + @permissions.role_ids.to_json + '}' }
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
  def check_permissions
    
    
    
    #ApplicationController.send(:subclasses).each do |controller_name|
    #classname = controller_name
    
    classnames = ['GroupsController','RolesController','PermissionsController']
    classnames.each do |classname|
    
    a= Kernel.const_get(classname).public_instance_methods(false)
    #a= classname.instance_methods(false)
  
    a.each do |method| 
        
      p = Permission.new
      p.controller = classname
      p.method = method
      p.role_ids = []
      
  
      s = Permission.all(:conditions=>{:controller=>classname, :method=>p.method})
      #s = Permission.all
  
        if s.empty?
          p.save
        end
      end 
    #end
    
    
    end
    
  end

end
