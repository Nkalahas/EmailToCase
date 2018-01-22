/****************************************************************************************************
 * Description - Email service to create Case on receiveng email to tsn request
 * Author - Naresh Kalahasthi
 ****************************************************************************************************/

global class EmailCaseGVE implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        

        boolean count;
        string uName;
        string uTitle;
        string uOrg;
        string uwpn;
        string ucountry;
        string umobile;
        string uRequestor;
        string uEmail;
        
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        Date d = Date.today();
        date duedate = addBusinessDays(d,3);
        String caseLanguage = caseLanguage(email.headers);
        
        Case caseGVE = new Case();
        string emailAdress = email.fromAddress.trim().toLowerCase();
        if (emailAdress.contains('@cisco.com'))
        {
            List<User> ciscoUser = [SELECT Id,Name,Email, Title,Theatre__c,Country,Phone,MobilePhone,Department FROM User WHERE Email = :email.fromAddress and UserType = 'Standard' LIMIT 1];
            System.debug('Cisco User for Case: ' + ciscoUser);
            caseGVE.Cisco_Contact__c = email.fromAddress;
            if (!ciscoUser.isEmpty())
            {
                uName = ciscoUser[0].Name;
                uTitle = ciscoUser[0].Title;
                ucountry = ciscoUser[0].Country;
                uRequestor = ciscoUser[0].Id;
                uOrg =  ciscoUser[0].Department;
                umobile= ciscoUser[0].MobilePhone;
                uwpn = ciscoUser[0].Phone;
                uEmail = ciscoUser[0].Email;

            }
            else {
               case caseval  = new case();
               String cec = email.fromAddress.substring(0,email.fromAddress.indexOf('@')).trim().toLowerCase();
 
                   caseval = TSNUserUnifiedDetailsWebService.getCecVal(cec);
                   
                   if(caseval != null){
                       uName = caseval.Cisco_Contact_Name__c;
                       uTitle = caseval.Cisco_Contact_Title__c;
                       uOrg = caseval.Cisco_Contact_Organization__c;
                       uwpn =  caseval.Cisco_Contact_Work_Phone_Number__c;
                       ucountry = caseval.Country__c;
                       umobile = caseval.Cisco_Contact_Mobile_Number__c;
                       uEmail = envelope.fromAddress;
                   }
                   else{
                        uEmail =  email.fromAddress; 
                   }            
        } 
        
        caseGVE.Status = 'New';
        caseGVE.Origin = 'Email';
        caseGVE.Subject = email.subject;
        caseGVE.description = email.plaintextbody;
        caseGVE.RecordtypeId = system.Label.GVECaseRecordType;
        caseGVE.Preferred_Contact_Method__c =  'Email';
        caseGVE.Requested_Due_Date__c = duedate;
        caseGVE.Case_Language__c = caseLanguage;
        caseGVE.Cisco_Contact__c = uEmail;
        caseGVE.Cisco_Contact_Name__c = uName;        
        caseGVE.Cisco_Contact_Organization__c= uOrg;        
        caseGVE.Cisco_Contact_Work_Phone_Number__c= uwpn;         
        caseGVE.Cisco_Contact_Title__c= uTitle; 
        caseGVE.Cisco_Contact_Mobile_Number__c= umobile;
        caseGVE.Case_Requester__c  = uRequestor;         

         insert caseGVE;

        System.debug('====> Created case '+caseGVE.Id);
        
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                Attachment attachment = new Attachment();
                // attach to the newly created contact record
                attachment.ParentId = caseGVE.Id;
                attachment.Name = email.binaryAttachments[i].filename;
                attachment.Body = email.binaryAttachments[i].body;
               try{
                    insert attachment ;
                } catch (DMLException e){
                               
                caseGVE.description = system.label.GVEEmailtocaseAttachmentFailure + email.plaintextbody;
                update caseGVE;    
                }                                
                    
                }
            }                                                                                              
        }
        else {

                     Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                     String body = 'Dear ' + 'User ' + ', '+'<br/>'+'<br/>';
                      body += 'Thank you for your request. '+'<br/>'+'<br/>';
                      body += 'Email requests are supported for internal Cisco employees. If you are a Cisco partner, please use our  <a href="https://www.cisco.com/c/en/us/partners/tools/partner-helpline.html">GVE Web Form</a> to submit your request.'+'<br/>'+'<br/>';
                      body += 'Sincerely,'+'<br/>';
                      body += 'Cisco GVE Team'+ '<br/>';
                     mail.setHtmlBody(body);
                     String[] toAddresses;
                     if( envelope.fromAddress!= null && envelope.fromAddress!= '' )
                     {
                     toAddresses = new String[] {envelope.fromAddress};
                     }

                     mail.setToAddresses(toAddresses);
                     mail.setSubject(email.subject);
                     mail.setSenderDisplayName('Cisco GVE Team');

                     system.debug('??'+mail);
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        
        return result;
    }
    
    /*    ***********************  Business days logic to capture due date **************************
    
          *************************************************************************************     */
    public static date addBusinessDays(Date startingdate, integer daystoAdjust){
        date newDate = startingdate;
        integer businessDayLeft;
        boolean isweekend;
        integer direction;
        If(daysToAdjust == 0){
            Return startingdate;
        }
        Direction = daysToAdjust>0?1:-1;
        
        For (integer i=0;i<daysToAdjust;i++){
            date weekstartdate = newdate.tostartofWeek();
            integer numberdays = weekstartdate.daysbetween(newdate);
            newdate = newdate.adddays(direction);
            If(numberDays==0 || numberDays == 6){
                i--;
            }
        }
        return newdate;
    }
    
        /*    ***********************  Method to get Languaage **************************
    
          *************************************************************************************     */
     public static string caseLanguage(Messaging.InboundEmail.Header[] headers)
     {
     String caseLanguagetoupdate = 'English';
     String headervalue;
     for (Messaging.InboundEmail.Header header : headers) {
             if (header.name == 'To') {
                 headervalue = header.value;
             }  
      } 
     if(headervalue.contains(System.Label.tsnGermanGVE)){
     caseLanguagetoupdate = 'German';
     }
     if(headervalue.contains(System.Label.tsnKoreanGVE)){
     caseLanguagetoupdate = 'Korean';
     }
     if(headervalue.contains(System.Label.tsnMandarinGVE)){
     caseLanguagetoupdate = 'Mandarin';
     }
     if(headervalue.contains(System.Label.tsnItalianGVE)){
     caseLanguagetoupdate = 'Italian';
     }
     if(headervalue.contains(System.Label.tsnFrenchGVE)){
     caseLanguagetoupdate = 'French';
     } 
     if(headervalue.contains(System.Label.tsnJapaneseGVE)){
     caseLanguagetoupdate = 'Japanese';
     }
     if(headervalue.contains(System.Label.tsnPortugueseGVE)){
     caseLanguagetoupdate = 'Portuguese';
     }     
     if(headervalue.contains(System.Label.tsnSpanishGVE)){
     caseLanguagetoupdate = 'Spanish';
     }
     if(headervalue.contains(System.Label.tsnEnglishGVE))
     {
     caseLanguagetoupdate  = 'English';
     }   

        return caseLanguagetoupdate ;
    }  
}