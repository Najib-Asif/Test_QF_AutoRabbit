/*********************************************************************************
Name         : QCC_OpenAqireContactPageController
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 October 2019
Usages       : This is used to generate the Aqire URL for each contact and get the pop the contact record
*********************************************************************************/
public class QCC_OpenAqireContactPageController {
    public String aqireURL {get; set;}
    public String recordId {get; set;}
    public String tierCode {get; set;}
    public String ffNo {get; set;}
    public String callType {get; set;}
    public String PINStatus {get; set;}
    public String callerOrigin {get; set;}
    public String previousAgent {get; set;}
    public String DNIS {get; set;}
    public String IVRD {get; set;}

    public QCC_OpenAqireContactPageController(ApexPages.StandardController controller){
        
    }
    
    //@Purpose: This method generate the Aqire URL containing the frequent flyer number of the contact 
    //@input parameters:
    //	- None
    //@return type: PageReference
    public PageReference openAqire() {
        System.debug('QCC_OpenAqireContactPageController.openAqire');

        tierCode = Apexpages.currentPage().getParameters().get('paramTierCode');
        ffNo = Apexpages.currentPage().getParameters().get('paramFFNo');
        callType = Apexpages.currentPage().getParameters().get('paramCallType');
        PINStatus = Apexpages.currentPage().getParameters().get('paramPINStatus');
        callerOrigin = Apexpages.currentPage().getParameters().get('paramCallerOrigin');
        previousAgent = Apexpages.currentPage().getParameters().get('paramPreviousAgent');
        DNIS = Apexpages.currentPage().getParameters().get('paramDNIS');
        IVRD = Apexpages.currentPage().getParameters().get('paramIVRD');
        System.debug('ffNo: ' + ffNo);
        
        //Set the Aqire URL
        String url = Label.QCC_Aqire_Application_URL;
        aqireURL = url.replace('<FrequentFlyerNumber>', ffNo);
        System.debug('aqireURL: ' + aqireURL);
        
        //Get the contact record with Individual Contact record type based on the frequent flyer number
        Contact contactRecord;
        try {
            Id individualRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
            contactRecord = [
                SELECT Id, Frequent_Flyer_Number__c 
                FROM Contact 
                WHERE Frequent_Flyer_Number__c =: ffNo 
                AND RecordTypeId =: individualRecordTypeId
                LIMIT 1
            ];
        } catch(Exception ex) {
            contactRecord = null;
        }
        
        System.debug('contactRecord: ' + contactRecord);
        
        //Set the contact record Id
        if (contactRecord != null) {
            recordId = contactRecord.Id;
        } else {
            //Reset the recordId so that it will not pop up the same contact record if the user received more than 2 consecutive calls.
            recordId = null;
        }
        
        return null;
    }
}