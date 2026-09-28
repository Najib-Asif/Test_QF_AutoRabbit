/*********************************************************************************
Created By   : Capgemini
Company Name : Capgemini
Project      : Qantas Customer Direct
Created Date : 20 October 2017
Usages       : QCC Customer search server side controller
History
<Date>       : <Brief Description of Change>
20/10/2017   : Initial Release
*********************************************************************************/
public with sharing class QCC_CustomerSearchHandler {

    public static List<ContactWrapper> records;
    private static string queryString;
    public static Integer score = 0;

    public class ContactWrapper{
        @AuraEnabled public List<Contact> contacts;
        @AuraEnabled public String contact;
        @AuraEnabled public String pnr;
        @AuraEnabled public List<String> errors;
    }


    public static QCC_CustomerDetailsRequest searchHelper(Contact contact , String pnr){
        System.debug('searchHelper ' + contact);
        QCC_CustomerDetailsRequest requestBody = new QCC_CustomerDetailsRequest();
        if(contact == null) return null;
        try{
            //split phone number to phone number and area code if the phone number is 10 digits and start with 04
            if(String.isNotBlank(Contact.Phone_Line_Number__c) && Contact.Phone_Line_Number__c.startsWith('04') 
                && Contact.Phone_Line_Number__c.length() == 10) {
                Contact.Phone_Area_Code__c = '04';
                Contact.Phone_Line_Number__c = Contact.Phone_Line_Number__c.subString(2);
            }
            
            if(String.isNotBlank(Contact.FirstName)){
                requestBody.FirstName = Contact.FirstName.trim();
                score += 50;
            }
            if(String.isNotBlank(Contact.Lastname)){
                requestBody.Lastname = Contact.Lastname.trim();
                score += 50;
            }
            if(String.isNotBlank(Contact.email)){
                requestBody.emailAddr = Contact.email.trim();
                score += 25;
            }

            if(String.isNotBlank(Contact.Frequent_Flyer_Number__c)){
                requestBody.qantasFFNo = Contact.Frequent_Flyer_Number__c.trim();
                score += 75;
            }
            if(String.isNotBlank(pnr)){
                requestBody.pnr = pnr.trim().toUpperCase();
                score += 75;
            }
            if(String.isNotBlank(Contact.Phone_Extension__c)){
                requestBody.phoneExtension = Contact.Phone_Extension__c.trim();
                score += 2;
            }
            if(String.isNotBlank(Contact.Phone_Area_Code__c)){
                requestBody.phoneAreaCode = Contact.Phone_Area_Code__c.trim();
                score += 5;
            }
            if(String.isNotBlank(Contact.Phone_Line_Number__c)){
                requestBody.phoneLineNumber = Contact.Phone_Line_Number__c.trim();
                score += 40;
            }
            if(String.isNotBlank(Contact.Phone_Country_Code__c)){
                requestBody.phoneCountryCode = Contact.Phone_Country_Code__c.trim();
                score += 5;
            }

            if(String.isNotBlank(Contact.CAP_ID__c)){
                requestBody.qantasUniqueId = Contact.CAP_ID__c.trim();
                score += 75;
            }

            requestBody.system_z = 'CAPCRE_CC';
            requestBody.customerPerPage = '100'; 
            System.debug('Score ' + score);
        }catch(Exception ex){
            system.debug('ex###############'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer search', 'QCC_CustomerSearchHandler', 
                                    'searchHelper', String.valueOf(''), String.valueOf(''),false,'', ex);
        }

        return requestBody;
    }


    /**
    * @description  : Orchestrates mapping of CAP fields with to SFDC fields - Updated to Loyalty Fields Jira CRM -5595
    * @param        : 
    * @return       : Contact
    */ 
   // public static List<Contact> processResponse(QCC_CustomerDetailsResponse.Response responseIn , Integer score , Boolean enableSingleAttributeSearch)
    public static List<Contact> processResponse(QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile responseIn,
                                                QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact responseIn_contact ,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier responseIn_Tier, Integer score)
    {
        List<Contact> myContacts;
        try{
           // for(QCC_CustomerDetailsResponse.Customers obj: responseIn.customers){
                if(myContacts == null) myContacts = new List<Contact>();
                Contact crmContact = new Contact();
                //String qantasUniqueId = obj.Customer.qantasUniqueId;
                //String returnedScore  = obj.Customer.customerMatchScore;
                //if(String.isBlank(returnedScore)) continue;

                /*if(enableSingleAttributeSearch){
                    if(Integer.valueOf(obj.Customer.customerMatchScore) < 75) continue;
                }else{
                    if(Integer.valueOf(obj.Customer.customerMatchScore) != score) continue;
                }*/

                //if(obj != null && obj.Customer != null && String.isNotBlank(qantasUniqueId))
                if(responseIn!= null || responseIn_contact!=null  ||responseIn_Tier !=null)////CRM-5595
                {
                    crmContact.source__c                    = 'CAP';
                   /* crmContact.CAP_ID__c                    = qantasUniqueId;
                    crmContact                              = setName(crmContact , obj);
                    crmContact                              = setPhoneNumbers(crmContact , obj);
                    crmContact                              = setEmailAddresses(crmContact , obj);
                    crmContact                              = setAddresses(crmContact , obj);
                    crmContact                              = setLoyaltyDetails(crmContact , obj);*/
                    crmContact                              = setName(crmContact , responseIn);
                    crmContact                              = setPhoneNumbers(crmContact , responseIn_contact);
                     crmContact                              = setEmailAddresses(crmContact , responseIn_contact);
                     crmContact                              = setAddresses(crmContact , responseIn_contact);
                    crmContact                              = setLoyaltyDetails(crmContact ,responseIn_Tier,responseIn);
                    String temp;
                   /* if(obj.Customer.previousQantasIds != null && obj.Customer.previousQantasIds.size() > 0){
                        for(String oldCId : obj.Customer.previousQantasIds){
                            if(String.isBlank(crmContact.TECH_previousIds__c)) {
                                crmContact.TECH_previousIds__c = oldCId;  
                            }else{
                                crmContact.TECH_previousIds__c = ',' + oldCId;  
                            }
                            
                        }
                    }
                }*/
                if(myContacts == null ) return myContacts;
                myContacts.add(crmContact);
            }
            System.debug('processResponse - Exit ' + myContacts);
            return myContacts;
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer search', 'QCC_CustomerSearchHandler', 
                                    'processResponse', String.valueOf(''), String.valueOf(''),false,'', ex);
            return null;
        }
    }


    /**
    * @description  : Handles customer search operation/ Updated to Loyalty System Jira CRM -5595
    * @param        : 
    * @return       : Contact
    */ 
    public static ContactWrapper searchCustomer(Contact contact, String pnr)
    {
        try{
            ContactWrapper record = new ContactWrapper();
            QCC_CustomerDetailsRequest requestBody = searchHelper(contact , pnr);
            System.debug(requestBody);
            //QCC_CustomerDetailsResponse.Response response;
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile response;//CRM-5595
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact response_contact;//CRM-5595
             QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier response_Tier;//CRM-5595
            try {
                //CRM-6427: CIP Decommissioning
                //response = QCC_InvokeCAPAPI.invokeCustomerDetailCAPAPI(requestBody);
                response = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(requestBody.pnr);//CRM-5595
                response_contact=QCC_InvokeCAPAPI.invokeLoyaltyContactAPI(requestBody.pnr);//CRM-5595
                response_Tier=QCC_InvokeCAPAPI.invokeLoyaltyTierAPI(requestBody.pnr);//CRM-5595
                } catch(Exception e) {
                    System.debug(e.getMessage());
                }

                record.pnr = pnr;
            //searching CRM 
            //if(response == null || response.customers == null || response.customers.size() == 0) 
            if(response == null && response_contact == null) 
            {
                return null;
            }
            
            //record.contacts =  processResponse(response , score , false);
            record.contacts =  processResponse(response,response_contact,response_Tier,score);
            if(record.contacts.size() > 0) return record;
            return null;
            }catch(Exception ex){
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer search', 'QCC_CustomerSearchHandler', 
                    'searchCustomer', String.valueOf(''), String.valueOf(''),false,'', ex);
                return null;
            }
        }

    /**
    * @description  : Orchestrates mapping of CAP fields with to SFDC fields/ Updated to Loyalty Fields Jira CRM-5595
    * @param        : 
    * @return       : Contact
    */ 
    //public static Contact setName(Contact crmContact , QCC_CustomerDetailsResponse.Customers obj){
    public static Contact setName(Contact crmContact, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile obj){
        //CRM-6835: INC2278556 - flight event with nil passengers
       //QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(crmContact.firstname);
        /*if(obj == null || 
            obj.Customer == null || 
            obj.Customer.Name == null) return crmContact;
        crmContact.firstname = obj.Customer.Name.firstname;
        crmContact.lastname = obj.Customer.Name.lastname;
        crmContact.Middle_Name__c = obj.Customer.Name.middleName;
        //crmContact.title = obj.Customer.Name.prefix;
        crmContact.salutation = obj.Customer.Name.prefix;*/
        if(obj == null || obj.FirstName  == null || obj.LastName== null) return crmContact;
        crmContact.firstname =  obj.FirstName;
        crmContact.lastname = obj.LastName;
        /** Removed birthdate mapping - CRM-3112
        if(String.isNotBlank(obj.Customer.Name.birthDate)){
            crmContact.Birthdate = date.parse(obj.Customer.Name.birthDate);
        }*/
        return crmContact;
    }

    public static List<Contact> getExistingContact(Contact contact){
        Boolean search = false;
        try{
            //List<String> fieldNames = new List<String>( Schema.SObjectType.Contact.fields.getMap().keySet() );
            List<String> fieldNames = new List<String>();
            fieldNames.add( 'id');
            fieldNames.add( 'source__c');
            fieldNames.add( 'CAP_ID__c');
            fieldNames.add( 'firstname');
            fieldNames.add( 'lastname');
            fieldNames.add( 'Middle_Name__c');
            fieldNames.add( 'salutation');
            fieldNames.add( 'Phone_Country_Code__c');
            fieldNames.add( 'Phone_Area_Code__c');
            fieldNames.add( 'Phone_Line_Number__c');
            fieldNames.add( 'mobilePhone');
            fieldNames.add( 'Business_Phone__c');
            fieldNames.add( 'Phone');
            fieldNames.add( 'homePhone');
            fieldNames.add( 'otherPhone');
            fieldNames.add( 'Alternate_Phone__c');
            fieldNames.add( 'email');
            fieldNames.add( 'Business_Email__c');
            fieldNames.add( 'Home_Email__c');
            fieldNames.add( 'QCC_Other_Email__c');
            fieldNames.add( 'Alternate_Email__c');
            fieldNames.add( 'Preferred_Email__c');
            fieldNames.add( 'Preferred_Contact_Method__c');
            fieldNames.add( 'MailingStreet');
            fieldNames.add( 'MailingCity');
            fieldNames.add( 'MailingStateCode');
            fieldNames.add( 'MailingPostalCode');
            fieldNames.add( 'MailingCountryCode');
            fieldNames.add( 'OtherStreet');
            fieldNames.add( 'OtherCity');
            fieldNames.add( 'OtherStateCode');
            fieldNames.add( 'OtherPostalCode');
            fieldNames.add( 'OtherCountryCode');
            fieldNames.add( 'Profile_Homeport__c');
            fieldNames.add( 'Frequent_Flyer_Number__c');
            fieldNames.add( 'Frequent_Flyer_tier__c');
            fieldNames.add( 'TECH_previousIds__c');

   
            String strQuery = ' SELECT ' + String.join( fieldNames, ',' ) + ' FROM Contact '; 

            List<String> conditions = new List<String>();
            if(String.isNotBlank(contact.CAP_ID__C)){
                conditions.add(' CAP_ID__C = '  +'\''+ String.escapeSingleQuotes(contact.CAP_ID__C.trim())+'\'') ;
                search = true;
            }

            if(String.isNotBlank(contact.Frequent_Flyer_Number__c)){
                conditions.add(' Frequent_Flyer_Number__c = '  +'\''+ String.escapeSingleQuotes(contact.Frequent_Flyer_Number__c.trim())+'\'') ;
                search = true;
            }

            //search cap based on historical customerId
            /* Commented since this is causing more than 50,000 rows
            if(String.isNotBlank(contact.TECH_previousIds__c)){
                String tempId = contact.TECH_previousIds__c;
                Set<String> ids = new Set<String>();
                if(tempId.containsIgnoreCase(',')){
                    for(String str : contact.TECH_previousIds__c.split(',')){
                        ids.add(str);
                    }
                    conditions.add(' CAP_ID__C in :ids ');
                }else{
                    conditions.add(' CAP_ID__C = '  +'\''+ String.escapeSingleQuotes(contact.TECH_previousIds__c.trim())+'\'') ;
                }
                search = true;
            }*/

            if(!search) return null;
            if(conditions.size() > 0){
                strQuery += ' WHERE ' + conditions[0];
                for (Integer i = 1; i < conditions.size(); i++){
                    strQuery += ' OR ' + conditions[i];
                }
            }

           return Database.query(strQuery);
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer search', 'QCC_CustomerSearchHandler', 
                'getExistingContact', String.valueOf(''), String.valueOf(''),false,'', ex);
            return null;
        }
    }

     /**
    * @description  : This method dynamically builds the search query and returns contacts. No search againts null.
    * @param        : 
    * @return       : 
    * @author       : 
    */ 
    public static ContactWrapper searchCRMContacts(Contact contact){

        ContactWrapper conWrp = new ContactWrapper();
        Boolean search = false;
        try{
            String strQuery = 'select firstname ,Frequent_Flyer_Number__c, lastname , Id, Alternate_Email__c,Preferred_Email__c,Business_Email__c,Home_Email__c,QCC_Other_Email__c, email , phone,Business_Phone__c,homePhone,mobilePhone,Alternate_Phone__c,otherPhone,Phone_Line_Number__c, TECH_previousIds__c from Contact ';
            List<String> conditions = new List<String>();
            if(String.isNotBlank(contact.Frequent_Flyer_Number__c)){
                conWrp.contacts = [select firstname ,Frequent_Flyer_Number__c, lastname , Id, Alternate_Email__c,Preferred_Email__c,Business_Email__c,Home_Email__c,QCC_Other_Email__c, email , phone,Business_Phone__c,homePhone,mobilePhone,Alternate_Phone__c,otherPhone,Phone_Line_Number__c, TECH_previousIds__c from Contact where Frequent_Flyer_Number__c =:Contact.Frequent_Flyer_Number__c];
                if(conWrp.contacts != null && conWrp.contacts.size() > 0) return conWrp;
            }
            if(String.isNotBlank(contact.firstname)){
                conditions.add(' firstname = '  +'\''+ String.escapeSingleQuotes(contact.firstname.trim())+'\'') ;
                search = true;
            }
            if(String.isNotBlank(contact.lastname)){
                conditions.add(' lastname = '  +'\''+ String.escapeSingleQuotes(contact.lastname.trim())+'\'') ;
                search = true;
            }
            if(String.isNotBlank(contact.email)){
                conditions.add(' (email = '  +'\''+ String.escapeSingleQuotes(contact.email.trim())+'\'' + 
                    ' OR Preferred_Email__c = '  +'\''+ String.escapeSingleQuotes(contact.email.trim())+'\''+
                    ' OR Alternate_Email__c = '  +'\''+ String.escapeSingleQuotes(contact.email.trim())+'\''+
                    ' OR Business_Email__c = '  +'\''+ String.escapeSingleQuotes(contact.email.trim())+'\''+
                    ' OR Home_Email__c = '  +'\''+ String.escapeSingleQuotes(contact.email.trim())+'\''+
                    ' OR QCC_Other_Email__c = '  +'\''+ String.escapeSingleQuotes(contact.email.trim())+'\'' + ')') ;
                search = true;
                System.debug('Email query ' + conditions);
            }
            if(String.isNotBlank(contact.Phone_Line_Number__c)){
                conditions.add(' (phone = '  +'\''+ String.escapeSingleQuotes(contact.Phone_Line_Number__c.trim())+'\''+
                    ' OR Business_Phone__c = '  +'\''+ String.escapeSingleQuotes(contact.Phone_Line_Number__c.trim())+'\''+
                    ' OR homePhone = '  +'\''+ String.escapeSingleQuotes(contact.Phone_Line_Number__c.trim())+'\''+
                    ' OR mobilePhone = '  +'\''+ String.escapeSingleQuotes(contact.Phone_Line_Number__c.trim())+'\''+
                    ' OR Alternate_Phone__c = '  +'\''+ String.escapeSingleQuotes(contact.Phone_Line_Number__c.trim())+'\''+
                    ' OR otherPhone = '  +'\''+ String.escapeSingleQuotes(contact.Phone_Line_Number__c.trim())+'\''+')') ;
                search = true;
            }
            if(String.isNotBlank(contact.Frequent_Flyer_Number__c)){
                conditions.add('Frequent_Flyer_Number__c = '  +'\''+ String.escapeSingleQuotes(contact.Frequent_Flyer_Number__c.trim())+'\'') ;
                search = true;
            }
            if(!search) return null;
            if(conditions.size() > 0){
                strQuery += ' WHERE ' + conditions[0];
                for (Integer i = 1; i < conditions.size(); i++){
                    strQuery += ' AND ' + conditions[i];
                }
            }
            System.debug('strQuery ' + strQuery);
            conWrp.contacts = Database.query(strQuery);
            for(Contact cont : conWrp.contacts){
                cont.Source__c                  = 'SFDC';
                if(String.isNotBlank(contact.email)){
                    cont.Email                      = contact.email;
                }
                if(String.isNotBlank(contact.Phone_Line_Number__c)){
                    cont.Phone                      = contact.Phone_Line_Number__c;
                }
            }

            return conWrp;
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer search', 'QCC_CustomerSearchHandler', 
                'searchCRMContacts', String.valueOf(''), String.valueOf(''),false,'', ex);
            return null;
        }
    }

    
    /**
    * @description  : helper method - build phone numbers -CRM-5595
    * @param        : 
    * @return       : 
    */ 
    //public static Contact setPhoneNumbers(Contact crmContact , QCC_CustomerDetailsResponse.Customers obj){
    public static Contact setPhoneNumbers(Contact crmContact ,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact obj){
       // if(obj == null || obj.Customer == null || obj.Customer.Phone == null) return crmContact;
       if(obj == null) return crmContact;
        //for(QCC_CustomerDetailsResponse.Phone thisPhone : obj.Customer.Phone){
        for(QCC_LoyaltyResponseWrapper.Phones thisPhone : obj.phones){//CRM-5595
            String phoneNumber;
            //if(String.isNotBlank(thisPhone.phoneCountryCode)){
                //crmContact.Phone_Country_Code__c = thisPhone.phoneCountryCode;
                if(String.isNotBlank(thisPhone.countryCode)){
                crmContact.Phone_Country_Code__c = thisPhone.countryCode;
                if(String.isBlank(phoneNumber)){
                    //phoneNumber = thisPhone.phoneCountryCode;
                    phoneNumber = thisPhone.countryCode;
                }else{
                    //phoneNumber += thisPhone.phoneCountryCode;
                    phoneNumber += thisPhone.countryCode;
                }
            }
            //if(String.isNotBlank(thisPhone.phoneAreaCode)){
            //crmContact.Phone_Area_Code__c = thisPhone.phoneAreaCode;
            if(String.isNotBlank(thisPhone.areaCode)){
                crmContact.Phone_Area_Code__c = thisPhone.areaCode;
                
                if(String.isBlank(phoneNumber)){
                   // phoneNumber = thisPhone.phoneAreaCode;
                   phoneNumber = thisPhone.areaCode;
                }else{
                    //phoneNumber += thisPhone.phoneAreaCode;
                    phoneNumber = thisPhone.areaCode;
                }
            }
            /*if(String.isNotBlank(thisPhone.phoneLineNumber)){
                crmContact.Phone_Line_Number__c = thisPhone.phoneLineNumber;*/
            if(String.isNotBlank(thisPhone.number_Z)){
                crmContact.Phone_Line_Number__c = thisPhone.number_Z;
                if(String.isBlank(phoneNumber)){
                    //phoneNumber = thisPhone.phoneLineNumber;
                    phoneNumber = thisPhone.number_Z;
                }else{
                    //phoneNumber += thisPhone.phoneLineNumber;
                    phoneNumber = thisPhone.number_Z;
                }
            }
            phoneNumber = phoneNumber.trim();
            /*if(String.isNotBlank(thisPhone.typeCode)){
                if(thisPhone.typeCode.equalsIgnoreCase('M')){*/
            if(String.isNotBlank(thisPhone.type_Z)){
                if(thisPhone.type_Z.equalsIgnoreCase('M')){
                    crmContact.mobilePhone       = phoneNumber;
               // }else if (thisPhone.typeCode.equalsIgnoreCase('B')) {
               }else if (thisPhone.type_Z.equalsIgnoreCase('B')) {
                    crmContact.Business_Phone__c = phoneNumber;
                //}else if (thisPhone.typeCode.equalsIgnoreCase('H')){
                }else if (thisPhone.type_Z.equalsIgnoreCase('H')){
                    crmContact.homePhone         = phoneNumber;
                }else{
                    crmContact.otherPhone        = phoneNumber;
                }
            }
                if(String.isNotBlank(crmContact.otherPhone)) {
                    crmContact.Phone = crmContact.otherPhone;
                } else if(String.isNotBlank(crmContact.Business_Phone__c)) {
                    crmContact.Phone = crmContact.Business_Phone__c;
                }else if(String.isNotBlank(crmContact.homePhone)) {
                    crmContact.Phone = crmContact.homePhone;
                }

            if(String.isNotBlank(crmContact.Business_Phone__c)) crmContact.phone = crmContact.Business_Phone__c.trim();
            if(String.isNotBlank(crmContact.mobilePhone)) crmContact.phone = crmContact.mobilePhone.trim();
            if(String.isNotBlank(crmContact.homePhone)) crmContact.phone = crmContact.homePhone.trim();
            
        }
        return crmContact;
    }

    /* @description  : helper method - build email addresses -CRM-5595
    * @param        : 
    * @return       : a contact with email updated
    */ 
    //public static Contact setEmailAddresses(Contact crmContact , QCC_CustomerDetailsResponse.Customers obj){
    public static Contact setEmailAddresses(Contact crmContact ,QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact obj){
        //if(obj == null || obj.Customer == null || obj.Customer.Email == null) return crmContact;
        if(obj == null) return crmContact;//CRM-5595
        //for(QCC_CustomerDetailsResponse.Email thisEmail: obj.Customer.Email){
        for(QCC_LoyaltyResponseWrapper.Emails thisEmail: obj.emails){
            //String email = thisEmail.emailId.trim();
             String email = thisEmail.emailAddress.trim();
            if(String.isNotBlank(email)) crmContact.email = email;
            /*if(String.isNotBlank(thisEmail.typeCode)){
                if (thisEmail.typeCode.equalsIgnoreCase('B')) {
                    crmContact.Business_Email__c = email;
                    }else if (thisEmail.typeCode.equalsIgnoreCase('H')){
                        crmContact.Home_Email__c    =  email;
                    }
                    else{
                        crmContact.QCC_Other_Email__c = email;
                    }
                }*/
                if(String.isNotBlank(crmContact.QCC_Other_Email__c)) {
                    crmContact.email = crmContact.QCC_Other_Email__c;
                    crmContact.Preferred_Contact_Method__c  = 'Other';
                }

                if(String.isNotBlank(crmContact.Business_Email__c)) {
                    crmContact.email = crmContact.Business_Email__c;
                    crmContact.Preferred_Contact_Method__c  = 'Business';
                }

                if(String.isNotBlank(crmContact.Home_Email__c)) {
                    crmContact.email = crmContact.Home_Email__c;
                    crmContact.Preferred_Contact_Method__c  = 'Home';
                }

                if(String.isNotBlank(crmContact.Business_Email__c)) crmContact.email = crmContact.Business_Email__c;
                if(String.isNotBlank(crmContact.Home_Email__c)) crmContact.email = crmContact.Home_Email__c;

            }
            if(String.isBlank(crmContact.Home_Email__c) && String.isNotBlank(crmContact.Email)) crmContact.Home_Email__c = crmContact.Email;
            
            //Added for QDCUSCON-4101
            if(String.isBlank(crmContact.Email)) {
                crmContact.Email = CustomSettingsUtilities.getConfigDataMap('QCC_ContactEmail');
            }
            return crmContact;
        }

    /*@description  : helper method - build addresses -CRM-5595
    * @param        : 
    * @return       : a contact with email updated
    */ 
   // public static Contact setAddresses(Contact crmContact , QCC_CustomerDetailsResponse.Customers obj){
   public static Contact setAddresses(Contact crmContact , QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact obj){ //CRM-5595
        //if(obj == null || obj.Customer == null || obj.Customer.Address == null) return crmContact;
        if(obj == null) return crmContact;

        //for(QCC_CustomerDetailsResponse.Address thisAddress : obj.Customer.Address){
        for(QCC_LoyaltyResponseWrapper.Addresses thisAddress : obj.addresses){
            String MailingStreet                                            = thisAddress.lineOne  + ' ' + thisAddress.lineTwo;//CRM-5595
            /*String MailingStreet                                            = thisAddress.line1 + ' ' + thisAddress.line2 + ' ' + thisAddress.line3 + ' ' + thisAddress.line4;
            String MailingCity                                              = thisAddress.suburb.trim();
            String MailingStateCode                                         = thisAddress.state.trim();
            String MailingPostalCode                                        = thisAddress.postCode.trim();
            String MailingCountryCode                                       = thisAddress.country.trim();*/
            //System.debug('Setting Homeport to ' + MailingCity);
            System.debug('Setting Homeport to ' + MailingStreet);

            //if(String.isNotBlank(thisAddress.typeCode))
            if(String.isNotBlank(thisAddress.type_Z))
            {
               // if(thisAddress.typeCode.equalsIgnoreCase('H')){
                if(thisAddress.type_Z.equalsIgnoreCase('H')){
                    crmContact.MailingStreet                                        = MailingStreet;//CRM-5595
                    /*crmContact.MailingCity                                          = MailingCity;
                    crmContact.MailingStateCode                                     = MailingStateCode;
                    crmContact.MailingPostalCode                                    = MailingPostalCode;
                    crmContact.MailingCountryCode                                   = MailingCountryCode;
                    crmContact.Profile_Homeport__c                                 = MailingCity;*/
                }
                /*else if(thisAddress.typeCode.equalsIgnoreCase('B')){
                    crmContact.OtherStreet                                          = MailingStreet;
                    crmContact.OtherCity                                            = MailingCity;
                    crmContact.OtherStateCode                                       = MailingStateCode;
                    crmContact.OtherPostalCode                                      = MailingPostalCode;
                    crmContact.OtherCountryCode                                     = MailingCountryCode;
                    crmContact.Profile_Homeport__c                                  = MailingCity;
                }else{
                    crmContact.Profile_Homeport__c                                  = MailingCity;
                }*/

            }
        }
        return crmContact;
    }

    /**
    * @description  : set loyalty details on crm contact/ CAP to Loyalty Jira CRM-5595
    * @param        : 
    * @return       : Contact
    */ 
   // public static Contact setLoyaltyDetails(Contact crmContact , QCC_CustomerDetailsResponse.Customers obj){
   public static Contact setLoyaltyDetails(Contact crmContact , QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier obj, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile obj_profile){
        /*if(obj == null || 
            obj.Customer == null || 
            obj.Customer.LoyaltyDetails == null) return crmContact;*/
      if(obj == null) return crmContact;
        /*for(QCC_CustomerDetailsResponse.LoyaltyDetails thisLoyalty : obj.Customer.LoyaltyDetails){
            System.debug('typeCode ' + thisLoyalty.schemeOperatorCode);
            if(String.isNotBlank(thisLoyalty.schemeOperatorCode)){
                if(thisLoyalty.schemeOperatorCode.equalsIgnoreCase('QF')){
                    crmContact.Frequent_Flyer_Number__c = thisLoyalty.loyaltyId;
                    if(String.isNotBlank(thisLoyalty.airlineTierCode)){
                        crmContact.Frequent_Flyer_tier__c   = CustomSettingsUtilities.getConfigDataMap(thisLoyalty.airlineTierCode);
                    }
                }
            }
            
        }*/
       
       if(obj_profile!=null){
            if(obj!=null){
                    crmContact.Frequent_Flyer_Number__c =obj_profile.memberId;
                    if(String.isNotBlank(obj.qantasFrequentFlyerTier.tierType)){
                        crmContact.Frequent_Flyer_tier__c   = CustomSettingsUtilities.getConfigDataMap(obj.qantasFrequentFlyerTier.tierType);
                    }
                }
            }
       
        System.debug('setLoyaltyDetails - Exit ' + crmContact);
        return crmContact;
    }

    public static Contact forceSaveContact(Contact contact , Boolean create){
        try{
            // Try to save a duplicate contact
            Database.SaveResult sr;
            if(create){
            	sr = Database.insert(contact, false);
            }else{
            	sr = Database.update(contact, false);
            }
            
            if (!sr.isSuccess()) {
                Database.SaveResult sr2;
                // If the duplicate rule is an alert rule, we can try to bypass it
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.AllowSave = true;
                if(create){

                    sr2 = Database.insert(contact, dml);
                    // CRM-3112
                    for(Database.Error err : sr2.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Contact fields that affected this error: ' + err.getFields());
                        if(err.getFields()[0] != null){
                            if(err.getFields()[0] == 'MailingStateCode'){
                                contact.MailingStreet=contact.MailingStreet+contact.MailingStateCode;
                                contact.MailingStateCode = null;
                                sr2 = Database.insert(contact, dml);
                            }else if(err.getFields()[0] == 'OtherStateCode'){
                                contact.OtherStreet=contact.OtherStreet+contact.OtherStateCode;
                                contact.OtherStateCode = null;
                                sr2 = Database.insert(contact, dml);
                            }
                        }
                        
                    }
                    // END CRM-3112
                    }else{
                        sr2 = Database.update(contact, dml);
                    }
                
                if (sr2.isSuccess()) {
                    System.debug('Potential duplicate contact has been inserted in Salesforce!');
                }

            }
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer search', 'QCC_CustomerSearchHandler', 
                'forceSaveContact', String.valueOf(''), String.valueOf(''),false,'', ex);
            return null;
        }
        return contact;
    }

    public static List<Contact> updateContact(List<Contact> existingContacts , Contact contact){
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        for (String fieldName : fieldMap.keySet()){
            if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                SObjectField sfield = fieldMap.get(fieldName);
                schema.describefieldresult dfield = sfield.getDescribe();
                for(Contact con : existingContacts){
                    if(contact.get(dfield.getName()) == null) continue;
                    if((fieldName.containsIgnoreCase('firstname') || 
                        fieldName.containsIgnoreCase('lastName') || 
                        fieldName.containsIgnoreCase('Middle_Name__c') || 
                        fieldName.containsIgnoreCase('title') || 
                        //fieldName.containsIgnoreCase('Birthdate') || 
                        fieldName.containsIgnoreCase('MailingStreet')||
                        fieldName.containsIgnoreCase('MailingCity')||
                        fieldName.containsIgnoreCase('MailingStateCode')||
                        fieldName.containsIgnoreCase('MailingPostalCode')||
                        fieldName.containsIgnoreCase('MailingCountryCode')||
                        fieldName.containsIgnoreCase('salutation')) && con.get(dfield.getName()) != null) continue;
                    
                    //Ignore Email Address update when it has a value for QDCUSCON-4101
                    if(fieldName.containsIgnoreCase('Email') &&  con.Email != Null && con.Email != '' && 
                       con.Email != CustomSettingsUtilities.getConfigDataMap('QCC_ContactEmail'))
                        continue;
                    con.put(dfield.getName() ,contact.get(dfield.getName()));
                }
            }
        }
        System.debug('Updated contact ' + existingContacts);
        return existingContacts;
    }

    /**
    * @description  : upsert a CAP contact
    * @param        : 
    * @return       : Contact
    */ 
    public static Contact saveCAPContact(Contact contact){
        try{

        List<Contact> duplicates = getExistingContact(contact);
        if(duplicates == null || duplicates.size() == 0){
            return forceSaveContact(contact , true);
            }else{
                duplicates = updateContact(duplicates , contact);
                return forceSaveContact(duplicates[0] , false);
                //return duplicates[0];            
            }
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer search', 'QCC_CustomerSearchHandler', 
                'saveCAPContact', String.valueOf(''), String.valueOf(''),false,'', ex);
            return null;
        }
        }

}