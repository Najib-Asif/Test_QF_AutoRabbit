/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to validate PNR using Agency Retrieval and its child records
* REST API : QAC_AgencyRetrievalAPI
*/
@RestResource(urlmapping='/QACAgencyRetrieval')
global with sharing class QAC_AgencyRetrieval
{
    public static Boolean retrieveFlag = false;
    public static Boolean pccExists = false;
    public static Account existingAccount;
    
    // To Do Retrieval
    @HttpPost
    global static void doRetrieval()
    {
        set<String> incomingIATAs = new Set<String>();
        String requestJson;
        QAC_Responses.QAC_AgencyValidationResponse myAgenValResp;
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        requestJson = req.requestBody.toString();
        
        try
        {
            system.debug(' @@ request 1 @@' +requestJson);
            
            // to convert the received String into object
            QAC_AgencyRetrievalAPI acApi = QAC_AgencyRetrievalAPI.parse(requestJson);
            
            // check if login IATA equal to booking IATA
            if(acApi != null &&
               acApi.agencyRetrieval.loginIATA != null && String.isNotBlank(acApi.agencyRetrieval.loginIATA) && 
               acApi.agencyRetrieval.bookingIATA != null)
            {
                fetchAccount(acApi.agencyRetrieval.loginIATA);
                if(existingAccount != null)
                {
                    // login IATA account exists
                    
                    if(acApi.agencyRetrieval.loginIATA == acApi.agencyRetrieval.bookingIATA){
                        retrieveFlag = true;
                    }
                    else
                    {
                        Id tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId();
                        for(Agency_Info__c eachAgency : [Select Id,Code__c,Active__c,PCC__c from Agency_Info__c 
                                                         where Account__c =: existingAccount.Id AND Active__c = true AND RecordTypeId = :tmcRTId])
                        {
                            if(eachAgency != null && String.isNotBlank(eachAgency.PCC__c) && eachAgency.PCC__c == acApi.agencyRetrieval.pcc)
                            {
                                retrieveFlag = true;
                                pccExists = true;
                                break;
                            }
                        }
                    }
                    
                    if(!retrieveFlag && !pccExists)
                    {
                        // check for booking iata on login iata and vice versa
                        incomingIATAs.add(acApi.agencyRetrieval.loginIATA);
                        incomingIATAs.add(acApi.agencyRetrieval.bookingIATA);
                        
                        for(Account_Relation__c eachTA : [Select Id, Related_Account__c, Related_Account__r.Qantas_Industry_Centre_ID__c, Primary_Account__c, Primary_Account__r.Qantas_Industry_Centre_ID__c, Active__c
                                                          from Account_Relation__c Where Active__c = true AND Primary_Account__r.Qantas_Industry_Centre_ID__c IN: incomingIATAs 
                                                          AND Related_Account__r.Qantas_Industry_Centre_ID__c IN: incomingIATAs])
                        {
                            if(eachTA != null)
                            {
                                String existingIATACombo = eachTA.Primary_Account__r.Qantas_Industry_Centre_ID__c + '_' + eachTA.Related_Account__r.Qantas_Industry_Centre_ID__c;
                                String incomingIATACombo = acApi.agencyRetrieval.loginIATA + '_' + acApi.agencyRetrieval.bookingIATA;
                                if(existingIATACombo == incomingIATACombo)
                                {
                                    retrieveFlag = true;
                                    break;
                                }                           
                            }
                        }
                    }
                    
                    // print positive / negative response and return. 
                    res.statusCode = (retrieveFlag) ? 201 : 403 ;
                    myAgenValResp = new QAC_Responses.QAC_AgencyValidationResponse(String.valueOf(res.statusCode),
                                                                                   ((retrieveFlag) ? 'Accepted' : 'Declined'));
                    res.responseBody = Blob.valueOf(JSON.serializePretty(myAgenValResp));
                }
                else{
                    // send error that no account exists
                    res.statusCode = 404 ;
                    myAgenValResp = new QAC_Responses.QAC_AgencyValidationResponse(String.valueOf(res.statusCode),
                                                                                   'ERROR : No Account Found in SF');
                    res.responseBody = Blob.valueOf(JSON.serializePretty(myAgenValResp));
                }
            }
            else{
                // print error JSON Map wrong
                res.statusCode = 400 ;
                myAgenValResp = new QAC_Responses.QAC_AgencyValidationResponse(String.valueOf(res.statusCode),
                                                                               'ERROR : Please check your JSON Input');
                res.responseBody = Blob.valueOf(JSON.serializePretty(myAgenValResp));
            }
            
        }
        catch(Exception ex)
        {
            // print Exception here
            res.statusCode = 500 ;
            myAgenValResp = new QAC_Responses.QAC_AgencyValidationResponse(String.valueOf(res.statusCode),
                                                                           'EXCEPTION : Internal Server Error');
            res.responseBody = Blob.valueOf(JSON.serializePretty(myAgenValResp));
        }
    }
    
    // used to fetch Account using IATA
    public static void fetchAccount(String myIATA)
    {
        for(Account eachAccount : [Select Id,Name,ABN_Tax_Reference__c, Qantas_Industry_Centre_ID__c,Tradesite__c,Active__c
                                   from Account where Qantas_Industry_Centre_ID__c =: myIATA])
        {
            if(eachAccount != null)
                existingAccount = eachAccount;
        }
    }
    
}