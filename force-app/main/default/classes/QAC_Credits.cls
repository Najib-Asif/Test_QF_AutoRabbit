/***********************************************************************************************************************************
Description: ResptAPI class for GET on Asset,Ledger__c. It would get Credits from Asset and Statement from Ledger__c  
Author: Sobhan - TCS

***********************************************************************************************************************************/
@RestResource(urlmapping='/QACCredits/*')
global with sharing class QAC_Credits {

    public static string responseJson='';
    Public Static QAC_CreditsResponse assetResp = new QAC_CreditsResponse();
    
    @HttpGet
    global static void doCreditsRetrieval()
    {
         /*
         * Variable Declarations
         */
        RestRequest request                             = RestContext.request;
        RestResponse response                           = RestContext.response;
        
        list<QAC_CreditsResponse.balanceResponse> assetResponsesList = new list<QAC_CreditsResponse.balanceResponse>();
        List<QAC_CreditsResponse.FieldErrors> listFieldErrorResp = new List<QAC_CreditsResponse.FieldErrors>();
        QAC_CreditsResponse.ExceptionResponse myExceptionResponse; 
    
        String accId;
        String filter;
        
        map<Id,Account> existingAccountMap = new Map<Id,Account>();
        map<Id,list<Asset>> existingAssetsMap = new map<Id,list<Asset>>();
        map<Id,list<Asset>> inactiveAssetsMap = new map<Id,list<Asset>>();
        try{
           String agencyCode = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            system.debug('agencyCode @@'+agencyCode);
            filter = request.params.get('filter');
            Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
            
            if(String.isNotBlank(agencyCode))
            {
                for(Account eachAccount : [Select Id, Qantas_Industry_Centre_ID__c,Active__c,Tradesite__c from Account 
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
                    if(existingAccountMap.get(accId).Active__c==false || existingAccountMap.get(accId).Tradesite__c==false )
                    {
                        response.statusCode         = 404;
                        listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('AccountId','No Active Account For Agency :'+agencyCode));
                        myExceptionResponse         = new QAC_CreditsResponse.ExceptionResponse('404','Agency not Active', listFieldErrorResp); 
                        assetResp.exceptionResponse=myExceptionResponse;
                        
                        //response.responseBody     = Blob.valueOf(JSON.serializePretty(myExceptionResponse, true));   
                    }
                    else{
                    String asstRecType = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Credit').getRecordTypeId();
                    for(Asset eachAsset : [SELECT id,AccountId,Agency_Identifier__c,Asset_Year__c,Total_Acquired_Credits__c,Total_Consumed_Credits__c,
                               Total_Outstanding_Credits__c,Active__c FROM Asset
                               WHERE AccountId IN: existingAccountMap.keySet()  
                               AND RecordTypeId =:asstRecType])
                    {
                        if(eachAsset != null){
                            if(eachAsset.Active__c)
                            {
                                if(existingAssetsMap.containsKey(eachAsset.AccountId)){
                                    existingAssetsMap.get(eachAsset.AccountId).add(eachAsset);
                                }
                                else{
                                    existingAssetsMap.put(eachAsset.AccountId, new list<Asset>{eachAsset});
                                }
                            }
                            else{
                              if(inactiveAssetsMap.containsKey(eachAsset.AccountId)){
                                inactiveAssetsMap.get(eachAsset.AccountId).add(eachAsset);
                            }
                            else{
                                inactiveAssetsMap.put(eachAsset.AccountId, new list<Asset>{eachAsset});
                            }  
                            }
                        }
                    }
                    if(filter!='Statement' && existingAssetsMap.isEmpty()){
                    response.statusCode         = 412;
                    listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('Assets', 'No Active Assets Found'));
                    myExceptionResponse         = new QAC_CreditsResponse.ExceptionResponse('412', 'Agency not eligible for this program', listFieldErrorResp); 
                    assetResp.exceptionResponse=myExceptionResponse;
                    //response.responseBody     = Blob.valueOf(JSON.serializePretty(myExceptionResponse, true));    
                    }
                    else if(filter=='Statement'){
                        assetResp=  doLedger(existingAccountMap,existingAssetsMap,inactiveAssetsMap,accId,request,response);    
                    }
                    else if(existingAssetsMap.get(accId).size()>0){
                           if(existingAssetsMap.get(accId).size() == 1){
                                response.statusCode         = 200;
                                assetResponsesList.add(new QAC_CreditsResponse.balanceResponse(existingAssetsMap.get(accId)));
                                assetResp.creditResponse = assetResponsesList;
                               
                            //response.responseBody         = Blob.valueOf(JSON.serializePretty(assetResponsesList, true));    
                            }
                            else if(existingAssetsMap.get(accId).size() > 1){
                            response.statusCode         = 409;
                            listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('Assets', 'Data Issue'));
                            myExceptionResponse         = new QAC_CreditsResponse.ExceptionResponse('409', 'Multiple Active Assets Found', listFieldErrorResp); 
                            assetResp.exceptionResponse = myExceptionResponse;
                            
                            //response.responseBody     = Blob.valueOf(JSON.serializePretty(myExceptionResponse, true));    
                            }
                    }
                    }
                 }
                else {
                response.statusCode         = 404;
                listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('AccountId','No Account For Agency :'+agencyCode));
                myExceptionResponse         = new QAC_CreditsResponse.ExceptionResponse('404','Agency does not exist in Salesforce', listFieldErrorResp); 
                assetResp.exceptionResponse = myExceptionResponse;
                //response.responseBody     = Blob.valueOf(JSON.serializePretty(myExceptionResponse, true));
                }
               
            }
                              
            /*
             * Preparing Appropriate Response If IATA not found
             */
                
            else{
                response.statusCode         = 400;
                listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('Agency Code', 'Missing'));
                myExceptionResponse         = new QAC_CreditsResponse.ExceptionResponse('400', 'Agency Code Not Provided in Header', listFieldErrorResp); 
                assetResp.exceptionResponse = myExceptionResponse;
                
                //response.responseBody     = Blob.valueOf(JSON.serializePretty(myExceptionResponse, true));
            }
            responseJson += JSON.serializePretty(assetResp,true);
            response.responseBody = Blob.valueOf(responseJson);
            
      }
        
        /*
         * Checking Exceptions
         */
       catch(Exception ex)
        {
            system.debug(' @@ ' + ex.getMessage());
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Agency Credits', 'QAC_Credits',
                                    'doCreditsRetrieval', (responseJson.length() > 32768) ? responseJson.substring(0,32767) : responseJson,
                                    String.valueOf(''), true,'', ex);
            
            String sfErrMessage = ex.getMessage();
            
            response.statusCode = 500;
            listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('Exception',sfErrMessage));
            myExceptionResponse = new QAC_CreditsResponse.ExceptionResponse('500','Found errors.Please contact Salesforce.',listFieldErrorResp);

            assetResp.exceptionResponse = myExceptionResponse;
            responseJson += JSON.serializePretty(assetResp,true);
            response.responseBody = Blob.valueOf(responseJson);
            
        }
    }
        
    public static QAC_CreditsResponse doLedger(Map<Id,Account> accountMap, Map<Id,List<Asset>> assetMap,Map<Id,List<Asset>> inactiveMap,String accId,RestRequest request,RestResponse response)
    {
        QAC_CreditsResponse.QACCreditResponse ledgerResponse;
        List<QAC_CreditsResponse.LedgerResponse> liststatementResp = new List<QAC_CreditsResponse.LedgerResponse>();
        List<QAC_CreditsResponse.FieldErrors> listFieldErrorResp = new List<QAC_CreditsResponse.FieldErrors>();
        QAC_CreditsResponse.ExceptionResponse myExceptionResponse; 
        Date fromDate = request.params.get('fromDate')!=null?Date.parse(request.params.get('fromDate')):system.today().addDays(-90);
        Date toDate   = request.params.get('toDate')!=null?Date.parse(request.params.get('toDate')):System.today();
        map<String,list<Ledger__c>> existingLedgerMap = new map<String,list<Ledger__c>>();
        
        if(fromDate<system.today().addMonths(-15) || toDate<system.today().addMonths(-15)){
            response.statusCode         = 412;
            listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('fromDate/toDate','RequestDates Beyond 15 months'));
            myExceptionResponse         = new QAC_CreditsResponse.ExceptionResponse('412','Please Change the filter', listFieldErrorResp); 
            assetResp.exceptionResponse = myExceptionResponse;  
        }
        else
        {
            for(Ledger__c eachLedger : [Select Id,case__r.CaseNumber,case__r.Sub_Type_1__c,Transaction_Type__c,Transaction_Frequency__c,
                                                Transaction_date__c,Reason__c,Total_Credit_value__c,Account__C
                                                from Ledger__c where Account__C IN: accountMap.keySet() AND
                                                Transaction_date__c>= :fromDate AND Transaction_date__c<=:toDate])
                    {
                        if(eachLedger != null){
                            if(existingLedgerMap.containsKey(eachLedger.Account__c)){
                                existingLedgerMap.get(eachLedger.Account__c).add(eachLedger);
                            }
                            else{
                                existingLedgerMap.put(eachLedger.Account__c, new list<Ledger__c>{eachLedger});
                            }
                        }
                    }
        if(!existingLedgerMap.isEmpty())
        {   
            if(existingLedgerMap.get(accId).size()<500)
            {
                if(!assetmap.isEmpty() && assetmap.get(accId).size()==1 )
                {
                    ledgerResponse = new QAC_CreditsResponse.QACCreditResponse('200',assetMap.get(accId),
                                                                                     existingLedgerMap.get(accId)
                                                                                    );
                    assetResp.QACCreditResponse = ledgerResponse;
                }
                else if(!assetmap.isEmpty() && assetmap.get(accId).size()>1){
                    response.statusCode         = 409;
                    listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('Assets', 'Data Issue'));
                    myExceptionResponse         = new QAC_CreditsResponse.ExceptionResponse('409', 'Multiple Active Assets Found', listFieldErrorResp); 
                    assetResp.exceptionResponse = myExceptionResponse;
                            
                }
                else{
                    for(Ledger__c ledgerObj :existingLedgerMap.get(accId) )
                    {
                    liststatementResp.add(new QAC_CreditsResponse.LedgerResponse(ledgerObj.case__r.CaseNumber,
                                                                            ledgerObj.case__r.Sub_Type_1__c,
                                                                            ledgerObj.Transaction_Type__c,
                                                                            ledgerObj.Transaction_Frequency__c,
                                                                            ledgerObj.Transaction_date__c,
                                                                            ledgerObj.Reason__c,
                                                                            ledgerObj.Total_Credit_value__c));
                    assetResp.Statement = liststatementResp;
                    }
                }
            }                
        
        else{
            response.statusCode         = 412;
            listFieldErrorResp.add(new QAC_CreditsResponse.FieldErrors('LedgerData','Records Limit Exceeded'));
            myExceptionResponse         = new QAC_CreditsResponse.ExceptionResponse('412','Narrow the results by giving filter', listFieldErrorResp); 
            assetResp.exceptionResponse = myExceptionResponse;
                
        }
        }            
      }
        return assetResp;
    }
}