/*----------------------------------------------------------------------------------------------------------------------
Author:          Priyadharshini Vellingiri
Company:         TCS
Description:    
Inputs:
Test Class:      
************************************************************************************************
History
************************************************************************************************
 27-Apr-2018           Priyadharshini Vellingiri      Initial Design       
-----------------------------------------------------------------------------------------------------------------------*/



public without sharing class QL_InvokeCAPCREAPI {

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeTokenCapAPI
    Description:        Invoke authorization Token from CAP system
    Parameter:          Custom Setting
    --------------------------------------------------------------------------------------*/ 
    public static QL_CAPCRETokenWrapper invokeTokenCapAPI( Qantas_API__c qantasAPI ){
        HTTPRequest req=new HTTPRequest();
        req.setEndpoint(qantasAPI.EndPoint__c);
        req.setHeader('client_id',qantasAPI.ClientId__c);
        req.setHeader('client_secret',qantasAPI.ClientSecret__c);
        req.setHeader('grant_type',qantasAPI.GrantType__c);
        req.setMethod(qantasAPI.Method__c); 
        req.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse response = http.send(req);
        System.debug('response.getBody(): '+response.getBody());
        QL_CAPCRETokenWrapper token;
        if(response.getStatusCode() == 200){
           token = (QL_CAPCRETokenWrapper) System.JSON.deserialize(response.getBody(), QL_CAPCRETokenWrapper.class);
        }        
        return token;        
    }
}