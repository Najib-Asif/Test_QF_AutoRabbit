/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to update secondary details for My Agency Profile
* REST API : QAC_AgencySecondaryParsing

Modified Date   : 23/08/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4725
Version         : V2.0 - Added new field "Maintenance Date"
*/

@RestResource(urlmapping='/QACAgencySecondaryInfo/*')
global class QAC_AgencySecondaryDetailsUpdate
{
    public static String responseJSON = '';
    
    @HttpPatch
    global static void doSecondaryUpdate()
    {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        //QAC_AgencyProfileResponses qacAgResp = new QAC_AgencyProfileResponses();
        QAC_AgencyProfileResponses.QACAgencySecondaryDetailsResponse myAgSecResp;
        QAC_AgencyProfileResponses.ExceptionResponse myExcepResp;
        list<QAC_AgencyProfileResponses.FieldErrors> myFieldErrorRespList = new list<QAC_AgencyProfileResponses.FieldErrors>();
        
        try
        {
            String iataNumber = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            //QAC_AgencySecondaryParsing receivedRequest = new QAC_AgencySecondaryParsing(); 
            QAC_AgencySecondaryParsing receivedRequest = QAC_AgencySecondaryParsing.parse(request.requestBody.toString());
            system.debug('request @@'+receivedRequest);
            
            Account existingAccount;
            
            if(String.isNotBlank(iataNumber))
            {
                for(Account eachAccount : [Select Id, BillingState,Tradesite__c,ATOL_Number__c,ABTA_Number__c,                       //CIAM - Added Tradesite
                                           Business_Type__c,BillingStreet,BillingCity,BillingCountryCode,BillingPostalCode,
                                           Phone_Number__c,Phone_Country_Code__c,NumberOfEmployees,Email__c,ATAS__c,Website,Maintenance_Date__c //New Change JIRA:TS-4725 : Add Maintenance Date on this query
                                           from Account where Qantas_industry_centre_id__c =: iataNumber])
                {
                    existingAccount = eachAccount;
                }
                system.debug('existingAccount:'+existingAccount);
                if(existingAccount != null)
                {
                    if(receivedRequest.primaryAgencyBusiness != null)
                        existingAccount.Business_Type__c = receivedRequest.primaryAgencyBusiness;
                    
                    if(receivedRequest.tradesite != null)
                        existingAccount.Tradesite__c = receivedRequest.tradesite;

                    if(receivedRequest.agencyAddressLine1 != null)
                        existingAccount.BillingStreet = receivedRequest.agencyAddressLine1;
                    
                    if(receivedRequest.city != null)
                        existingAccount.BillingCity = receivedRequest.city;
                    
                    if(receivedRequest.stateCode != null)
                        existingAccount.BillingState = receivedRequest.stateCode;
                    
                    if(receivedRequest.countryCode != null)
                        existingAccount.BillingCountryCode = receivedRequest.countryCode;
                    
                    if(receivedRequest.postalCode != null)
                        existingAccount.BillingPostalCode = receivedRequest.postalCode;
                    
                    // to replace special Characters in the String
                    String regExp = '[\\-\\+\\.\\^:\\(\\)\\" ",]';
                    String regExpCountry = '[\\(\\)\\" ",]';
                    String replaceExp = '';
                    
                    // to Store Phone Area Code & Country Code
                    String countryCode = '';
                    String areaCode = '';
                    String phoneCode = '';
                    String myPhoneNumber = '';
                    String dialingCode = '';
                    List<string> listPhone;
                    
                    if(receivedRequest.PhoneNumber != null)
                    {
                        myPhoneNumber = receivedRequest.PhoneNumber.replaceAll(regExp,replaceExp);
                        myPhoneNumber = myPhoneNumber.replaceAll(' ', '');
                        existingAccount.Phone_Number__c = myPhoneNumber;
                    }
                    //Comment this code inorder to revert
                    if(receivedRequest.dialCode != null)
                    {
                        dialingCode = receivedRequest.dialCode.replaceAll(regExp,replaceExp);
                        dialingCode = dialingCode.replaceAll(' ', '');
                        existingAccount.Phone_Country_Code__c = dialingCode;
                    }
                    
                    if(receivedRequest.employees != null)
                        existingAccount.NumberOfEmployees = String.isNotBlank(receivedRequest.employees) ? Integer.valueOf(receivedRequest.employees) : null;
                    
                    if(receivedRequest.accountEmail != null)
                        existingAccount.Email__c = receivedRequest.accountEmail;
                    
                    if(receivedRequest.agencyWebSite != null)
                        existingAccount.Website = receivedRequest.agencyWebSite;
                    
                    if(receivedRequest.atasNumber != null)
                        existingAccount.ATAS__c = receivedRequest.atasNumber;
                    
                    if(receivedRequest.atolNumber != null)
                        existingAccount.ATOL_Number__c = receivedRequest.atolNumber;

                    if(receivedRequest.abtaNumber != null)
                        existingAccount.ABTA_Number__c = receivedRequest.abtaNumber;
					
					//New Changes JIRA:TS-4725
					if(receivedRequest.maintenanceDate != null)
                        existingAccount.Maintenance_Date__c = receivedRequest.maintenanceDate;
					//Changes Ended JIRA:TS-4725

                    update existingAccount;
                    
                    if(existingAccount.Id != null){
                        response.statusCode = 200;
                        myAgSecResp = new QAC_AgencyProfileResponses.QACAgencySecondaryDetailsResponse(existingAccount);
                        responseJson += JSON.serializePretty(myAgSecResp,true);
                        //qacAgResp.qacAgencySecondaryDetailsResponse = myAgSecResp;
                    }
                }
                else 
                {
                    response.statusCode = 404;
                    myFieldErrorRespList.add(new QAC_AgencyProfileResponses.FieldErrors('AccountId','Query Returned NULL in Salesforce'));
                    myExcepResp = new QAC_AgencyProfileResponses.ExceptionResponse('404','Agency does not exist in Salesforce',myFieldErrorRespList);
                    responseJson += JSON.serializePretty(myExcepResp);
                    //qacAgResp.exceptionResponse = myExcepResp;
                }
            }
            else
            {
                response.statusCode = 400;
                myFieldErrorRespList.add(new QAC_AgencyProfileResponses.FieldErrors('IATA_Number__c','Invalid Request'));
                myExcepResp = new QAC_AgencyProfileResponses.ExceptionResponse('400','Invalid IATA Number',myFieldErrorRespList);
                responseJson += JSON.serializePretty(myExcepResp);
                //qacAgResp.exceptionResponse = myExcepResp;
            }
            //responseJson += JSON.serializePretty(qacAgResp,true);
            response.responseBody = Blob.valueOf(responseJson);
        }
        catch(Exception ex)
        {
            system.debug(' @@ ' + ex.getMessage());
            response.statusCode = 500;
            string strException = ex.getStackTraceString();
            strException = strException.replace('QAC_AgencySecondaryDetailsUpdate', '');
            myFieldErrorRespList.add(new QAC_AgencyProfileResponses.FieldErrors('Exception',strException));
            myExcepResp = new QAC_AgencyProfileResponses.ExceptionResponse('500','Salesforce Internal Issue',myFieldErrorRespList);
            responseJson += JSON.serializePretty(myExcepResp);
            //qacAgResp.exceptionResponse = myExcepResp;
            response.responseBody = Blob.valueOf(responseJson);
        }
        finally{
            response.addHeader('Content-Type', 'application/json');                       //CIAM
        }
    }
}