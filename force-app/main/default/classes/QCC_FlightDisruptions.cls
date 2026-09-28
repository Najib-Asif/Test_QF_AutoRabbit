/**********************************************************************************************
Author:        Pushkar Purushothaman
Company:       TCS
Description:   Fetch case disruption data from the CAP Disruption API 
   
************************************************************************************************
History
************************************************************************************************
24-Oct-2018      Pushkar Purushothaman               Initial Design
12-Dec-2018		 Pushkar Purushothaman				 Logic updation for disruption communication
**********************************************************************************************/

public without sharing class QCC_FlightDisruptions {
    @AuraEnabled(cacheable=true)
    public static List<QCC_DisruptionCommTblHeaders__mdt> getCommunicationTblHeaders(){
        List<QCC_DisruptionCommTblHeaders__mdt> hdrList = new List<QCC_DisruptionCommTblHeaders__mdt>();
        hdrList =  [SELECT id,MasterLabel ,Title__c,Sequence__c,Width__c FROM QCC_DisruptionCommTblHeaders__mdt ORDER BY Sequence__c ASC];
        System.debug('hdrList'+hdrList);
        return hdrList;
    }
    @AuraEnabled
    public static Object getFlightDisruptionDetails(String ffNum){
        
        DateTime currentDateTime = DateTime.now();
        Long fromTimeStamp = currentDateTime.addMonths(-12).getTime();
        Long toTimeStamp = currentDateTime.getTime();
        
        //Named credential callout CRM-9361
         if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            string dynamicURL = '/' + ffNum +'/flights/disrupted?fromTimeStamp='+fromTimeStamp+'&toTimeStamp='+toTimeStamp+'&includeQFOperatedOnly=true&returnCountOnly=false';
            String endpoint = 'callout:QCC_FlightDisruptionsAPI'+ dynamicURL;
            system.debug('Endpoint**'+endpoint);
            HTTP http = new HTTP();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('GET');
            httpRequest.setEndpoint(endpoint);
            HttpResponse httpResponse = http.send(httpRequest);     
            if(httpResponse.getStatusCode() == 200){
                Object myObj = JSON.deserializeUntyped(httpResponse.getBody());
                System.debug(httpResponse.getBody());
                return myObj;
            }else{
                System.debug('response: '+httpResponse.getBody());
            }
        }
        
    	//Callout using QantasAPI object.
        else{
            String token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken');
            if(String.isBlank(token)) return null;
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_FlightDisruptionsAPI');
            String endpoint = qantasAPI.EndPoint__c+ffNum+'/flights/disrupted?fromTimeStamp='+fromTimeStamp+'&toTimeStamp='+toTimeStamp+'&includeQFOperatedOnly=true&returnCountOnly=false';
            system.debug('Endpoint**'+endpoint);
            HTTP http = new HTTP();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(qantasAPI.Method__c);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setHeader('Authorization', token);
            httpRequest.setHeader('system','CAPCRE_CC');
            HttpResponse httpResponse = http.send(httpRequest);
            //Jira-5620 Token refresh when there is a mismatch Venkat.P
            if (httpResponse.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken', true);
                httpRequest.setHeader('Authorization', token);
                httpResponse = http.send(httpRequest);
            }
            QCC_GenericUtils.updateToken(token, 'QCC_CAPToken');
            if(httpResponse.getStatusCode() == 200){
                Object myObj = JSON.deserializeUntyped(httpResponse.getBody());
                System.debug(httpResponse.getBody());
                return myObj;
            }else{
                System.debug('response: '+httpResponse.getBody());
            }
        }
        
        return null;
    } 
    
    @AuraEnabled
    public static Object getFlightCommDetails(String pnr,String firstName,String lastName,String creationDate){
        System.debug('Flight response: ***pnr'+pnr);
        
        //Callout using Named credential CRM-9361
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            String dynamicURL = '/'+ pnr + '/remarks/communications?';
            if(firstName != '')
                dynamicURL +='firstName=' +EncodingUtil.urlEncode(firstName, 'UTF-8')+'&';
            if(lastName != '')
                dynamicURL +='lastName='+EncodingUtil.urlEncode(lastName, 'UTF-8')+'&';
            if(creationDate != '')
                dynamicURL +='creationDate='+creationDate;
            String endpoint = 'callout:QCC_FlightDisruptionsCommAPI' + dynamicURL;
            system.debug('Endpoint:' +endpoint);
            HTTP http = new HTTP();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('GET');
            httpRequest.setEndpoint(endpoint);
            HttpResponse httpResponse = http.send(httpRequest);
            if(httpResponse.getStatusCode() == 200){
                Object myObj = JSON.deserializeUntyped(httpResponse.getBody());
                System.debug('Flight response: ***'+httpResponse.getBody());
                return myObj;
            }else{
                System.debug('Flight response: ***'+httpResponse.getBody());
            } 
            }
        
        //Callout using QantasAPI object.
        else{
            String token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken');
            if(String.isBlank(token)) return null;
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_FlightDisruptionsCommAPI');  
            String endpoint = qantasAPI.EndPoint__c+pnr+'/remarks/communications?';
            if(firstName != '')
                endpoint +='firstName='+EncodingUtil.urlEncode(firstName, 'UTF-8')+'&';
            if(lastName != '')
                endpoint +='lastName='+EncodingUtil.urlEncode(lastName, 'UTF-8')+'&';
            if(creationDate != '')
                endpoint +='creationDate='+creationDate;
            System.debug('Endpoint'+endpoint);
            HTTP http = new HTTP();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(qantasAPI.Method__c);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setHeader('Authorization', token);
            httpRequest.setHeader('system','CAPCRE_CC');
            HttpResponse httpResponse = http.send(httpRequest);
            //Jira-5620 Token refresh when there is a mismatch Venkat.P
            if (httpResponse.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken', true);
                httpRequest.setHeader('Authorization', token);
                httpResponse = http.send(httpRequest);
            }
            QCC_GenericUtils.updateToken(token, 'QCC_CAPToken');
            if(httpResponse.getStatusCode() == 200){
                system.debug('Came in');
                Object myObj = JSON.deserializeUntyped(httpResponse.getBody());
                System.debug('Flight response: ***'+httpResponse.getBody());
                return myObj;
            }else{
                System.debug('Flight response: ***'+httpResponse.getBody());
            } 
            }
               
        return null;
    }    
}