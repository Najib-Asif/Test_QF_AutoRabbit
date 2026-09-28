/*-----------------------------------------------------------------------------------------------------------------------------
Author:TCS
JIRA: TS-4863
Description:To check whether Manager contact is duplicate or not based few scenarios   
Test Class:QAC_ManagerContDupCheck_Test   
*********************************************************************************************************************************
*********************************************************************************************************************************/
public class QAC_ManagerContactsDuplicateCheck {
	public static Set<String> incomingContactEmail = new Set<String>();
    public static map<String,Contact> duplicateContMap = new map<String,Contact>();
    public static Set<String> incomingContactLname = new Set<String>();
    public static Set<String> incomingContactFname = new Set<String>();
    public static Set<String> incomingContactPhone = new Set<String>();
    public static Set<String> incomingContactEmailLname = new Set<String>();
    public static Set<String> incomingVerificationNumber = new Set<String>();
    
    
    public static void doContactDuplicateCheck(List<Contact> newList)
    {
        try{
        String conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId(); 
        for(Contact con : newList)
        {
            if(con.QAC_Contact__c!=null && con.QAC_Contact__c=='Yes'){
            incomingContactEmail.add(con.email.toUppercase());
            incomingContactLname.add(con.lastName.toUppercase());
            incomingContactFname.add(con.firstName.toUppercase());
            incomingContactEmailLname.add(con.firstName.toUppercase()+'_'+con.lastName.toUppercase()+'_'+con.email.toUppercase()+'_'+con.mobilePhone);
            incomingContactPhone.add(con.mobilePhone);
            incomingVerificationNumber.add(con.verification_Number__c);
            }
        }
        
        
        for(Contact cont : [Select Id,FirstName,LastName,Email,MobilePhone,Verification_Number__c,QAC_Contact__c,AccountId,RecordTypeId from Contact where RecordTypeId=:conRTId AND QAC_Contact__c='Yes' AND ((Email IN: incomingContactEmail AND LastName IN: incomingContactLname AND MobilePhone IN: incomingContactPhone AND FirstName IN: incomingContactFname) OR Verification_Number__c IN:incomingVerificationNumber)])
        {
            if(cont != null){
                String dupCheckCombo = cont.FirstName.toUppercase()+'_'+cont.LastName.toUppercase() + '_' + cont.Email.toUppercase()+'_'+cont.MobilePhone +':'+ cont.Id;
                String dupCheckVerificationNumber = cont.verification_Number__c + ':' + cont.Id;
				System.debug('ContactId***1'+cont.Id);
                if(cont.Verification_Number__c!=null){
                    duplicateContMap.put(cont.Verification_Number__c,cont);
                }else
                {
                    duplicateContMap.put(dupCheckCombo.split(':')[0],cont);
                }
                system.debug('dup map**'+duplicateContMap);
              }
        }
       
        system.debug('dup Map 2**'+duplicateContMap);
        for(Contact cont : newList)
        {
            if(cont != null) {
                String dupValues = cont.FirstName.toUppercase()+'_'+cont.lastname.toUppercase() + '_' + cont.email.toUppercase()+'_'+cont.mobilePhone;
                system.debug('ContactId***2'+cont.id);
                if(!duplicateContMap.isEmpty())
                {
                    if(cont.verification_Number__c==null && duplicateContMap.containsKey(dupValues) && cont.Id!=duplicateContMap.get(dupvalues).id ) 
                	{
                     cont.adderror('Duplicate contact found with the given details');
                    }else if(cont.verification_Number__c!=null && duplicateContMap.containsKey(cont.Verification_Number__c) && cont.id!=duplicateContMap.get(cont.Verification_Number__c).id){
                     cont.verification_Number__c.adderror('Duplicate contact found for verification number: '+cont.Verification_Number__c);   
                    }
                    else if(cont.verification_Number__c!=null && duplicateContMap.containsKey(dupValues) && duplicateContMap.get(dupValues).verification_Number__c==null && cont.id!=duplicateContMap.get(dupValues).id ){
                     cont.adderror('Duplicate contact found with the given details');
                    }
                }
                    
            }
        }
        }Catch(Exception e){
            System.debug('Exception found'+e.getMessage());
        }    
    }
    
    public static void beforeUpdate(List<Contact> newList,Map<Id,Contact> oldMap){
        List<Contact> updatedContacts = new List<Contact>();
        for(Contact con:newList){
            if(con.QAC_Contact__c=='Yes' && (oldMap.get(con.id).verification_Number__c!=con.Verification_Number__c 
               || oldMap.get(con.id).firstName!=con.firstName
               || oldMap.get(con.id).lastName!=con.LastName 
               || oldMap.get(con.Id).email!=con.Email
               || oldMap.get(con.Id).MobilePhone!=con.MobilePhone)
              ){
                updatedContacts.add(con);
                System.debug('before update duplicate check'+con);
            }
        }
        if(updatedContacts.size()>0)
        doContactDuplicateCheck(updatedContacts);
    }

}