/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to fetch the Asset Details for Qantas Channel
* REST API : No Rest API Needed

Modified Date   : 30/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4824
Version         : Include Registration Type
*/
@RestResource(urlmapping='/QantasChannelRetrieval/*')
global with sharing class QantasChannelRetrieval
{
    public static QantasChannelResponses qcResp = new QantasChannelResponses();
    
    @HttpGet
    global static void doChannelRetrieve()
    {
        // Responses Classes for Channel Retrieval
        QantasChannelResponses.QantasChannelRetrievalResponse myChannelRetResp;
        QantasChannelResponses.ExceptionResponse myExcepResp;
        list<QantasChannelResponses.FieldErrors> myFieldErrorRespList = new list<QantasChannelResponses.FieldErrors>();
        
        // local variables
        Boolean isException = false;
        String responseJson = '';
        String accId;
        
        // collection variables for handling incoming and existing Case Numbers
        map<Id,Account> existingAccountMap = new Map<Id,Account>();
        map<Id,list<Asset>> existingAssetsMap = new map<Id,list<Asset>>();
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        try
        {
            String agencyCode = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            system.debug('agencyCode @@'+agencyCode);
            
            //Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
            Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
            
            if(String.isNotBlank(agencyCode))
            {
                for(Account eachAccount : [Select Id, Qantas_Industry_Centre_ID__c,Channel_Member__c,Channel_Subscription_Date__c from Account 
                                           where Qantas_Industry_Centre_ID__c =: agencyCode AND RecordTypeId =: accRTId])
                {
                    if(eachAccount != null){
                        existingAccountMap.put(eachAccount.Id,eachAccount);
                        accId = eachAccount.Id;
                    }
                }
                system.debug('existingAccount:'+existingAccountMap);
                
                if(!existingAccountMap.isEmpty())
                {
                    //String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Channel').getRecordTypeId();
                    String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
                    // changes added by Vinoth - Include Registration_Type__c
                    DateTime effectiveDate = DateTime.newInstanceGmt(2025, 05, 14, 14, 00, 00); //15 May 2025 00:00:00 in Sydney Timezone = 14 May 2025 14:00:00 in GMT
                    for(Asset eachAsset : [SELECT Id,AccountId,Status,GDS__c,GDS__r.Name,Customer_ID__c,Channel_Effective_Date__c, Registration_Type__c 
                                                FROM Asset WHERE AccountId IN: existingAccountMap.keySet() AND RecordTypeId =: assetRTId and CreatedDate < :effectiveDate])
                    {
                        if(eachAsset != null){
                            if(existingAssetsMap.containsKey(eachAsset.AccountId)){
                                existingAssetsMap.get(eachAsset.AccountId).add(eachAsset);
                            }
                            else{
                                existingAssetsMap.put(eachAsset.AccountId, new list<Asset>{eachAsset});
                            }
                        }
                    }
                    
                    system.debug('Assets**'+existingAssetsMap);
                    
                    // to check if Asset is available for agency code    
                    if(existingAssetsMap.isEmpty()){
                        response.statusCode = 404;
                        myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('GDS','No Asset Records Found'));
                        myExcepResp = new QantasChannelResponses.ExceptionResponse('404','Assets does not exist in Salesforce',myFieldErrorRespList);
                        qcResp.exceptionResponse = myExcepResp;
                        //responseJson += JSON.serializePretty(myExcepResp);
                    }
                    else{
                        response.statusCode = 200;
                        
                        myChannelRetResp = new QantasChannelResponses.QantasChannelRetrievalResponse(
                            existingAccountMap.get(accId).Channel_Member__c,
                            existingAssetsMap.get(accId)
                        );
                        qcResp.channelRetrievalResponse = myChannelRetResp;
                    }
                }
                else 
                {
                    // account does not exist for the provided IATA in SF
                    response.statusCode = 404;
                    myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('AccountId','No Records Found :'+agencyCode));
                    myExcepResp = new QantasChannelResponses.ExceptionResponse('404','Agency does not exist in Salesforce',myFieldErrorRespList);
                    qcResp.exceptionResponse = myExcepResp;
                    //responseJson += JSON.serializePretty(myExcepResp);
                }
            }
            else
            {
                response.statusCode = 400;
                myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('AgencyCode','Bad Request'));
                myExcepResp = new QantasChannelResponses.ExceptionResponse('400','Invalid IATA Number',myFieldErrorRespList);
                qcResp.exceptionResponse = myExcepResp;
                //responseJson += JSON.serializePretty(myExcepResp);
            }
            responseJson += JSON.serializePretty(qcResp,true);
            response.responseBody = Blob.valueOf(responseJson);
        }
        catch(Exception ex)
        {
            system.debug(' @@ ' + ex.getMessage());
            
            isException = true;
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Channel - Retrieval', 'QantasChannelRetrieval',
                                    'doChannelRetrieve', (responseJson.length() > 32768) ? responseJson.substring(0,32767) : responseJson,
                                    String.valueOf(''), true,'', ex);
            
            String sfErrMessage = ex.getMessage();
            
            response.statusCode = 500;
            myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('Exception',sfErrMessage));
            myExcepResp = new QantasChannelResponses.ExceptionResponse('500','Found errors.Please contact Salesforce.',myFieldErrorRespList);

            qcResp.exceptionResponse = myExcepResp;
            responseJson += JSON.serializePretty(qcResp,true);
            response.responseBody = Blob.valueOf(responseJson);
        }
    }
}