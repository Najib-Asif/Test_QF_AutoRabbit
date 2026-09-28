@isTest(SeeAllData = false)
private class QL_convertMemberCAPsearchControllerTest {
    @testSetup
    static void createData() {
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        Id ContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        List<Account> accList = new List<Account>();
        // Load Accounts
        accList = QL_TestUtilityData.getAccounts();
        Contact con = new Contact(AccountId=accList[0].Id,LastName='Sample', FirstName='User',Frequent_Flyer_Number__c = '12345678',Profile_Email__c ='test@abc.com', recordtypeid = ContRecordTypeId);
        Contact con1 = new Contact(LastName='Sample', FirstName='User',Frequent_Flyer_Number__c = '1234567890',Profile_Email__c ='test@abc.com', recordtypeid = ContRecordTypeId);
        List<Contact> conlist = new List<Contact>();
        conlist.add(con);
        conlist.add(con1);
        insert conlist;

    }
    static testMethod void validateTestData() 
    {
        List<Account> accList = new List<Account>();
        List<Associated_Person__c> Memberlist = new List<Associated_Person__c>();
        ID recID;
        
        // Load Accounts
        accList = QL_TestUtilityData.getAccounts();
        
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@test' + sandboxName + '.com'; 
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = uniqueName + '@test' + sandboxName + '.com'; 
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey = 'en_AU';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        u.CountryCode='AU';
        insert u;
        system.runAs(u) 
        {
            for(Integer i = 0; i < 5; i++) {
                Associated_Person__c  member = new Associated_Person__c(Account__c=accList[0].Id,Last_Name__c='Sample', First_Name__c='User',Frequent_Flyer_Number__c = '0002750079'+i,Profile_Email__c ='test@abc.com');
                
                Memberlist.add(member);
            }
            insert Memberlist;
            Test.starttest();
            String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';               
            Map<String, String> mapHeader= new Map<String, String>();
            mapHeader.put('Content-Type', 'application/json');
            try{
                for(Associated_Person__c eachMember : Memberlist)
                {
                    Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
                    recID = eachMember.id;
                    QL_convertMemberCAPsearchController.invokeWebServiceCAPSearch(recID);
                }
            }
            catch(Exception ex)
            {
                
            }
            Test.stoptest();
        }
    }
    
    static testMethod void validateTestNegativeData() 
    {
        List<Account> accList = new List<Account>();
        List<Associated_Person__c> Memberlist = new List<Associated_Person__c>();
        ID recID;
        
        // Load Accounts
        accList = QL_TestUtilityData.getAccounts();
        
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@test' + sandboxName + '.com'; 
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = uniqueName + '@test' + sandboxName + '.com'; 
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey = 'en_AU';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        u.CountryCode='AU';
        insert u;
        Id ContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        system.runAs(u) 
        {
           // Contact con = new Contact(AccountId=accList[0].Id,LastName='Sample', FirstName='User',Frequent_Flyer_Number__c = '12345678',Profile_Email__c ='test@abc.com', recordtypeid = ContRecordTypeId);
          //  insert con;
          //  system.debug('con'+con);
            List<Contact> existingcon = new List<Contact>();
            existingcon =[SELECT Id,Frequent_Flyer_Number__c,accountid FROM CONTACT WHERE Frequent_Flyer_Number__c='12345678'
                          AND RecordTypeId = :ContRecordTypeId];
            system.debug('existingcon ********'+existingcon);
            Associated_Person__c  member = new Associated_Person__c(Account__c=accList[0].Id,Last_Name__c='Sample', First_Name__c='User',Frequent_Flyer_Number__c = existingcon[0].Frequent_Flyer_Number__c,Profile_Email__c ='test@abc.com');                
            Memberlist.add(member);
            insert Memberlist;
            system.debug('memberlist'+Memberlist);
            Test.starttest();
            String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';               
            Map<String, String> mapHeader= new Map<String, String>();
            mapHeader.put('Content-Type', 'application/json');
            try{
                for(Associated_Person__c eachMember : Memberlist)
                {
                    Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
                    recID = eachMember.id;
                    QL_convertMemberCAPsearchController.invokeWebServiceCAPSearch(recID);
                }
            }
            catch(Exception ex)
            {
                
            }
            Test.stoptest();
        }
    }
        static testMethod void validateTestDatawithoutAccount() 
    {
        List<Account> accList = new List<Account>();
        List<Associated_Person__c> Memberlist = new List<Associated_Person__c>();
        ID recID;
        
        // Load Accounts
        accList = QL_TestUtilityData.getAccounts();
        
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@test' + sandboxName + '.com'; 
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = uniqueName + '@test' + sandboxName + '.com'; 
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey = 'en_AU';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        u.CountryCode='AU';
        insert u;
        Id ContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        system.runAs(u) 
        {
           // Contact con = new Contact(AccountId=accList[0].Id,LastName='Sample', FirstName='User',Frequent_Flyer_Number__c = '12345678',Profile_Email__c ='test@abc.com', recordtypeid = ContRecordTypeId);
          //  insert con;
          //  system.debug('con'+con);
            List<Contact> existingcon = new List<Contact>();
            existingcon =[SELECT Id,Frequent_Flyer_Number__c,accountid FROM CONTACT WHERE Frequent_Flyer_Number__c='1234567890'
                          AND RecordTypeId = :ContRecordTypeId];
            system.debug('existingcon ********'+existingcon);
            Associated_Person__c  member = new Associated_Person__c(Account__c=accList[0].Id,Last_Name__c='Sample', First_Name__c='User',Frequent_Flyer_Number__c = existingcon[0].Frequent_Flyer_Number__c,Profile_Email__c ='test@abc.com');                
            Memberlist.add(member);
            insert Memberlist;
            system.debug('memberlist'+Memberlist);
            Test.starttest();
            String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';               
            Map<String, String> mapHeader= new Map<String, String>();
            mapHeader.put('Content-Type', 'application/json');
            try{
                for(Associated_Person__c eachMember : Memberlist)
                {
                    Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
                    recID = eachMember.id;
                    QL_convertMemberCAPsearchController.invokeWebServiceCAPSearch(recID);
                }
            }
            catch(Exception ex)
            {
                
            }
            Test.stoptest();
        }
    }
    
}