@RestResource(urlMapping='/customapi/*')
global with sharing class InboundRequestRouter {
    @HttpPost
    global static void handlePost(){
        InboundRequestRouter.processRequest(RestContext.request, Restcontext.response);
    }

    @HttpGet
    global static void handleGet(){
        InboundRequestRouter.processRequest(RestContext.request, Restcontext.response);
    }

    @HttpPut
    global static void handlePut(){
        InboundRequestRouter.processRequest(RestContext.request, Restcontext.response);
    }

    @HttpPatch
    global static void handlePatch(){
        InboundRequestRouter.processRequest(RestContext.request, Restcontext.response);
    }

    @HttpDelete
    global static void handleDelete(){
        InboundRequestRouter.processRequest(RestContext.request, Restcontext.response);
    }

   global static void processRequest(RestRequest req, RestResponse res) {
    String errorStr;
    Exception exLog;
    Integration_Mapping__mdt usedConfig;
    system.debug(req.requestURI);
    try {
        String relativePath = req.requestURI.substringAfter('/customapi/');

        List<String> uriParts = relativePath.split('/');
        if (String.isBlank(relativePath) ||  uriParts.size() < 3) { throw new IllegalArgumentException('Required parameters missing in URL'); }
        String category = uriParts[0], apiVersion = uriParts[1], messageType = uriParts[2];
        res.statusCode = 200;

        //SOQL query metadata to get the respective entry.
        usedConfig = [select id, Handler_Class__c, Handler_Method__c, Log_Request__c from Integration_Mapping__mdt where Category__c = :category and 
                                                        Api_Version__c = :apiVersion and Http_Method__c = :req.httpMethod and 
                                                        Message_Type__c = :messageType and Active__c = true WITH SYSTEM_MODE limit 1];
        
        //Make the callable call.
        Callable extension = (Callable) Type.forName(usedConfig.Handler_Class__c).newInstance();
        extension.call(usedConfig.Handler_Method__c, new Map<String, Object> { 'restRequest' => req, 'restResponse' => res });
    } catch (QueryException e) {
        exLog = e;
        res.statusCode = 500;
        errorStr = 'Invalid Request - No subscriber present for the requested URL';
        res.responseBody = Blob.valueOf(errorStr);
    } catch (Exception e) {
        exLog = e;
        res.statusCode = 500;
        errorStr = 'Error - ' + e.getMessage();
        res.responseBody = Blob.valueOf(errorStr);
    } finally {

        //Setup Logs here
        if ((res.statusCode != 200 && res.statusCode != 201) || usedConfig?.Log_Request__c) {
            CreateLogs.insertLogRec('Log Integration Logs Rec Type', req.requestURI?.left(100), 'InboundRequestRouter',
                                        'processRequest', req.requestBody.toString()?.left(32767), 
                                        res.responseBody?.toString()?.left(32767), true,'', exLog);
        }
    }
   }
}