/***********************************************************************************************************************************

Description: Apex class for retrieving the account information and TMC Information. 

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan       Account and TMC  record retrieval class                      T01
Ajay Bharathan               Included null check logics & Not in salesforce logic         T02

Created Date    : 11/12/17 (DD/MM/YYYY)

Modified Date   : 23/08/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4725
Version         : V2.0 - Added new field "Maintenance Date"

30-Mar-2026    Zain S                CIAM-1896: Avoid querying TMC and TA records when source is CIAM_QantasGateway as it doesn't require TMC and TA details.
30-Mar-2026    Zain S                CIAM-1881: Added new fields in Account Retrieval Response for CIAM integration
**********************************************************************************************************************************/
@RestResource(urlMapping = '/QACAgencyAccountRetrieval/')
global with sharing class QAC_AccountRetrieval {
    
    @HttpPost
    global static void doAccountRetrieval() 
    {
        //Savepoint sp = Database.setSavePoint();
        QAC_Responses qacResp = new QAC_Responses();
        QAC_Responses.QACAccountRetrievalResponse myAccTmcResp;
        list<QAC_Responses.QACAccountRetrievalResponse> myAccTmcRespList = new list<QAC_Responses.QACAccountRetrievalResponse>();    
        
        // labels for where condition
        String tmcRT = Label.QAC_AccRet_TMCRecType;
        String taPicklist = Label.QAC_AccRet_TA_Relationship;
        
        Boolean isException = false;
        set <String> incomingQIC = new set <String> ();
        map<String,Account> existingAccountmap = new map<String,Account>();
        map<String,list<Agency_Info__c>> existingTMCsMap = new map<String,list<Agency_Info__c>>();
        map<String,list<Account_Relation__c>> existingTAsMap = new map<String,list<Account_Relation__c>>();
        String responseJson = '';
        String request;
        
        // Reading Request parameters, JSON extration from Body of request is primary
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        request = req.requestBody.toString();
		String source;                      //CIAM
        
        try {
            // Retrieving body of request from URI
            QAC_AccountRetrievalAPI acRApi = QAC_AccountRetrievalAPI.parse(request);
            source = acRApi.source;                      //CIAM
            
            for (QAC_AccountRetrievalAPI.AccountRecords accRet: acRApi.AccountRetrieval.AccountRecords) {
                incomingQIC.add(accRet.AgencyCode);
            }
            
            system.debug('incoming **'+incomingQIC);
            
            if(!incomingQIC.isEmpty())
            {
                for(Account eachAccount : [Select Id,Name,ABN_Tax_Reference__c, Qantas_Industry_Centre_ID__c,Website,Fax,Email__c,Agency_Sales_Region__c,
                                           External_Reference_ID__c,Business_Type__c,BillingAddress,RCTI__c,Agency_Sub_Chain__c,Agency_Sales_Region__r.Name,
                                           Phone_Country_Code__c,Phone_Area__c,Phone_Number__c,Fax_Country__c,Fax_Area__c,Fax_Number__c,Agency_Sales_Region__r.Brand_Code__c,
                                           Owner.Name,Aquire_Membership_Number__c,Industry,Tradesite__c,IATA_Expiry_Date__c,Office_Type__c,
                                           Active__c,Customer_Category__c,Agency_Type__c,Legal_Name__c,IATA_Number__c,Agency_TIDS_Number__c,NumberOfEmployees, Maintenance_Date__c  //New Change JIRA:TS-4725 : Add Maintenance Date on this query
                                           ,QAC_Request_Pending__c  //CIAM - Add QAC_Request_Pending__c on this query
                                           ,AccreditationType__c //CIAM-1881
                                           from Account where Qantas_Industry_Centre_ID__c IN: incomingQIC])
                {
                    if(eachAccount != null)
                    {
                        existingAccountmap.put(eachAccount.Qantas_Industry_Centre_ID__c,eachAccount);
                    }
        }  

        if(source != 'CIAM_QantasGateway' && !existingAccountmap.isEmpty()){                //CIAM-1896: Avoid querying TMC and TA records when source is CIAM_QantasGateway as it doesn't require TMC and TA details.
          for(Agency_Info__c eachAgency : [Select Id, Account__c,Account__r.Qantas_Industry_Centre_ID__c, Name, Agency_Product_Fares__c, Email_Id__c, Code__c, Active__c, Market_Segment__c, PCC__c, Last_Inactive_Date__c
                          from Agency_Info__c where Account__r.Qantas_Industry_Centre_ID__c IN: existingAccountmap.keySet() AND RecordType.Name = :tmcRT])
          {
            if(eachAgency != null){
              if(existingTMCsMap.containsKey(eachAgency.Account__r.Qantas_Industry_Centre_ID__c)){
                existingTMCsMap.get(eachAgency.Account__r.Qantas_Industry_Centre_ID__c).add(eachAgency);
              }
              else{
                existingTMCsMap.put(eachAgency.Account__r.Qantas_Industry_Centre_ID__c, new list<Agency_Info__c>{eachAgency});
              }
            }
          }
          
          for(Account_Relation__c eachTA : [Select Id, Name, Related_Account__c, Related_Account__r.Qantas_Industry_Centre_ID__c, Primary_Account_f__c, Relationship__c, Primary_Account__c, Primary_Account__r.Qantas_Industry_Centre_ID__c, Related_Account_f__c, Active__c, Start_Date__c,Last_Inactive_Date__c 
                            from Account_Relation__c Where Primary_Account__r.Qantas_Industry_Centre_ID__c IN: existingAccountmap.keySet() AND Relationship__c = :taPicklist])
          {
            if(eachTA != null){
              if(existingTAsMap.containsKey(eachTA.Primary_Account__r.Qantas_Industry_Centre_ID__c)){
                existingTAsMap.get(eachTA.Primary_Account__r.Qantas_Industry_Centre_ID__c).add(eachTA);
              }
              else{
                existingTAsMap.put(eachTA.Primary_Account__r.Qantas_Industry_Centre_ID__c, new list<Account_Relation__c>{eachTA});
              }
            }
          }
        }
            }
            
            system.debug('existing ***'+existingAccountmap);
            system.debug('existing tmc ***'+existingTMCsMap);
            system.debug('existing ta ***'+existingTAsMap);
            
            if(!existingAccountmap.isEmpty()){
                res.statusCode = 200;
                for (String qicCode : incomingQIC) {
                    if(existingAccountmap.containsKey(qicCode)){
                        myAccTmcResp = new QAC_Responses.QACAccountRetrievalResponse('200',existingAccountmap.get(qicCode),
                                                                                     existingTMCsMap.get(qicCode),
                                                                                     existingTAsMap.get(qicCode) 
                                                                                    );
                        myAccTmcRespList.add(myAccTmcResp);
                        
                    }
                }
                incomingQic.removeAll(existingAccountmap.keySet());
            }
            system.debug('existing ***'+myAccTmcRespList.size());
            
            for(String qicCode : incomingQIC) 
            {
                if (!(source == 'CIAM_QantasGateway' && !existingAccountmap.isEmpty() )) res.statusCode = 404;                      //CIAM
                myAccTmcResp = new QAC_Responses.QACAccountRetrievalResponse('404','the Requested QIC is not found in salesforce system',qicCode);
                myAccTmcRespList.add(myAccTmcResp);
            }
            qacResp.QACAccountRetrievalResponse = myAccTmcRespList;
            
            responseJson += JSON.serializePretty(qacResp,true);
            // responseJson += JSON.serializePretty(qacResp);
            system.debug('arr val**'+responseJson);
            // responseJson = responseJson.unescapeJava();
            res.responseBody = Blob.valueOf(responseJson);
            
        } 
        catch (Exception ex) 
        {
            system.debug('Exception###' + ex);
            isException = true;
            
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC - Create Retrieval API', 'QAC_AccountRetrieval',
                                    'create',(responseJson.length() > 32768) ? responseJson.substring(0,32767) : responseJson,
                                    String.valueOf(''), true, '', ex);
            
            res.statusCode = 400;
            myAccTmcResp = new QAC_Responses.QACAccountRetrievalResponse('400','There is a salesforce internal issue, please contact Salesforce Support team',null);
            myAccTmcRespList.add(myAccTmcResp);
            qacResp.QACAccountRetrievalResponse = myAccTmcRespList;
            
            responseJson += JSON.serializePretty(qacResp,true);
            res.responseBody = Blob.valueOf(responseJson);
            
        }
        finally {
            res.addHeader('Content-Type', 'application/json');                      //CIAM
            if (!isException) {
                CreateLogs.insertLogRec('Log Integration Logs Rec Type', 'QAC - Create Retrieval API', 'QAC_AccountRetrieval',
                                        'create', (request.length() > 32768) ? request.substring(0,32767) : request, String.valueOf(''), true, '', null);
            }
        }
        
    }
}