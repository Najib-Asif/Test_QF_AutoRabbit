@isTest
public class batchToMergeDuplicateNonFFContsTest {

    @testSetup
    static void setup() {
        // Create test record type
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        
        List<Contact> contList=new List<Contact>();
        List<Contact> contList2=new List<Contact>();

        Contact cont=new Contact(firstname='Duplicate',lastname='Cont1',email='duplicate.cont1@qantas.com.au',phone='61123456789',Source__c='',SSU__c=false,recordtypeid=contactRTID);
        Contact cont4=new Contact(firstname='Duplicate',lastname='Cont1',email='duplicate.cont1@qantas.com.au',phone='+61123456789',QCC_Last_Activity_Date__c=system.today(),QCC_TECH_RecordType__c='Individual Contact',QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont5=new Contact(firstname='Duplicate',lastname='Cont1',email='duplicate.cont1@qantas.com.au',phone='61123456789',QCC_Last_Activity_Date__c=system.today(),QCC_TECH_RecordType__c='Individual Contact',QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID);
        Contact cont8=new Contact(firstname='Duplicate',lastname='Cont1',email='duplicate.cont1@qantas.com.au',phone='061123456789',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
        Contact cont9=new Contact(firstname='Duplicate',lastname='Cont1',email='duplicate.cont1@qantas.com.au',phone='61123456789',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
        Contact cont10=new Contact(firstname='Duplicate',lastname='Cont1',email='duplicate.cont1@qantas.com.au',phone='061123456789',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
       
        Contact cont2=new Contact(firstname='Duplicate',lastname='Cont2',email='duplicate.cont2@qantas.com.au',phone='61123456788',Source__c='',SSU__c=false,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
        Contact cont6=new Contact(firstname='Duplicate',lastname='Cont2',email='duplicate.cont2@qantas.com.au',phone='061123456788',Source__c='CAP',SSU__c=true,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
        Contact cont7=new Contact(firstname='Duplicate',lastname='Cont2',email='duplicate.cont2@qantas.com.au',phone='+61123456788',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
        
        Contact cont3=new Contact(firstname='Duplicate',lastname='Cont3',email='duplicate.cont3@qantas.com.au',phone='+61123846789',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
        Contact cont11=new Contact(firstname='Duplicate',lastname='Cont3',email='duplicate.cont3@qantas.com.au',phone='061123846789',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
        Contact cont12=new Contact(firstname='Duplicate',lastname='Cont3',email='duplicate.cont3@qantas.com.au',phone='61123846789',QCC_Last_Activity_Date__c=system.today(),QCC_Last_Flight_Date__c=system.today(),Source__c='CAP',SSU__c=true,recordtypeid=contactRTID,QCC_TECH_RecordType__c='Individual Contact');
        
        contList.add(cont);
        contList.add(cont2);
        contList.add(cont3);
        
        contList2.add(cont2);
        contList2.add(cont5);
        contList2.add(cont8);
        contList2.add(cont9);
        contList2.add(cont10);
        contList2.add(cont6);
        contList2.add(cont7);
        contList2.add(cont11);
        contList2.add(cont12);
        
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true; 
        
        Database.insert(contList, dml); 
        Database.insert(contList2, dml); 
       
        
        
    }

    @isTest
    static void testBatch() {
        // Start the test
        Test.startTest();

        // Execute the batch
         
         Database.executeBatch(new batchToMergeDuplicateNonFFConts(5));

        // Finish the test
        Test.stopTest();



    }
}