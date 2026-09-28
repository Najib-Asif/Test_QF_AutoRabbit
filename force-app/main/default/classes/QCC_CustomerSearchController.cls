public with sharing class QCC_CustomerSearchController {
     /**
    * @description  : Creates a new record in CRM
    * @param        : 
    * @return       : a contact
    * @author       : Cyrille 
    */ 
    @AuraEnabled
    public static Contact saveIt(Contact contact) {
        try {
            contact = QCC_CustomerSearchHandler.saveCAPContact(contact);
        } catch(Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());    
        }
        return contact;
        
    }

    /**
    * @description  : Searches customer profile
    * @param        : 
    * @return       : 
    * @author       : Cyrille
    */ 
    @AuraEnabled
    public static QCC_CustomerSearchHandler.ContactWrapper executeSearch(Contact contact , String pnr , Boolean crmSearch){ 
        if(contact == null) return null;
        if(crmSearch){
            return QCC_CustomerSearchHandler.searchCRMContacts(contact);
        }else{
            return QCC_CustomerSearchHandler.searchCustomer(contact , pnr);
        }
    }

    /**
    * @description  : attach a case to a unique SFDC contact. Enforce dedup rules
    * @param        : 
    * @return       : Contact
    */ 
    @AuraEnabled
    public static Case AssignToContact(Contact contact, Id caseId) {
    	Contact result = QCC_CustomerSearchHandler.saveCAPContact(contact);
        List<Case> cases = [select Id , First_Name__c,Last_Name__c , Email__c , contactId from Case where Id =: caseId limit 1];
        if(cases.size() > 0 && result != null){
        	cases[0].contactId 		= result.Id;
            cases[0].First_Name__c 	= result.firstName;
            cases[0].Last_Name__c  	= result.lastname;
            cases[0].Email__c  		= result.email;
            update cases[0];
        }
        
        return cases[0];
    }
}