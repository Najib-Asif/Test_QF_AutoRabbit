public with sharing class QL_AquireAmexsection 
{
    @AuraEnabled
	public static Account AquireAmexSection(String Accid)
    {
        Account Accobj = new Account();
        Accobj = [Select Id, Name, Aquire_System__c, Airline_Level__c,Aquire_Eligibility_f__c, Aquire_Override__c, Primary_Reason_Not_Eligible__c,
                  Aquire_Enrollment_Date_System__c, AMEX__c,(SELECT Process_Status__c,AMEX_Accept_or_Reject_Code__c FROM Product_Registrations__r WHERE Active__c = True AND Type__c ='AEQCC') FROM Account WHERE Id=:Accid];
        
        system.debug('Aquire and amex'+Accobj);
        return Accobj;
    }
}