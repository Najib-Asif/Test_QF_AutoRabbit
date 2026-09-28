public class QCC_CAPCustomerDetailHelper{
    private static Integer expectedScore = 0;

    private static Map<String , QCC_CustomerDetailsResponse.Response> allResponses;
    private static Map<String , String> newOldIdMap;
    private static Map<String , Contact> newCidContact;
    private static Map<String , String> pIdCIdMap;
    private static List<Contact> capContacts;

    public static Map<String , Contact> getContacts(Map<String, List<QCC_CreatePassengerForEvents.CAPSearchWrapper>> paramsIn) {
        Map<String, Contact> ffNumToContactMap = new Map<String, Contact>();
        List<QCC_CreatePassengerForEvents.CAPSearchWrapper> wrappers = new List<QCC_CreatePassengerForEvents.CAPSearchWrapper>();
        
        for( String key : paramsIn.keySet()){
            wrappers.addAll(paramsIn.get(key));
           
        }
        List<String> lstffNumber = new List<String>();
        Map<String, Id> mapFFCon = new Map<String, Id>();
        for(QCC_CreatePassengerForEvents.CAPSearchWrapper searchWrap : wrappers){
            String ffNumber = searchWrap.ffNumber;
            String ffleadZero =  ffNumber.leftPad(10,'0');
            String ffNoleadZero =  ffNumber.replaceFirst('^0+','');
            lstffNumber.add(ffleadZero);
            lstffNumber.add(ffNoleadZero);    
        }
        system.debug('lstffNumber####'+lstffNumber);
        //GRAPHITE-932/1105: Add condition to only retrieve Individual Contacts to be attached to Passenger record.
        Id individualContactRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
        for(Contact objCon: [select id, Frequent_Flyer_Number__c from Contact where
                             Frequent_Flyer_Number__c IN: lstffNumber AND RecordTypeId =: individualContactRecTypeId]){
            mapFFCon.put(objCon.Frequent_Flyer_Number__c, objCon.Id);
        }
        system.debug('mapFFCon####'+mapFFCon);
        //CRM-7330: 201 SOQL limit fix
        String loyaltyToken = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        for(QCC_CreatePassengerForEvents.CAPSearchWrapper searchWrap : wrappers) {
            String ffNumber = searchWrap.ffNumber;
            String lastName = searchWrap.lastName;
            String capId = searchWrap.capId;
            String passengerId = searchWrap.passengerId;
            // Call CAP to retrieve Customer information
            //CRM-7330: 201 SOQL limit fix
            String result = QCC_LookupFrequentFlyerController.lookupCustomer(ffNumber, lastName, capId, loyaltyToken);
            system.debug('result$$$$'+result);
            if(result != null && result != 'NameMismatch') {
                QCC_LookupFrequentFlyerController.CustomerWrapper cw = (QCC_LookupFrequentFlyerController.CustomerWrapper)JSON.deserialize(result, QCC_LookupFrequentFlyerController.CustomerWrapper.Class);
                System.debug('CustomerWrapper###'+cw);
                List<QCC_LookupFrequentFlyerController.Phone> phoneList = cw.displayPhone;
                String phoneNumber;
                Boolean phoneSelected = false;
                
                // Phone number to be considered as below
                // Give priority to Other, if it doesn't exists then Home. If Home doesn't exists then Business
                for(QCC_LookupFrequentFlyerController.Phone ph: phoneList) {
                    if(ph.label.startsWith('Other')) {
                        System.debug('PhoneToBeSelected = '+ph);
                        phoneNumber = ph.value;
                        break;
                    } else if(!phoneSelected) {
                        phoneNumber = ph.value;
                        phoneSelected = true;
                    }
                }
                
                Contact con = new Contact();
                if(mapFFCon.containsKey(cw.ffNumber.leftPad(10,'0'))){
                    con.Id = mapFFCon.get(cw.ffNumber.leftPad(10,'0'));
                }
                else if(mapFFCon.containsKey(cw.ffNumber.replaceFirst('^0+',''))){
                    con.Id = mapFFCon.get(cw.ffNumber.replaceFirst('^0+',''));
                }
                system.debug('con###'+con);
                con.FirstName = cw.firstName;
                con.LastName = cw.lastName;
                con.Preferred_Email__c = cw.email;
                con.Preferred_Phone_Number__c = phoneNumber;
                con.Frequent_Flyer_Number__c = cw.ffNumber;
                con.Frequent_Flyer_Tier__c = cw.ffTierSF;
                con.CAP_ID__c = cw.capId;
                ffNumToContactMap.put(ffNumber,con);
                system.debug('ffNumToContactMap###'+ffNumToContactMap);
            }
        }
        system.debug('ffNumToContactMapOutside$$$$'+ffNumToContactMap);
        return ffNumToContactMap;
    }

}