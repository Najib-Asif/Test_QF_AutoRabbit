/*********************************************************************************
Name         : QCC_InvokeMicroserviceAPI
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 18 November 2019
Usages       : This will handle all callout for Microservice
*********************************************************************************/
public class QCC_InvokeMicroserviceAPI {
    //@Purpose: This method is used to send the actual callout to get day prior form.
    //@input parameters:
    //	1. qantasAPI - The record holding the endpoint and other variables that is being used to send the callout.
    //	2. token - The token to be used as part of the callout.
    //	3. requestBody - The request body to be used as part of the callout.
    //@return type: None
    public static QantasHostDayPriorResponse invokeRetrieveDayPriorURL(Qantas_API__c qantasAPI, String token, String requestBody) {
        System.debug('QCC_InvokeMicroserviceAPI.invokeRetrieveDayPriorURL');
        QantasHostDayPriorResponse myWrapper = new QantasHostDayPriorResponse();
        
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(qantasAPI.EndPoint__c);
        request.setMethod(qantasAPI.Method__c);
        //request.setHeader('client_id', qantasAPI.ClientId__c);
        //request.setHeader('client_secret', qantasAPI.ClientSecret__c);
        //request.setHeader('grant_type', qantasAPI.GrantType__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', token);
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        System.debug('request: ' + request);
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        System.debug('response: ' + response);
        
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 || response.getStatusCode() == 202) {
            myWrapper = (QantasHostDayPriorResponse) System.JSON.deserialize(response.getBody(), QantasHostDayPriorResponse.class);
            myWrapper.hasError = false;
        } else {
            myWrapper.hasError = true;
        }
        
        System.debug('myWrapper: ' + myWrapper);

        return myWrapper;
    }
    
    public class QantasHostDayPriorResponse {
        public Boolean hasError {get;set;}
        public String url {get;set;}
    }
    
    public class QantasHostDayPriorRequest {
        public String name {get;set;}
        public String id {get;set;}
        public String dateOfDeparture {get;set;}
    }
}