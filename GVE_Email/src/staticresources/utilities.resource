function getConstant(i_key, i_oType){
        
        var qrStr = "SELECT Production_Value__c,  Non_Production_Value__c " +
        "FROM Org_Constant_CS__c " +
        "WHERE Name = '" + i_key + "'";
        
        try {
            var queryResult=sforce.connection.query(qrStr);
            var records = queryResult.getArray('records');
            var q_value;  
            
            if (records.length > 0){
                var hostname = window.location.hostname.toLowerCase();
                if (((hostname.indexOf('ww') && hostname.indexOf('ciscosales.my')) != -1)){
                    q_value = records[0].Production_Value__c;
                } else {
                    q_value = records[0].Non_Production_Value__c;
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