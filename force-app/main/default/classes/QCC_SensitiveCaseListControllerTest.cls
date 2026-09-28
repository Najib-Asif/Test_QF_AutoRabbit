@isTest
private class QCC_SensitiveCaseListControllerTest {
    
    private static List<User> listUser = new List<User>();
    
    static {
        
        listUser = TestUtilityDataClassQantas.getUsers('Standard User', 'Department 1', 'QF');
        System.debug('=======listUser=========' + listUser);
        // Create Account
        System.runAs(listUser[0]){
            // create Case
            TestUtilityDataClassQantas.insertQantasConfigData();
            List<Trigger_Status__c> listTriggerConfigs = new List<Trigger_Status__c>();
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
            for(Trigger_Status__c triggerStatus : listTriggerConfigs){
                triggerStatus.Active__c = false;
            }
            insert listTriggerConfigs;
            
            //Fix for Jira(CRM-3702) - Prospect validation exception.
            List<Account> listAccountTest = new List<Account>();
            Id AccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
            
            for(Integer i=1; i<4; i++){ 
                Account acc = new Account(Name = 'Sample'+i, Active__c = true, Aquire__c = true, Type = 'Customer Account', 
                                          RecordTypeId = AccRecType, Migrated__c = false, 
                                          Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                          Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,ABN_Tax_Reference__c = '1234567890'+i  
                                         );
                listAccountTest.add(acc); 
            }
            
            insert listAccountTest;
            
            //List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
            listAccountTest[0].OwnerId = listUser[0].Id;
            update listAccountTest[0];
            // CRETAE contact
            List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
            String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
            Contact newContact = new Contact();
            newContact.RecordTypeId = contactRecordTypeId;
            newContact.AccountId = listAccountTest[0].Id;
            newContact.Function__c = 'IT';
            newContact.Business_Types__c = 'B&G';
            newContact.Job_Role__c ='BDM';
            newContact.Job_Title__c ='Developer';
            newContact.Phone='8907654321';
            newContact.Email='abc@gmail.com';
            newContact.FirstName = 'newContact';
            newContact.LastName = 'newContact';
            
            insert  newContact;
            
            // create case
            List<Case> listCaseTest = new List<Case>();
            
            listCaseTest.add(createSensitiveCase('caseTest1', listContactTest[0].Id,true));
            listCaseTest.add(createSensitiveCase('caseTest2', listContactTest[1].Id,true));
            listCaseTest.add(createSensitiveCase('caseTest2', newContact.Id,true));
            
            listCaseTest.add(createSensitiveCase('caseTest1', listContactTest[0].Id,false));
            listCaseTest.add(createSensitiveCase('caseTest2', listContactTest[1].Id,false));
            listCaseTest.add(createSensitiveCase('caseTest2', newContact.Id,false));
            
            insert listCaseTest;
        }
        
        
        
    }
    
    private static Case createSensitiveCase(String subject, String contactId, Boolean sensitive){
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
        cs.Subject = subject;
        cs.Origin = 'Qantas.com';
        cs.Booking_PNR__c = 'K5F5ZE';
        cs.Flight_Number__c = 'QF0401';
        cs.ContactId = contactId;
        cs.Airline__c = 'Qantas';
        cs.Suburb__c = 'NSW';
        cs.Street__c = 'Jackson';
        cs.State__c = 'Mascot';
        cs.Post_Code__c = '20020';
        cs.Country__c = 'Australia';
        cs.Cabin_Class__c = 'Business';
        cs.Sensitive__c = sensitive;
        //For sensitive Case validation error
        cs.Status = 'In Progress';
        
        return cs;
    }
    
    @isTest static void testGetListCaseWrapperAccountPageOwnerNotLoginUser() {
        List<Account> lstAccount = [SELECT Id FROM Account where OwnerId =: listUser[0].Id];
        
        Test.startTest();
        
        // Implement test code
        ApexPages.StandardController sc = new ApexPages.StandardController(lstAccount[0]);
        QCC_SensitiveCaseListController controller = new QCC_SensitiveCaseListController(sc);
        
        PageReference pageRef = Page.QCC_AccountSensitiveCaseList;
        pageRef.getParameters().put('id', String.valueOf(lstAccount[0].Id));
        Test.setCurrentPage(pageRef);
        Boolean isDisplayList = controller.getIsDisplay();
        System.assertEquals(false, isDisplayList);
        Test.stopTest();
    }
    
    @isTest static void testGetListCaseWrapperAccountPageOwnerLoginUser() {
        List<Account> lstAccount = [SELECT Id, OwnerId FROM Account where OwnerId =: listUser[0].Id Limit 1];
        System.runAs(listUser[0]){
            Test.startTest();
            // Implement test code
            ApexPages.StandardController sc = new ApexPages.StandardController(lstAccount[0]);
            QCC_SensitiveCaseListController controller = new QCC_SensitiveCaseListController(sc);
            
            PageReference pageRef = Page.QCC_AccountSensitiveCaseList;
            pageRef.getParameters().put('id', String.valueOf(lstAccount[0].Id));
            Test.setCurrentPage(pageRef);
            controller.initSensitiveCaseLayout();
            controller.getSensitiveCaseWrapperList();
            controller.getIsDisplay();
            controller.getTotalPages();
            controller.getTotalPages();
            controller.previous();
            controller.next();
            controller.getTotalRecord();
            system.assertEquals( false ,controller.hasPrevious);
            system.assertEquals( false ,controller.hasNext);
            system.assertEquals( 1 ,controller.pageNumber);
            Test.stopTest();
        }
        
    }
    
    @isTest static void testGetListCaseWrapperContactPage() {
        List<Contact> lstContact = [SELECT Id, OwnerId FROM Contact Limit 1];
        System.runAs(listUser[0]){
            Test.startTest();
            // Implement test code
            ApexPages.StandardController sc = new ApexPages.StandardController(lstContact[0]);
            QCC_SensitiveCaseListController controller = new QCC_SensitiveCaseListController(sc);
            
            PageReference pageRef = Page.QCC_AccountSensitiveCaseList;
            pageRef.getParameters().put('id', String.valueOf(lstContact[0].Id));
            Test.setCurrentPage(pageRef);
            controller.initSensitiveCaseLayout();
            controller.getSensitiveCaseWrapperList();
            controller.getIsDisplay();
            system.assertEquals( false ,controller.hasPrevious);
            system.assertEquals( false ,controller.hasNext);
            system.assertEquals( 1 ,controller.pageNumber);
            Test.stopTest();
        }
        
    }
    
    @isTest static void testGetListCaseWrapperAccountPageOwnerLoginUserNonSensitive() {
        List<Account> lstAccount = [SELECT Id, OwnerId FROM Account where OwnerId =: listUser[0].Id Limit 1];
        System.runAs(listUser[0]){
            Test.startTest();
            // Implement test code
            ApexPages.StandardController sc = new ApexPages.StandardController(lstAccount[0]);
            QCC_SensitiveCaseListController controller = new QCC_SensitiveCaseListController(sc);
            
            PageReference pageRef = Page.QCC_AccountSensitiveCaseList;
            pageRef.getParameters().put('id', String.valueOf(lstAccount[0].Id));
            Test.setCurrentPage(pageRef);
            controller.initNonSensitiveCaseLayout();
            controller.getSensitiveCaseWrapperList();
            controller.getIsDisplay();
            controller.getTotalPages();
            controller.getTotalPages();
            controller.previous();
            controller.next();
            controller.getTotalRecord();
            system.assertEquals( false ,controller.hasPrevious);
            system.assertEquals( false ,controller.hasNext);
            system.assertEquals( 1 ,controller.pageNumber);
            Test.stopTest();
        }
        
    }
    
}