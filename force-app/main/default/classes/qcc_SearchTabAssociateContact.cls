/*
Developer: Navpreet Kaur
Date: 1 November 2023
*/
public with sharing class qcc_SearchTabAssociateContact 
{
    @auraEnabled
    public static Boolean associateContact(Id caseId,Id contactId)
    {
       Boolean flag=false;
       try
       {
           List<Case> updateCase=new List<Case>();
           system.debug('the value of case id'+caseId);
           system.debug('the value of contact id'+contactId);
           
           if(caseId!=null && contactId!=null)
           {
               List<Case> getCases=[select id,contactid,First_Name__c,Last_Name__c,Contact_Phone__c,Contact_Email__c,Frequent_Flyer_Number__c from case where id=:caseId limit 1];
               List<Contact> getContacts=[select id,firstname,lastname,phone,email,Frequent_Flyer_Number__c from contact where id=:contactId limit 1];   
               
               if(getCases!=null && getCases.size()>0 && getContacts!=null && getContacts.size()>0)
               {
                   getCases[0].contactid=getContacts[0].id;
                   getCases[0].First_Name__c=getContacts[0].firstname;
                   getCases[0].Last_Name__c=getContacts[0].lastname;
                   //Commenting below line to keep the contact phone entact CRM-8061
                   //getCases[0].Contact_Phone__c=getContacts[0].phone;
                    getCases[0].Contact_Email__c=getContacts[0].email;
                   if(getContacts[0].Frequent_Flyer_Number__c!=null && getContacts[0].Frequent_Flyer_Number__c!='')
                   {
                       getCases[0].Frequent_Flyer_Number__c=getContacts[0].Frequent_Flyer_Number__c;  
                   }
                   updateCase.add(getCases[0]); 
               }
               if(updateCase!=null && updateCase.size()>0)
               {
                   update updateCase;
                   flag=true;
               }
           }
       }
       catch(Exception e)
       {
           system.debug('Exception has occurred'+e.getmessage());
       }
       return flag;
    }
}