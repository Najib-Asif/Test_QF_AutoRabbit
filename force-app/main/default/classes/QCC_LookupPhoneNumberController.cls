/*----------------------------------------------------------------------------------------------------------------------
Author:        Sherin Yohannan
Company:       Accenture
Description:   Lookup Phone Number Controller
Inputs:
Test Class:    QCC_LookupPhoneNumberControllerTest 
************************************************************************************************
History
************************************************************************************************
 
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_LookupPhoneNumberController {
    private static String ffTier;
    private static String ffTierSF;
    private static String ffNum;
    private static Map<String, String> countryCodeMap = new Map<String, String>();
    private static Boolean isNameMismatch = false;
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    lookupCustomer
    Description:    Search for the Customer in CAP CRE / Updated to Loyalty Jira CRM-5595
    Parameter:      String, String    
    Return:         String    
    ----------------------------------------------------------------------------------------------*/
	@AuraEnabled
    public static List<String> lookupCustomer(String ffNumber, String PhNumber, String capId){
        List<String> returnVal = new List<String>();
        try {
            Id contactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
            List<Contact> conph = new List<Contact>();
            ffNumber = QCC_GenericUtils.doTrim(ffNumber);
            ffNumber = ffNumber.replaceFirst('^0+','');
            PhNumber = QCC_GenericUtils.doTrim(PhNumber);
            Contact con = new Contact();
            con.Frequent_Flyer_Number__c = ffNumber;
            con.MobilePhone = PhNumber;
            con.CAP_ID__c = capId;
            if(ffNumber <> '' && ffNumber <> null){
            QCC_CustomerDetailsRequest requestBody = QCC_CustomerSearchHandler.searchHelper(con,'');
            //CRM-6427: CIP Decommissioning
            //QCC_CustomerDetailsResponse.Response response = QCC_InvokeCAPAPI.invokeCustomerDetailCAPAPI(requestBody);
           QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(requestBody.qantasFFNo);
           //CRM-6835: INC2278556 - flight event with nil passengers
           //QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact loyaltyContactResponse = QCC_InvokeCAPAPI.invokeLoyaltyContactAPI(requestBody.qantasFFNo);

           //if(response == null || response.customers == null || response.customers.size() == 0) 
           //CRM-6835: INC2278556 - flight event with nil passengers
            //if(loyaltyContactResponse == null) 
            if(loyaltyProfileResponse == null) 
            {
                return null;
            }
            //QCC_CustomerDetailsResponse.Customer customer;
            if(String.isBlank(capId)) {
                
                //customer = getValidCustomer(ffNumber,null, response);
                //if(customer == null) {
                loyaltyProfileResponse = getValidCustomer(ffNumber,null,loyaltyProfileResponse);
                if(loyaltyProfileResponse == null) {
                    return null;
                }
            } else {
                //customer = response.customers[0].customer;
                loyaltyProfileResponse = loyaltyProfileResponse;
            }
            if(PhNumber <> '' && PhNumber <> null){
                    conph = [Select Id from contact 
                             where frequent_flyer_number__c = :ffNumber and RecordTypeId = :contactTypeId and (MobilePhone = :PhNumber or Business_Phone__c = :PhNumber or HomePhone = :PhNumber or  OtherPhone = :PhNumber or Phone = :PhNumber or QCC_Travel_SMS__c = :PhNumber)];
                    
             }
                
             if(conph.size() <> 0 || PhNumber == '' || PhNumber == null) {
				//String returncus =  JSON.serialize(getCustomerInfo(ffNumber, customer)).replaceALL('type_x', 'type');
				String returncus =  JSON.serialize(getCustomerInfo(ffNumber,  loyaltyProfileResponse)).replaceALL('type_x', 'type');
                 if(returncus == 'null' || returncus == ''){
                    return null;
                 }else{
                     returnVal.add(returncus);return returnVal;
                 }
             }else{
                    return null;
             }
             } else if (PhNumber <> '' && PhNumber <> null){
                 List<Contact> customer = [Select Id,firstName,lastName,CAP_ID__c,frequent_flyer_number__c,
                                          frequent_flyer_tier__c,MobilePhone from contact 
                                          where RecordTypeId = :contactTypeId and (MobilePhone = :PhNumber or Business_Phone__c = :PhNumber or 
                                          HomePhone = :PhNumber or OtherPhone = :PhNumber or Phone = :PhNumber 
                                          or QCC_Travel_SMS__c = :PhNumber)];
                 List<String> cwList = new List<String>();
                for(Contact cust:customer){
                    CustomerWrapper cw = new CustomerWrapper();
                    cw.Id = cust.Id;
            		cw.firstName = cust.firstName;
            		cw.lastName = cust.lastName;
       				cw.capId = cust.CAP_ID__c;
        			cw.ffNumber = cust.frequent_flyer_number__c;
        			cw.ffTier = cust.frequent_flyer_tier__c;
               
        			List<displayColumn> listColumn = new List<displayColumn>();
        			cw.displayColumn = listColumn;
        			cwList.add(JSON.serialize(cw).replaceALL('type_x', 'type'));
                }
                return cwList;
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Lookup Frequent Flyer', 'QCC_LookupFrequentFlyerController', 
                                    'lookupCustomer', '', '', false,'', ex);
        }
        return null;
    }
    
    @AuraEnabled
    public static Contact saveIt(Contact contact) {
        try {
            contact = QCC_CustomerSearchHandler.saveCAPContact(contact);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        return contact;
        
    }
    /*----------------------------------------------------------------------------------------------      
    Method Name:    getValidCustomer
    Description:    Checks and returns the valid customer
    Parameter:      String, String, QCC_CustomerDetailsResponse.Response/loyaltyProfileResponse Jira CRM-5595    
    Return:         QCC_CustomerDetailsResponse.Customer    
    ----------------------------------------------------------------------------------------------*/
    private static QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile getValidCustomer(String ffNumber, String lastname,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse) {
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTier = QCC_InvokeCAPAPI.invokeLoyaltyTierAPI(ffNumber);
        Boolean isValid = false;
        isNameMismatch = false;
        String loyaltyProfileMap;
            if(loyaltyProfileResponse != null) {
                if(loyaltyTier != null) {
                   // Map<String, QCC_CustomerDetailsResponse.LoyaltyDetails> loyaltyMap = new Map<String, QCC_CustomerDetailsResponse.LoyaltyDetails>();
                   loyaltyProfileMap=loyaltyProfileResponse.memberId.replaceFirst('^0+','');
                        system.debug('member Id'+loyaltyProfileResponse);
                            ffNum = loyaltyProfileResponse.memberId;
                             if(String.isNotBlank(loyaltyTier.qantasFrequentFlyerTier.tierType)){
                                    ffTier = loyaltyTier.qantasFrequentFlyerTier.tierType;
                                    System.debug('FF Tier == '+ffTier);
                                    ffTierSF = CustomSettingsUtilities.getConfigDataMap(loyaltyTier.qantasFrequentFlyerTier.tierType);
                                    System.debug('FF TierSF == '+ffTierSF);
                                }
                    system.debug('loyaltyMap###'+ loyaltyProfileMap);
                    system.debug('ffNumber####'+ffNumber);
                            
                        
                    
                    isValid = true;
                }
               
            }
            
        system.debug('customer####'+loyaltyProfileResponse);
        system.debug('isValid####'+isValid);
        loyaltyProfileResponse = isValid ? loyaltyProfileResponse : null;
        return loyaltyProfileResponse;
    }
    /*private static QCC_CustomerDetailsResponse.Customer getValidCustomer(String ffNumber, String lastName,QCC_CustomerDetailsResponse.Response response) {
        QCC_CustomerDetailsResponse.Customer customer;
        Boolean isValid = false;
        isNameMismatch = false;
        for(QCC_CustomerDetailsResponse.Customers cust: response.customers) {
            customer = cust.customer;
            if(customer != null) {
                if(customer.loyaltyDetails != null && customer.loyaltyDetails.size() > 0) {
                    Map<String, QCC_CustomerDetailsResponse.LoyaltyDetails> loyaltyMap = new Map<String, QCC_CustomerDetailsResponse.LoyaltyDetails>();
                    for(QCC_CustomerDetailsResponse.LoyaltyDetails loyalty: customer.loyaltyDetails) {
                        loyaltyMap.put(loyalty.loyaltyId.replaceFirst('^0+',''), loyalty);
                        if(String.isNotBlank(loyalty.schemeOperatorCode)){
                            if(loyalty.schemeOperatorCode.equalsIgnoreCase('QF')){
                                ffNum = loyalty.loyaltyId;
                                if(String.isNotBlank(loyalty.airlineTierCode)){
                                    ffTier = loyalty.airlineTierCode;
                                    ffTierSF = CustomSettingsUtilities.getConfigDataMap(loyalty.airlineTierCode);
                                }
                            }
                        }
                    }
                    isValid = loyaltyMap.containsKey(ffNumber.replaceFirst('^0+',''));
                   }
               
            }
            
            if(isValid) {
                break;
            }
        }
        customer = isValid ? customer : null;
        return customer;
    }*/
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    getCustomerInfo
    Description:    Retrieves the required customer information
    Parameter:      String, QCC_CustomerDetailsResponse.Customer/ QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile Jira CRM-5595   
    Return:         CustomerWrapper    
    ----------------------------------------------------------------------------------------------*/
   // private static CustomerWrapper getCustomerInfo(String ffNumber,QCC_CustomerDetailsResponse.Customer customer) {
   private static CustomerWrapper getCustomerInfo(String ffNumber,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse) {
        CustomerWrapper cw = new CustomerWrapper();
       QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact loyaltyContactResponse = QCC_InvokeCAPAPI.invokeLoyaltyContactAPI(ffNumber);
        Id contactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        List<Contact> cont = [select Id from contact where frequent_flyer_number__c = :ffNumber and RecordTypeId = :contactTypeId];
        system.debug('sherin testing inside getcustomerInfo'+[select Id,frequent_flyer_number__c,RecordTypeId from contact]);
        system.debug('sherin testing inside getcustomerInfo2'+ffNum+contactTypeId);
        If(cont.size() <> 0){
                    cw.Id = cont[0].Id;
        }else{
            return null;
        }
        /*if(customer.Name != null) {
            cw.firstName = customer.Name.firstName;
            cw.lastName = customer.Name.lastName;
        }*/
       if(loyaltyProfileResponse.firstName != null && loyaltyProfileResponse.lastName != null ) {
            cw.firstName =loyaltyProfileResponse.firstName;
            cw.lastName = loyaltyProfileResponse.lastName;
        }
        //cw.capId = customer.qantasUniqueId;
        cw.ffNumber = ffNum;
        cw.ffTier = ffTier;
        cw.ffTierSF = ffTierSF;
        
        /*if(customer.Phone != null) {
            cw.displayPhone = getPhoneDetails(customer.Phone);
        }else{
            cw.displayPhone = getPhoneDetails(new List<QCC_CustomerDetailsResponse.Phone>());
        }*/
        if(loyaltyContactResponse.phones != null) { //CRM-5595
            cw.displayPhone = getPhoneDetails(loyaltyContactResponse.phones);
        }else{
            cw.displayPhone = getPhoneDetails(new List<QCC_LoyaltyResponseWrapper.Phones>());
        }
        
        
        /*if(customer.Address != null) {
            for(QCC_CAPCountryCodeMap__mdt codeData: [SELECT Label, Country_Code__c, Country_Name__c FROM QCC_CAPCountryCodeMap__mdt]) {
                countryCodeMap.put(codeData.Country_Code__c, codeData.Country_Name__c);
            }*/
       if(loyaltyContactResponse.addresses != null) {
            for(QCC_CAPCountryCodeMap__mdt codeData: [SELECT Label, Country_Code__c, Country_Name__c FROM QCC_CAPCountryCodeMap__mdt]) {
                countryCodeMap.put(codeData.Country_Code__c, codeData.Country_Name__c);
            }
            
           // for(QCC_CustomerDetailsResponse.Address thisAddress : customer.Address){
             //   String street = thisAddress.line1 + ' ' + thisAddress.line2 + ' ' + thisAddress.line3 + ' ' + thisAddress.line4;
              for(QCC_LoyaltyResponseWrapper.Addresses thisAddress :loyaltyContactResponse.addresses){
                String street = thisAddress.lineOne + ' ' + thisAddress.lineTwo;  
                //String suburb = thisAddress.suburb.trim();
                //String state = thisAddress.state.trim();
                //String postCode = thisAddress.postCode.trim();
                //String countryCode = thisAddress.country.trim();
                //String country = countryCodeMap.containsKey(countryCode) ? countryCodeMap.get(countryCode) : null;
                
               // if(String.isNotBlank(thisAddress.typeCode))
               if(String.isNotBlank(thisAddress.type_Z))
                {
                   /* if(thisAddress.typeCode.equalsIgnoreCase('H')){
                        cw.address = new Address(street, suburb, postCode, state, country);*/
                    if(thisAddress.type_Z.equalsIgnoreCase('H')){
                        cw.address = new Address(street);
                        break;
                    }
                    //else if(thisAddress.typeCode.equalsIgnoreCase('B')){
                      //  cw.address = new Address(street, suburb, postCode, state, country);
                      else if(thisAddress.type_Z.equalsIgnoreCase('B')){
                        cw.address = new Address(street);
                    }
                }
            }
        }
        
        /*if(customer.email != null){
            for(QCC_CustomerDetailsResponse.Email email : customer.email) {
                if(String.isNotBlank(email.emailId)) {
                    cw.email = email.emailId;
                    break;*/
       if(loyaltyContactResponse.emails!= null){
            for(QCC_LoyaltyResponseWrapper.emails email : loyaltyContactResponse.emails) {
                if(email != null) {
                    cw.email =  email.emailAddress;
                    break;
                }
            }
        }
        
        List<displayColumn> listColumn = new List<displayColumn>();
        listColumn.add(new displayColumn('Phone', 'phoneNumberWithType', 'text'));
        cw.displayColumn = listColumn;
        return cw;
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    getPhoneDetails
    Description:    Retrieves the phone details of the customer 
    Parameter:      List<QCC_CustomerDetailsResponse.Phone>   
    Return:         List<Phone>    
    ----------------------------------------------------------------------------------------------*/
    //private static List<Phone> getPhoneDetails(List<QCC_CustomerDetailsResponse.Phone> phonesRes) {
    private static List<Phone> getPhoneDetails(List<QCC_LoyaltyResponseWrapper.Phones> phonesRes) {
        List<Phone> phones = new List<Phone>();
        //for(QCC_CustomerDetailsResponse.Phone thisPhone : phonesRes) {
        for(QCC_LoyaltyResponseWrapper.Phones thisPhone : phonesRes) {
            Phone ph = new Phone();
            String phoneNumber;
            /*if(String.isNotBlank(thisPhone.phoneCountryCode)){
                phoneNumber = thisPhone.phoneCountryCode;
            }*/
            if(String.isNotBlank(thisPhone.countryCode)){
                phoneNumber = thisPhone.countryCode;
            }
            /*if(String.isNotBlank(thisPhone.phoneAreaCode)){
                phoneNumber = String.isBlank(phoneNumber) ? thisPhone.phoneAreaCode : phoneNumber + thisPhone.phoneAreaCode;
            }*/
            if(String.isNotBlank(thisPhone.areaCode)){
                phoneNumber = String.isBlank(phoneNumber) ? thisPhone.areaCode : phoneNumber + thisPhone.areaCode;
            }
            /*if(String.isNotBlank(thisPhone.phoneLineNumber)){
                phoneNumber = String.isBlank(phoneNumber) ? thisPhone.phoneLineNumber : phoneNumber + thisPhone.phoneLineNumber;
            }*/
            if(String.isNotBlank(thisPhone.number_Z)){
                phoneNumber = String.isBlank(phoneNumber) ? thisPhone.number_Z : phoneNumber + thisPhone.number_Z;
            }
            
            // phoneIds have been given to sort the list in desired order. The order is Home - Business - Other - Additional Phone Number
            //if(String.isNotBlank(thisPhone.typeCode) && String.isNotBlank(phoneNumber)){
            if(String.isNotBlank(thisPhone.type_Z) && String.isNotBlank(phoneNumber)){
                ph.phoneNumber = phoneNumber.trim();
               // if (thisPhone.typeCode.equalsIgnoreCase('B')) {
               if (thisPhone.type_Z.equalsIgnoreCase('B')) {
                    ph.phoneType = 'Business';
                    ph.phoneId = 1;
                //}else if (thisPhone.typeCode.equalsIgnoreCase('H')){
                }else if (thisPhone.type_Z.equalsIgnoreCase('H')){
                    ph.phoneType = 'Home';
                    ph.phoneId = 0;
                }else{
                    ph.phoneType = 'Other';
                    ph.phoneId = 2;
                }
                ph.phoneNumberWithType = ph.phoneType + ': ' + ph.phoneNumber;
                ph.label = ph.phoneNumberWithType;
                ph.value = ph.phoneNumberWithType;//ph.phoneNumber;
                phones.add(ph);
            }
        }
        // This is to show an additional option to the User for entering a Phone number manually
        phones.add(new Phone('','','',Label.QCC_AdditionalPhoneLabel,'additional'));
        phones.sort();
        return phones;
    }
    
    // Wrapper class used to display the columns on the lightning component
    public class displayColumn{
        public String label{get;set;}
        public String fieldName{get;set;}
        public String type_x{get;set;}

        public displayColumn(String label, String fieldName, String inputType){
            this.label = label;
            this.fieldName = fieldName;
            this.type_x = inputType;
        }
    }
    
    public class Phone implements Comparable{
        public Integer phoneId;
        public String phoneType;
        public String phoneNumber;
        public String phoneNumberWithType;
        public String label;
        public String value;
        
        public Phone() {
            
        }
        
        public Phone(String phoneType, String phoneNumber, String phoneNumberWithType, String label, String value) {
            this.phoneType = phoneType;
            this.phoneNumber = phoneNumber;
            this.phoneNumberWithType = phoneNumberWithType;
            this.label = label;
            this.value = value;
            if(value == 'additional') {
                this.phoneId = 3;
            }
        }
        
        // Sorts the custom list based on phoneId field
        public Integer compareTo(Object compareTo) {
            Phone compareToPhone = (Phone)compareTo;
            if (phoneId == compareToPhone.phoneId) return 0;
            if (phoneId > compareToPhone.phoneId) return 1;
            return -1;        
        }
    }
    
    public class Address {//CRM-5595 
        String street;
       /* String suburb;
        String postCode;
        String state;
        String country;*/
        
        //public Address(String street, String suburb, String postCode, String state, String country) {
         public Address(String street) {//CRM-5595 
            this.street = street;
           // this.suburb = suburb;
            //this.postCode = postCode;
            //this.state = state;
            //this.country = country;
        }
    }
    
    
    
    public class CustomerWrapper {
        public List<displayColumn> displayColumn{get;set;}
        public String Id{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String ffNumber{get;set;}
        public String email{get;set;}
        public String capId{get;set;}
        public String ffTier{get;set;}
        public List<Phone> displayPhone{get;set;}
        public Address address{get;set;}
        public String ffTierSF{get;set;}
    }
}