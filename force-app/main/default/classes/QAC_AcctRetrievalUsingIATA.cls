/*
Purpose : used by My Agency Profile for retrieving the account primary and secondary Information using IATA Code. 
Developed By : 
Yuvraj MV :     Account record retrieval class
Ajay :          Edited Class based on Channel changes
TestClass :     QAC_AcctRetrievalUsingIATA_Test

Modified Date   : 23/08/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4725
Version         : V2.0 - Added new field "Maintenance Date"

Modified Date   : 18/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4810
Version         : V3.0 - Add Agency Sales Region Brand Code
*/
@RestResource(urlmapping='/QACAcctInformationRetrieval/*')
global with sharing class QAC_AcctRetrievalUsingIATA 
{
    @HttpGet
    global static void doAcctRetrieval()
    {
        QAC_AgencyAccountRetrieval accret;
        QAC_AgencyAccountRetrieval.AgencyPrimaryDetails primary;
        QAC_AgencyAccountRetrieval.AgencySecondaryDetails secondary;
        
        QAC_AgencyProfileResponses.exceptionResponse mapErrorResponse;
        List<QAC_AgencyProfileResponses.FieldErrors> listFieldErrorResp = new List<QAC_AgencyProfileResponses.FieldErrors>();
        map<String,Account> existingAccountmap = new map<String,Account>();
        map<String,Set<String>> existingTMCGDSmap = new map<String,Set<String>>();
        
        string finalResponse;
        String iataCode;
        String myFilter;
        
        try
        {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;
            iataCode = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            
            system.debug('IATA CODE**'+iataCode);
            
            myFilter = request.params.get('filter');
            
            if(string.isNotEmpty(iataCode))
            {
                //New Changes JIRA:TS-4810 (Add Agency Sales Region Brand Code to the Below query)
                for(Account eachAccount : [Select Id,Name,ABN_Tax_Reference__c, Qantas_Industry_Centre_ID__c,Agency_Sub_Chain__c,
                                           QAC_Request_Pending__c,Agency_Sales_Region__r.Name,Active__c,Business_Type__c,Channel_Member__c,Agency_Sales_Region__r.Brand_Code__c,
                                           Agency_Sales_Region__r.Hide_TMCTA__c,Agency_Sales_Region__c,BillingStreet,Email__c,Tradesite__c,
                                           BillingCity,BillingCountryCode,BillingPostalCode,Phone_Number__c,Phone_Country_Code__c,
                                           Phone_Area__c,phone,ATAS__c,BillingState,NumberOfEmployees,Website,ABTA_Number__c,ATOL_Number__c,Maintenance_Date__c //New Change JIRA:TS-4725 : Add Maintenance Date on this query
                                           from Account where Qantas_Industry_Centre_ID__c =: iataCode])
                {
                    if(eachAccount != null)
                    {
                        existingAccountmap.put(eachAccount.Qantas_Industry_Centre_ID__c,eachAccount);
                    }
                }
            }
            
            system.debug('existing ***'+existingAccountmap);
            
            if(!existingAccountmap.isEmpty())
            {
                if(String.isNotBlank(myFilter))
                {
                    String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId();                    
                    for(Agency_Info__c eachAgency : [SELECT Id,Account__r.Qantas_Industry_Centre_ID__c FROM Agency_Info__c
                                                     WHERE Account__r.Qantas_Industry_Centre_ID__c IN: existingAccountmap.keySet()
                                                     AND RecordTypeId =: tmcRTId AND Active__c = TRUE])
                    {
                        
                     /*   if(eachAgency != null){
                            if(existingTMCGDSmap.containsKey(eachAgency.Account__r.Qantas_Industry_Centre_ID__c)){
                                existingTMCGDSmap.get(eachAgency.Account__r.Qantas_Industry_Centre_ID__c).add(eachAgency.Code__c);
                            }
                            else{
                                existingTMCGDSmap.put(eachAgency.Account__r.Qantas_Industry_Centre_ID__c, new Set<String>{eachAgency.Code__c});
                            }
                        }*/
                    }
                    
                   // System.debug('existingTMCGDSmap'+existingTMCGDSmap);
                }
                
                response.statusCode = 200;
                
                if(existingAccountmap.containsKey(iataCode))
                {
                    accret = new QAC_AgencyAccountRetrieval();
                    primary =  new QAC_AgencyAccountRetrieval.AgencyPrimaryDetails(existingAccountmap.get(iataCode));
                    secondary = new QAC_AgencyAccountRetrieval.AgencySecondaryDetails(existingAccountmap.get(iataCode),
                                                                                      (existingTMCGDSmap.isEmpty()) ? null : existingTMCGDSmap.get(iataCode));
                    accret.agencyPrimaryDetails = primary;
                    accret.agencySecondaryDetails = secondary;
                    finalResponse = JSON.serializePretty(accret,true);
                    response.responseBody = Blob.valueOf(finalResponse);
                }
            }
            else if(string.isEmpty(iataCode))
            {
                response.statusCode = 400;
                listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('Id','IATA is Blank, Please enter valid IATA code' ));
                mapErrorResponse = new QAC_AgencyProfileResponses.exceptionResponse('400', 'Bad Request', listFieldErrorResp);
                response.responseBody = Blob.valueOf(JSON.serializePretty(mapErrorResponse,true));
            }
            else
            {
                response.statusCode         = 404;
                listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('Id','IATA doesnt exits' ));
                mapErrorResponse = new QAC_AgencyProfileResponses.exceptionResponse('404', 'Bad Request', listFieldErrorResp);
                response.responseBody = Blob.valueOf(JSON.serializePretty(mapErrorResponse,true));
            }
        }
        catch(Exception ex)
        {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;
            system.debug('Exception###' + ex);
            response.statusCode = 500;
            listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors(ex.getStackTraceString(), ex.getMessage() ));
            mapErrorResponse = new QAC_AgencyProfileResponses.ExceptionResponse('500', 'Salesforce Internal Error', listFieldErrorResp);
            response.responseBody = Blob.valueOf(JSON.serializePretty(mapErrorResponse,true));
        }
    }
}