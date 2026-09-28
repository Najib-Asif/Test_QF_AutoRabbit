/***********************************************************************************************************************************

Description: Agency Primary Details update, Account Maintainace case creation.

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Abhijeet P              Account Maintainance case creation.                       T01

Created Date    :   05/07/18 (DD/MM/YYYY)

Test Class    :  QAC_AgencyPrimaryDetailsUpdate_Test

-----------------------------------------------------------------------------------------------------------------------
Modified Date   : 12/07/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-3805
Version         : V2.0 - Old Agency Sales Region should return as Name instead of Id 
**********************************************************************************************************************************/
@RestResource(urlMapping = '/QACAgencyPrimaryInfo/*')
global class QAC_AgencyPrimaryDetailsUpdate {
    
    @HttpPatch
    global static void doTMCPrimaryUpdate(){
        
        
        /*
         * Variable Declarations
         */
         
        RestRequest request                 = RestContext.request;
        RestResponse response         = RestContext.response;
        
        QAC_AgencyProfileResponses qacAgResp = new QAC_AgencyProfileResponses();
        QAC_AgencyProfileResponses.QACAgencyPrimaryDetailsResponse myAgSecResp;
        QAC_AgencyProfileResponses.ExceptionResponse expectionResponse;
        list<QAC_AgencyProfileResponses.FieldErrors> fieldErrors = new list<QAC_AgencyProfileResponses.FieldErrors>();
       
        string caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Account_Maintenance').getRecordTypeId();
        
        try{
            /*
             * Retrienving URL parameter for Identifying AccountId
             */
            String accountId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            system.debug('accountId: ' +accountId);
            QAC_AgencyPrimaryParsing parsedData; 
            Case toInsertAccountMaintCase  = new Case();
            list<Account> abnAccount = new list<Account>();  
            list <Case> allCases = new List<Case>();
            //Map<ID,String> openCases = new Map<ID,String>();
            list<Case> openCaseList = new list<Case>();
              
            if(accountId !=null && string.isNotBlank(accountId))
            {
                abnAccount = [SELECT Id, Name, ABN_Tax_Reference__c, IATA_Number__c, Agency_Sub_Chain__c, Agency_Sales_Region__c, Agency_Sales_Region__r.Name, 
                              Active__c, QAC_Request_Pending__c, Legal_Name__c FROM Account WHERE qantas_industry_centre_id__C =: accountId LIMIT 1];                       //CIAM - Added Legal_Name__c
                
            }
            parsedData = QAC_AgencyPrimaryParsing.parse(request.requestBody.toString());
            
            if(abnAccount.size() > 0 &&  !abnAccount[0].QAC_Request_Pending__c)
            {
                /**for(Case eachCase : [SELECT id, Status from Case where AccountId =: abnAccount[0].Id and RecordTypeId =: caseRecordTypeId
                                    and Type = 'Agency Account' and Sub_Type_1__c = 'Account Update'])
                    {
                        if(eachCase != null && eachCase.Status != 'Closed')
                        {
                           //system.debug('case id :' + eachCase);
                           openCases.Put(eachCase.ID, eachCase.Status);
                        }
                    }**/
                openCaseList =[SELECT id, Status from Case where AccountId =: abnAccount[0].Id and RecordTypeId =: caseRecordTypeId
                                    and Type = 'Agency Account' and Sub_Type_1__c = 'Account Update' and status != 'Closed' and Isclosed = true];
                
                if(openCaseList.isEmpty())
                {
                    //parsedData = QAC_AgencyPrimaryParsing.parse(request.requestBody.toString());
                
                    toInsertAccountMaintCase.Subject = 'Agency (' + abnAccount[0].IATA_Number__c + ') - Primary Details Update';
                    toInsertAccountMaintCase.AccountId = abnAccount[0].Id;
                    toInsertAccountMaintCase.RecordTypeId = caseRecordTypeId;
                    string description = '';
                    Map<String,Object> modValues = new Map<String,Object>();                       //CIAM
                    if(parsedData.agencyABN != null){
                        description = 'ABN - ' + '\r\n Old Value - ' +  abnAccount[0].ABN_Tax_Reference__c + '\r\n New Value - ' + parsedData.agencyABN + '\r\n\r\n';
                        modValues.put('agencyABN', new Map<String,Object>{'oldValue'=>abnAccount[0].ABN_Tax_Reference__c,'newValue'=>parsedData.agencyABN});                       //CIAM
                    }
                    if(parsedData.agencyChain != null){
                        //description += 'Agency Chain - ' + '\r\n Old Value - ' +  abnAccount[0].Agency_Sales_Region__c + '\r\n New Value - ' + parsedData.agencyChain + '\r\n\r\n';
                        description += 'Agency Chain - ' + '\r\n Old Value - ' +  abnAccount[0].Agency_Sales_Region__r.Name + '\r\n New Value - ' + parsedData.agencyChain + '\r\n\r\n';
                        modValues.put('agencyChain', new Map<String,Object>{'oldValue'=>abnAccount[0].Agency_Sales_Region__r.Name,'newValue'=>parsedData.agencyChain});                       //CIAM
                    }
                    if(parsedData.agencyCode != null){
                        description += 'Agency Code - ' + '\r\n Old Value - ' +  abnAccount[0].IATA_Number__c + '\r\n New Value - ' + parsedData.agencyCode + '\r\n\r\n';
                        modValues.put('agencyCode', new Map<String,Object>{'oldValue'=>abnAccount[0].IATA_Number__c,'newValue'=>parsedData.agencyCode});                       //CIAM
                    }
                    if(parsedData.agencyTradingName != null){
                        description += 'Agency Trading Name - ' + '\r\n Old Value - ' +  abnAccount[0].Name + '\r\n New Value - ' + parsedData.agencyTradingName + '\r\n\r\n';
                        modValues.put('agencyTradingName', new Map<String,Object>{'oldValue'=>abnAccount[0].Name,'newValue'=>parsedData.agencyTradingName});                       //CIAM
                    }
                    if(parsedData.agencySubChain != null){
                        description += 'Agency Sub Chain - ' + '\r\n Old Value - ' +  abnAccount[0].Agency_Sub_Chain__c + '\r\n New Value - ' + parsedData.agencySubChain + '\r\n\r\n';
                        modValues.put('agencySubChain', new Map<String,Object>{'oldValue'=>abnAccount[0].Agency_Sub_Chain__c,'newValue'=>parsedData.agencySubChain});                       //CIAM
                    }
                    if(parsedData.agencyLegalName != null){                       //CIAM - Block added
                        description += 'Agency Legal Name - ' + '\r\n Old Value - ' +  abnAccount[0].Legal_Name__c + '\r\n New Value - ' + parsedData.agencyLegalName + '\r\n\r\n';
                        modValues.put('agencyLegalName', new Map<String,Object>{'oldValue'=>abnAccount[0].Legal_Name__c,'newValue'=>parsedData.agencyLegalName});
                    }

                    toInsertAccountMaintCase.Additional_Requirements__c = JSON.serialize(modValues);                       //CIAM
                    toInsertAccountMaintCase.Description  = description;
                    toInsertAccountMaintCase.Origin    = 'QAC Website';
                    toInsertAccountMaintCase.Type    = 'Agency Account';
                    toInsertAccountMaintCase.Sub_Type_1__c = 'Account Update';     
                    
                    system.debug('@@ Insert Case @@ ' + toInsertAccountMaintCase);                
                    insert toInsertAccountMaintCase;
                    
                    abnAccount[0].QAC_Request_Pending__c   = TRUE;
                    update abnAccount[0];
                    system.debug('QAC_Request_Pending__c: ' +abnAccount[0].QAC_Request_Pending__c);
                    toInsertAccountMaintCase   = [SELECT CaseNumber, Id FROM Case WHERE Id =: toInsertAccountMaintCase.Id];
                    myAgSecResp          = new QAC_AgencyProfileResponses.QACAgencyPrimaryDetailsResponse(toInsertAccountMaintCase.CaseNumber, 'Account Maintainance Case has been created', '200'); 
                    response.statusCode     = 200;
                    response.responseBody    = Blob.valueOf(JSON.serializePretty(myAgSecResp,True));
                }
                else if(!openCaseList.isEmpty() || abnAccount[0].QAC_Request_Pending__c)
                {
                    fieldErrors.add(new QAC_AgencyProfileResponses.FieldErrors('IsManualRequestPending', 'True'));
                    expectionResponse      = new QAC_AgencyProfileResponses.ExceptionResponse('412', 'One or more Open Account Maintenance Case(s) is available', fieldErrors); 
                    response.statusCode     = 412;
                    response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));
                }
            }
            
            /*
             * Preparing Appropriate Response, In case IATA is empty
             */
            else if(accountId == '' || accountId == null || string.isBlank(accountId)){
                fieldErrors.add(new QAC_AgencyProfileResponses.FieldErrors('Agency Code', 'Missing'));
                expectionResponse      = new QAC_AgencyProfileResponses.ExceptionResponse('400', 'Agency Code Not Provided in Header', fieldErrors); 
                response.statusCode     = 400;
                response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));
            }
            /*
             * Preparing Appropriate Response, In case IATA not Found
             */
            else if(abnAccount.Size() <=0) 
            {
                fieldErrors.add(new QAC_AgencyProfileResponses.FieldErrors('Agency Code', 'Not Existing'));
                expectionResponse      = new QAC_AgencyProfileResponses.ExceptionResponse('404', 'No TMC record Exists', fieldErrors); 
                response.statusCode     = 404;
                response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));
            }  
            else if(!openCaseList.isEmpty() || abnAccount[0].QAC_Request_Pending__c)
            {
                fieldErrors.add(new QAC_AgencyProfileResponses.FieldErrors('IsManualRequestPending', 'True'));
                expectionResponse      = new QAC_AgencyProfileResponses.ExceptionResponse('412', 'One or more Open Account Maintenance Case(s) is available', fieldErrors); 
                response.statusCode     = 412;
                response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true));
            }
              
        }
        
        /*
         * Checking Exceptions
         */
        Catch(Exception ex){
            string strException = ex.getStackTraceString();
            strException = strException.replace('QAC_AgencyPrimaryDetailsUpdate', '');
            fieldErrors.add(new QAC_AgencyProfileResponses.FieldErrors('Exception', strException));
            expectionResponse      = new QAC_AgencyProfileResponses.ExceptionResponse('500', 'Salesforce Internal Issue', fieldErrors); 
            response.statusCode     = 500;
            response.responseBody    = Blob.valueOf(JSON.serializePretty(expectionResponse, true)); 
        }
        
        finally
        {
            response.addHeader('Content-Type', 'application/json');
            CreateLogs.insertLogRec('Log Integration Logs Rec Type', 'QAC Tradesite - QAC_AgencyPrimaryDetailsUpdate', 'QAC_AgencyPrimaryDetailsUpdate',
                                    'QAC_AgencyPrimaryDetailsUpdate',(request.requestBody.toString().length() > 32768) ? request.requestBody.toString().substring(0,32767) : request.requestBody.toString(), String.valueOf(''), true,'', null);
        }
        
    }

}