/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay
Company:       TCS
Description:   RestAPI Business Logic Class exposed to QAC website for Creation of Accounts/Contacts/TMC/Cases in Salesforce
Test Class:    QAC_AccountServicesProcess_Test.   

*********************************************************************************************************************************
History
10-Dec-2017    Ajay               Initial Design

Modified Date   : 22/08/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4725
Version         : V2.0 - Added new field "Maintenance Date"

Modified Date   : 17/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4805
Version         : V3.0 - Added new field Tradesite and Contract Group

Modified Date   : 15/11/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-4058
Version         : V4.0 - Added Condition to check the duplicates against Contact Record Type OR Blank one

Modified Date   : 27/11/19 (DD/MM/YYYY)
Modified By     : Sobhan
JIRA            : TS-4863
Version         : V5.0 - Agency Manager Deduplication Logic

Modified Date   : 30/01/2020
Modified By     : Gnanavelu
Jira            : CRM-4161
Version         : V6.0 - Updated doACRCreation to copy contact's mobile to Related phone

Modified Date  : 13/03/2020
Modified By    : Vinothkumar Balasubramanian
Jira           : CRM-4252
Version        : V7.0 - Updated Case Status to Closed if the Sub Type 2 is Successful Registration
********************************************************************************************************************************/

@RestResource(urlMapping='/QACAcctServices/')
global with sharing class QAC_AccountServicesProcess 
{
    
    // Instance variables for Agency Registration process
    public static Boolean accountDuplicate = false;
    public static Boolean salesRegionRecord = false;
    public static Account createdAcc;
    public static Case createdCase;
    public static String responseJSON = '';
    //public static String comboABNQIC = '';
    public static String iata_or_tids_value='';
    public static String findObject = '';
    public static String srDesc = '';
    public static map<String,Contact> duplicateContMap = new map<String,Contact>();
    public static map<String,Account> duplicateAcctMap = new map<String,Account>();
    public static map<String,Account> existingAcctIATAMap = new map<String,Account>();
    public static list<Contact> newContactList = new list<Contact>();
    
    public static list<Agency_Info__c> newTMCList = new list<Agency_Info__c>();
    public static list<Account_Relation__c> newTAList = new list<Account_Relation__c>();
    public static list<AccountContactRelation> newACRList = new list<AccountContactRelation>();
  
  //New Changes JIRA:TS-4805
  public static String conGroupDesc = '';
  public static Boolean contractGroupRecord = false;
  //Changes ends JIRA:TS-4805
    
    // Set variables to check incoming duplicates from Agency Registration Site
    public static Set<String> incomingContactEmail = new Set<String>();
    public static Set<String> incomingContactFF = new Set<String>();
    public static Set<String> incomingContactLname = new Set<String>();
    public static Set<String> incomingContactFname = new Set<String>();
    public static Set<String> incomingContactPhone = new Set<String>();
    public static Set<String> incomingContactEmailLname = new Set<String>();
    public static Set<String> incomingTicketingIATA = new Set<String>();
    public static Set<String> incomingVerificationNumber = new Set<String>();
    
    @HttpPost
    global static void doAgencyRegistrationProcess()
    {
        // All Responses from Salesforce after processing
        QAC_Responses qacResp = new QAC_Responses();
        QAC_Responses.AccountResponse myAccResp;
        QAC_Responses.CaseResponse myCaseResp;
        QAC_Responses.TmcResponse myTmcResp;
        QAC_Responses.TaResponse myTaResp;
        QAC_Responses.ContactResponse myContResp;
        QAC_Responses.AcrResponse myAcrResp;
        QAC_Responses.ExceptionResponse myExcepResp;
        
        // some object responses are returned as lists after processing
        list<QAC_Responses.TmcResponse> myTmcRespList = new list<QAC_Responses.TmcResponse>();
        list<QAC_Responses.TaResponse> myTaRespList = new list<QAC_Responses.TaResponse>();
        list<QAC_Responses.ContactResponse> myContRespList = new list<QAC_Responses.ContactResponse>();
        list<QAC_Responses.AcrResponse> myAcrRespList = new list<QAC_Responses.AcrResponse>();
        
        // local variables for business logic
        String receivedReq;
        String jsonErrMessage;
        Boolean isException = false;
        Boolean accProcessSuccess;
        Boolean caseCreatedforAcc = false;
        String myDesc = '';
        String taDesc = '';
        Account existingAcc;
        Integer i = 0;
        
        // Getting REST JSON from Request and setting to Response codes
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        receivedReq = req.requestBody.toString();
        QAC_AccountServicesAPI.ContactDetails agencyContact = new QAC_AccountServicesAPI.ContactDetails();
        QAC_AccountServicesAPI.AccountDetail accRecResp; //JIRA:TS-2842
        
        try
        {
            system.debug(' @@ request 1 @@' +receivedReq);
            
            // to convert the received String into object
            QAC_AccountServicesAPI acApi = QAC_AccountServicesAPI.parse(receivedReq);
            
            // To Retrieve Agency information contact details
            // It will be used for Assigning Agency contact details
            // while creation of Account Maintainance Case
            if(acApi.agencyRegistration != null &&
               acApi.agencyRegistration.accountDetail != null &&
               acApi.agencyRegistration.AccountDetail.contactDetails != null)
            {
                for(QAC_AccountServicesAPI.ContactDetails eachCon : acApi.agencyRegistration.AccountDetail.ContactDetails)
                {
                    agencyContact = eachCon;
                    break;
                }   
            }
            
            // null check on all the valid object entries of JSON
            if(acApi.agencyRegistration != null)
            {
                if(acApi.agencyRegistration.accountDetail != null)
                {
                    system.debug(' @@ request 2 @@' +acApi.AgencyRegistration.AccountDetail); 
                    
                    // accRecResp is the account record details received from JSON
                    accRecResp = acApi.agencyRegistration.accountDetail; //JIRA:TS-2842
                    
                    // perform duplicate check on account records for ABN & QIC
                    accProcessSuccess = doAccountDuplicateCheck(accRecResp,qacResp);
                    if(!accProcessSuccess){
                        // if duplicate found send exception as response with 404 CODE
                        res.statusCode = 404;
                        responseJson += JSON.serializePretty(qacResp,true);
                        res.responseBody = Blob.valueOf(responseJson);
                        return;
                    }
                    
                    // perform duplicate check on contact records for last name, mobile and email
                    if(accRecResp.contactDetails != null){
                        //doContactDuplicateCheck(accRecResp);
                    }
                    system.debug('Duplicate on acc:'+accountDuplicate+' dup acc map**'+duplicateAcctMap);
                    
                    // if no duplicates are found in account, perform insertion and other objects insertion
                    if(!accountDuplicate)
                    {
                        // insert Account records
                        createdAcc = doAccountCreation(accRecResp,iata_or_tids_value);
                        findObject = 'Account';
                        insert createdAcc;
                        
                        // send account response
                        if(createdAcc.Id != null)
                        {
                            res.statusCode = 201;
                            myAccResp = new QAC_Responses.AccountResponse('201',
                                                                          accRecResp.referenceId,
                                                                          createdAcc.Id,
                                                                          accRecResp.iataCode,
                                                                          createdAcc.Tradesite__c,
                                                                          createdAcc.Active__c,
                                                                          //accRecResp.tidsCode,
                                                                          accRecResp.AgencyABN);
                            
                            qacResp.accountResponse = myAccResp;
                            
                            myDesc += 'Account Created Successfully -'+createdAcc.Name+'\n'+
                                'Reference Id -'+accRecResp.referenceId+'\n'+
                                'ABN -'+createdAcc.ABN_Tax_Reference__c+'\n'+
                                'IATA|TIDS -'+createdAcc.Qantas_Industry_Centre_ID__c+'\n';
                            myDesc += srDesc + '\n';
                            //New Changes JIRA:TS-4805
                            if(String.isNotBlank(accRecResp.contractGroup)){
                                myDesc += conGroupDesc + '\n';
                            }
                            //Changes ends JIRA:TS-4805
                            myDesc += '\n';
                        }
                        
                        // insert TMC records
                        if(accRecResp.tmcDetails != null)
                        {
                            for(QAC_AccountServicesAPI.TmcDetails tmcRecResp : accRecResp.tmcDetails){
                                if(tmcRecResp != null) {
                                    newTMCList.add(doTMCCreation(tmcRecResp,createdAcc));
                                }
                            }
                            // send tmc creation response
                            if(!newTMCList.isEmpty())
                            {
                                findObject = 'TMC';
                                insert newTMCList;
                                
                                for(Agency_info__c eachAgency : newTMCList){
                                    ++i;
                                    if(eachAgency.Id != null){
                                        
                                        String tmcRTName = (String.isBlank(eachAgency.Code__c)) ? 'Market Segment' : 'GDS';
                                        
                                        res.statusCode = 201;
                                        myTmcResp = new QAC_Responses.TmcResponse('201',i+'TMC record(s) Created Successfully',
                                                                                  eachAgency.Id,
                                                                                  tmcRTName);
                                        myTmcRespList.add(myTmcResp);
                                        
                                        myDesc += 'PCC:'+eachAgency.PCC__c +'|Record Type:'+tmcRTName+' - TMC Created Successfully'+'\n';
                                        myDesc += '\n';
                                    }
                                }
                                i=0;
                                qacResp.tmcResponses = myTmcRespList;
                            }
                        }
                        // send exception response if tmc is null
                        else{
                            myDesc += 'No TMC Details Found'+'\n';
                            myDesc += '\n';
                            
                            res.statusCode = 400;
                            jsonErrMessage = 'Issue with JSON Format on TMC Detail Structure. Please check your Payload';
                            myExcepResp = new QAC_Responses.ExceptionResponse('400',jsonErrMessage,
                                                                              'Exception Found','TMC Value Not Found');
                            qacResp.exceptionResponse = myExcepResp;
                        }
                        
                        // insert Ticketing Authority Details records
                        if(accRecResp.ticketingAuthorityDetails != null)
                        {
                            doTAExistsCheck(accRecResp.ticketingAuthorityDetails,createdAcc);
                            
                            for(QAC_AccountServicesAPI.TicketingAuthorityDetails taRecResp : accRecResp.ticketingAuthorityDetails){
                                if(taRecResp != null) {
                                    newTAList.add(doTicketingAuthorityCreation(taRecResp,createdAcc,existingAcctIATAMap));
                                    taDesc += fetchTADescription(taRecResp,existingAcctIATAMap);
                                }
                            }
                            
                            // send ta creation response
                            if(!newTAList.isEmpty())
                            {
                                findObject = 'Account Relations';
                                
                                List<Database.SaveResult> taResults = Database.insert(newTAList, false);                               
                                for(Integer it=0;it<taResults.size();it++)
                                {
                                    if(taResults.get(it).isSuccess())
                                    {
                                        res.statusCode = 201;
                                        myTaResp = new QAC_Responses.TaResponse('201',(it+1)+'TA record(s) Created Successfully',
                                                                                newTAList[it].Id,
                                                                                createdAcc.Qantas_Industry_Centre_ID__c,
                                                                                createdAcc.Name,
                                                                                accRecResp.ticketingAuthorityDetails[it].iataCode,
                                                                                accRecResp.ticketingAuthorityDetails[it].iataName
                                                                               );
                                        myTaRespList.add(myTaResp);
                                    }
                                    else if (!taResults.get(it).isSuccess())
                                    {
                                        // DML operation failed
                                        Database.Error error = taResults.get(it).getErrors().get(0);
                                        String failedDML = 'IATA Not found in Salesforce. Error Found:' + error.getMessage();
                                        
                                        myTaResp = new QAC_Responses.TaResponse('500',failedDML,
                                                                                null,
                                                                                null,
                                                                                null,
                                                                                accRecResp.ticketingAuthorityDetails[it].iataCode,
                                                                                accRecResp.ticketingAuthorityDetails[it].iataName
                                                                               );
                                        myTaRespList.add(myTaResp);
                                    }
                                    
                                }
                                
                                myDesc += taDesc+'\n';
                                qacResp.ticketingAuthorityResponses = myTaRespList;
                                
                            }
                        }
                        
                        // logic to check for duplicate contact, if found create acr else create contact
                        if(accRecResp.contactDetails != null)
                        {
                            for(QAC_AccountServicesAPI.ContactDetails contRecResp : accRecResp.contactDetails)
                            {
                                if(contRecResp != null) {
                                    String dupValues = contRecResp.firstname.toUppercase()+'_'+contRecResp.lastname.toUppercase() + '_' + contRecResp.email.toUppercase()+'_'+contRecResp.mobile;
                                    //New Changes JIRA:TS-3110
                                    contRecResp.keyContact = true;
                                    //changes ends JIRA:TS-3110
                                    if(contRecResp.verificationNumber=='')
                                    system.debug('contRecResp.verificationNumber'+contRecResp.verificationNumber);
                                    if(!duplicateContMap.isEmpty() 
                                       &&(duplicateContMap.containsKey(contRecResp.verificationNumber) || duplicateContMap.containsKey(dupValues))
                                     // && ((contRecResp.verificationNumber=='' && duplicateContMap.containsKey(dupValues)) ||
                                     //      (contRecResp.verificationNumber!='' && (duplicateContMap.containsKey(contRecResp.verificationNumber)||(duplicateContMap.containsKey(dupValues) && duplicateContMap.get(dupValues).verification_Number__c==null)))) 
                                       // || duplicateContMap.containsKey(contRecResp.frequentFlyerNumber))
                                      )
                                    {
                                        newACRList = doACRCreation(createdAcc,duplicateContMap,contRecResp);
                                        if(duplicateContMap.containsKey(dupValues))
                                        {
                                        Contact con = new contact();
                                        con.id=duplicateContMap.get(dupValues).id;
                                        con.Verification_Number__c=contRecResp.verificationNumber;
                                        newContactList.add(con);
                                        }
                                    }
                                    else{
                                        newContactList.add(doContactCreation(contRecResp,createdAcc));
                                    }
                                }
                            }
                            // insert Contact (or) ACR Records
                            if(!newContactList.isEmpty())
                            {
                                findObject = 'Contact';
                                upsert newContactList;
                                //send contact response
                                for(Contact eachContact : newContactList){
                                    ++i;
                                    if(eachContact.Id != null){
                                        res.statusCode = 201;
                                        myContResp = new QAC_Responses.contactResponse('201',i+'Contact(s) Created/Updated Successfully',
                                                                                       eachContact.Id,
                                                                                       eachContact.email,
                                                                                       eachContact.LastName,
                                                                                       eachContact.phone,
                                                                                       eachContact.verification_number__c);
                                        myContRespList.add(myContResp);
                                        
                                        myDesc += 'Contact Created Successfully - '+eachContact.LastName+'\n'+
                                            'Phone - '+eachContact.Phone+'\n'+
                                            'Email - '+eachContact.Email+'\n'+
                                            'Mobile - '+eachContact.MobilePhone+'\n'+
                                            'verificationNumber - '+eachContact.Verification_Number__c+'\n';
                                        myDesc += '\n';
                                    }
                                }
                                i=0;
                                qacResp.contactResponses = myContRespList;
                            }
                            
                            // Create ACR Records
                            if(!newACRList.isEmpty())
                            {
                                findObject = 'ACR';
                                insert newACRList;
                                // send acr response
                                for(AccountContactRelation eachACR : newACRList){
                                    ++i;
                                    if(eachACR.Id != null){
                                        res.statusCode = 201;
                                        myAcrResp = new QAC_Responses.acrResponse('201',i+'ACR Record(s) Created Successfully',
                                                                                  fetchACRDetails(eachACR.Id,'contact'),
                                                                                  fetchACRDetails(eachACR.Id,'account')
                                                                                 );
                                        myAcrRespList.add(myAcrResp);
                                        
                                        myDesc += 'ACR Created Successfully -'+fetchACRDetails(eachACR.Id,'contact')+'\n'+
                                            'Associated Account -'+fetchACRDetails(eachACR.Id,'account')+'\n';
                                        myDesc += '\n';
                                    }
                                }
                                i=0;
                                qacResp.acrResponses = myAcrRespList;
                            }
                        }
                        // send exception response if contact details are null
                        else{
                            myDesc += 'No Contact/ACR Details Found'+'\n';
                            myDesc += '\n';
                            
                            res.statusCode = 400;
                            jsonErrMessage = 'Issue with JSON Format on Contact Detail Structure. Please check your Payload';
                            myExcepResp = new QAC_Responses.ExceptionResponse('400',jsonErrMessage,
                                                                              'Exception Found','Contact Value Not Found');
                            qacResp.exceptionResponse = myExcepResp;
                        }
                        
                        // Create Case Record for new ABN
                        if(createdAcc.Id != null){
                            res.statusCode = 201;
                            myCaseResp = doCaseCreation(receivedReq, createdAcc, accRecResp, null, accountDuplicate, myDesc,agencyContact); //JIRA:TS-2842
                            qacResp.caseResponse = myCaseResp;
                            system.debug('QAC Response**'+qacResp);
                        }
                    }
                    // Account duplicate found, Create Case for failure scenario
                    else{
                        existingAcc = duplicateAcctMap.get(iata_or_tids_value);
                        
                        // account failed / duplicate response
                        res.statusCode = 409;
                        myAccResp = new QAC_Responses.AccountResponse('409',
                                                                      accRecResp.referenceId,
                                                                      '',
                                                                      accRecResp.iataCode,
                                                                      existingAcc.Tradesite__c,
                                                                      existingAcc.Active__c,
                                                                      //accRecResp.tidsCode,
                                                                      accRecResp.AgencyABN);
                        qacResp.accountResponse = myAccResp;
                        
                        // Case Creation record for duplicate ABN
                        myCaseResp = doCaseCreation(receivedReq, existingAcc, accRecResp, null, accountDuplicate,'',agencyContact); //JIRA:TS-2842
                        qacResp.caseResponse = myCaseResp;
                    }
                }
                // send exception response if account details are null
                else{
                    res.statusCode = 400;
                    jsonErrMessage = 'Issue with JSON Format on Account Detail Structure. Please check your Payload';
                    myExcepResp = new QAC_Responses.ExceptionResponse('400',jsonErrMessage,
                                                                      'Exception Found','Account Value Not Found');
                    qacResp.exceptionResponse = myExcepResp;
                    
                }
            }
            // send exception response if agency registration are null
            else{
                res.statusCode = 400;
                jsonErrMessage = 'Issue with JSON Format on Agent Registration Structure. Please check your Payload';
                myExcepResp = new QAC_Responses.ExceptionResponse('400',jsonErrMessage,
                                                                  'Exception Found','Agency Value Not Found');
                qacResp.exceptionResponse = myExcepResp;
            }
            
            responseJson += JSON.serializePretty(qacResp,true);
            res.responseBody = Blob.valueOf(responseJson);
            res.addHeader('Content-Type', 'application/json');                      //CIAM
        }     
        /*catch(Exception ex)
        {
            // if exception found, update Logs for Exception details
            isException = true;
            system.debug('Exception we got'+ex);
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Tradesite - AccountServicesProcess', 'QAC_AccountServicesProcess',
                                    'doAgencyRegistrationProcess', (receivedReq.length() > 32768) ? receivedReq.substring(0,32767) : receivedReq, String.valueOf(''), true,'', ex);
            
            String sfErrMessage = ex.getMessage();
            
            if(ex.getMessage().contains(':')){
                sfErrMessage = ex.getMessage().substringAfter(':');
            }
            
            if(createdAcc != null && createdAcc.Id != null){
                res.statusCode = 201;
                myCaseResp = doCaseCreation(receivedReq, createdAcc, accRecResp, findObject, accountDuplicate,myDesc,agencyContact); //JIRA:TS-2842
                qacResp.caseResponse = myCaseResp;
            }
            else{
                res.statusCode = 400;   
            }
            
            // exception response for JSON and Non JSON Exceptions
            if(ex.getTypeName().contains('JSON')){
                jsonErrMessage = 'Issue with JSON Format. Please check your Payload';
            }
            else{
                jsonErrMessage = 'Found errors.Please contact Salesforce.';
                jsonErrMessage += (String.isNotBlank(findObject)) ? 'Registration Process Failed for - '+findObject : 'Registration Failed.';
            }
            
            myExcepResp = new QAC_Responses.ExceptionResponse(String.valueOf(res.statusCode),jsonErrMessage,
                                                              'Exception Found',sfErrMessage);
            qacResp.exceptionResponse = myExcepResp;
            
            // create case for exception response as well
            system.debug('QAC Response**'+qacResp);
            responseJson += JSON.serializePretty(qacResp,true);
            res.responseBody = Blob.valueOf(responseJson);
        }*/
        finally{
            // if no exception found, update Logs for Integration details
            if(!isException){
                CreateLogs.insertLogRec('Log Integration Logs Rec Type', 'QAC Tradesite - AccountServicesProcess', 'QAC_AccountServicesProcess',
                                        'doAgencyRegistrationProcess',(receivedReq.length() > 32768) ? receivedReq.substring(0,32767) : receivedReq, String.valueOf(''), true,'', null);
            }
        }
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doAccountDuplicateCheck
        Description:        Method for checking duplicates on Account
        Parameter:          QAC Account Service API - account Detail, QAC Response object
    --------------------------------------------------------------------------------------*/
    public static Boolean doAccountDuplicateCheck(QAC_AccountServicesAPI.AccountDetail accRecResp, QAC_Responses qacResp)
    {
        iata_or_tids_value = (String.isNotBlank(accRecResp.iataCode)) ? accRecResp.iataCode : (String.isNotBlank(accRecResp.tidsCode)) ? accRecResp.tidsCode : '';
        system.debug('iataCode / Tids value**'+iata_or_tids_value);
        
        //New Changes JIRA:TS-3111
        string billingCountryCode = accRecResp.countryCode;
        
        /* commenting out for Channel Story : TS-4218 
        if(billingCountryCode == 'AU' && (String.isBlank(iata_or_tids_value) || String.isBlank(accRecResp.agencyABN)))
        {
            qacResp.accountResponse = new QAC_Responses.AccountResponse('404','Error Found: tidsCode / iataCode (OR) ABN value is Incorrect');
            return false;
        }
        */
    if(String.isBlank(iata_or_tids_value))
        {
            qacResp.accountResponse = new QAC_Responses.AccountResponse('404','Error Found: tidsCode / iataCode is Incorrect');
            return false;
        }
        //changes ends JIRA:TS-3111
        else{
            //comboABNQIC = accRecResp.agencyABN + '_' + iata_or_tids_value;
            for(Account acc : [Select Id,Phone,Email__c,ABN_Tax_Reference__c,Qantas_Industry_Centre_ID__c,Active__c,Tradesite__c from Account where Qantas_Industry_Centre_ID__c =: iata_or_tids_value])
            {
                system.debug('acc ***'+acc);
                if(acc != null && String.isNotBlank(acc.Qantas_Industry_Centre_ID__c)){
                    duplicateAcctMap.put(acc.Qantas_Industry_Centre_ID__c,acc);
                }
            }
            if(duplicateAcctMap.containskey(iata_or_tids_value))
                accountDuplicate = true;
        }
        return true;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doTAExistsCheck
        Description:        Method for checking Ticketing Authority Account available in Salesforce
        Parameter:          QAC Account Service API - account Detail, QAC Response object
    --------------------------------------------------------------------------------------*/
    public static void doTAExistsCheck(list<QAC_AccountServicesAPI.TicketingAuthorityDetails> taList, Account newAccount)
    {
        for(QAC_AccountServicesAPI.TicketingAuthorityDetails eachTA : taList){
            if(eachTA != null && String.isNotBlank(eachTA.iataCode)){
                incomingTicketingIATA.add(eachTA.iataCode);
            }
        }
        
        for(Account oldAccount : [SELECT id,Qantas_Industry_Centre_ID__c from Account where Qantas_Industry_Centre_ID__c in: incomingTicketingIATA]){
            if(oldAccount != null){
                existingAcctIATAMap.put(oldAccount.Qantas_Industry_Centre_ID__c,oldAccount);
            }
        }
        //incomingTicketingIATA.removeAll(existingAcctIATAMap.keyset());
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doContactDuplicateCheck
        Description:        Method for checking duplicates on Contact
        Parameter:          QAC Account Service API - account Detail
    --------------------------------------------------------------------------------------*/
    public static void doContactDuplicateCheck(QAC_AccountServicesAPI.AccountDetail accRecResp)
    {
        //Changes Starts CRM-4058
        String conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
      //Changes ends CRM-4058
        for(QAC_AccountServicesAPI.ContactDetails contRecResp : accRecResp.ContactDetails)
        {
            incomingContactEmail.add(contRecResp.email.toUppercase());
            incomingContactLname.add(contRecResp.lastName.toUppercase());
            incomingContactFname.add(contRecResp.firstName.toUppercase());
            incomingContactEmailLname.add(contRecResp.firstName.toUppercase()+'_'+contRecResp.lastName.toUppercase()+'_'+contRecResp.email.toUppercase()+'_'+contRecResp.mobile);
            incomingContactPhone.add(contRecResp.mobile);
            incomingContactFF.add(contRecResp.frequentFlyerNumber);
            if(String.isNotBlank(contRecResp.verificationNumber))
            incomingVerificationNumber.add(contRecResp.verificationNumber);
        }
        
        // commenting FF Conditions as Incoming FF wont be coming from Digital Team for Release 1.
        //New Changes JIRA:CRM-4058 (Added the RecordType on the below Query and where Condition
        for(Contact cont : [Select Id,FirstName,LastName,Email,MobilePhone,Verification_Number__c,QAC_Contact__c,Frequent_Flyer_Number__c,AccountId,RecordTypeId from Contact where  RecordTypeId =: conRTId AND QAC_Contact__c='Yes' AND ((Email IN: incomingContactEmail AND FirstName IN: incomingContactFname AND LastName IN: incomingContactLname AND MobilePhone IN: incomingContactPhone) OR Verification_Number__c IN:incomingVerificationNumber) /* OR Frequent_Flyer_Number__c IN: incomingContactFF */])
        {
        //Changes ends CRM-4058   
            if(cont != null){
                String dupCheckCombo = cont.FirstName.toUppercase()+'_'+cont.LastName.toUppercase() + '_' + cont.Email.toUppercase()+'_'+cont.MobilePhone +':'+ cont.Id;
                String dupCheckVerificationNumber = cont.verification_Number__c + ':' + cont.Id;
                //String dupCheckFF = cont.Frequent_Flyer_Number__c + ':' + cont.Id;
                if(cont.Verification_Number__c!=null){
                    duplicateContMap.put(cont.Verification_Number__c,cont);
                }else
                {
                    duplicateContMap.put(dupCheckCombo.split(':')[0],cont);
                }
                
            }
        }
        
        system.debug('dup Map 2**'+duplicateContMap);
    }

    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doAccountCreation
        Description:        Method for inserting Account
        Parameter:          QAC Account Service API - account Detail, QIC
    --------------------------------------------------------------------------------------*/
    public static Account doAccountCreation(QAC_AccountServicesAPI.AccountDetail acc, String qic){
        
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        string conCatSiteRegion = 'QAC-';
        
        Account newAccount = new Account();
        newAccount.Active__c = TRUE;
        newAccount.Customer_Category__c = 'Industry - White';
        newAccount.Agency_Type__c = 'IATA Agent';
        newAccount.Industry = 'Travel';
    
        //New Changes JIRA:TS-4805
        //newAccount.Tradesite__c = TRUE; // handled it in agency secondary update api
        if(acc.tradesiteFlag == FALSE)
            newAccount.Tradesite__c = FALSE;
        else
            newAccount.Tradesite__c = TRUE;
        if(String.isNotBlank(acc.contractGroup)){
            newAccount.Contract_Group__c = getSalesRegion(acc.contractGroup);
            conGroupDesc += (!contractGroupRecord) ? 'Contract Group Name : '+acc.contractGroup+' is not found' :
            'Contract Group Name : '+acc.contractGroup;
        }
        //Changes ends JIRA:TS-4805
    
        newAccount.RCTI__c = String.isBlank(acc.bookingEngineAccess) ? TRUE : Boolean.valueOf(acc.bookingEngineAccess);
        newAccount.External_Reference_ID__c = acc.referenceID;
        newAccount.RecordTypeId = accRTId;
        newAccount.Name = acc.agencyName;
        newAccount.Legal_Name__c = acc.legalName;
        newAccount.ABN_Tax_Reference__c = acc.agencyABN;
        newAccount.Qantas_Industry_Centre_ID__c = qic;
        newAccount.IATA_Number__c = acc.iataCode;
        newAccount.Agency_TIDS_Number__c = acc.tidsCode;
        newAccount.Business_Type__c = acc.primaryAgencyBusiness;
        newAccount.BillingStreet = acc.agencyAddressLine1;
        newAccount.BillingCity = acc.city;
        //newAccount.BillingState = acc.stateCode;                      //CIAM
        newAccount.BillingCountryCode = acc.countryCode;
        newAccount.BillingPostalCode = acc.postalCode;
        newAccount.ShippingCountryCode = acc.countryCode;
        newAccount.ShippingStreet = acc.agencyAddressLine1;
        newAccount.ShippingCity = acc.city;
        //newAccount.ShippingState = acc.stateCode;                      //CIAM
        newAccount.ShippingPostalCode = acc.postalCode;
        //CIAM Change started for State and Region field update based on the length of the value coming from API
        if (String.isNotBlank(acc.stateCode) && acc.stateCode.length() == 2) {
            newAccount.BillingStateCode = acc.stateCode;
            newAccount.ShippingStateCode = acc.stateCode;
        } else {
            newAccount.BillingState = acc.stateCode;
            newAccount.ShippingState = acc.stateCode;
        }
        //CIAM Change ended for State and Region field update based on the length of the value coming from API
    
        //New Changes JIRA:TS-3110
        if(string.isNotBlank(acc.siteRegion))
            newAccount.AccountSource = conCatSiteRegion + acc.siteRegion;
        //changes ends JIRA:TS-3110
    
        //New Changes JIRA:TS-4725
        newAccount.Maintenance_Date__c = system.today();
        //changes ends JIRA:TS-4725
        
        if(String.isNotBlank(acc.employees))
            newAccount.NumberOfEmployees = Integer.valueOf(acc.employees);
        
        newAccount.Office_Type__c = acc.officeType;
        newAccount.Website = acc.website;
        newAccount.Email__c = acc.accountEmail;
        newAccount.E_Ticket__c = String.isBlank(acc.iataCode) ? FALSE : TRUE;
        
        newAccount.Agency_Sales_Region__c = fetchSalesRegion(acc.agencyChain);
        srDesc += (!salesRegionRecord) ? 'Sales Region Name : '+acc.agencyChain+' is not found' :
        'Sales Region Name : '+acc.agencyChain;
        newAccount.Agency_Sub_Chain__c = acc.agencySubChain;
        
        //New Changes JIRA:TS-3110
        // to replace special Characters in the String
        String regExp = '[\\-\\+\\.\\^:\\(\\),]';
        String replaceExp = '';
        
        // to Store Phone Area Code & Country Code
        String countryCode = '';
        String areaCode = '';
        String phoneCode = '';
        String myPhoneNumber = '';
        
        if(acc.PhoneNumber != null){
            myPhoneNumber = acc.phoneNumber.replaceAll(regExp,replaceExp);
            myPhoneNumber = myPhoneNumber.replaceAll(' ','');
            
            //countryCode = acc.phoneNumber.substringBefore('-');                                                           //CIAM
            countryCode = acc.phoneNumber.contains('-') ? acc.phoneNumber.substringBefore('-') : '';                        //CIAM
            areaCode = (acc.phoneNumber.substringBeforeLast('-').contains('-')) ? acc.phoneNumber.substringBetween('-') : '';
            //phoneCode = acc.phoneNumber.substringAfterLast('-');                                                      //CIAM
            phoneCode = acc.phoneNumber.contains('-') ? acc.phoneNumber.substringAfterLast('-') : acc.phoneNumber;      //CIAM
        }
        
        newAccount.Phone = myPhoneNumber;
        newAccount.Phone_Country_Code__c = countryCode;       
        //newAccount.Phone_Area__c = String.isBlank(areaCode) ? '' : areaCode.replaceAll(regExp,replaceExp);       
        areaCode = String.isBlank(areaCode) ? '' : areaCode.replaceAll(regExp,replaceExp);       
        newAccount.Phone_Number__c = areaCode + phoneCode;
        //Changes Ends JIRA:TS-3110
        
        if(acc.faxNumber != null){
            myPhoneNumber = acc.faxNumber.replaceAll(regExp,replaceExp);
            
            countryCode = acc.faxNumber.substringBefore('-');
            areaCode = (acc.faxNumber.substringBeforeLast('-').contains('-')) ? acc.faxNumber.substringBetween('-') : '';
            phoneCode = acc.faxNumber.substringAfterLast('-');
            newAccount.Fax_Country__c = countryCode;       
            newAccount.Fax_Area__c = String.isBlank(areaCode) ? '' : areaCode.replaceAll(regExp,replaceExp);       
            newAccount.Fax_Number__c = phoneCode;
        }
        
        //New Changes JIRA:TS-3287
        if(acc.abtaNumber != null)
            newAccount.ABTA_Number__c = acc.abtaNumber;
        
        if(acc.atolNumber != null)
            newAccount.ATOL_Number__c = acc.atolNumber;
        //Changes Ends JIRA:TS-3287
        
        //insert newAccount;
        system.debug('acc created:'+newAccount);
        return newAccount;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doContactCreation
        Description:        Method for inserting Contact
        Parameter:          QAC Account Service API - contact Details, newAccount
    --------------------------------------------------------------------------------------*/
    public static Contact doContactCreation(QAC_AccountServicesAPI.ContactDetails cont, Account newAccount){
        //Changes Starts CRM-4058
        String conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        //Changes ends CRM-4058 
        system.debug('inside contact**');
        Contact newContact = new Contact();
        //Changes Starts CRM-4058
        newContact.RecordTypeId = conRTId;
        //Changes ends CRM-4058 
        newContact.Business_Types__c = 'Agency';
        newContact.External_Reference_ID__c = cont.referenceID;
        newContact.AccountId = newAccount.Id;
        newContact.Salutation = cont.salutation;
        newContact.FirstName = cont.firstName;
        newContact.LastName = cont.lastName;
        newContact.Preferred_Name__c = cont.preferredName;
        newContact.Job_Title__c = cont.jobTitle;
        newContact.Function__c = String.isBlank(cont.jobFunction) ? 'Other' : cont.jobFunction;
        newContact.Frequent_Flyer_Number__c = cont.frequentFlyerNumber;  
        newContact.Job_Role__c = cont.jobRole;
        newContact.Email = cont.email;
        newContact.Phone = cont.phone;
        newContact.MobilePhone = cont.mobile;
        //New Changes JIRA:TS-3110
        newContact.Key_Contact__c = true;
        //Changes ends JIRA:TS-3110
        //insert newContact;
        newContact.QAC_Contact__c='Yes';
        newContact.Verification_Number__c=cont.verificationNumber;
        system.debug('cont values:'+newContact);
        return newContact;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doACRCreation
        Description:        Method for inserting ACR
        Parameter:          newAccount, dupContactMap, QAC Account Service API - contact Details
    --------------------------------------------------------------------------------------*/
    public static list<AccountContactRelation> doACRCreation(Account newAccount, map<String,Contact> dupContactMap, QAC_AccountServicesAPI.ContactDetails cont){
        
        list<AccountContactRelation> ACRList = new list<AccountContactRelation>();
        
        for(Contact eachDuplicate : dupContactMap.values()){
            AccountContactRelation newACR = new AccountContactRelation();
            newACR.AccountId = newAccount.Id;
            newACR.ContactId = eachDuplicate.Id;
            //newACR.IsDirect = false;
            newACR.IsActive = true;
            newACR.Job_Title__c = cont.JobTitle;
            newACR.Business_Type__c = 'Agency';
            newACR.Function__c = 'Other'; // need to check with business for this value
            newACR.Job_Role__c = cont.jobrole;
            //newACR.StartDate = Date.today(); // need to check
            //newACR.EndDate = Date.today().addDays(365); // need to check
            newACR.Related_Email__c = cont.email;
            newACR.Related_Phone__c = cont.mobile;
            //New Changes JIRA:TS-3110
            newACR.Key_Contact__c = true;
            //Changes ends JIRA:TS-3110
            //As part of JIRA:TS-4879
            newACR.Primary_Contact__c=true;
            ACRList.add(newACR);
        }
        
        system.debug('acr values:'+ACRList);
        return ACRList;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doTMCCreation
        Description:        Method for inserting TMC
        Parameter:          QAC Account Service API - TMC Details, newAccount
    --------------------------------------------------------------------------------------*/
    public static Agency_Info__c doTMCCreation(QAC_AccountServicesAPI.TMCDetails tmc, Account newAccount){
        
        string RTName = tmc.RecordType;
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
        
        system.debug('inside tmc**');
        Agency_Info__c newTMC = new Agency_Info__c();
        newTMC.Account__c = newAccount.Id;
        newTMC.External_Reference_ID__c = tmc.referenceID;
        newTMC.RecordTypeId = tmcRTId;
        newTMC.Code__c = tmc.gdsCode;
        newTMC.PCC__c = tmc.pseudoCityCode;
        
        system.debug('tmc values:'+newTMC);
        return newTMC;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doTicketingAuthorityCreation
        Description:        Method for inserting Account Relation object
        Parameter:          QAC Account Service API - TA Details, newAccount, existingAccount
    --------------------------------------------------------------------------------------*/
    public static Account_Relation__c doTicketingAuthorityCreation(QAC_AccountServicesAPI.TicketingAuthorityDetails ta, Account newAccount, map<String,Account> existingAccount){
        
        system.debug('inside ta**');
        Account_Relation__c newTA = new Account_Relation__c();
        
        if(!existingAccount.isEmpty() && existingAccount.get(ta.iataCode) != null)
            newTA.Related_Account__c = existingAccount.get(ta.iataCode).Id;
        
        newTa.Primary_Account__c = newAccount.Id;
        newTA.Active__c = true;
        newTA.Start_Date__c = system.today();
        newTA.Relationship__c = 'Ticketed by';
        
        system.debug('ta values:'+newTA);
        return newTA;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doCaseCreation
        Description:        Method for inserting Case
        Parameter:          json , myAccount, exceptionObject, accountDuplicate, myDesc
        //JIRA:TS-2842
    --------------------------------------------------------------------------------------*/
    public static QAC_Responses.CaseResponse doCaseCreation(String json, Account myAccount, QAC_AccountServicesAPI.AccountDetail incomingReq, String exceptionObject, Boolean accountDuplicate, String myDesc, QAC_AccountServicesAPI.ContactDetails myContact){
        
        QAC_Responses.CaseResponse caseResp;
        String caseRTName, caseNum;
        string businessPhoneNumber;
        system.debug('inside case**'+myDesc);
        system.debug('Sales region found? '+salesRegionRecord);
        //String ABN_or_QIC = myAccount.ABN_Tax_Reference__c + ' | ' +myAccount.Qantas_Industry_Centre_ID__c;
        String mySubject = (!accountDuplicate) ? 'IATA/TIDS: '+myAccount.Qantas_Industry_Centre_ID__c+'.Registration Successful' :
                            'IATA/TIDS: '+myAccount.Qantas_Industry_Centre_ID__c+'..Duplicate Found, Registration Unsuccessful.';
        
        if(String.isNotBlank(exceptionObject)){
            myDesc += 'Exception found on :'+exceptionObject;
        }
        else{
            if(!accountDuplicate){
                myDesc += 'Please complete Registration process';
            }
            else{
                myDesc = '';
                myDesc += 'Account Creation Failed !'+'\n'+
                    'Duplicate IATA|TIDS Found ';
                //'Email has been sent to Agent.';
            }
        }
        
        Case newCase = new Case();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Maintenance').getRecordTypeId();
        newCase.AccountId = myAccount.Id;
        newCase.RecordTypeId = caseRTId;
        newCase.Subject = mySubject;
        newCase.Description = myDesc;
        
        //newCase.Status = (!accountDuplicate) ? 'New' : 'Closed';
        //Changes Start for CRM-4252
        //newCase.Status = (!accountDuplicate) ? 'New' : (myAccount.Active__c && myAccount.Tradesite__c && !salesRegionRecord) ? 'Closed' : 'New';
        newCase.Status = (myAccount.Active__c && salesRegionRecord) ? 'Closed' : 'New';
        // Changes end
        
        newCase.Type = 'Agency Account';
        newCase.Sub_Type_1__c = (!accountDuplicate) ? 'New Account' : 'Duplicate Account' ;
        newCase.Sub_Type_2__c = (accountDuplicate) ? 'Multiple agency accounts identified' : (salesRegionRecord == false) ? 'Sales Region mismatch' : 'Successful Registration';
        
        //newCase.Priority = (!accountDuplicate) ? 'High' : 'Low';
        newCase.Priority = (!accountDuplicate) ? 'High' : (myAccount.Active__c && myAccount.Tradesite__c) ? 'Low' : 'high';
        
        newCase.Origin = 'Web';
        newCase.Sales_Region__c = incomingReq.agencyChain;
        //newCase.Country__c = 'Australia'; //JIRA:TS-3382
        newCase.IATA__c = myAccount.Qantas_Industry_Centre_ID__c;
        newCase.ABN_Tax_Reference__c = incomingReq.agencyABN; //JIRA:TS-2842
        newCase.Consultant_Phone__c = myContact.Phone;
        newCase.Consultant_Email__c = myContact.Email;
        newCase.Justification__c = 'Justification is NA as this case is created for Agency Registration process';
        newCase.Consultants_Name__c = myContact.FirstName + ' ' + myContact.LastName;
        
        //New Changes JIRA:TS-2842
        businessPhoneNumber = incomingReq.dialCode + '-' + incomingReq.phoneNumber;
        if(businessPhoneNumber.length() <= 18)
        {
            newCase.Business_Phone_Number__c = businessPhoneNumber; 
        }
        else
        {
            businessPhoneNumber = businessPhoneNumber.substring(0, 18);
            newCase.Business_Phone_Number__c = businessPhoneNumber;
        }
        
        newCase.Email__c = incomingReq.accountEmail;
        //Changes Ends JIRA:TS-2842
        
        findObject = 'Case';
        insert newCase;
        
        system.debug(' @@ Case Id @@ ' + newCase.Id);
        
        if(newCase.Id != null){
            caseRTName = 'Account Maintenance';
            caseNum = fetchCaseNumber(newCase.Id);
            
            if(!newCase.Subject.contains('Duplicate'))
                caseResp = new QAC_Responses.CaseResponse('201','Case Created Successfully',caseNum,caseRTName,'Account Created Successfully');
            else
                caseResp = new QAC_Responses.CaseResponse('201','Case Created Successfully',caseNum,caseRTName,newCase.Subject);
            
            doFilesCreation(newCase,json);
        }
        return caseResp;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        doFilesCreation
        Description:        Method for inserting Files to Case
        Parameter:          myCase , json
    --------------------------------------------------------------------------------------*/
    public static void doFilesCreation(Case myCase, String myJson)
    {
        // Creating files using Content Version
        ContentVersion myVersion = new ContentVersion();
        myVersion.ContentLocation = 'S'; // indicates it is in Salesforce , Use 'E' if it is External
        myVersion.PathOnClient = 'Agency Registration Information.txt';
        myVersion.Title = 'Agency Registration Information';
        myVersion.VersionData = Blob.valueOf(myJson);
        insert myVersion;
        
        // Adding the Content Document from Content Version to the Files Related list
        Id ContentDocId = [Select ContentDocumentId from ContentVersion where Id =: myVersion.Id].ContentDocumentId;
        
        ContentDocumentLink myDocument = new ContentDocumentLink();
        myDocument.ContentDocumentId = ContentDocId;
        myDocument.LinkedEntityId = myCase.Id; // Parent id / Group Id for whichever person you want the file to be accessed
        myDocument.ShareType = 'I'; // I - record level access ; V - view file ; C - Edit file
        insert myDocument;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        fetchSalesRegion
        Description:        Method to fetch Sales Region
        Parameter:          sales region Name
  --------------------------------------------------------------------------------------*/
    public static Id fetchSalesRegion(String srName){
        Id srId;       
        if(String.isNotBlank(srName)){
            for(Sales_Region__c theRegion : [Select id from Sales_Region__c where Name =: srName]){
                if(theRegion != null){
                    srId = theRegion.Id;
                    salesRegionRecord = true;
                }
            }
        }
        system.debug('sr id**'+srId);
        return srId;
    }
  //New Changes JIRA:TS-4805
  /*--------------------------------------------------------------------------------------     
        Method Name:        getSalesRegion
        Description:        Method to get Sales Region for Contract Group
        Parameter:          sales region Name
  --------------------------------------------------------------------------------------*/
    public static Id getSalesRegion(String cgName){
        Id cgRecordId;       
        if(String.isNotBlank(cgName)){
            for(Sales_Region__c theRegion : [Select id from Sales_Region__c where Name =: cgName]){
                if(theRegion != null){
                    cgRecordId = theRegion.Id;
          contractGroupRecord = true;
                }
            }
        }
        system.debug('cgRecord id**'+cgRecordId);
        return cgRecordId;
    }
    //Changes Ends JIRA:TS-4805                                    
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        fetchCaseNumber
        Description:        Method to fetch Case Number
        Parameter:          caseId
  --------------------------------------------------------------------------------------*/
    public static String fetchCaseNumber(Id caseId){
        return [Select CaseNumber from Case where Id =: caseId].CaseNumber;
    }
    
    /*--------------------------------------------------------------------------------------     
        Method Name:        fetchTADescription
        Description:        Method to fetch Description for Ticket Authority Details
        Parameter:          QAC Account Service API - TA Details, existingAccount
  --------------------------------------------------------------------------------------*/   
    public static String fetchTADescription(QAC_AccountServicesAPI.TicketingAuthorityDetails ta, map<String,Account> existingAccount)
    {
        String thedesc = '';
        
        thedesc += 'Ticketing Authority Details:'+'\n';
        if(existingAccount.containsKey(ta.iataCode)){
            thedesc += 'IATA: '+ta.iataCode+'|IATA Name: '+ta.iataName+' - TA Created Successfully'+'\n';
        }
        else{
            thedesc += 'IATA: '+ta.iataCode+'|IATA Name: '+ta.iataName+' - TA Creation Failed'+'\n';
        }
        return thedesc;
    }
    
    /*--------------------------------------------------------------------------------------     
      Method Name:        fetchACRDetails
        Description:        Method to fetch ACR Details
        Parameter:          acrId, flag
    --------------------------------------------------------------------------------------*/
    public static String fetchACRDetails(Id acrId,String flag){
        if(flag == 'contact' && acrId != null)
            return [Select Contact.Name from AccountContactRelation where Id =: acrId].Contact.Name;
        else if(flag == 'account' && acrId != null)
            return [Select Account.Name from AccountContactRelation where Id =: acrId].Account.Name;
        return null;
    }
}