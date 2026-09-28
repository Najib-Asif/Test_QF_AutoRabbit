/***********************************************************************************************************************************
Author:          Jayaraman Jayaraj
Company:         TCS
Description:     Agency TA information Update.
Test Class Name:

History: 
======================================================================================================================
Date               Name                          Description                                                 
======================================================================================================================
14-Jun-2018        Jay                         Initial Design
**********************************************************************************************************************************/
@RestResource(urlMapping='/QACAgencyTADetailsUpdate/*')
global class QAC_AgencyTADetailsUpdate {
    
    @HttpPatch
    global static void doTADetailsUpdate()
    {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        QAC_AgencyProfileResponses.ExceptionResponse mapErrorResponse;
        List<QAC_AgencyProfileResponses.FieldErrors> listFieldErrorResp = new List<QAC_AgencyProfileResponses.FieldErrors>();
        
        // Changes added by Ajay
        try{
            String iataNumber = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            QAC_AgencyTADetailsUpdateParsing receivedRequest = QAC_AgencyTADetailsUpdateParsing.parse(request.requestBody.toString());
            system.debug('request @@'+receivedRequest);
            
            Account_Relation__c existingTA;
            List<Account> existingAccount = new List<Account>();
            
            string taRelation   =   Label.QAC_AccRet_TA_Relationship;
            
            if(String.isNotBlank(iataNumber))
            {
                system.debug('iataNumber:'+iataNumber);
                String recordid = receivedRequest.id;
                //if(String.isNotBlank(recordid))
                if(String.isNotBlank(receivedRequest.id) || String.isNotEmpty(receivedRequest.id))
                {
                    for(Account_Relation__c eachTA : [SELECT Id, Name, Active__c,End_Date__c, Primary_Account__c, Related_Account__c, 
                                                      Last_Inactive_Date__c, Primary_Account__r.IATA_Number__c FROM Account_Relation__c 
                                                      WHERE Id =: recordid and Relationship__c =: taRelation])
                    {
                        existingTA = eachTA;
                    }
                    existingAccount = [select id from Account where qantas_industry_centre_id__c =: iataNumber];
                    
                    if(existingTA != null && existingAccount.size() > 0 )
                    {
                        if(existingTA.Active__c == receivedRequest.isActive)
                        {
                            system.debug('inside412:'+iataNumber);
                            // send 412 error message
                            response.statusCode = 412;
                            listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('Active__c','Active value already exists in Salesforce'));
                            mapErrorResponse = new QAC_AgencyProfileResponses.ExceptionResponse('412','Fields are Identical',listFieldErrorResp);
                            response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
                        }
                        else
                        {
                            // send 200 status code
                            existingTA.Active__c = receivedRequest.isActive;
                            existingTA.End_Date__c = (!receivedRequest.isActive) ? Date.today() : null;
                            existingTA.Last_Inactive_Date__c = (!receivedRequest.isActive) ? Date.today() : existingTA.Last_Inactive_Date__c;
                            update existingTA;
                            response.statusCode = 200;
                        }
                    }
                    else if(existingTA == null || existingAccount.size() == 0)
                    {
                        response.statusCode = 404;
                        listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('TA Record/Agency Code','TA Record/Agency Code is blank/Invalid'));
                        mapErrorResponse = new QAC_AgencyProfileResponses.ExceptionResponse('404','Bad Request',listFieldErrorResp);
                        response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
                    }                   
                }
            }
            else
            {
                response.statusCode = 400;
                listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('IATA Number','AgencyCode is blank in URI'));
                mapErrorResponse = new QAC_AgencyProfileResponses.ExceptionResponse('400','Bad Request',listFieldErrorResp);
                response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
            }
        }
        catch(Exception ex){
            system.debug('********' + ex.getMessage());
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC - QACAgencyTADetailsUpdate API', 'QAC_AgencyTADetailsUpdate',
                                    'create',(request.requestBody.toString().length() > 32768) ? request.requestBody.toString().substring(0,32767) : request.requestBody.toString(),
                                    String.valueOf(''), true, '', ex);
            response.statusCode             = 500;
            listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('', ex.getMessage() ));
            mapErrorResponse           = new QAC_AgencyProfileResponses.ExceptionResponse('500', 'Bad Request - Json format is invalid', listFieldErrorResp);
            response.responseBody       = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
        }
        // Changes ended - Ajay
    }
}