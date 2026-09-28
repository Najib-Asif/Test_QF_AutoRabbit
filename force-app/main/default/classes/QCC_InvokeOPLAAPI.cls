/*----------------------------------------------------------------------------------------------------------------------
Author:        Cuong Ly
Company:       Capgemini
Description:   Webservice Class to Invoke OPLA System
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
19-Jun-2018      Cuong Ly               Build invokeLoungePassPostAPI

-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class QCC_InvokeOPLAAPI {
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoungePassPostAPI
    Description:        Fetch Booking Summary Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_OPLALoungePassWrapper.Response invokeLoungePassPostAPI(QCC_OPLALoungePassWrapper.Request oplaReq) {
        QCC_OPLALoungePassWrapper.Response oplaResp = new QCC_OPLALoungePassWrapper.Response();
        String token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_OPLAToken');
        if(String.isBlank(token)) return null;
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_OPLAAPI');
        String body = JSON.serialize(oplaReq, true);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '';
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setBody(body);
        req.setTimeout(120000);
        System.debug('Request :' +  req);
        HTTPResponse response = http.send(req);
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());
        QCC_GenericUtils.updateToken(token, 'QCC_OPLAToken');

        if(response.getStatusCode() == 202 || response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            oplaResp = (QCC_OPLALoungePassWrapper.Response)System.JSON.deserialize(response.getBody(), QCC_OPLALoungePassWrapper.Response.class);
            oplaResp.isSuccess = true;     
        }else if(response.getStatusCode() == 500){
            oplaResp.isSuccess = false;
            oplaResp.errorMessage = 'Call Timeout';
        }else{
            oplaResp = (QCC_OPLALoungePassWrapper.Response)System.JSON.deserialize(response.getBody(), QCC_OPLALoungePassWrapper.Response.class);
            oplaResp.isSuccess = false; 
        }
        return oplaResp; 
    }
}