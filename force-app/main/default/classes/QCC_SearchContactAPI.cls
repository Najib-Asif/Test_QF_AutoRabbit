/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Rest API Request Apex to create update Passenger and contact
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
11-June-2018      	Praveen Sampath				Initial Design
23-March-2023		Leslie Padilla				ADT-140: Updating current case creation logic across channels to ensure that "not null" Contact is attached 
												if 4pt ID is provided (FirstName, LastName, Email, Phone)
-----------------------------------------------------------------------------------------------------------------------*/
@RestResource(urlMapping='/QCCSearchContact')
global class QCC_SearchContactAPI {
    /*----------------------------------------------------------------------------------------------      
    Method Name:        searchContact
    Description:        Create Contact or Get the Correct contact
    Parameter:          FF Number, Last Name and isFF
    Return:             Contact ID
    ----------------------------------------------------------------------------------------------*/
    @HttpPost
    global static void searchContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try{
            String resBody;
            String reqBody = req.requestBody.toString();
            QCC_ContactWrapper conWrap =  (QCC_ContactWrapper) Json.deserialize(reqBody, QCC_ContactWrapper.class);
            Contact objCon = new Contact();
            if(conWrap != Null){
                if(conWrap.isFF){
                    objCon = QCC_GenericUtils.fetchContactForFFCase(conWrap);
                }else{
                    //ADT-140: Create Non FF contact
                    List<String> contactDetails = new List<String>();
                    contactDetails.add(reqBody);
                    String contactMappingSource = 'ContactWrapper_Field__c';
                    Map<String,Contact> allContactsMap = QCC_GenericUtils.getNonFFContactForCase(contactDetails, contactMappingSource);
                    //If all fields required to create a non ff contact are defined then non ff contact (RecordType = Individual) will return
                    if (!allContactsMap.isEmpty()) {
                        objCon = allContactsMap.values().get(0);
                    } else {//Otherwise, NULL contact (RecordType = Placeholder) will be created
                        objCon = QCC_GenericUtils.fetchContactForNonFFCase();
                    }
                }
                
            }
            // Inspect publishing result 
            if (objCon != Null) {
                res.statusCode = 200;
                ContactInfo con = new ContactInfo();
                con.conId = objCon.Id;
                con.msg = 'Success';
                resBody = Json.serialize(con);
            } 
            res.responseBody = Blob.valueOf(resBody); 
        }catch(Exception ex){
            res.statusCode = 400;
            ContactInfo con = new ContactInfo();
            con.msg = 'Error returned: '+ ex.getMessage();
            String resBody = Json.serialize(con);
            res.responseBody = Blob.valueOf(resBody); 
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer Search', 'QCC_SearchContactAPI', 
                                    'searchContact', String.valueOf(req), String.valueOf(res), true,'', ex);
        }
    }

    public class ContactInfo{
        public String conId;
        public String msg;
    }
}