/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to create & update the Asset Details for Qantas Channel
* REST API : QantasChannelCreationAPI

  Modified Date   : 12/07/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : TS-4729
  Version         : V2.0 - Added the Condition to update the Asset Status even if the associated
                    GDS TMC record is not there.
  
  Modified Date   : 3/10/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : TS-4813
  Version         : V3.0 - Deregistration - Update PCC GDS status in Salesforce
*/
@RestResource(urlmapping='/QantasChannelCreation/*')
global with sharing class QantasChannelCreation
{
    // collection variables for handling Account,Asset & TMC
    public static map<Id,list<Asset>> existingAssetMap = new map<Id,list<Asset>>();
    public static map<String,GDS_Reference__c> existingGDSMap = new map<String,GDS_Reference__c>();
  public static map<Id,Account> existingAccountMap = new Map<Id,Account>();
  public static map<Id,list<Agency_Info__c>> existingTMCMap = new Map<Id,list<Agency_Info__c>>();
  public static map<String,Id> accIATAIdMap = new map<String,Id>();
    public static Set<String> incomingGDSNames = new Set<String>();
    public static Set<String> assetGDSNames = new Set<String>();
    public static Set<String> assetIds = new Set<String>();
    public static Set<String> theIncomingIATAs = new Set<String>();
    public static list<String> nonChannelGDS = new list<String>();

    // instance variables
    public static String responseJson = '';
    public static Boolean isException = false;
    public static String requestJson;
    public static String agencyCode;
    public static String accId;
    public static Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
  public static Id assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();                                       
  public static Id tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();                                       

  // response variables
    public static QantasChannelResponses qcResp = new QantasChannelResponses();
  public static QantasChannelResponses.ExceptionResponse myExcepResp;
    public static list<QantasChannelResponses.FieldErrors> myFieldErrorRespList = new list<QantasChannelResponses.FieldErrors>();

    @HttpPatch
    global static void doChannelUpdation()
    {
        // Responses Classes for Channel Updation
        QantasChannelResponses.QantasChannelUpdationResponse myChannelUpdResp;
        list<QantasChannelResponses.QantasChannelUpdationResponse> myChannelUpdRespList = new list<QantasChannelResponses.QantasChannelUpdationResponse>();

        list<Asset> toUpdateAssets = new list<Asset>();
        list<Agency_Info__c> toUpdateTMCs = new list<Agency_Info__c>();
        Integer i=0;
        Boolean errorFound;
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        requestJson = request.requestBody.toString();
        try{
            agencyCode = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            system.debug('agencyCode @@'+agencyCode);
            
            list<QantasChannelCreationAPI> qcAPI = QantasChannelCreationAPI.parse(requestJson);
            system.debug('request @@'+qcAPI);
            
            // check incoming api is valid
            if(qcAPI != null)
            {
                // check agencyCode is blank
                if(String.isNotBlank(agencyCode))
                {
          theIncomingIATAs.add(agencyCode);
                    fetchAccount(theIncomingIATAs);
                    if(!existingAccountMap.isEmpty())
                    {
                        // get the list of GDS names from API
                        for(QantasChannelCreationAPI eachCr : qcAPI){
                            if(eachCr.assetId != null)
                              assetIds.add(eachCr.assetId);
                            if(eachCr.gdsCode != null)
                                incomingGDSNames.add(eachCr.gdsCode);
                        }                        
                      fetchAssets(existingAccountMap,assetIds); 
                      //Changes added by Vinoth for TS-4824  by commenting below and handling it in Trigger          
                      //fetchTMC();
                      //Changes ends for TS-4824 
                        // to update Asset Status
                        if(!existingAssetMap.isEmpty())
                        {
                            for(Asset eachAsset : existingAssetMap.get(accId))
                            {
                                if(eachAsset.Status == 'Accepted')
                                {
                                    eachAsset.Status = 'Pending deregistration';
                                    assetGDSNames.add(eachAsset.GDS_Name__c);
                                    errorFound = false;
                                    toUpdateAssets.add(eachAsset);
                                }
                                else{
                                    // send error message for each Asset with 400
                                    errorFound = true;
                                    response.statusCode = 400;
                                    myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors(eachAsset.GDS_Name__c,'Invalid Status :'+eachAsset.Status));
                                    myExcepResp = new QantasChannelResponses.ExceptionResponse('400','Status is not available for De-registration',myFieldErrorRespList);
                                    qcResp.exceptionResponse = myExcepResp;
                                    //responseJson += JSON.serializePretty(myExcepResp);
                                }
                            }
                            
              //Changes added by Vinoth for TS-4824  by commenting below and handling it in Trigger  
                            // to update TMC's GDS Status
                            /*if(!existingTMCMap.isEmpty())
                            {
                                for(Agency_Info__c eachTMC : existingTMCMap.get(accId))
                                {
                                    if(assetGDSNames.contains(eachTMC.Code__c)){
                                        eachTMC.GDS_Status__c = 'Pending deregistration';
                                        toUpdateTMCs.add(eachTMC);
                                    }    
                                }
                                system.debug('tmcexis*'+existingTMCMap);
                            }*/
              //Changes ends for TS-4824
                            
                            if(!toUpdateAssets.isEmpty())
                            {
                              update toUpdateAssets;
                                for(Asset eachAst : toUpdateAssets)
                                {
                                    ++i;
                                    response.statusCode = (errorFound) ? 400 : 201;
                                    myChannelUpdResp = new QantasChannelResponses.QantasChannelUpdationResponse('201',
                                                                                                                eachAst.Id,
                                                                                                                eachAst.Status,
                                                                                                                qcAPI[i-1].gdsCode,
                                                                                                                'Channel is De-registered. '+i+' Asset(s) Updated Successfully'
                                                                                                               );
                                    myChannelUpdRespList.add(myChannelUpdResp);
                                
                                }
                                system.debug('channel cr responses*'+myChannelUpdRespList);
                                i=0;
                                qcResp.channelUpdationResponse = myChannelUpdRespList.isEmpty() ? null : myChannelUpdRespList;
                            }
                            if(!toUpdateTMCs.isEmpty())
                                update toUpdateTMCs;
                        }
                        else
                        {
                            // 404 for account NOT found
                            response.statusCode = 404;
                            myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('Asset','No Records Found :'+agencyCode));
                            myExcepResp = new QantasChannelResponses.ExceptionResponse('404','Asset does not exist for agencyCode',myFieldErrorRespList);
                            qcResp.exceptionResponse = myExcepResp;
                            //responseJson += JSON.serializePretty(myExcepResp);    
                        }
                    }
                    else{
                        // 404 for account NOT found
                        response.statusCode = 404;
                        myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('AccountId','No Records Found :'+agencyCode));
                        myExcepResp = new QantasChannelResponses.ExceptionResponse('404','Agency does not exist in Salesforce',myFieldErrorRespList);
                        qcResp.exceptionResponse = myExcepResp;
                        //responseJson += JSON.serializePretty(myExcepResp);
                    }
                }
                else{
                    // Agency Code not found
                    response.statusCode = 404;
                    myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('AgencyCode','Agency not found'));
                    myExcepResp = new QantasChannelResponses.ExceptionResponse('404','Invalid IATA Number',myFieldErrorRespList);
                    qcResp.exceptionResponse = myExcepResp;
                    //responseJson += JSON.serializePretty(myExcepResp);
                }
            }
            responseJson += JSON.serializePretty(qcResp,true);
            response.responseBody = Blob.valueOf(responseJson);
        }
        Catch(Exception ex)
        {
            system.debug(' Exception found @@ ' + ex.getMessage());
            
            isException = true;
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Channel - Updation', 'QantasChannelUpdation',
                                    'doChannelUpdate', (responseJson.length() > 32768) ? responseJson.substring(0,32767) : responseJson,
                                    String.valueOf(''), true,'', ex);
            
            String sfErrMessage = ex.getMessage();
            
            if(ex.getTypeName().contains('JSON')){
                response.statusCode = 400;
                myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('Exception',sfErrMessage));
                myExcepResp = new QantasChannelResponses.ExceptionResponse('400','Issue with JSON Format. Please check your Payload',myFieldErrorRespList);
            }
            else{
                response.statusCode = sfErrMessage.contains('DUPLICATE') ? 409 : 500;
                sfErrMessage = sfErrMessage.substringAfter(':');
                myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('Exception',sfErrMessage));
                myExcepResp = new QantasChannelResponses.ExceptionResponse(String.valueOf(response.statusCode),'Found errors.Please contact Salesforce.',myFieldErrorRespList);
            }
            qcResp.exceptionResponse = myExcepResp;
            //responseJson += JSON.serializePretty(myExcepResp);
            responseJson += JSON.serializePretty(qcResp,true);
            response.responseBody = Blob.valueOf(responseJson);
        }
    }
    
    @HttpPost
    global static void doChannelCreation()
    {
        // local variables
        Boolean conflictFound;
        String duplicateGDS;
        Integer i=0;
        
        // Responses Classes for Channel Retrieval
        QantasChannelResponses.QantasChannelCreationResponse myChannelCrResp;
        list<QantasChannelResponses.QantasChannelCreationResponse> myChannelCrRespList = new list<QantasChannelResponses.QantasChannelCreationResponse>();
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        requestJson = request.requestBody.toString();
        try
        {
            agencyCode = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            system.debug('agencyCode @@'+agencyCode);
            
            list<QantasChannelCreationAPI> qcAPI = QantasChannelCreationAPI.parse(requestJson);
            system.debug('request @@'+qcAPI);
            
            // check incoming api is valid
            if(qcAPI != null)
            {
                // check agencyCode is blank
                if(String.isNotBlank(agencyCode))
                {
          // get the list of GDS names from API
          for(QantasChannelCreationAPI eachCr : qcAPI){
            incomingGDSNames.add(eachCr.gdsCode);
            if(eachCr.registeredBy != null) 
                            theIncomingIATAs.add(eachCr.registeredBy);
          }
          theIncomingIATAs.add(agencyCode);
                    fetchAccount(theIncomingIATAs);
                    
                    // check if account exists
                    if(!existingAccountMap.isEmpty())
                    {
                        /*
                         * Commenting this out from API Class and handling it in Asset trigger
                        if(!existingAccountMap.get(accId).Channel_Member__c){
                            Account myAcc = new Account(Id = accId,Channel_Member__c = true,Channel_Subscription_Date__c = Date.today());
                            update myAcc;
                        } 
                        */
                        
                        // check for conflict with existing Assets & GDS Reference table for Channel GDS's
                        fetchAssets(existingAccountMap,assetIds);
                        
                        if(existingAssetMap.isEmpty()){
                            conflictFound = false;
                        }
                        else{
                            for(Asset eachAst : existingAssetMap.get(accId)){
                                
                                if(incomingGDSNames.contains(eachAst.GDS_Name__c)){
                                    duplicateGDS = eachAst.GDS_Name__c;
                                    conflictFound = true;
                                    break;
                                }
                                else{
                                    conflictFound = false;
                                }
                            }
                        }
                        
                        if(conflictFound){
                            // Conflict 409 error
                            response.statusCode = 409;
                            myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('gdsCode','Duplicates found on GDS: '+duplicateGDS));
                            myExcepResp = new QantasChannelResponses.ExceptionResponse('409','Resource conflict has occured.',myFieldErrorRespList);
                            qcResp.exceptionResponse = myExcepResp;
                            //responseJson += JSON.serializePretty(myExcepResp);
                        }
                        else{
                            // insert asset
                            
                            system.debug('incoming gds**'+incomingGDSNames);
                            list<Asset> createdAssets = doCreateAssets(qcAPI);
                            
                            if(!nonChannelGDS.isEmpty()){
                                for(String eachGDS : nonChannelGDS){
                                    response.statusCode = 400;
                                    myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('gdsCode','Invalid GDS :'+eachGDS));
                                    myExcepResp = new QantasChannelResponses.ExceptionResponse('400','Channel is not available for GDS',myFieldErrorRespList);
                                    qcResp.exceptionResponse = myExcepResp;
                                    //responseJson += JSON.serializePretty(myExcepResp);
                                }
                            }
                            else{
                                insert createdAssets; 
                                for(Asset eachAst : createdAssets)
                                {
                                    ++i;
                                    if(eachAst.Id != null){
                                        
                                        response.statusCode = 201;
                                        myChannelCrResp = new QantasChannelResponses.QantasChannelCreationResponse('201',
                                                                                                                   eachAst.Id,
                                                                                                                   eachAst.AccountId,
                                                                                                                   agencyCode,
                                                                                                                   qcAPI[i-1].gdsCode,
                                                                                                                   //existingGDSMap.get(qcAPI[i-1].gdsCode).PCC_Min_Length__c,
                                                                                                                   //existingGDSMap.get(qcAPI[i-1].gdsCode).PCC_Max_Length__c,
                                                                                                                   'Channel is registered. '+i+' Asset(s) Created Successfully'
                                                                                                                  );
                                        myChannelCrRespList.add(myChannelCrResp);
                                    }
                                }
                                system.debug('channel cr responses*'+myChannelCrRespList);
                                i=0;
                                qcResp.channelCreationResponse = myChannelCrRespList.isEmpty() ? null : myChannelCrRespList;
                            }
                        }
                    }
                    else{
                        // 404 for account NOT found
                        response.statusCode = 404;
                        myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('AccountId','No Records Found :'+agencyCode));
                        myExcepResp = new QantasChannelResponses.ExceptionResponse('404','Agency does not exist in Salesforce',myFieldErrorRespList);
                        qcResp.exceptionResponse = myExcepResp;
                        //responseJson += JSON.serializePretty(myExcepResp);
                    }
                }
                else
                {
                    // Bad request for Agency Code
                    response.statusCode = 400;
                    myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('AgencyCode','Bad Request'));
                    myExcepResp = new QantasChannelResponses.ExceptionResponse('400','Invalid IATA Number',myFieldErrorRespList);
                    qcResp.exceptionResponse = myExcepResp;
                    //responseJson += JSON.serializePretty(myExcepResp);
                }
            }
            responseJson += JSON.serializePretty(qcResp,true);
            response.responseBody = Blob.valueOf(responseJson);
        }
        catch(Exception ex)
        {
            system.debug(' Exception found @@ ' + ex.getMessage());
            
            isException = true;
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Channel - Creation', 'QantasChannelCreation',
                                    'doChannelCreate', (responseJson.length() > 32768) ? responseJson.substring(0,32767) : responseJson,
                                    String.valueOf(''), true,'', ex);
            
            String sfErrMessage = ex.getMessage();
            
            if(ex.getTypeName().contains('JSON')){
                response.statusCode = 400;
                myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('Exception',sfErrMessage));
                myExcepResp = new QantasChannelResponses.ExceptionResponse('400','Issue with JSON Format. Please check your Payload',myFieldErrorRespList);
            }
            else{
                response.statusCode = sfErrMessage.contains('DUPLICATE') ? 409 : 500;
                sfErrMessage = sfErrMessage.substringAfter(':');
                myFieldErrorRespList.add(new QantasChannelResponses.FieldErrors('Exception',sfErrMessage));
                myExcepResp = new QantasChannelResponses.ExceptionResponse(String.valueOf(response.statusCode),'Found errors.Please contact Salesforce.',myFieldErrorRespList);
            }
            qcResp.exceptionResponse = myExcepResp;
            //responseJson += JSON.serializePretty(myExcepResp);
            responseJson += JSON.serializePretty(qcResp,true);
            response.responseBody = Blob.valueOf(responseJson);
        }
    }
    
    public static void fetchAssets(map<Id,Account> existingAccountMap, Set<String> assetIds)
    {
        String Query;
        Id accountId = accId;
        Query = 'SELECT Id,AccountId,Status,GDS__c,GDS_Name__c,Customer_ID__c,Channel_Effective_Date__c FROM Asset';
        Query += ' WHERE AccountId = :accountId AND RecordTypeId = :assetRTId';
        if(!assetIds.isEmpty())
          Query += ' AND Id IN :assetIds';
    
        for(Asset eachAsset : Database.query(Query))
        {
            if(eachAsset != null)
            {
                if(existingAssetMap.containsKey(eachAsset.AccountId)){
                    existingAssetMap.get(eachAsset.AccountId).add(eachAsset);
                }
                else{
                    existingAssetMap.put(eachAsset.AccountId, new list<Asset>{eachAsset});
                }
            }
        }
        system.debug('Assets**'+existingAssetMap);
    }
    
  //Changes added by Vinoth for TS-4824  by commenting below and handling it in Trigger  
    /*public static void fetchTMC()
    {
        for(Agency_Info__c eachTMC : [SELECT Id,Account__c,PCC__c,Code__c,
                                      GDS_Status__c,QDP_Status__c,Surcharge_Exemption_Status__c,ATPCO_Status__c
                                      FROM Agency_Info__c
                                      WHERE Account__c =: accId AND RecordTypeId =: tmcRTId AND Active__c = TRUE AND Code__c IN: incomingGDSNames])
        {
            if(eachTMC != null)
            {
                if(existingTMCMap.containsKey(eachTMC.Account__c)){
                    existingTMCMap.get(eachTMC.Account__c).add(eachTMC);
                }
                else{
                    existingTMCMap.put(eachTMC.Account__c, new list<Agency_Info__c>{eachTMC});
                }
            }    
        }
    }*/
  //Changes added by Vinoth for TS-4824  by commenting below and handling it in Trigger  
    
    public static list<Asset> doCreateAssets(list<QantasChannelCreationAPI> theAPI)
    {
        
        list<Asset> theAssetList = new list<Asset>();
        fetchGDSRecord(incomingGDSNames);
        
        for(QantasChannelCreationAPI eachCr : theAPI)
        {
            if(!existingGDSMap.isEmpty() && existingGDSMap.containsKey(eachCr.gdsCode))
            {
                Asset myAsset = new Asset();
                myAsset.Name = agencyCode +'_'+ eachCr.gdsCode;
                myAsset.AccountId = accId;
                myAsset.RecordTypeId = assetRTId;
                myAsset.GDS__c = existingGDSMap.get(eachCr.gdsCode).Id;
                myAsset.Active__c = TRUE;
                myAsset.Customer_ID__c = eachCr.customerId;
                myAsset.Status = 'New';
        myAsset.Registration_Type__c = eachCr.registrationType;
        myAsset.AssetProvidedById = accIATAIdMap.get(eachCr.registeredBy);
                myAsset.QDP_Portal_Agreement__c = eachCr.qdpTermsAndConditions; // CRM- 6829
                myAsset.QDP_Portal_Agreement_Date__c = System.Today(); // CRM- 6829
                theAssetList.add(myAsset);
            }
            else
            {
                nonChannelGDS.add(eachCr.gdsCode);
                system.debug('non channel GDS**'+nonChannelGDS);
            }
        }
        return theAssetList;
    }
    
    public static void fetchGDSRecord(Set<String> gdsNames){
        for(GDS_Reference__c eachGDS : [Select Id,Name,Channel_Enabled__c,QAC_Enabled__c,PCC_Max_Length__c,PCC_Min_Length__c,PCC_OID__c
                                        from GDS_Reference__c where Name in: gdsNames])
        {
            if(eachGDS != null){
                system.debug('each GDS**'+eachGDS);
                existingGDSMap.put(eachGDS.Name,eachGDS);
            }    
        }
        system.debug('GDS MAP**'+existingGDSMap);
    }
    
    public static void fetchAccount(Set<String> incomingIATA){
        for(Account eachAccount : [Select Id, Qantas_Industry_Centre_ID__c,Channel_Member__c,Channel_Subscription_Date__c from Account 
                                   where Qantas_Industry_Centre_ID__c IN: incomingIATA AND RecordTypeId =: accRTId])
        {
            if(eachAccount != null){
                // accountexists
                existingAccountMap.put(eachAccount.Id,eachAccount);
        accIATAIdMap.put(eachAccount.Qantas_Industry_Centre_ID__c,eachAccount.Id);
            }
        }
    accId = accIATAIdMap.get(agencyCode);
        system.debug('existingAccount:'+existingAccountMap);
    }
}