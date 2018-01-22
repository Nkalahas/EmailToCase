function getConstant(i_key, i_oType) 
{ 

var qrStr = "SELECT prod_value__c, non_prod_value__c " + 
"FROM Org_Constants__c " + 
"WHERE Key__c = '" + i_key + "'";  
try { 
var queryResult=sforce.connection.query(qrStr); 
var records = queryResult.getArray('records'); 
var q_value; 


if (records.length > 0) 
{ 
var hostname = window.location.hostname.toLowerCase(); 
org_id = '{!($Label.organizationId)}';
if (org_id == '00D300000000QUu' && ((hostname.indexOf('ww') && hostname.indexOf('ciscosales.my')) != -1)) 
{ 
q_value = records[0].prod_value__c; 
} 
else 
{ 
q_value = records[0].non_prod_value__c; 
} 
} 
else if (records.length == 0) 
alert('No value defined for ' + i_key +', ' + i_oType); 

if (q_value == null) alert(i_key +', ' + i_oType + ' has a null value'); 
return q_value; 
} 
catch(ex) { 
alert(ex); 
} 
} 

///////////////////// RECORD TYPES 

function getRecordTypeId(i_object, i_typeName){ 

try { 
var qrStr = "Select Id From RecordType where" + 
" sObjectType = '" + i_object + "'" + 
" and Name = '" + i_typeName + "'" + 
" and isactive = true limit 1"; 

var queryResult=sforce.connection.query(qrStr); 
var records = queryResult.getArray('records'); 
var Id = na; 

for (var i= 0; i < records.length; i++){ 
Id = records[i].Id; 
} 
return Id 
} 
catch(ex) { 
alert(ex); 
} 
} 

//////////////////// UTILS 

function Get_Cookie(name) { 
var start = document.cookie.indexOf( name + "=" ); 
var len = start + name.length + 1; 
if ( ( !start ) && 
( name != document.cookie.substring( 0, name.length ) ) ) 
{ 
return null; 
} 
if ( start == -1 ) return null; 
var end = document.cookie.indexOf( ";", len ); 
if ( end == -1 ) end = document.cookie.length; 
return( unescape( document.cookie.substring( len, end ) )); 
} 

//////////////// User Theater Value 

function getUserTheater(){ 
var qrStr = "Select Theatre__c From User where " + 
"Id = '{!$User.Id}' "; 
var queryResult=sforce.connection.query(qrStr); 
var records = queryResult.getArray('records'); 
return records[0].Theatre__c; 
} 

//////////////// Checking permissions from 'Additional User Permission' picklist 