public with sharing class associatedPersonSearchController {
    public String searchString {get; set;}
    public List<Associated_Person__c> allContacts {get; set;}
    public Boolean displayContacts {get; set;}
    public Boolean displayError {get; set;}
    public Account acc {get; set;}
    public String selectedContactId {get; set;}
    public String recordType;
    public String accId;
    
    public associatedPersonSearchController(ApexPages.StandardController controller) {
       
       if(controller.getRecord().Id != null) acc = [SELECT Id, RecordType.Name, Name FROM Account where Id=:controller.getRecord().Id];    
       //if(acc.RecordType.Name == 'Agency Account') recordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agency Contact').getRecordTypeId();
       //if(acc.RecordType.Name == 'Customer Account') recordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non-Agency Contact').getRecordTypeId();
       accId = acc.Id;    
    }
    
    public void searchContacts(){
        allContacts = new List<Associated_Person__c>();        
        if(searchString != null && searchString != '') allContacts = [SELECT Id, Account__c, Account__r.ABN_Tax_Reference__c, First_Name__c, Last_Name__c, Job_Title__c, Frequent_Flyer_Number__c, Phone__c, Email__c, Profile_Email__c, Profile_Phone__c FROM Associated_Person__c where Frequent_Flyer_Number__c=:searchString];
        if(allContacts.size() > 0){ displayContacts = true; displayError = false;}
        else{ displayError = true; displayContacts = false;}
        System.debug('*****'+allContacts.size()+ displayContacts +'  '+displayError);
    }
    
    public PageReference createNewContact(){                
             
        String URL = '/003/e?ent=Contact&RecordType='+recordType+'&con4_lkid='+acc.Id+'&con4='+acc.Name+'&retURL='+acc.Id;
        PageReference page = new PageReference(URL);    
        return page;   
    }
    
    public PageReference contiueToEdit(){
        
        Associated_Person__c assPerson = new Associated_Person__c();        
        for(Associated_Person__c ap: allContacts){
            if(selectedContactId == ap.Id){
                assPerson = ap;   
            }
        }
        
        Associated_Person_Fields__c assPersonFieldIds = Associated_Person_Fields__c.getValues('AssociatedPersonField-Ids');
        
        String URL = '/003/e?'+assPersonFieldIds.Account__c+'='+acc.Id;
        if(assPerson.First_Name__c != null) URL = URL+'&'+assPersonFieldIds.FirstName__c+'='+assPerson.First_Name__c;
        if(assPerson.Last_Name__c != null) URL = URL+'&'+assPersonFieldIds.LastName__c+'='+assPerson.Last_Name__c;
        if(assPerson.Frequent_Flyer_Number__c != null) URL = URL+'&'+assPersonFieldIds.FrequentFlyerNumber__c+'='+assPerson.Frequent_Flyer_Number__c;
        if(assPerson.Job_Title__c != null) URL = URL+'&'+assPersonFieldIds.JobTitle__c+'='+assPerson.Job_Title__c;
        if(assPerson.Phone__c != null) URL = URL+'&'+assPersonFieldIds.Phone__c+'='+assPerson.Phone__c;
        if(assPerson.Email__c != null) URL = URL+'&'+assPersonFieldIds.Email__c+'='+assPerson.Email__c;
        
        URL = URL+'&retURL='+accId;
        PageReference page = new PageReference(URL);
        return page;
    }
    
    public PageReference goBack(){
        String URL = '/'+accId.subString(0,15)+'#'+accId.subString(0,15)+'_RelatedContactList_target';
        PageReference page = new PageReference(URL);
        return page;
    }

}