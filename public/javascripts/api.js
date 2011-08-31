function ajaxUpdateControllerMethodPermission(roleId, methodName, controllerName, value){
	
	$.ajax({
		url: "/permissions/update",
		type: "POST",
		dataType: "html",
		data: {role:roleId, methodName:methodName, controllerName:controllerName, value:value},
		success: function(data){
			alert(data);
		},
		error: function (xhr,err,e) {
		  	alert(e);
		}
	});
}