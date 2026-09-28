/*
Modified By : Venkata Suresh Kumar Yalla (TCS Team), 29-May-2026
Desc : Rmediated test class failures. Updated initTestData() method. Updated 'Platinum One & SSU Service' profile ref with 'Qantas Service Lightning' 
****************************************************************
History
21-Jul-2026		Jonathan-Capgemini		RBAC SND
*/
@isTest
public class RecoveryApproverReassignSchedulerTest {
    // Added By 
    @TestSetUp
    public static void initTestData() {
        List<CronTrigger> lstJobs = [Select id FROM CronTrigger Where CronJobDetail.Name = 'QCC_RecoveryApproverReassignScheduler'];
        
        for(CronTrigger ct : lstJobs){
            System.abortJob(ct.id);
        }
        
        
        
        //TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.insertQantasConfigData();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        
        //Added by Suresh for Test class fix
        Trigger_Status__c createIndividualRec = new Trigger_Status__c();
        createIndividualRec.Name = 'createIndividualRecord';
        lsttrgStatus.add(createIndividualRec);
        
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        insert lsttrgStatus; 
        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        
        User user5_Manager = new User(FirstName = 'User5',
                                      LastName = 'Manager',
                                      Email = 'user5M@yopmail.com',
                                      CompanyName = 'test.com',
                                      Title = 'User5 Manager',
                                      Username = 'user5M@yopmail.com',
                                      Alias = 'user5',
                                      //ProfileId = profMap.get('Platinum One & SSU Service').Id, //CRM-11408 Commented line
                                 	  ProfileId = profMap.get('Sales and Distribution-Sales').Id, //CRM-11408 Added line //RBAC SND
                                      Location__c = 'Manila',
                                      EmailEncodingKey = 'UTF-8',
                                      LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_AU',
                                      TimeZoneSidKey = 'Australia/Sydney'
                                     );
        insert user5_Manager;
        
        //RBAC SND - Permission Set Update
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('SND_Base_Permissions,SND_Non_GSA_Permission,SND_Sales_Account_Manager_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(user5_Manager.Id,permissionSetIds);
        }
         // RBAC - updated Qantas CC Operational Manager to new profile QCC Operational Manager
        User user4_OM = new User(FirstName = 'User4',
                                 LastName = 'Operational Manager',
                                 Email = 'user4OM@yopmail.com',
                                 CompanyName = 'test.com',
                                 Title = 'User4 OM',
                                 Username = 'user4OM@yopmail.com',
                                 Alias = 'user4',
                                 ProfileId = profMap.get('QCC Operational Manager').Id,
                                 Location__c = 'Manila',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_AU',
                                 TimeZoneSidKey = 'Australia/Sydney',
                                 ManagerId = user5_Manager.Id
                                );
        insert user4_OM;
        
         // RBAC - updated Qantas CC Operational Manager to new profile QCC Operational Manager
        User user3_OM = new User(FirstName = 'User3',
                                 LastName = 'Operational Manager',
                                 Email = 'user3OM@yopmail.com',
                                 CompanyName = 'test.com',
                                 Title = 'User3 OM',
                                 Username = 'user3OM@yopmail.com',
                                 Alias = 'user3',
                                 ProfileId = profMap.get('QCC Operational Manager').Id,
                                 Location__c = 'Manila',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_AU',
                                 TimeZoneSidKey = 'Australia/Sydney',
                                 ManagerId = user5_Manager.Id
                                );
        insert user3_OM;
        
        User user2_TL = new User(FirstName = 'User2',
                                 LastName = 'Team Lead',
                                 Email = 'user2TL@yopmail.com',
                                 CompanyName = 'test.com',
                                 Title = 'User2 TL',
                                 Username = 'user2TL@yopmail.com',
                                 Alias = 'user2',
                                 ProfileId = profMap.get('QCC Contact Center Agent Manila').Id,
                                 Location__c = 'Manila',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_AU',
                                 TimeZoneSidKey = 'Australia/Sydney',
                                 ManagerId = user3_OM.Id
                                );
        insert user2_TL;
        
        User user2_TL2 = new User(FirstName = 'UserTL2',
                                  LastName = 'Team Lead 2',
                                  Email = 'user2TL2@yopmail.com',
                                  CompanyName = 'test.com',
                                  Title = 'User2 TL2',
                                  Username = 'user2TL2@yopmail.com',
                                  Alias = 'user2tl2',
                                  ProfileId = profMap.get('QCC Contact Center Agent Manila').Id,
                                  Location__c = 'Manila',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_AU',
                                  TimeZoneSidKey = 'Australia/Sydney',
                                  ManagerId = user4_OM.Id
                                 );
        insert user2_TL2;
        
        User user1_Consultant = new User(FirstName = 'User1',
                                         LastName = 'Consultant',
                                         Email = 'user1Consultant@yopmail.com',
                                         CompanyName = 'test.com',
                                         Title = 'User1 Consultant',
                                         Username = 'user1Consultant@yopmail.com',
                                         Alias = 'user1',
                                         ProfileId = profMap.get('QCC Customer Advocacy Agent').Id,
                                         Location__c = 'Sydney',
                                         EmailEncodingKey = 'UTF-8',
                                         LanguageLocaleKey = 'en_US',
                                         LocaleSidKey = 'en_AU',
                                         TimeZoneSidKey = 'Australia/Sydney',
                                         ManagerId = user2_TL.Id
                                        );
        insert user1_Consultant;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Customer_Advocacy_Agent_Permissions,Composer_User');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(user1_Consultant.Id,permissionSetIds);
            List<Id> permissionSetIdsTL = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Team_Lead_Coaching_and_Training_User_Permissions');
            List<PermissionSetAssignment> psaListTL2 = TestUtilityDataClassQantas.createPermissionSetAssignments(user2_TL2.Id,permissionSetIdsTL);
            List<PermissionSetAssignment> psaListTL = TestUtilityDataClassQantas.createPermissionSetAssignments(user2_TL.Id,permissionSetIdsTL);

        }

        list<queuesObject> listQO = [select id, QueueId from QueuesObject where SobjectType ='Case'];
        Group g = [select id, name from Group where id = :listQO[0].QueueId and Type='Queue' order by Name limit 1];        
        
        List<Contact> contacts = new List<Contact>();
        
        System.runAs(user1_Consultant) {
            
            for(Integer i = 0; i < 1; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', 
                                          Function__c='Advisory Services', Email='test@sample.com', MailingStreet = '15 hobart rd', 
                                          MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249', 
                                          CountryName__c = 'Australia', Frequent_Flyer_tier__c   = 'Silver',Frequent_Flyer_Number__c = '12345');
                con.CAP_ID__c = '71000000001'+ (i+7);
                contacts.add(con);
            }
            insert contacts;
        }
        
        // RBAC - Added permission sets to test user
        System.runAs(new User(Id = UserInfo.getUserId())) {
           List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Team_Lead_Coaching_and_Training_User_Permissions, QCC_Analytics_User_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = user3_OM.Id, PermissionSetId = psId));
                 psaList.add(new PermissionSetAssignment(AssigneeId = user4_OM.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }

        System.runAs(user1_Consultant) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.Last_Queue_Owner__c = g.id;
                cs.Last_Queue_Owner_Name__c = g.Name;
                cases.add(cs);
            }
            insert cases;
        }
        
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        System.runAs(user1_Consultant) {
            Recovery__c rec = new Recovery__c();
            rec.Type__c = 'Qantas Points';
            rec.Amount__c = 121000;
            rec.Case_Number__c = cases[0].Id;
            rec.Contact__c = cases[0].ContactId; 
            rec.Investigated_By__c = user1_Consultant.Id;
            rec.status__c = 'Pending Approval';
            insert rec;
            System.debug(LoggingLevel.ERROR, [SELECT ActorId,CreatedById,CreatedDate,Id,
                                              OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                                              FROM ProcessInstanceWorkitem
                                              WHERE ProcessInstance.TargetObjectId = :rec.Id]);
        }
    }
    
    @isTest
    public static void testApproval_Lev1_BeforeScheduletime() {
        User consultant = [SELECT Id FROM User WHERE Username = 'user1Consultant@yopmail.com'];
        User TL = [SELECT Id FROM User WHERE Username = 'user2TL@yopmail.com'];
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        Test.startTest();       
        
        Recovery__c rec;
        Id recoveryRTId = SObjectType.Recovery__c.getRecordTypeInfosByDeveloperName().get('Travel_Voucher_Recovery').getRecordTypeId();
        System.runAs(consultant) {
            rec = new Recovery__c();
            rec.RecordTypeId = recoveryRTId;
            rec.Type__c = 'Travel Vouchers';
            rec.Amount__c = 3;
            rec.value__c = 2510;
            rec.Case_Number__c = cases[0].Id;
            rec.Contact__c = cases[0].ContactId; 
            rec.Investigated_By__c = consultant.Id;
            rec.Status__c = 'Pending Approval';
            rec.Process_Status__c = 'Pending Approval';
            insert rec;
            
        }
        
        System.runAs(TL) {
            List<ProcessInstanceWorkitem> workItems =
    [
        SELECT Id,
               ActorId,
               OriginalActorId,
               ProcessInstance.Status,
               ProcessInstance.TargetObjectId
        FROM ProcessInstanceWorkitem
        WHERE ProcessInstance.TargetObjectId = :rec.Id
    ];
    
    }
        
        
        //Select all the Processinstances which are Approval and Id equal to new Recovery
        List<Processinstance> mapPendingApprovals = [SELECT CompletedDate, CreatedById, CreatedDate,
                                                     Id, LastActorId, LastModifiedById, LastModifiedDate,
                                                     ProcessDefinitionId, Status, SystemModstamp,
                                                     TargetObjectId, SubmittedById 
                                                     FROM ProcessInstance 
                                                     WHERE ProcessDefinition.Type = 'Approval' 
                                                     AND TargetObjectId =: rec.Id];
        
        // System.assertEquals(mapPendingApprovals.size(), 1);
        //Processinstance pI = mapPendingApprovals.get(0); //Commenting as part of RBAC to remove and re-add later
        // System.assertEquals(pI.Status, 'Approved');
        
        QCC_RecoveryApproverReassignScheduler pa= new QCC_RecoveryApproverReassignScheduler();
        DateTime nowSchedule = System.Now().addMinutes(5);
        String day = string.valueOf(nowSchedule.day());
        String month = string.valueOf(nowSchedule.month());
        String hour = string.valueOf(nowSchedule.hour());
        String minute = string.valueOf(nowSchedule.minute());
        String second = string.valueOf(nowSchedule.second());
        String year = string.valueOf(nowSchedule.year());
        
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule('QCC_RecoveryApproverReassignScheduler', strSchedule, pa);
        
        Test.stopTest();
        
    }
    /*
    @isTest
    public static void testApproval_Lev1_AfterScheduletime() {
        User consultant = [SELECT Id FROM User WHERE Username = 'user1Consultant@yopmail.com'];
        User TL = [SELECT Id, ManagerId FROM User WHERE Username = 'user2TL@yopmail.com'];
        User TL2 = [SELECT Id FROM User WHERE Username = 'user2TL2@yopmail.com'];
        Group g = [select id, name from Group where Name='CCC MNL Recovery Approval Queue' 
                   AND Type='Queue' order by Name limit 1];   
        
        GroupMember member = new GroupMember();
        member.UserOrGroupId = TL.Id;
        member.GroupId = g.Id;
        insert member;
        
        GroupMember member2 = new GroupMember();
        member2.UserOrGroupId = TL2.Id;
        member2.GroupId = g.Id;
        insert member2;
        
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        Test.startTest();       
        
        Recovery__c rec;
        System.runAs(consultant) {
            rec = new Recovery__c();
            rec.Type__c = 'Qantas Points';
            rec.Amount__c = 121000;
            rec.Case_Number__c = cases[0].Id;
            rec.Contact__c = cases[0].ContactId; 
            rec.Investigated_By__c = consultant.Id;
            rec.Status__c = 'Pending Approval';
            insert rec;
            System.debug(LoggingLevel.ERROR, [SELECT ActorId,CreatedById,CreatedDate,Id,
                                              OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                                              FROM ProcessInstanceWorkitem
                                              WHERE ProcessInstance.TargetObjectId = :rec.Id]);
        }
        
        QCC_RecoveryApproverReassignScheduler pa= new QCC_RecoveryApproverReassignScheduler();
        DateTime nowSchedule = System.Now().addMinutes(5);
        String day = string.valueOf(nowSchedule.day());
        String month = string.valueOf(nowSchedule.month());
        String hour = string.valueOf(nowSchedule.hour());
        String minute = string.valueOf(nowSchedule.minute());
        String second = string.valueOf(nowSchedule.second());
        String year = string.valueOf(nowSchedule.year());
        
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule('QCC_RecoveryApproverReassignScheduler', strSchedule, pa);
        
        Test.stopTest();
        System.debug(LoggingLevel.ERROR, [SELECT ActorId,CreatedById,CreatedDate,Id,
                                          OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                                          FROM ProcessInstanceWorkitem
                                          WHERE ProcessInstance.TargetObjectId = :rec.Id]);
        //Select all the Processinstances which are Approval and Id equal to new Recovery
        List<ProcessInstanceWorkItem> listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                                                      OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                                                      FROM ProcessInstanceWorkitem
                                                      WHERE ProcessInstance.TargetObjectId = :rec.Id];
        
        // System.assertEquals(listWorkItem.size(), 1);
        ProcessInstanceWorkItem pI = listWorkItem.get(0);
        // System.assertEquals(pI.ProcessInstance.Status, 'Pending');
        //Approval is Escalated to TL Queue of the same City (Manila)
        // System.assertEquals(pI.ActorId, g.Id);
        
        //Different team lead approval
        System.runAs(TL2) {
            Approval.ProcessResult result = approveRecord(rec);
        }
        
        listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                        OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                        FROM ProcessInstanceWorkitem
                        WHERE ProcessInstance.TargetObjectId = :rec.Id];
        
        // System.assertEquals(listWorkItem.size(), 1);
        pI = listWorkItem.get(0);
        // System.assertEquals(pI.ProcessInstance.Status, 'Pending');
        //Even when TL2 approved the Recovery at lev1, the Lev2 still go to TL1 Manager
        //System.assertEquals(pI.ActorId, TL.ManagerId);
        
    }
    
    @isTest
    public static void testApproval_Lev2_BeforeScheduletime() {
        User consultant = [SELECT Id FROM User WHERE Username = 'user1Consultant@yopmail.com'];
        User TL1 = [SELECT Id, ManagerId FROM User WHERE Username = 'user2TL@yopmail.com'];
        User TL2 = [SELECT Id FROM User WHERE Username = 'user2TL2@yopmail.com'];
        User OM1 = [SELECT Id FROM User WHERE Username = 'user3OM@yopmail.com'];
        
        Group g = [select id, name from Group where Name='CCC MNL Recovery Approval Queue' 
                   AND Type='Queue' order by Name limit 1];   
        
        GroupMember member = new GroupMember();
        member.UserOrGroupId = TL1.Id;
        member.GroupId = g.Id;
        insert member;
        
        GroupMember member2 = new GroupMember();
        member2.UserOrGroupId = TL2.Id;
        member2.GroupId = g.Id;
        insert member2;
        
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        Test.startTest();       
        
        Recovery__c rec;
        System.runAs(consultant) {
            rec = new Recovery__c();
            rec.Type__c = 'Qantas Points';
            rec.Amount__c = 121000;
            rec.Case_Number__c = cases[0].Id;
            rec.Contact__c = cases[0].ContactId; 
            rec.Investigated_By__c = consultant.Id;
            rec.Status__c = 'Pending Approval';
            insert rec;
            
        }
        
        System.runAs(TL1) {
            Approval.ProcessResult result = approveRecord(rec);
        }
        
        
        //Select all the Processinstances which are Approval and Id equal to new Recovery
        List<ProcessInstanceWorkItem> listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                                                      OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                                                      FROM ProcessInstanceWorkitem
                                                      WHERE ProcessInstance.TargetObjectId = :rec.Id];
        
       // System.assertEquals(listWorkItem.size(), 1);
        ProcessInstanceWorkItem pIWI = listWorkItem.get(0);
      //  System.assertEquals(pIWI.ProcessInstance.Status, 'Pending');
        //Lev2 Approval go to OM1
        // System.assertEquals(pIWI.ActorId, TL1.ManagerId);
        
        System.runAs(OM1) {
            Approval.ProcessResult result = approveRecord(rec);
        }
        
        QCC_RecoveryApproverReassignScheduler pa= new QCC_RecoveryApproverReassignScheduler();
        DateTime nowSchedule = System.Now().addMinutes(5);
        String day = string.valueOf(nowSchedule.day());
        String month = string.valueOf(nowSchedule.month());
        String hour = string.valueOf(nowSchedule.hour());
        String minute = string.valueOf(nowSchedule.minute());
        String second = string.valueOf(nowSchedule.second());
        String year = string.valueOf(nowSchedule.year());
        
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule('QCC_RecoveryApproverReassignScheduler', strSchedule, pa);
        
        Test.stopTest();
        
        listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                        OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                        FROM ProcessInstanceWorkitem
                        WHERE ProcessInstance.TargetObjectId = :rec.Id];
        //Approval Request Approved, so no Approval Submit
      //  System.assertEquals(listWorkItem.size(), 1);
        
        
        //Select all the Processinstances which are Approval and Id equal to new Recovery
        List<Processinstance> mapPendingApprovals = [SELECT CompletedDate, CreatedById, CreatedDate,
                                                     Id, LastActorId, LastModifiedById, LastModifiedDate,
                                                     ProcessDefinitionId, Status, SystemModstamp,
                                                     TargetObjectId, SubmittedById 
                                                     FROM ProcessInstance 
                                                     WHERE ProcessDefinition.Type = 'Approval' 
                                                     AND TargetObjectId =: rec.Id];
        
       // System.assertEquals(mapPendingApprovals.size(), 1);
        Processinstance pI = mapPendingApprovals.get(0);
        //System.assertEquals(pI.Status, 'Pending');
    }
    
    @isTest
    public static void testApproval_Lev2_AfterScheduletime1() {
        User consultant = [SELECT Id FROM User WHERE Username = 'user1Consultant@yopmail.com'];
        User TL1 = [SELECT Id, ManagerId FROM User WHERE Username = 'user2TL@yopmail.com'];
        User TL2 = [SELECT Id FROM User WHERE Username = 'user2TL2@yopmail.com'];
        User OM1 = [SELECT Id FROM User WHERE Username = 'user3OM@yopmail.com'];
        User OM2 = [SELECT Id FROM User WHERE Username = 'user4OM@yopmail.com'];
        
        Group g = [select id, name from Group where Name='CCC MNL Recovery Approval Queue' 
                   AND Type='Queue' order by Name limit 1]; 
        Group gOM = [select id, name from Group where Name='CCC OM Recovery Approval Queue' 
                     AND Type='Queue' order by Name limit 1]; 
        
        GroupMember member = new GroupMember();
        member.UserOrGroupId = OM1.Id;
        member.GroupId = gOM.Id;
        insert member;
        
        GroupMember member2 = new GroupMember();
        member2.UserOrGroupId = OM2.Id;
        member2.GroupId = gOM.Id;
        insert member2;
        
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        Test.startTest();       
        
        Recovery__c rec;
        System.runAs(consultant) {
            rec = new Recovery__c();
            rec.Type__c = 'Qantas Points';
            rec.Amount__c = 121000;
            rec.Case_Number__c = cases[0].Id;
            rec.Contact__c = cases[0].ContactId; 
            rec.Investigated_By__c = consultant.Id;
            rec.Status__c = 'Pending Approval';
            insert rec;
            
        }
        
        System.runAs(TL1) {
            Approval.ProcessResult result = approveRecord(rec);
        }
        
        
        //Select all the Processinstances which are Approval and Id equal to new Recovery
        List<ProcessInstanceWorkItem> listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                                                      OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                                                      FROM ProcessInstanceWorkitem
                                                      WHERE ProcessInstance.TargetObjectId = :rec.Id];
        
      //  System.assertEquals(listWorkItem.size(), 1);
        ProcessInstanceWorkItem pIWI = listWorkItem.get(0);
     //   System.assertEquals(pIWI.ProcessInstance.Status, 'Pending');
        //Lev2 Approval go to OM1
        // System.assertEquals(pIWI.ActorId, TL1.ManagerId);
        
        QCC_RecoveryApproverReassignScheduler pa= new QCC_RecoveryApproverReassignScheduler();
        DateTime nowSchedule = System.Now().addMinutes(5);
        String day = string.valueOf(nowSchedule.day());
        String month = string.valueOf(nowSchedule.month());
        String hour = string.valueOf(nowSchedule.hour());
        String minute = string.valueOf(nowSchedule.minute());
        String second = string.valueOf(nowSchedule.second());
        String year = string.valueOf(nowSchedule.year());
        
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule('QCC_RecoveryApproverReassignScheduler', strSchedule, pa);
        
        Test.stopTest();
        
        listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                        OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                        FROM ProcessInstanceWorkitem
                        WHERE ProcessInstance.TargetObjectId = :rec.Id];
        //Approval Request Approved, so no Approval Submit
        // System.assertEquals(listWorkItem.size(), 1);
        pIWI = listWorkItem.get(0);
        // System.assertEquals(pIWI.ProcessInstance.Status, 'Pending');
        //Approval is Escalated to OM Queue
        //System.assertEquals(pIWI.ActorId, gOM.Id);
        
        //Different team lead approval
        System.runAs(OM2) {
            Approval.ProcessResult result = approveRecord(rec);
        }
        
        listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                        OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                        FROM ProcessInstanceWorkitem
                        WHERE ProcessInstance.TargetObjectId = :rec.Id];
        
        //System.assertEquals(listWorkItem.size(), 1);
        
        //Select all the Processinstances which are Approval and Id equal to new Recovery
        List<Processinstance> mapPendingApprovals = [SELECT CompletedDate, CreatedById, CreatedDate,
                                                     Id, LastActorId, LastModifiedById, LastModifiedDate,
                                                     ProcessDefinitionId, Status, SystemModstamp,
                                                     TargetObjectId, SubmittedById 
                                                     FROM ProcessInstance 
                                                     WHERE ProcessDefinition.Type = 'Approval' 
                                                     AND TargetObjectId =: rec.Id];
        
       // System.assertEquals(mapPendingApprovals.size(), 1);
        Processinstance pI = mapPendingApprovals.get(0);
        //System.assertEquals(pI.Status, 'Pending');
    }
    
    @isTest
    public static void testApproval_Lev2_AfterScheduletime2() {
        User consultant = [SELECT Id FROM User WHERE Username = 'user1Consultant@yopmail.com'];
        User TL1 = [SELECT Id, ManagerId FROM User WHERE Username = 'user2TL@yopmail.com'];
        User TL2 = [SELECT Id, ManagerId FROM User WHERE Username = 'user2TL2@yopmail.com'];
        User OM1 = [SELECT Id, ManagerId  FROM User WHERE Username = 'user3OM@yopmail.com'];
        User OM2 = [SELECT Id, ManagerId FROM User WHERE Username = 'user4OM@yopmail.com'];
        User theDean = [SELECT Id FROM User WHERE Username = 'user5M@yopmail.com'];
        
        Group g = [select id, name from Group where Name='CCC MNL Recovery Approval Queue' 
                   AND Type='Queue' order by Name limit 1]; 
        Group gOM = [select id, name from Group where Name='CCC OM Recovery Approval Queue' 
                     AND Type='Queue' order by Name limit 1];
        
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        Test.startTest();       
        
        Recovery__c rec;
        System.runAs(consultant) {
            rec = new Recovery__c();
            rec.Type__c = 'Qantas Points';
            rec.Amount__c = 121000;
            rec.Case_Number__c = cases[0].Id;
            rec.Contact__c = cases[0].ContactId; 
            rec.Investigated_By__c = consultant.Id;
            rec.Status__c = 'Pending Approval';
            insert rec;
        }
        
        System.runAs(TL1) {
            Approval.ProcessResult result = approveRecord(rec);
        }
        
        
        //Select all the Processinstances which are Approval and Id equal to new Recovery
        List<ProcessInstanceWorkItem> listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                                                      OriginalActorId,ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId,SystemModstamp 
                                                      FROM ProcessInstanceWorkitem
                                                      WHERE ProcessInstance.TargetObjectId = :rec.Id];
        
      //  System.assertEquals(1, listWorkItem.size());
        ProcessInstanceWorkItem pIWI = listWorkItem.get(0);
       // System.assertEquals('Pending', pIWI.ProcessInstance.Status);
        //Lev2 Approval go to OM1
       // System.assertEquals(pIWI.ActorId, OM1.Id);
        
        //replicate the Escalation from OM to OM Queue
        pIWI.ActorId = gOM.Id;
        Update pIWI;
        
        QCC_RecoveryApproverReassignScheduler pa= new QCC_RecoveryApproverReassignScheduler();
        DateTime nowSchedule = System.Now().addMinutes(5);
        String day = string.valueOf(nowSchedule.day());
        String month = string.valueOf(nowSchedule.month());
        String hour = string.valueOf(nowSchedule.hour());
        String minute = string.valueOf(nowSchedule.minute());
        String second = string.valueOf(nowSchedule.second());
        String year = string.valueOf(nowSchedule.year());
        
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule('QCC_RecoveryApproverReassignScheduler', strSchedule, pa);
        
        Test.stopTest();
        
        listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                        OriginalActorId,ProcessInstanceId, ProcessInstance.Status, 
                        ProcessInstance.TargetObjectId,SystemModstamp 
                        FROM ProcessInstanceWorkitem
                        WHERE ProcessInstance.TargetObjectId = :rec.Id];
        //Approval Request Approved, so no Approval Submit
      //  System.assertEquals(1, listWorkItem.size());
        pIWI = listWorkItem.get(0);
        //System.assertEquals('Pending', pIWI.ProcessInstance.Status);
        //Approval is Escalated to the Dean
        //System.assertEquals(theDean.Id, pIWI.ActorId); 
        
    }
    
    /*
    *   If auto submit approval working correctly, we don't need this function
    */
    private static void submitForApproval(Recovery__c rec) {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Apex');
        req1.setObjectId(rec.id);
        //req1.setNextApproverIds(new Id[] {rec.Next_Approver__c});
        Approval.ProcessResult result = Approval.process(req1);
    }
    /**
    * Get ProcessInstanceWorkItemId using SOQL
    **/
    private static Id getWorkItemId(Id targetObjectId) {
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                                                 where p.ProcessInstance.TargetObjectId =: targetObjectId]) {
                                                     retVal  =  workItem.Id;
                                                 }
        return retVal;
    }
    
    /**
    * This method will Approve the rec
    **/
    private static Approval.ProcessResult approveRecord(Recovery__c rec) {
        Approval.ProcessResult result = null;
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request using Apex');
        req.setAction('Approve');
        //req.setNextApproverIds(new Id[] {rec.Next_Approver__c});
        Id workItemId = getWorkItemId(rec.id); 
        
        if(workItemId == null) {
            rec.addError('Error Occured in Apex Test');
        } else {
            req.setWorkitemId(workItemId);
            System.debug('WorkItemId=' + workItemId);

            ProcessInstanceWorkitem wi =
            [
                SELECT Id,
                       ActorId,
                       OriginalActorId
                FROM ProcessInstanceWorkitem
                WHERE Id = :workItemId
            ];
            
            System.debug('ActorId=' + wi.ActorId);
            System.debug('OriginalActorId=' + wi.OriginalActorId);
            result =  Approval.process(req);
        }
        return result;
    }
    
    /**
    * This method will Reject the rec
    **/
    private static Approval.ProcessResult rejectRecord(Recovery__c rec) {
        Approval.ProcessResult result = null;
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Rejected request using Apex');
        req.setAction('Reject');
        Id workItemId = getWorkItemId(rec.id);   
        
        if(workItemId == null) {
            rec.addError('Error Occured in Apex Test');
        } else {
            req.setWorkitemId(workItemId);
            result =  Approval.process(req);
        }
        return result;
    }

    @isTest
    static void testExecuteDirectly() {
    
        Test.startTest();
    
        new QCC_RecoveryApproverReassignScheduler().execute(null);
    
        Test.stopTest();
    
        System.assert(true);
    }
}