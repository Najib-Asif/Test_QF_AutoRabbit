/*
* Created By : Ajay | TCS | Cloud Developer 
* Purpose : To validate, create, reset Site Admin credentials in LDAP System
* Reference : QAC_LDAPDetailsWrapper

    Modified Date   : 26/06/19 (DD/MM/YYYY)
    Modified By        : Vinothkumar Balasubramanian
    Version         : V2.0 - Tradesite flag is not required for LDAP Account creation 
                      and Remove the Reset Flag
*/

public with sharing class QAC_SiteAdministrator_Controller {
    
    @AuraEnabled
    public String ldapResponse;
    
    @AuraEnabled
    public QAC_LDAPDetailsWrapper ldapDetails;
    
    @AuraEnabled
    public Account accDetails;
    
    @AuraEnabled
    public static QAC_SiteAdministrator_Controller sfAccDetails(string strIATA)
    {
        QAC_SiteAdministrator_Controller myWrap = new QAC_SiteAdministrator_Controller();
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Account myAcc;
        for(Account eachAcc : [select id, Qantas_Industry_Centre_ID__c, name, 
                               Country_f__c, Email__c,tradesite__c,active__c,rcti__c,CreatedDate 
                               from Account where qantas_industry_centre_id__c =: strIATA AND RecordTypeId =: agencyRecordTypeId])
        {
            if(eachAcc != null){
                myWrap.accDetails = eachAcc;                
            }
        }
        return myWrap;
    }
    
    @AuraEnabled
    public static QAC_SiteAdministrator_Controller validateLDAP(string strIATA)
    {
        QAC_SiteAdministrator_Controller myWrap = new QAC_SiteAdministrator_Controller();
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QAC_LDAPValidateAPI');
        myWrap = httpUtilityLogic(qantasAPI.EndPoint__c,qantasAPI.Method__c,strIATA,'validate');
        return myWrap;
    }
    
    @AuraEnabled
    public static QAC_SiteAdministrator_Controller createLDAP(string strIATA)
    {
        QAC_SiteAdministrator_Controller myWrap = new QAC_SiteAdministrator_Controller();
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QAC_LDAPCreateAPI');
        myWrap = httpUtilityLogic(qantasAPI.EndPoint__c,qantasAPI.Method__c,strIATA,'create');
        return myWrap;
    }
    
    /*@AuraEnabled
    public static QAC_SiteAdministrator_Controller resetLDAP(string strIATA)
    {
        QAC_SiteAdministrator_Controller myWrap = new QAC_SiteAdministrator_Controller();
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QAC_LDAPResetAPI');
        myWrap = httpUtilityLogic(qantasAPI.EndPoint__c,qantasAPI.Method__c,strIATA,'reset');
        return myWrap;
    }*/
    
    public static Datetime getDateTimeValue(String myDt){
        // 20190111011924.522
        Datetime myDateTime = DateTime.newInstance(Integer.valueOf(myDt.substring(0,4)),
                                                   Integer.valueOf(myDt.substring(4,6)),
                                                   Integer.valueOf(myDt.substring(6,8)),
                                                   Integer.valueOf(myDt.substring(8,10)),
                                                   Integer.valueOf(myDt.substring(10,12)),
                                                   Integer.valueOf(myDt.substring(12,14)));
        return myDateTime;
    }
    
    public static String fetchToken()
    {
        // To retrieve Authentication token
        String token = QCC_GenericUtils.getCAPValidToken('QAC_AdminSiteToken');
        return token;
    }
    
    public static void updateToken(String token)
    {
        // To update Authentication token
        QCC_GenericUtils.updateToken(token, 'QAC_AdminSiteToken');
    }

    public static User getUserDetails(){
        return [Select Id,FederationIdentifier,Qantas_Staff_ID__c,Email from User where Id =: UserInfo.getUserId()];
    }
    
    public static QAC_SiteAdministrator_Controller httpUtilityLogic(String epURL, String method, String iataNum, String buttonName)
    {
        QAC_SiteAdministrator_Controller myWrap = new QAC_SiteAdministrator_Controller();
        QAC_LDAPDetailsWrapper myLdap = new QAC_LDAPDetailsWrapper();
        
        try
        {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String endpointURL;
            
            String token = fetchToken();
            
            if(buttonName == 'validate'){
                endpointURL = epURL+'/'+iataNum;
            }
            else{
                endpointURL = epURL;
                User theUser = getUserDetails();
                string staffId = (String.isBlank(theUser.FederationIdentifier)) ? theUser.Qantas_Staff_ID__c : theUser.FederationIdentifier;
                myLdap.agencyCode = iataNum;
                myLdap.staffIdentifier = staffId;
                String requestJson = QAC_LDAPDetailsWrapper.convertToJsonString(myLdap);
                
                //String requestJson = '{"agencyCode":"'+ iataNum +'","staffIdentifier":"'+ staffId +'"}';
                system.debug('request json** '+requestJson); 
                req.setBody(requestJson);
            }
            
            req.setEndpoint(endpointURL);
            req.setMethod(method);      
            req.setHeader('Authorization', token);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(120000);
            HTTPResponse response = http.send(req); 
            
            system.debug('response Body#########' + response.getBody());
            myWrap.ldapDetails = QAC_LDAPDetailsWrapper.parse(response.getBody());
            
            if(response.getStatusCode() == 200){
                if(buttonName == 'validate')
                {
                    if(myWrap.ldapDetails.username == iataNum && myWrap.ldapDetails.managerAccountExists){
                        myWrap.ldapDetails.agencyStatus = 'ACTIVE';
                    }
                    else{
                        myWrap.ldapDetails.agencyStatus = 'INACTIVE';
                    }
                    
                    myWrap.ldapDetails.agencyLastUpdated = String.isNotBlank(myWrap.ldapDetails.agencyPasswordLastModifiedTimeStamp) ? getDateTimeValue(myWrap.ldapDetails.agencyPasswordLastModifiedTimeStamp) : null;
                    myWrap.ldapDetails.managerLastUpdated = String.isNotBlank(myWrap.ldapDetails.managerPasswordLastModifiedTimeStamp) ? getDateTimeValue(myWrap.ldapDetails.managerPasswordLastModifiedTimeStamp) : null;              
                    myWrap.ldapResponse = 'Pass';
                }
                else if(buttonName == 'create'){
                    myWrap.ldapDetails.sfMessage = 'Set Password Link sent to : '+myWrap.ldapDetails.maskedEmailAddress;           
                    myWrap.ldapResponse = 'Pass_SetAsMessage';
                }
                /*else{
                    //myWrap.ldapDetails.sfMessage = 'Password Reset link: '+myWrap.ldapDetails.passwordSetUpLink;          
                    myWrap.ldapResponse = 'Pass_SetAsMessage';
                }*/
            }
            else if(response.getStatusCode() == 404){
                myWrap.ldapDetails.sfMessage = 'Agency Account does not exist in LDAP System';
                myWrap.ldapResponse = 'Fail_SetAsMessage';
            }
            else if(response.getStatusCode() == 400){
                myWrap.ldapDetails.sfMessage = 'Agency Account already exist in LDAP System';
                myWrap.ldapResponse = 'Fail_SetAsMessage';
            }
            else if(response.getStatusCode() == 500){
                myWrap.ldapDetails.sfMessage = 'Internal Server issue. Please contact System Administrator.';
                myWrap.ldapResponse = 'Fail_SetAsMessage';
            }               
            else{
                myWrap.ldapDetails.sfMessage = 'Connection Failed from LDAP System. Error Code : '+ response.getStatusCode();
                myWrap.ldapResponse = 'Fail_SetAsMessage';
            }        
            
            updateToken(token);
            
            system.debug('my wrap values**'+myWrap);
            return myWrap;                 
        }
        catch(Exception ex){
            myWrap.ldapDetails.sfMessage = 'Connection Failed to LDAP System';
            myWrap.ldapResponse = 'Fail_SetAsMessage';
            system.debug('my wrap values**'+myWrap);
            return myWrap;                  
        }
    }
}