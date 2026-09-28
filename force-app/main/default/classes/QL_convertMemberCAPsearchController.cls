public class QL_convertMemberCAPsearchController
{
    
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    @AuraEnabled public String recID {get;set;}
    
    @AuraEnabled
    public static QL_convertMemberCAPsearchController invokeWebServiceCAPSearch(Id memID)
        
    {     
        QL_convertMemberCAPsearchController objq = new QL_convertMemberCAPsearchController();
        List<Contact> lstcon = new List<Contact>();
        List<Contact> existingcon = new List<Contact>();
        String CAPID;
        Id ContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        try
        {  
            Associated_Person__c  member= [SELECT Id,Account__c,First_Name__c,Frequent_Flyer_Number__c,Last_Name__c,Profile_Email__c FROM Associated_Person__c  WHERE ID =:memID ];
            system.debug('Assosciated Person:' + member);
            
            //check if email field is present
            if(String.isBlank(member.Profile_Email__c)){
                objq.isSuccess = false;
                objq.msg = 'Please enter the Profile Email';
                return objq; 
            }
            
            existingcon =[SELECT Id,Frequent_Flyer_Number__c,accountid FROM CONTACT WHERE Frequent_Flyer_Number__c=: member.Frequent_Flyer_Number__c 
                          AND RecordTypeId = :ContRecordTypeId];
            system.debug('existingcon ********'+existingcon);
            if(!existingcon.isEmpty() && existingcon[0].accountid != null)
            {
                objq.isSuccess = false;
                objq.msg = 'Contact exist for this Member';
                return objq;
            }
            else if(!existingcon.isEmpty() && existingcon[0].accountid == null)
            {
                objq.isSuccess = false;
                objq.msg = 'Contact exist for this Member but No Account is tagged to it. Please raise a System Admin case';
                return objq;
            }
            
            QL_CAPCREDetailsRequest requestBody = new QL_CAPCREDetailsRequest();
            requestBody.qantasFFNo = member.Frequent_Flyer_Number__c.trim();
            System.debug('requestBody.qantasFFNo'+requestBody.qantasFFNo);
            requestBody.lastName =member.Last_Name__c;
            System.debug('lastName'+requestBody.lastName);
            requestBody.emailAddr = member.Profile_Email__c;
            System.debug('email'+requestBody.emailAddr);
            requestBody.customerPerPage='100';
            requestBody.system_z='CAPCRE_CC';
            system.debug('requestBody^^^^^^^'+requestBody);
            
            String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken'); // Updated from CAP to Loyalty Jira CRM-5595
            if(String.isBlank(token)) return null;
            //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/v2/'+requestBody.qantasFFNo+'/profile'; //CRM-5595
            //CRM-6427: CIP Decommissioning
            //CRM-6900: 201 SOQL limit fix
        	String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
            //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            
            req.setEndpoint(endpointURL);
            //req.setMethod(qantasAPI.Method__c); 
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            
            //CRM-5575 Automated token refresh for the loyalty subscription
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
            }
            system.debug('response#########'+response);
            system.debug('response#########'+response.getStatusCode());
            system.debug('response Body#########'+response.getBody());
            system.debug('req#########'+req);
            system.debug('req body#########'+req.getBody());
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
            
            if(response.getStatusCode() == 200){
                String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
                system.debug('modifiedJSON'+modifiedJSON);
                QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile formattedJSONProfile = (QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile.class);
                system.debug('formattedJSON Body######### profile'+formattedJSONProfile);
               
                QCC_LoyaltyResponseWrapper custResp = (QCC_LoyaltyResponseWrapper) System.JSON.deserialize(response.getBody(), QCC_LoyaltyResponseWrapper.class);
                if(custResp != null){
                                      
                    // system.debug('obj.Customer.qantasUniqueId*********'+obj.Customer.qantasUniqueId);
                    Contact cont = new Contact();
                    cont.firstname = member.First_Name__c;
                    cont.lastname = member.Last_Name__c;
                    cont.Frequent_Flyer_Number__c= member.Frequent_Flyer_Number__c;                
                    //cont.CAP_ID__c =  obj.Customer.qantasUniqueId;
                    // CAPID = obj.Customer.qantasUniqueId;
                    cont.Email=member.Profile_Email__c;
                    cont.Function__c='Other';
                    cont.Business_Types__c='Agency';
                    cont.Job_Role__c='Other';
                    cont.AccountId=member.Account__c;
                    cont.RecordTypeId = ContRecordTypeId;
                    lstcon.add(cont); 
                    System.debug('lstcon added contact: '+ lstcon);
                }
                system.debug('lstcon.size()'+lstcon.size());
                if(lstcon.size()>=0)
                    insert lstcon;
              
                objq.recID=lstcon[0].Frequent_Flyer_Number__c;
                system.debug('RecId=*****'+objq.recID);
                objq.isSuccess = true;
                objq.msg = 'Contact has been created sucessfully!';
                
            } 
            return objq;  
            
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());    
        }
        
    }
    
}