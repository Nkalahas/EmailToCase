function AdditionalCheckUserPermission(val_perm_to_check) 
{ 
var permission_flag = false; 
var user_id = '{!$User.Id}'; 
var qrStr = "Select u.additional_user_permissions__c From User u where u.Id = '" +user_id+ "'"; 
var queryResult=sforce.connection.query(qrStr); 
var records = queryResult.getArray('records'); 
if (records[0].Additional_User_Permissions__c == null) { 
permission_flag = false; 
} 
else { 
var split_val = records[0].Additional_User_Permissions__c; 
split_val = split_val.split(";"); 
for (var i=0; i< split_val.length; i++) { 
if(split_val[i] == val_perm_to_check) { 
permission_flag = true; 
break; 
} 
} 
} 
return permission_flag; 
} 