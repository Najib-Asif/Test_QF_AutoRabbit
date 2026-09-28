@isTest
public with sharing class batchToMergeDuplicateFFContsTest {
    @testSetup
    static void createCaseData(){
        Id contactRTID= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        List<Contact> contList=new List<Contact>();
        List<Contact> contList2=new List<Contact>();

        Contact cont=new Contact(firstname='Duplicate',lastname='Cont1',Frequent_Flyer_Number__c='12345',Source__c='',SSU__c=false,recordtypeid=contactRTID);
        Contact cont4=new Contact(firstname='Duplicate',lastname='Cont4',Frequent_Flyer_Number__c='12345',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont5=new Contact(firstname='Duplicate',lastname='Cont5',Frequent_Flyer_Number__c='12345',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont8=new Contact(firstname='Duplicate',lastname='Cont8',Frequent_Flyer_Number__c='12345',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont9=new Contact(firstname='Duplicate',lastname='Cont9',Frequent_Flyer_Number__c='12345',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont10=new Contact(firstname='Duplicate',lastname='Cont10',Frequent_Flyer_Number__c='12345',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
       
        Contact cont2=new Contact(firstname='Duplicate',lastname='Cont2',Frequent_Flyer_Number__c='1234',Source__c='',SSU__c=false,recordtypeid=contactRTID);
        Contact cont6=new Contact(firstname='Duplicate',lastname='Cont6',Frequent_Flyer_Number__c='1234',Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont7=new Contact(firstname='Duplicate',lastname='Cont7',Frequent_Flyer_Number__c='1234',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        
        Contact cont3=new Contact(firstname='Duplicate',lastname='Cont3',Frequent_Flyer_Number__c='123456',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont11=new Contact(firstname='Duplicate',lastname='Cont11',Frequent_Flyer_Number__c='123456',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont12=new Contact(firstname='Duplicate',lastname='Cont12',Frequent_Flyer_Number__c='123456',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        
        contList.add(cont);
        contList.add(cont4);
        contList.add(cont5);
        contList.add(cont8);
        contList.add(cont9);
        contList.add(cont10);
        
        contList2.add(cont2);
        contList2.add(cont6);
        contList2.add(cont7);
        contList2.add(cont3);
        contList2.add(cont11);
        contList2.add(cont12);
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true; 
        
        Database.insert(contList, dml); 
        Database.insert(contList2, dml); 
       

    }
    @isTest
    static void testMergeOperation()
    {
        try {
            
       test.startTest();
        Id contactRTID= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        List<Contact> getCont=[SELECT id,email,firstname,lastname,Frequent_Flyer_Number__c,QCC_Last_Activity_Date__c,QCC_Last_Flight_Date__c, QCC_Recent_Activity_Date__c,Source__c,QCC_TECH_FF_Number_External_Id__c,SSU__c FROM Contact WHERE Frequent_Flyer_Number__c!=null and recordtypeid=:contactRTID limit 200];

        
		database.executeBatch(new batchToMergeDuplicateFFConts(),100);
        test.stopTest();
    } catch (Exception ex) {
            System.debug('Exception Has Occurred'+ ex.getMessage());
    }
    }
     @isTest
    static void testMergeOperation2()
    {
        try {
            
       test.startTest();
        Id contactRTID= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        List<Contact> getCont=[SELECT id,email,firstname,lastname,Frequent_Flyer_Number__c,QCC_Last_Activity_Date__c,QCC_Last_Flight_Date__c, QCC_Recent_Activity_Date__c,Source__c,QCC_TECH_FF_Number_External_Id__c,SSU__c FROM Contact WHERE Frequent_Flyer_Number__c!=null and recordtypeid=:contactRTID limit 1];

        
		database.executeBatch(new batchToMergeDuplicateFFConts(),100);
        test.stopTest();
    } catch (Exception ex) {
            System.debug('Exception Has Occurred'+ ex.getMessage());
    }
    }
}