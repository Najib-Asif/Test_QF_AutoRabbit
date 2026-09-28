/***********************************************************************************************************************************
Description: Apex class for GET,POST,PATCH on the TMC Information. 
Purpose : To send/receive API responses for all TMC Operations
Created By : Sobhan
Modified : Ajay | Included additional response for Update API

Modified Date   : 29/07/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-3851
Version         : V2.0 - Added Active on the gdsValues

Modified Date   : 30/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4815
Version         : V3.0 - PCC status to be displayed in QAC

Modified Date   : 10/01/2020 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-4142
Version         : V4.0 - Add 'Service' GDS Status Value on TMC Integration to show in the Portal
***********************************************************************************************************************************/
@RestResource(urlmapping='/QACTMCOperations/*')
global class QAC_TMCOperations 
{
    public static string responseJson='';
    public static map<String,String> channelStatus = new map<String, String>();
    public static map<String,Date> assetDate = new map<String,Date>();
    // Changes Start for CRM-4142 - Add Service on the below line
    public static String[] gdsValues = new String[]{'New','Validating','Rejected','Pending deregistration','Deregistered','Inactive','Active','Service'};
    // Changes end for CRM-4142   
        @HttpGet
        global static void doTMCRetrieval()
      {
        /*
    * Variable Declarations
    */
        RestRequest request               = RestContext.request;
        RestResponse response               = RestContext.response;
        list<Agency_Info__c> listTmcInfo         = new list<Agency_Info__c>();
        
        QAC_TMCResponse tmcResp = new QAC_TMCResponse();
        list<QAC_TMCResponse.TmcResponse> tmcResponsesList = new list<QAC_TMCResponse.TmcResponse>();
        List<QAC_TMCResponse.FieldErrors> listFieldErrorResp = new List<QAC_TMCResponse.FieldErrors>();
        QAC_TMCResponse.ExceptionResponse expectionResponse; 
        QAC_TMCResponse.FieldErrors fielderror;
        String accountId;
        String qacChannelStatus='';
        list<QAC_TMCResponse.FieldErrors> fieldErrors = new list<QAC_TMCResponse.FieldErrors>();
        
        try{
            /*
      * Retrienving URL parameter for Identifying AccountId
      */
            accountId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            
            /*
      * Retrienving TMC Data based on Account Id
      */
            if(accountId != null){
                
                listTmcInfo = [SELECT Id, Name, RecordType.Name, Account__c, Active__c,Code__c, PCC__c, LastModifiedDate,           //CRM-9841: Added LastModifiedDate to Query
                               GDS_Status__c, QDP_Status__c, ATPCO_Status__c, Surcharge_Exemption_Status__c,
                               GDS_Effective_Date__c,Channel_Effective_Date__c,Last_Inactive_Date__c, Account__r.Qantas_Industry_Centre_ID__c
                               FROM Agency_Info__c
                               WHERE Account__r.Qantas_Industry_Centre_ID__c =: accountId
                               AND RecordTypeId =: Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId()];  
            }
            List<Asset> assetList = [select id,GDS__r.Name,Accountid,Channel_Effective_Date__c from Asset where Account.Qantas_Industry_Centre_ID__c =: accountId ];
            
            fetchChannelStatus(assetList,listTmcInfo);
            
            /*
      * Preparing Appropriate Response, In case TMC Found
      */
            if(listTmcInfo.size() > 0){
                for(Agency_Info__c eachTmc : listTmcInfo){
                    tmcResponsesList.add(new QAC_TMCResponse.TmcResponse(eachTmc,channelStatus.get(eachTmc.Id)));
                }
                tmcResp.tmcResponses = tmcResponsesList;
                response.statusCode     = 200;
                response.responseBody     = Blob.valueOf(JSON.serializePretty(tmcResponsesList, true));    
            }
            
            /*
      * Preparing Appropriate Response If IATA not found
      */
            else if(accountId == '' || accountId == null){
                fieldErrors.add(new QAC_TMCResponse.FieldErrors('Agency Code', 'Missing'));
                expectionResponse      = new QAC_TMCResponse.ExceptionResponse('400', 'Agency Code Not Provided in Header', fieldErrors); 
                response.statusCode     = 400;
                response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));
            }
            
            /*
      * Preparing Appropriate Response, In case Agency code not exist
      */
            else{
                fieldErrors.add(new QAC_TMCResponse.FieldErrors('Agency Code', 'Not Existing'));
                expectionResponse      = new QAC_TMCResponse.ExceptionResponse('404', 'No TMC record Exists', fieldErrors); 
                response.statusCode     = 404;
                response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));
            }    
        }
        
        /*
    * Checking Exceptions
    */
        catch(Exception ex)
        {
            
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Tradesite - QAC_TMCRetrievalByIATA', 'QAC_TMCOperations',
                                    'doTMCRetrieval', (responseJson.length() > 32768) ? responseJson.substring(0,32767) : responseJson, String.valueOf(''), true,'', ex);
            
            response.statusCode= 500;
            listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('', ex.getMessage() ));
            expectionResponse           = new QAC_TMCResponse.ExceptionResponse('500', 'Salesforce Internal Error', '', ex.getMessage());
            response.responseBody       = Blob.valueOf(JSON.serializePretty(expectionResponse));
        }
    } 
    
    @Httppatch
    global static void doTMCupdate()
    {
        //Variable Declaration
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        QAC_TMCResponse.ExceptionResponse errorresponse;
        QAC_TMCResponse.ExceptionResponse mapErrorResponse;
        QAC_TMCResponse.success success;
        List<QAC_TMCResponse.FieldErrors> listFieldErrorResp = new List<QAC_TMCResponse.FieldErrors>();
        //Need to derive this based on few values
        string qacChannelStatus;
        
        try{
            
            //Retrieving URL Parameter for identify Account
            List<Agency_Info__c> tmc = new List<Agency_Info__c>();
            Map<Id,Agency_Info__c> mapTmcToUpdate = new Map<Id,Agency_Info__c>();
            
            String agencycode = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            
            QAC_TMCInformationParsing parsedData = QAC_TMCInformationParsing.parser(request.requestBody.toString());
            
            if(!String.isBlank(agencycode) && agencycode.length() == 7){
                String recordid = parsedData.id;
                if(!String.isBlank(parsedData.id) && recordid.length() == 18)
                {
                    
                    tmc = [SELECT Id, Name,GDS_Status__c,RecordTypeId, Code__c, PCC__c, Account__c, Active__c, Last_Inactive_Date__c,Account__r.IATA_Number__c 
                                FROM Agency_Info__c WHERE Id =: parsedData.id];    
                    
                    if(tmc!=null && tmc.size()>0)
                    {
                        if((tmc[0].Active__c!=parsedData.isActive) /*&& (String.isBlank(tmc[0].GDS_Status__c) || tmc[0].GDS_Status__c=='New') CRM-9733 */)
                        {
                            Agency_Info__c tmcInfo = new Agency_Info__c();
                            tmcInfo.Id=tmc[0].id;
                            tmcInfo.Active__c=parsedData.isActive;
                            if(!parsedData.isActive)
                            tmcInfo.Last_Inactive_Date__c=System.today();
                            mapTmcToUpdate.put(tmcInfo.Id,tmcInfo);
                        }   
                    }   
                    
                    if(mapTmcToUpdate.Size()>0)
                    {
                        system.debug(mapTmcToUpdate);
                        // Changes added by Ajay
                        Update mapTmcToUpdate.values();
                        response.statusCode     = 200;
            
                        List<Asset> assetInfo = [Select Id,GDS__r.Name,Accountid,Channel_Effective_Date__c 
                            from Asset where accountId =: tmc[0].Account__c and GDS__r.Name=: tmc[0].Code__c];
            
                        fetchTMC(mapTmcToUpdate.keySet());

                        fetchChannelStatus(assetInfo,fetchTMC(mapTmcToUpdate.keySet()));
                        Id myTMCId = fetchTMC(mapTmcToUpdate.keySet())[0].Id;
                        qacChannelStatus = channelStatus.get(myTMCId);

                        success = new QAC_TMCResponse.success('200',fetchTMC(mapTmcToUpdate.keySet())[0],qacChannelStatus);
                        response.responseBody = Blob.valueOf(JSON.serializePretty(success, true));
                        // Changes ended
                        
                    }/* CRM-9733 Change starts
                    else if(tmc.size()>0 && !parsedData.isActive &&(tmc[0].GDS_Status__c!='New' && String.isNotBlank(tmc[0].GDS_Status__c)))
                    {
                        response.statusCode     = 400;
                        listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('GDS_Status__c',' Cannot Inactivate PCC If GDS_Status__c is other than New or Blank' ));
                        mapErrorResponse           = new QAC_TMCResponse.ExceptionResponse('400', 'Bad Request', listFieldErrorResp);
                        response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
                    } CRM-9733 Change Ends*/ 
                    else if(tmc.size()>0 && (tmc[0].Active__c)==(parsedData.isActive))
                    {
                        response.statusCode     = 409;
                        listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('isActive',' Conflict' ));
                        mapErrorResponse           = new QAC_TMCResponse.ExceptionResponse('409', 'TMC Update Conflicted', listFieldErrorResp);
                        response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
                    }
                    else{
                        response.statusCode     = 404;
                        listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('Id',' Invalid TMC Record Id in Json Request' ));
                        mapErrorResponse           = new QAC_TMCResponse.ExceptionResponse('404', 'No TMC record Exist', 'Id',' Invalid TMC Record Id in Json Request');
                        response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
                    }
                    // }
                }   
                else if (String.isBlank(parsedData.Id) ){
                    //errorresponse           = new QAC_Responses.ExceptionResponse('400', 'Bad Request','','');
                    response.statusCode     = 400;
                    listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('Id','TMC Record Id is Blank in Json Request' ));
                    mapErrorResponse           = new QAC_TMCResponse.ExceptionResponse('400', 'Bad Request', 'Id','TMC Record Id is Blank in Json Request');
                    response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
                }
                else{
                    //errorresponse           = new QAC_Responses.ExceptionResponse('404', 'No TMC record Exist','','');
                    response.statusCode     = 404;
                    listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('Id',' Invalid TMC Record Id in Json Request' ));
                    mapErrorResponse           = new QAC_TMCResponse.ExceptionResponse('404', 'No TMC record Exist', 'Id',' Invalid TMC Record Id in Json Request');
                    response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
                }
            }
            else if (String.isBlank(agencycode) ){
                //errorresponse           = new QAC_Responses.ExceptionResponse('400', 'Bad Request','','');
                response.statusCode     = 400;
                listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('AgencyCode',' AgencyCode is blank in URI' ));
                mapErrorResponse           = new QAC_TMCResponse.ExceptionResponse('400', 'Bad Request', 'AgencyCode',' AgencyCode is blank in URI');
                response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
            }
            else{
                //errorresponse           = new QAC_Responses.ExceptionResponse('404', 'No Agnecy Exist','','');
                response.statusCode     = 404;
                listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('AgencyCode',' Invalid AgencyCode in URI' ));
                mapErrorResponse           = new QAC_TMCResponse.ExceptionResponse('404', 'No Agnecy Exist', 'AgencyCode',' Invalid AgencyCode in URI' );
                response.responseBody   = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
            }
        }
        catch(Exception ex){
            system.debug('********' + ex.getMessage());
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC - QACAgencyTMCDetailsUpdate API', 'QAC_TMCOperations',
                                    'Update',(request.requestBody.toString().length() > 32768) ? request.requestBody.toString().substring(0,32767) : request.requestBody.toString(),
                                    String.valueOf(''), true, '', ex);
            
            //errorresponse         = new QAC_Responses.ExceptionResponse('500', 'Salesforce Internal Issue', ex.getMessage(), '');
            response.statusCode             = 500;
            listFieldErrorResp.add(new QAC_TMCResponse.FieldErrors('', ex.getMessage() ));
            mapErrorResponse           = new QAC_TMCResponse.ExceptionResponse('500', 'Salesforce Internal Issue', '', ex.getMessage());
            response.responseBody       = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
        }
    }
    
    @HttpPost
    global static void doTMCInsertion()
    {
        /*
    * Variable Declarations
    */
        RestRequest request                 = RestContext.request;
        RestResponse response         = RestContext.response;
        QAC_TMCResponse.ExceptionResponse errorRes_NoTMCFound;
        String gdsRecordTypeId        = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId();
        QAC_TMCResponse.successResponse successResponse;
        QAC_TMCResponse.success success;
        QAC_TMCResponse qacAgResp = new QAC_TMCResponse();
        QAC_TMCResponse.ExceptionResponse expectionResponse; 
        list<QAC_TMCResponse.FieldErrors> fieldErrors = new list<QAC_TMCResponse.FieldErrors>();
        string qacChannelStatus;
        try{
            /*
      * Retrieving URL parameter for Identifying AccountId
      */
            String accountId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            
            List<Agency_Info__c> lstTMC    = new List<Agency_Info__c>();
            Map<String, Id> iataCodeToAccountId = new Map<String, Id>();
            iataCodeToAccountId.put(accountId, null);
            iataCodeToAccountId = retrunAgencyAccounts(iataCodeToAccountId.keySet());
            
            if(accountId !=null && iataCodeToAccountId.get(accountId) != NULL)
            {
                
                QAC_TMCInformationParsing qac_tmc = QAC_TMCInformationParsing.parser(request.requestBody.toString()) ;
                system.debug('@@ show data @@ ' + qac_tmc);
                
                Agency_Info__c ai      = new Agency_Info__c();
                ai.PCC__c             = qac_tmc.pseudoCityCode;
                ai.Code__c          = qac_tmc.gdsCode;
                //ai.Active__c        = qac_tmc.isActive;
                ai.Account__c        = iataCodeToAccountId.get(accountId);
                ai.RecordTypeId        = gdsRecordTypeId;
                
                List<Agency_Info__c> tmcInfo =[SELECT Id, Account__c, Code__c, Active__c From Agency_Info__c 
                                               Where Code__c =:ai.Code__c 
                                               AND Account__c=:ai.Account__c
                                               AND PCC__c =:ai.PCC__C ];   
                List<Asset> assetInfo = [Select Id from Asset where accountId =:ai.Account__c and GDS__r.Name=:ai.Code__c and RecordType.DeveloperName = 'Agency_Channel'];
                System.debug('TMCInfo'+tmcInfo);
                
                qacChannelStatus = (assetInfo.size()>0) ? 'New' : 'Not Applicable';
                
                if(tmcInfo.size()>0)
                {
                    response.statusCode     = 409;
                    successResponse             = new QAC_TMCResponse.successResponse('409', 'PCC Exist Already');
                    response.responseBody    =Blob.valueOf(JSON.serializePretty(successResponse, true));
                }
                else 
                {
                    Asset myAsset;      //CRM-9841
                    //CRM-9601 changes start
                    if (assetInfo.size()== 0){
                        myAsset = new Asset();
                        myAsset.Name = accountId +'_'+ ai.Code__c;
                        myAsset.AccountId = ai.Account__c;
                        myAsset.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
                        for(GDS_Reference__c eachGDS : [Select Id from GDS_Reference__c where Name = :ai.Code__c limit 1])
                        {
                            myAsset.GDS__c = eachGDS.Id;
                        }
                        myAsset.Active__c = TRUE;
                        myAsset.Status = 'New';
                        insert myAsset;
                    } else {                        //CRM-9841
                        myAsset = assetInfo[0];     //CRM-9841
                    }

                    //CRM-9601 changes end
                    
                    insert ai;
                    /*set<Id> tmcIds = new set<Id>();
                    for(Agency_Info__c eachInfo : lstTMC){
                    tmcIds.add(eachInfo.Id);
                    }
                    
                    list<QAC_Responses.tmcresponse> listResponse = new list<QAC_Responses.tmcresponse>();
                    for(Agency_Info__c eachInfo : [SELECT Id, Account__c, Code__c,  Active__c From Agency_Info__c Where ID IN: tmcIds]){
                    tmcResponsesList.add(new QAC_Responses.tmcresponse(eachInfo.Id,eachInfo.Account__c,eachInfo.Code__c,eachInfo.Active__c));      
                    }*/
                    Boolean isActive = true;
                    response.statusCode     = 201;
                    success             = new QAC_TMCResponse.success('201', 'PCC Created Successfully',ai.id,qacChannelStatus,isActive);
                    success.assetId = (myAsset != null) ? myAsset.Id : null;            //CRM-9841
                    response.responseBody    =Blob.valueOf(JSON.serializePretty(success, true));
                    //response.responseBody    = Blob.valueOf(JSON.serializePretty(tmcResponsesList, true));
                }
            }
            
            /*
      * Preparing Appropriate Response, In case TMC Found
      */
            else if(accountId == '' || accountId == null){
                fieldErrors.add(new QAC_TMCResponse.FieldErrors('Agency Code', 'Missing'));
                expectionResponse      = new QAC_TMCResponse.ExceptionResponse('400', 'Agency Code Not Provided in Header', fieldErrors); 
                response.statusCode     = 400;
                response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));
            }
            
            /*
      * Preparing Appropriate Response, In case TMC Found
      */
            else{
                fieldErrors.add(new QAC_TMCResponse.FieldErrors('Agency Code', 'Not Existing'));
                expectionResponse      = new QAC_TMCResponse.ExceptionResponse('404', 'No TMC record Exists', fieldErrors); 
                response.statusCode     = 404;
                response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));
            }    
        }
        
        /*
        * Checking Exceptions
    */
        catch(Exception ex){
            system.debug('@@ Show Error @@ ' + ex.getMessage());
            system.debug('@@ Show Error @@ ' + ex.getStackTraceString());
            CreateLogs.insertLogRec('Log Integration Logs Rec Type', 'QAC Tradesite - QAC_TMCInsertion', 'QAC_TMCOperations',
                                    'doTMCInsertion',(request.requestBody.toString().length() > 32768) ? request.requestBody.toString().substring(0,32767) : request.requestBody.toString(), String.valueOf(''), true,'', null);
            
            expectionResponse      = new QAC_TMCResponse.ExceptionResponse('500', 'Salesforce Internal Issue', 'Agency Code', 'Missing'); 
            response.statusCode     = 500;
            response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));   
        }
        
    }
    
    // changes added by Ajay
  public static list<Agency_Info__c> fetchTMC(Set<Id> tmcIds)
  {
    return [SELECT Id, Name, RecordType.Name, Account__c, Active__c,Code__c, PCC__c, 
           GDS_Status__c, QDP_Status__c, ATPCO_Status__c, Surcharge_Exemption_Status__c,
           GDS_Effective_Date__c,Channel_Effective_Date__c,Last_Inactive_Date__c, Account__r.Qantas_Industry_Centre_ID__c
           FROM Agency_Info__c WHERE Id IN: tmcIds];
  }
  
    public static void fetchChannelStatus(list<Asset> assetList,list<Agency_Info__c> listTmcInfo)
    {
        system.debug('assetList'+assetList);
        system.debug('GDS List'+listTmcInfo);
        
        for(Asset assetObj:assetList)
        {
            assetDate.put(assetObj.AccountId+''+assetObj.GDS__r.Name,assetObj.Channel_Effective_Date__c);
        }        
        
        //Changes added by Vinoth for TS-4815
        /*for(Agency_Info__c aInfo:listTmcInfo)
        {
            if(string.isblank(aInfo.GDS_Status__c)) 
            {
                channelStatus.put(aInfo.Id,'Not Applicable');
            }
            else if(gdsValues.contains(aInfo.GDS_Status__c))
            {
                channelStatus.put(aInfo.Id,aInfo.GDS_Status__c);
            }
            else if(aInfo.GDS_Status__c=='Accepted' && (aInfo.QDP_Status__c!='Accepted' || aInfo.ATPCO_Status__c!='Accepted' || aInfo.Surcharge_Exemption_Status__c!='Accepted'))
            {
                channelStatus.put(aInfo.Id,'Processing');
            }
            else if(aInfo.GDS_Status__c=='Accepted' && aInfo.QDP_Status__c=='Accepted' && 
                    aInfo.ATPCO_Status__c=='Accepted' && aInfo.Surcharge_Exemption_Status__c=='Accepted')
            {
                if(aInfo.Channel_Effective_Date__c > system.today() || assetDate.get(aInfo.Account__c+''+aInfo.Code__c)>system.today())
                {
                    channelStatus.put(aInfo.Id,'Accepted');
                }
                else if(aInfo.Channel_Effective_Date__c<=system.today() && assetDate.get(aInfo.Account__c+''+aInfo.Code__c)<=system.today())
                {
                    channelStatus.put(aInfo.Id,'Active');
                }
            }
        }*/
        //return channelStatus;
        
        for(Agency_Info__c aInfo:listTmcInfo)
        {
            if(string.isblank(aInfo.GDS_Status__c)) 
            {
                channelStatus.put(aInfo.Id,'Not Applicable');
            }
            else if(aInfo.GDS_Status__c=='Accepted' && (aInfo.QDP_Status__c!='Accepted' || aInfo.ATPCO_Status__c!='Accepted' || aInfo.Surcharge_Exemption_Status__c!='Accepted'))
            {
                channelStatus.put(aInfo.Id,'Processing');
            }
            else if((aInfo.GDS_Status__c=='Pending deregistration') || (aInfo.GDS_Status__c=='Deregistered' && (aInfo.ATPCO_Status__c=='Pending deregistration' || aInfo.Surcharge_Exemption_Status__c=='Pending deregistration' || aInfo.QDP_Status__c=='Pending deregistration')))
            {
                channelStatus.put(aInfo.Id,'Pending deregistration');
            }
            else if((aInfo.GDS_Status__c=='Deregistered' && string.isblank(aInfo.ATPCO_Status__c) && string.isblank(aInfo.Surcharge_Exemption_Status__c) && string.isblank(aInfo.QDP_Status__c))|| (aInfo.GDS_Status__c=='Deregistered' && aInfo.ATPCO_Status__c=='Deregistered' && aInfo.Surcharge_Exemption_Status__c=='Deregistered' && aInfo.Surcharge_Exemption_Status__c=='Deregistered'))
            {
                channelStatus.put(aInfo.Id,'Deregistered');
            }
            else if(aInfo.GDS_Status__c=='Accepted' && aInfo.QDP_Status__c=='Accepted' && 
                    aInfo.ATPCO_Status__c=='Accepted' && aInfo.Surcharge_Exemption_Status__c=='Accepted')
            {
                if(aInfo.Channel_Effective_Date__c > system.today() || assetDate.get(aInfo.Account__c+''+aInfo.Code__c)>system.today())
                {
                    channelStatus.put(aInfo.Id,'Accepted');
                }
                else if(aInfo.Channel_Effective_Date__c<=system.today() || assetDate.get(aInfo.Account__c+''+aInfo.Code__c)<=system.today())
                {
                    channelStatus.put(aInfo.Id,'Active');
                }
            }
            else if(gdsValues.contains(aInfo.GDS_Status__c))
            {
                channelStatus.put(aInfo.Id,aInfo.GDS_Status__c);
            }
        }
        //Changes ends for TS-4815
    }
    // changes ended
    
    public static map<String, Id> retrunAgencyAccounts(set<String> iataCodes){
        
        map<String, Id> returnMap = new map<String, Id>();
        
        for(Account eachAccount : [SELECT Id, Qantas_Industry_Centre_ID__c
                                   FROM Account
                                   WHERE Qantas_Industry_Centre_ID__c IN: iataCodes
                                   AND RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId()])
        {
            returnMap.put(eachAccount.Qantas_Industry_Centre_ID__c, eachAccount.Id);                           
        }
        
        return returnMap;
    }
}