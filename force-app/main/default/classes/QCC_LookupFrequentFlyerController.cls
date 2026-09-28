/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Lookup Frequent Flyer Controller
Inputs:
Test Class:    QCC_LookupFrequentFlyerControllerTest 
************************************************************************************************
History
************************************************************************************************
31-July-2018             Purushotham B          Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_LookupFrequentFlyerController {
    private static String ffTier;
    private static String ffTierSF;
    private static String ffNum;
    private static Map<String, String> countryCodeMap = new Map<String, String>();
    private static Boolean isNameMismatch = false;
    

/*----------------------------------------------------------------------------------------------      
Method Name:    lookupCustomer
Description:    Search for the Customer in CAP CRE, CRM-7330: 201 SOQL limit fix
Parameter:      String, String    
Return:         String    
----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String lookupCustomer(String ffNumber, String lastName, String capId) {
       return lookupCustomer(ffNumber, lastName, capId, null);
    }

    /*----------------------------------------------------------------------------------------------      
Method Name:    lookupCustomer
Description:    Search for the Customer in CAP CRE,  CRM-7330: 201 SOQL limit fix
Parameter:      String, String    
Return:         String    
----------------------------------------------------------------------------------------------*/
    //@AuraEnabled
    public static String lookupCustomer(String ffNumber, String lastName, String capId, String loyaltyToken){
        try {
            ffNumber = QCC_GenericUtils.doTrim(ffNumber);
            lastName = QCC_GenericUtils.doTrim(lastName);
            Contact con = new Contact();
            con.Frequent_Flyer_Number__c = ffNumber;
            con.LastName = lastName;
            con.CAP_ID__c = capId;
            QCC_CustomerDetailsRequest requestBody = QCC_CustomerSearchHandler.searchHelper(con,'');
            
           // QCC_CustomerDetailsResponse.Response response = QCC_InvokeCAPAPI.invokeCustomerDetailCAPAPI(requestBody);
             System.debug('requestBody' + requestBody.qantasFFNo);
             //CRM-7330: 201 SOQL limit fix
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(requestBody.qantasFFNo, loyaltyToken); 
            system.debug('loyaltyProfileResponse'+loyaltyProfileResponse);
            //CRM-6835: INC2278556 - flight event with nil passengers
           // QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTierResponse = QCC_InvokeCAPAPI.invokeLoyaltyTierAPI(requestBody.qantasFFNo);
            //system.debug('loyaltyTierResponse'+loyaltyTierResponse);
           
            //if(response == null || response.customers == null || response.customers.size() == 0) 
            if(loyaltyProfileResponse == null)
            {
                return null;
            }
            //system.debug('response======'+response);
            //QCC_CustomerDetailsResponse.Customer customer;
            system.debug('LoyaltyProfileResponse======'+loyaltyProfileResponse);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfile;
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTier;
            system.debug('loyaltyProfile'+loyaltyProfile);
            if(String.isBlank(capId)) {
                system.debug('ffNumber======'+ffNumber);
                system.debug('lastname======'+lastname);
                //system.debug('response======'+response);
                //customer = getValidCustomer(ffNumber, lastname, response);
                //system.debug('system======'+customer);
                system.debug('isNameMismatch======'+isNameMismatch);
                system.debug('loyaltyProfileResponse======'+loyaltyProfileResponse);
                //CRM-7330: 201 SOQL limit fix
                loyaltyProfile = getValidCustomer(ffNumber,lastname,loyaltyProfileResponse, loyaltyToken);
                system.debug('system======'+loyaltyProfile);
                
                //if(customer == null && !isNameMismatch) {
                if(loyaltyProfile == null && !isNameMismatch) {
                    return null;
                }
            } else {
                //customer = response.customers[0].customer;
                loyaltyProfile = loyaltyProfileResponse;
            }
            
            if(isNameMismatch) {
                return 'NameMismatch';
            }
            
            //return JSON.serialize(getCustomerInfo(ffNumber, customer)).replaceALL('type_x', 'type');
            //CRM-7330: 201 SOQL limit fix
            return JSON.serialize(getCustomerInfo(ffNumber, loyaltyProfile, loyaltyToken)).replaceALL('type_x', 'type');
        } catch(Exception ex) {
            system.debug('Exception###'+ex); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Lookup Frequent Flyer', 'QCC_LookupFrequentFlyerController', 
                                    'lookupCustomer', '', '', false,'', ex);
        }
        return null;
    }
  
      /*----------------------------------------------------------------------------------------------      
Method Name:    getValidCustomer
Description:    Checks and returns the valid customer
Parameter:      String, String, QCC_CustomerDetailsResponse.Response /Updated to Loyalty Response Jira CRM- CRM-7330: 201 SOQL limit fix   
Return:         QCC_CustomerDetailsResponse.Customer    
----------------------------------------------------------------------------------------------*/
private static QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile  getValidCustomer(String ffNumber, String lastName,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse) {
    return getValidCustomer(ffNumber, lastName, loyaltyProfileResponse, null);
}

    /*----------------------------------------------------------------------------------------------      
Method Name:    getValidCustomer
Description:    Checks and returns the valid customer
Parameter:      String, String, QCC_CustomerDetailsResponse.Response /Updated to Loyalty Response Jira CRM-5595    CRM-7330
Return:         QCC_CustomerDetailsResponse.Customer    
----------------------------------------------------------------------------------------------*/
    private static QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile  getValidCustomer(String ffNumber, String lastName,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse, String loyaltyToken) {
       //CRM-7330: 201 SOQL limit fix
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTier = QCC_InvokeCAPAPI.invokeLoyaltyTierAPI(ffNumber, loyaltyToken);
        Boolean isValid = false;
        isNameMismatch = false;
        String loyaltyProfileMap;
            if(loyaltyProfileResponse != null) {
                if(loyaltyTier != null) {
                       loyaltyProfileMap=loyaltyProfileResponse.memberId.replaceFirst('^0+','');
                       ffNum = loyaltyProfileResponse.memberId;
                       if(String.isNotBlank(loyaltyTier.qantasFrequentFlyerTier.tierType)){
                                ffTier = loyaltyTier.qantasFrequentFlyerTier.tierType;
                                ffTierSF = CustomSettingsUtilities.getConfigDataMap(loyaltyTier.qantasFrequentFlyerTier.tierType);
                                    System.debug('FF TierSF == '+ffTierSF);
                                }
                    system.debug('loyaltyMap###'+ loyaltyProfileMap);
                    system.debug('ffNumber####'+ffNumber);
                    system.debug('isValid####'+isValid);
                    isValid = true;
                }
                if(isValid && String.isNotBlank(lastName) && String.isNotBlank(loyaltyProfileResponse.lastName)) {
                    if(lastName.toUpperCase() != loyaltyProfileResponse.lastName.toUpperCase()) {
                        isNameMismatch = true;
                        isValid = false;
                    }
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
                                    System.debug('FF Tier == '+ffTier);
                                }
                            }
                        }
                    }
                    system.debug('loyaltyMap###'+loyaltyMap);
                    system.debug('ffNumber####'+ffNumber);
                    isValid = loyaltyMap.containsKey(ffNumber.replaceFirst('^0+',''));
                    system.debug('isValid####'+isValid);
                }
                if(isValid && String.isNotBlank(lastName) && customer.Name != null && String.isNotBlank(customer.Name.lastName)) {
                    if(lastName.toUpperCase() != customer.Name.lastName.toUpperCase()) {
                        isNameMismatch = true;
                        isValid = false;
                    }
                }
            }
            
            if(isValid) {
                break;
            }
        }
        system.debug('customer####'+customer);
        system.debug('isValid####'+isValid);
        customer = isValid ? customer : null;
        return customer;
    }*/
    
    /*----------------------------------------------------------------------------------------------      
Method Name:    getCustomerInfo
Description:    Retrieves the required customer information
Parameter:      String, QCC_CustomerDetailsResponse.Customer / Loyalty Response Jira CRM - 5595   
Return:         CustomerWrapper    
----------------------------------------------------------------------------------------------*/
    /*private static CustomerWrapper getCustomerInfo(String ffNumber,QCC_CustomerDetailsResponse.Customer customer) {
        system.debug('customer$$$$$'+customer);
        CustomerWrapper cw = new CustomerWrapper();
        if(customer.Name != null) {
            cw.firstName = customer.Name.firstName;
            cw.lastName = customer.Name.lastName;
        }
        cw.capId = customer.qantasUniqueId;
        cw.ffNumber = ffNum;
        cw.ffTier = ffTier;
        cw.ffTierSF = ffTierSF;
        system.debug('customer.Phone$$$$$'+customer.Phone);
        if(customer.Phone != null) {
            cw.displayPhone = getPhoneDetails(customer.Phone);
        }else{
            cw.displayPhone = getPhoneDetails(new List<QCC_CustomerDetailsResponse.Phone>());
        }
        
        system.debug('customer.Address$$$$$'+customer.Address);
        if(customer.Address != null) {
            for(QCC_CAPCountryCodeMap__mdt codeData: [SELECT Label, Country_Code__c, Country_Name__c FROM QCC_CAPCountryCodeMap__mdt]) {
                countryCodeMap.put(codeData.Country_Code__c, codeData.Country_Name__c);
            }
            
            for(QCC_CustomerDetailsResponse.Address thisAddress : customer.Address){
                String street = thisAddress.line1 + ' ' + thisAddress.line2 + ' ' + thisAddress.line3 + ' ' + thisAddress.line4;
                String suburb = thisAddress.suburb.trim();
                String state = thisAddress.state.trim();
                String postCode = thisAddress.postCode.trim();
                String countryCode = thisAddress.country.trim();
                String country = countryCodeMap.containsKey(countryCode) ? countryCodeMap.get(countryCode) : null;
                
                if(String.isNotBlank(thisAddress.typeCode))
                {
                    if(thisAddress.typeCode.equalsIgnoreCase('H')){
                        cw.address = new Address(street, suburb, postCode, state, country);
                        break;
                    }
                    else if(thisAddress.typeCode.equalsIgnoreCase('B')){
                        cw.address = new Address(street, suburb, postCode, state, country);
                    }
                }
            }
        }*/
    
        //CRM-7330: 201 SOQL limit fix
        private static CustomerWrapper getCustomerInfo(String ffNumber,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse) {
            return getCustomerInfo(ffNumber, loyaltyProfileResponse, null);   
        }
        
        //CRM-7330: 201 SOQL limit fix
        private static CustomerWrapper getCustomerInfo(String ffNumber,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse, String loyaltyToken) {
        //CRM-7330: 201 SOQL limit fix
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact loyaltyContactResponse = QCC_InvokeCAPAPI.invokeLoyaltyContactAPI(ffNumber, loyaltyToken);
        system.debug('loyaltyContactResponse'+loyaltyContactResponse);
        system.debug('customer$$$$$'+ loyaltyProfileResponse);
        CustomerWrapper cw = new CustomerWrapper();
        if(loyaltyProfileResponse.firstName != null && loyaltyProfileResponse.lastName != null ) {
            cw.firstName =loyaltyProfileResponse.firstName;
            cw.lastName = loyaltyProfileResponse.lastName;
        }
       // cw.capId = customer.qantasUniqueId;
        cw.ffNumber = ffNum;
        cw.ffTier = ffTier;
        cw.ffTierSF = ffTierSF;
        if(loyaltyContactResponse != null && loyaltyContactResponse.phones != null) {
            cw.displayPhone = getPhoneDetails(loyaltyContactResponse.phones);
        }else{
            cw.displayPhone = getPhoneDetails(new List<QCC_LoyaltyResponseWrapper.Phones>());
        }
        
        if(loyaltyContactResponse != null && loyaltyContactResponse.addresses != null) {
            for(QCC_CAPCountryCodeMap__mdt codeData: [SELECT Label, Country_Code__c, Country_Name__c FROM QCC_CAPCountryCodeMap__mdt]) {
                countryCodeMap.put(codeData.Country_Code__c, codeData.Country_Name__c);
            }
            
            for(QCC_LoyaltyResponseWrapper.Addresses thisAddress :loyaltyContactResponse.addresses){
                 String street = thisAddress.lineOne + ' ' + thisAddress.lineTwo;
                
                if(String.isNotBlank(thisAddress.type_Z))
                {
                    if(thisAddress.type_Z.equalsIgnoreCase('H')){
                        cw.address = new Address(street);
                        break;
                    }
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
          if(loyaltyContactResponse != null && loyaltyContactResponse.emails != null){
            for(QCC_LoyaltyResponseWrapper.emails email : loyaltyContactResponse.emails) {
                if(email != null) {
                    cw.email = email.emailAddress;
                    break;
                }
            }
        }
        
        List<displayColumn> listColumn = new List<displayColumn>();
        listColumn.add(new displayColumn('Phone', 'phoneNumberWithType', 'text'));
        cw.displayColumn = listColumn;
        System.debug('CustomerWrapper = '+cw);
        return cw;
    }
    
    /*----------------------------------------------------------------------------------------------      
Method Name:    getPhoneDetails
Description:    Retrieves the phone details of the customer 
Parameter:      List<QCC_CustomerDetailsResponse.Phone> /List< QCC_LoyaltyResponseWrapper.Phones> Jira CRM - 5595  
Return:         List<Phone>    
----------------------------------------------------------------------------------------------*/
   // private static List<Phone> getPhoneDetails(List<QCC_CustomerDetailsResponse.Phone> phonesRes) {
    private static List<Phone> getPhoneDetails(List< QCC_LoyaltyResponseWrapper.Phones> phonesRes) {
        System.debug('Inside');
        List<Phone> phones = new List<Phone>();
        //Integer i = 0;
        //for(QCC_CustomerDetailsResponse.Phone thisPhone : phonesRes) {
        for(QCC_LoyaltyResponseWrapper.Phones thisPhone : phonesRes) {
            Phone ph = new Phone();
            //ph.phoneId = String.valueOf(i++);
            String phoneNumber;
            String phno;
            String phonecc;
            String phoneac;
            /*if(String.isNotBlank(thisPhone.phoneCountryCode)){
                //added this logics to convert the phonenumber into E164 format as per jira CRM 5582
                phoneac = thisPhone.phoneCountryCode.replaceAll('[^0-9]','');
                phonecc = thisPhone.phoneCountryCode.startsWith('0') ? thisPhone.phoneCountryCode.replaceFirst( '0', ''):thisPhone.phoneCountryCode;
                phoneNumber = phonecc;
                System.debug('phoneCountrycode: ' +phoneNumber);
                
            }*/
            if(String.isNotBlank(thisPhone.countryCode)){
                //added this logics to convert the phonenumber into E164 format as per jira CRM 5582
                phoneac = thisPhone.countryCode.replaceAll('[^0-9]','');
                phonecc = thisPhone.countryCode.startsWith('0') ? thisPhone.countryCode.replaceFirst( '0', ''):thisPhone.countryCode;
                phoneNumber = phonecc;
                System.debug('phoneCountrycode: ' +phoneNumber);
                
            }
            /*if(String.isNotBlank(thisPhone.phoneAreaCode)){
                
                phoneac = thisPhone.phoneAreaCode.replaceAll('[^0-9]','');
                phoneac = thisPhone.phoneAreaCode.startsWith('0') ? thisPhone.phoneAreaCode.replaceFirst( '0', ''):thisPhone.phoneAreaCode;
                phoneNumber = String.isBlank(phoneNumber) ? phoneac : phoneNumber + phoneac;
                System.debug('phoneAreacode: ' +phoneNumber);
            }*/
            if(String.isNotBlank(thisPhone.areaCode)){
                
                phoneac = thisPhone.areaCode.replaceAll('[^0-9]','');
                phoneac = thisPhone.areaCode.startsWith('0') ? thisPhone.areaCode.replaceFirst( '0', ''):thisPhone.areaCode;
                phoneNumber = String.isBlank(phoneNumber) ? phoneac : phoneNumber + phoneac;
                System.debug('phoneAreacode: ' +phoneNumber);
            }
            /*if(String.isNotBlank(thisPhone.phoneLineNumber)){
                
                phno = thisPhone.phoneLineNumber.replaceAll('[^0-9]','');
                phno = thisPhone.phoneLineNumber.startsWith('0') ? thisPhone.phoneLineNumber.replaceFirst( '0', ''):phno;
                phoneNumber = String.isBlank(phoneNumber) ? phno : phoneNumber + phno;
                System.debug('phoneLineNumber: ' +phoneNumber);
            }*/
            if(String.isNotBlank(thisPhone.number_Z)){
                
                phno = thisPhone.number_Z.replaceAll('[^0-9]','');
                phno = thisPhone.number_Z.startsWith('0') ? thisPhone.number_Z.replaceFirst( '0', ''):phno;
                phoneNumber = String.isBlank(phoneNumber) ? phno : phoneNumber + phno;
                System.debug('phoneLineNumber: ' +phoneNumber);
            }
            
            
            // phoneIds have been given to sort the list in desired order. The order is Home - Business - Other - Additional Phone Number
            //if(String.isNotBlank(thisPhone.typeCode) && String.isNotBlank(phoneNumber)){
            if(String.isNotBlank(thisPhone.type_Z) && String.isNotBlank(phoneNumber)){
                ph.phoneNumber = phoneNumber.trim();
                ph.phoneNumber ='+' + phoneNumber;
                System.debug('Ph.phoneNumber :' +Ph.phoneNumber);
                
                
                //if (thisPhone.typeCode.equalsIgnoreCase('B')) {
                if (thisPhone.type_Z.equalsIgnoreCase('B')) {
                    ph.phoneType = 'Business';
                    ph.phoneId = 1;
                }//else if (thisPhone.typeCode.equalsIgnoreCase('H')){
                else if (thisPhone.type_Z.equalsIgnoreCase('H')){
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
        //phones.add(new Phone('','','',CustomSettingsUtilities.getConfigDataMap('AdditionalPhoneLabel'),'additional'));
        phones.add(new Phone('','','',Label.QCC_AdditionalPhoneLabel,'additional'));
        System.debug('Before Sort '+phones);
        phones.sort();
        System.debug('After sort '+phones);
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
        String suburb;
        String postCode;
        String state;
        String country;
        
       // public Address(String street, String suburb, String postCode, String state, String country) {
            public Address(String street) {//CRM-5595
            this.street = street;
           /* this.suburb = suburb;
            this.postCode = postCode;
            this.state = state;
            this.country = country;*/
        }
    }
    
    public class CustomerWrapper {
        public List<displayColumn> displayColumn{get;set;}
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