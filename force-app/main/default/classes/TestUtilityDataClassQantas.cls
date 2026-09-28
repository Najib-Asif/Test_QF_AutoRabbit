/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Generic TestData creation Class
Inputs:
Test Class:    Not Required   
************************************************************************************************
History
************************************************************************************************
28-Oct-2017    Praveen Sampath   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class TestUtilityDataClassQantas{
    
    public static String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
    //GRAPHITE-154/155: Contact Model Redesign - Add recordtype for Person Account
    public static String personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
    public static String customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static String aquireRecordTypeId = Schema.SObjectType.Product_Registration__c.getRecordTypeInfosByName().get('Aquire Registration').getRecordTypeId();
    public static String amexRecordTypeId = Schema.SObjectType.Product_Registration__c.getRecordTypeInfosByName().get('AEQCC Registration').getRecordTypeId(); 
    public static String qbdRecordTypeId = Schema.SObjectType.Product_Registration__c.getRecordTypeInfosByName().get('QBD Registration').getRecordTypeId();
    public static String businessGovRTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business and Government').getRecordTypeId();
    public static String contactRTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
    public static String signedByCustId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('CA - Signed by Customer').getRecordTypeId();

    // Get Account records
    public static List<Account> getAccounts(){
        createQantasConfigDataAccRecType();
        List<Account> accList = new List<Account>();
        
        for(Integer i=1; i<4; i++){ 
            Account acc = new Account(Name = 'Sample'+i, Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,ABN_Tax_Reference__c = '12345678901'
                                     );
            accList.add(acc);
        }   
        
        try{
            Database.Insert(accList);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return accList;
    }
    
    // Get Contacts to the given Accounts
    public static List<Contact> getContacts(List<Account> accList){
        List<Contact> contactList = new List<Contact>();
        Id recid = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        for(Account acc : accList){
            Contact con = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id,Function__c = 'IT',Business_Types__c = 'B&G',Job_Role__c ='BDM',Job_Title__c ='Developer',Phone='8907654321',Email='abc@gmail.com',RecordTypeId = recid,MailingCountry = 'AU',MailingStreet = 'xyz',MailingCity = 'abc',MailingState = 'VIC',MailingPostalCode = '123456',Salutation ='Mr.');            contactList.add(con);
        }
        
        try{
            Database.Insert(contactList);
        }catch(Exception e){
            System.debug('Error Occure: '+e.getMessage());
        }
        return contactList;
    }

//GRAPHITE-934 Create a new method to generate contact record for Account list.
    public static List<Contact> getIndividualContacts(List<Account> accList){ 
        List<Contact> contactList = new List<Contact>(); 
 
        for(Account acc : accList){ 
            Contact con = createIndividualContact(acc.Id); 
            contactList.add(con); 
        } 
 
        try{ 
            Database.Insert(contactList); 
        }catch(Exception e){ 
            System.debug('Error Occure: '+e.getMessage()); 
        } 
        return contactList; 
    } 

    
    // Get Opportunities to the given Accounts
    public static List<Opportunity> getOpportunities(List<Account> accList){
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Account acc: accList){
            Opportunity opp = new Opportunity(Name = 'Opp'+acc.Name , AccountId = acc.Id,
                                              Amount = 500000, Category__c = 'Corporate Airfares', CloseDate = Date.Today(),
                                              StageName = 'Qualify'
                                             );
            oppList.add(opp);
        }
        
        try{
            Database.Insert(oppList);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
        return oppList;
    }
    
    // Get Proposal & Discount List to the given Opportunity
    public static List<Proposal__c> getProposal(List<Opportunity> oppList){
        List<Proposal__c> propList = new List<Proposal__c>();
        List<Discount_List__c> discList = new List<Discount_List__c>();
        List<Fare_Structure__c > faresList = new List<Fare_Structure__c >();
        List<Standard_Discount_Guidelines__c> stdgList = new List<Standard_Discount_Guidelines__c>();
        
        for(Opportunity opp: oppList){
            Proposal__c prop = new Proposal__c(Name = 'Proposal '+opp.Name , Account__c = opp.AccountId, Opportunity__c = opp.Id,
                                               Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                               Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',
                                               MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),
                                               Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Draft',
                                               NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                               DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                               Approval_Required_Others__c = false, QL_Discount_Model__c='Tiered',Forecast_MCA_Revenue__c=20000
                                              );
            propList.add(prop);
        }
        
        try{
            Database.Insert(propList);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
        
        // Fares
        Fare_Structure__c fs = new Fare_Structure__c(Name = 'J', Active__c = true, Cabin__c = 'Business', 
                                                     Category__c = 'Mainline', Market__c = 'Australia', 
                                                     ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                     Segment__c = 'Domestic'
                                                    );
        faresList.add(fs);                                             
        try{
            Database.Insert(faresList);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        
        // Standard Discount Guidelines
        Standard_Discount_Guidelines__c sd = new Standard_Discount_Guidelines__c(Discount_Threshold_AM__c = 14, Discount_Threshold_NAM__c = 17,
                                                                                 Fare_Combination__c = 'Mainline - H in B deal', Fare_Structure__c = fs.Id,
                                                                                 Maximum_Revenue__c = 999999, Minimum_Revenue__c = 300000
                                                                                );
        try{
            Database.Insert(sd);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }        
        // Discount List
        for(Proposal__c prop: propList){
            for(Fare_Structure__c fr : faresList){
                Discount_List__c disc = new Discount_List__c(FareStructure__c = fr.Id, Proposal__c = prop.Id, 
                                                             Qantas_Published_Airfare__c = fr.Qantas_Published_Airfare__c, 
                                                             Fare_Combination__c = 'Mainline - H in B deal', Segment__c = fr.Segment__c,
                                                             Category__c = fr.Category__c, Network__c = fr.Network__c, 
                                                             Market__c = fr.Market__c, Cabin__c = fr.Cabin__c, 
                                                             Proposal_Type__c = prop.Type__c, Discount__c = 40,
                                                             Approved_by_NAM__c = false, Approved_by_Pricing__c = false,
                                                             DO_Approved__c = false, TeamLead_Approved__c = false,QL_Tier_1_Offering__c=6
                                                            	
                                                            );
                discList.add(disc);
            }            
        }
        
        
        
        
                List<QEC_Special_Condition__c> splconditionList = new List<QEC_Special_Condition__c>();

        for(Proposal__c prop: propList){
        
            QEC_Special_Condition__c condition1 = new QEC_Special_Condition__c(QEC_Baggagecode__c='ABCDE',QEC_BlockRevenueTarget__c=2.0,QEC_Blocksize__c='TEMP',QEC_Cancellation__c='As per published',
                                                                               QEC_Conditions__c='NIL',QEC_DayofWeek__c='TUESDAY',QEC_Discount__c=13.22,QEC_FarebasisFarerulenumber__c='354',QEC_FareBasis__c='TEST',QEC_History__c=False,
                                                                               QEC_Flightnumber__c='QEC225',QEC_FromDate__c =System.today() + 5,QEC_HourDay__c='Hours',QEC_KgPc__c='Kg',QEC_Network__c='Domestic',QEC_NoShow__c='Allowed',QEC_Numberofpieces__c=12,
                                                                               QEC_Route__c='SINGAPORE',QEC_TimefromDeparture__c=12.30,QEC_ToDate__c = System.today() +10,QEC_Type__c='JQ Inclusion', Proposal__c=prop.id);
            splconditionList.add(condition1);
        }
        
        
        
        try{
            Database.Insert(discList);
             Database.Insert(splconditionList);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
        
        return propList;
    }
    
    // Get Contracts by giving proposals as input
    public static List<Contract__c> getContracts(List<Proposal__c> propList){
        List<Contract__c> contrList = new List<Contract__c>();
        Boolean b = false;
        for(Proposal__c opp: propList){
            Contract__c contr = new Contract__c(Name = 'Contract '+opp.Name , Account__c = opp.Account__c, Opportunity__c = opp.Opportunity__c, Proposal__c = opp.Id,
                                                Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                                Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = b,
                                                MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = Date.Today(),
                                                Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer',                             
                                                Domestic_Amendment__c='Penalties',International_Amendment__c='Singapore',General__c='Renewal',QL_Discount_Model__c ='Tiered',QL_Effective_Tier__c ='Tier 1'
                                              );
            b = true;
            contrList.add(contr);
        }
        
        try{
            Database.Insert(contrList);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
        return contrList;
    }
    
    // Get Members by giving Accounts
    public static List<Associated_Person__c> getMembers(List<Account> accList){
        List<Associated_Person__c> memberList = new List<Associated_Person__c>();
        for(Account acc : accList){
            memberList.add(new Associated_Person__c( Account__c = acc.Id, Last_Name__c = 'Member'+acc.Name, First_Name__c = 'Praveen'+acc.Name,
                                                    Frequent_Flyer_Number__c = '7799339937', Active_Profile_Record__c = false,
                                                    Active_QBD_Record__c = false, QBD_Last_Name__c = 'Member'+acc.Name, Salutation__c = 'Mr',
                                                    Sync_Traveller_Override__c = false, Start_Date__c = Date.Today()
                                                   ));
        }
        
        try{
            Database.Insert(memberList);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }        
        return memberList;
    }
    
    // Get Cases by giving Accounts
    public static List<Case> getCases(List<Account> accList){
        List<Case> caseList = new List<Case>();
        for(Account acc : accList){
            caseList.add(new Case(AccountId = acc.Id, Type = 'New Traveller',
                                  Sub_Type__c = 'New QBD Traveller added', Status= 'New',
                                  Frequent_Flyer_Number__c = '7799339937'
                                 ));            
        }
        try{
            Database.Insert(caseList);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        } 
        return caseList;
    }
    
    public static List<Opportunity_Maintenance__c> getOpportunityMaintenance(){
        
        List<Opportunity_Maintenance__c> OpptyMainList = new List<Opportunity_Maintenance__c>();
        OpptyMainList.add(new Opportunity_Maintenance__c(Name = 'Sample', Active__c = TRUE, Category__c = 'Corporate Airfares', Create_an_Opportunity_before_in_months__c = 1, 
                                                         Close_Date__c = Date.Today()));
        OpptyMainList.add(new Opportunity_Maintenance__c(Name = 'Sample', Active__c = TRUE, Category__c = 'Qantas Business Savings', Create_an_Opportunity_before_in_months__c = 1, 
                                                         Close_Date__c = Date.Today()));
        try{
            Database.Insert(OpptyMainList);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return OpptyMainList;
    }
    
    public static Map<String, Opportunity_main__c> getOpportunityMaintenanceMap(){
        Map<String, Opportunity_main__c> opptymaintenanceMap = new Map<String, Opportunity_main__c>();  
        List<Opportunity_main__c> OpptyMainList = new List<Opportunity_main__c>();
           
        OpptyMainList.add(new Opportunity_main__c(Name = 'Corporate Airfares', Active__c = TRUE, Category__c = 'Corporate Airfares', Create_an_Opportunity_before_in_months__c = 1, 
                                                         Close_Date__c = Date.today().addDays(1))); 
                                                         
        OpptyMainList.add(new Opportunity_main__c(Name = 'Qantas Business Savings', Active__c = TRUE, Category__c = 'Qantas Business Savings', Create_an_Opportunity_before_in_months__c = 1, 
                                                         Close_Date__c = Date.today().addDays(1)));                                                 
        try{
            Database.Insert(OpptyMainList);
            for (Opportunity_main__c op : OpptyMainList){
                opptymaintenanceMap.put(op.Name, op);
            }
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
            return opptymaintenanceMap;
    }
    
    public static List<Opportunity_Maintenance__c> getOpportunityMaintenanceforQBS(){
        List<Opportunity_Maintenance__c> OpptyMainList1 = new List<Opportunity_Maintenance__c>();
        
        OpptyMainList1.add(new Opportunity_Maintenance__c(Name = 'Sample2', Active__c = TRUE, Category__c = 'Qantas Business Savings', Create_an_Opportunity_before_in_months__c = 6, 
                                                          Close_Date__c = Date.Today()));
        
        try{
            Database.Insert(OpptyMainList1);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return OpptyMainList1;
    }
    
    public static List<Opportunity_Maintenance__c> getOpportunityMaintenanceforCA(){
        List<Opportunity_Maintenance__c> OpptyMainList1 = new List<Opportunity_Maintenance__c>();
        
        OpptyMainList1.add(new Opportunity_Maintenance__c(Name = 'Sample2', Active__c = TRUE, Category__c = 'Corporate Airfares', Create_an_Opportunity_before_in_months__c = 6, 
                                                          Close_Date__c = Date.Today()));
        
        try{
            Database.Insert(OpptyMainList1);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return OpptyMainList1;
    }
    
    

   /* public static Map<Id, Opportunity_Maintenance__c> getOpportunityMaintenanceforQBSMap(){
        Map<Id, Opportunity_Maintenance__c> opptymaintenanceMap = new Map<Id, Opportunity_Maintenance__c>();  
        List<Opportunity_Maintenance__c> OpptyMainList = new List<Opportunity_Maintenance__c>();
           
        OpptyMainList.add(new Opportunity_Maintenance__c(Name = 'Sample', Active__c = TRUE, Category__c = 'Qantas Business Savings', Create_an_Opportunity_before_in_months__c = 1, 
                                                         Close_Date__c = Date.today())); 
                                                        
        try{
            Database.Insert(OpptyMainList);
            for (Opportunity_Maintenance__c op : OpptyMainList){
                opptymaintenanceMap.put(op.Id, op);
            }
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
            return opptymaintenanceMap;
    }*/
  
    // Get the 2 User based on the Given Profile, Department, Role
    public static List<User> getUsers(String profileName, String dName, String roleName){
        List<User> allUsers = new List<User>();
        Map<String, Profile> profMap = getProfileMap();
        Map<String, UserRole> roleMap = getRoles();
        Id role;
        if(roleMap.get(roleName) != null) 
            role = roleMap.get(roleName).Id; 
        else 
            role = null; 
        
        System.debug('111111111'+role);
        System.debug('222222222'+roleName);
        for(Integer i=1; i<3; i++){
            User u = new User(LastName = 'TestUser'+i, Alias = 'testu'+i , 
                              Email = 'testuser'+i+'@sample.com', Username = 'testusername'+i+'@sample.com', 
                              CommunityNickname = 'testu'+i, Department = dName, ProfileId = profMap.get(profileName).Id, 
                              UserRoleId = role, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                              TimeZoneSidKey = 'Australia/Sydney'
                             );
            
            allUsers.add(u);
        }
        
        try{
            system.runAs(new User (ID = userInfo.getUserId())){
            Database.Insert(allUsers);
            }
            
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return allUsers;
    }   
    
    // Get the Map of all profiles, (Profile Name, Profile)
    public static Map<String, Profile> getProfileMap(){
        Map<String, Profile> profileMap = new Map<String, Profile>();
        List<Profile> allProfiles = [SELECT Name, Id FROM Profile];
        
        for(Profile p: allProfiles){
            profileMap.put(p.Name, p);
        }
        return profileMap;
    }
    //CRM-11628 start
    public static List<Id> getPermissionSetIds(String commaSeparatedNames) {
        List<Id> permissionSetIds = new List<Id>();

        if (String.isBlank(commaSeparatedNames)) {
            return permissionSetIds;
        }

        List<String> nameList = new List<String>();
        for (String name : commaSeparatedNames.split(',')) {
            String trimmed = name.trim();
            if (String.isNotBlank(trimmed)) {
                nameList.add(trimmed);
            }
        }

        if (nameList.isEmpty()) {
            return permissionSetIds;
        }

        for (PermissionSet ps : [
            SELECT Id
            FROM PermissionSet
            WHERE Name IN :nameList
            AND IsOwnedByProfile = false
        ]) {
            permissionSetIds.add(ps.Id);
        }

        return permissionSetIds;
    }
    
    public static List<PermissionSetAssignment> createPermissionSetAssignments(Id userId, List<Id> permissionSetIds) {
        if (userId == null) {
            throw new IllegalArgumentException('User Id cannot be null.');
        }

        if (permissionSetIds == null || permissionSetIds.isEmpty()) {
            return new List<PermissionSetAssignment>(); 
        }

        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (Id permSetId : permissionSetIds) {
            if (permSetId != null) {
                assignments.add(new PermissionSetAssignment(
                    AssigneeId = userId,
                    PermissionSetId = permSetId
                ));
            }
        }
        if (!assignments.isEmpty()) {
            insert assignments;
        }

        return assignments;
    }

    //CRM-11628 end
    // Get the Map of all Roles, (Role Name, Role)
    public static Map<String, UserRole> getRoles(){
        Map<String, UserRole> rolesMap = new Map<String, UserRole>();
        List<UserRole> allRoles = [SELECT Name, Id FROM UserRole];
        
        for(UserRole ur : allRoles){
            rolesMap.put(ur.Name, ur);
        }
        return rolesMap;
    } 
    
    // Get Trigger Status Custom setting
    public static List<Trigger_Status__c> enableTriggers(){
        List<Trigger_Status__c> tsList = new List<Trigger_Status__c>();
        
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'AccountTeam';
        ts.Active__c = true;
        
        tsList.add(ts);
        
        Trigger_Status__c ts1 = new Trigger_Status__c();
        ts1.Name = 'AccountOwnerTrigger';
        ts1.Active__c = true;
        
        tsList.add(ts1);

        Trigger_Status__c ts2 = new Trigger_Status__c();
        ts2.Name = 'ContractTrigger';
        ts2.Active__c = true;
        
        tsList.add(ts2);
        
        Trigger_Status__c ts3 = new Trigger_Status__c();
        ts3.Name = 'CreateOpportunities';
        ts3.Active__c = true;
        
        tsList.add(ts3);
        
        Trigger_Status__c ts4 = new Trigger_Status__c();
        ts4.Name = 'DiscountListTrigger';
        ts4.Active__c = true;
        
        tsList.add(ts4);
        
        Trigger_Status__c ts5 = new Trigger_Status__c();
        ts5.Name = 'OpportunityTeam';
        ts5.Active__c = true;
        
        tsList.add(ts5);
        
        Trigger_Status__c ts6 = new Trigger_Status__c();
        ts6.Name = 'Trigger';
        ts6.Active__c = true;
        
        tsList.add(ts6);
        
        Trigger_Status__c ts7 = new Trigger_Status__c();
        ts7.Name = 'MemberTrigger';
        ts7.Active__c = true;
        
        
        tsList.add(new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = true));
        tsList.add(ts7);
        
        /*Gourav Bhardwaj */
        Trigger_Status__c ts8 = new Trigger_Status__c();
        ts8.Name = 'AccountEligibilityLogTrigger';
        ts8.Active__c = true;
        tsList.add(ts8);
        
        Trigger_Status__c ts9 = new Trigger_Status__c();
        ts9.Name = 'ContractAccountEligibilityLogTrigger';
        ts9.Active__c = true;
        tsList.add(ts9);
        
        Trigger_Status__c ts10 = new Trigger_Status__c();
        ts10.Name = 'OpportunityMaintenanceTrigger';
        ts10.Active__c = true;
        tsList.add(ts10);
        
        Trigger_Status__c ts11 = new Trigger_Status__c();
        ts11.Name = 'AccconRshipUpdate';
        ts11.Active__c = true;
        tsList.add(ts11);
        
        Trigger_Status__c ts12 = new Trigger_Status__c();
        ts12.Name = 'AccountAirlineLeveltrigger';
        ts12.Active__c = true;
        tsList.add(ts12);
        
        Trigger_Status__c ts13 = new Trigger_Status__c();
        ts13.Name = 'PrdRegProcessAMEXEligibility';
        ts13.Active__c = true;
        tsList.add(ts13);
        
        Trigger_Status__c AccountDeleteTrigger = new Trigger_Status__c();
        AccountDeleteTrigger.Name = 'AccountDeleteTrigger';
        AccountDeleteTrigger.Active__c = false;
        tsList.add(AccountDeleteTrigger);
        
        Trigger_Status__c CaseHotwordQueueRoutingTrigger= new Trigger_Status__c();
        CaseHotwordQueueRoutingTrigger.Name = 'CaseHotwordQueueRoutingTrigger';
        CaseHotwordQueueRoutingTrigger.Active__c = true;
        tsList.add(CaseHotwordQueueRoutingTrigger);
        
        Trigger_Status__c AccountUpdateAccountDetail = new Trigger_Status__c();
        AccountUpdateAccountDetail.Name = 'AccountUpdateAccountDetail';
        AccountUpdateAccountDetail.Active__c = true;
        tsList.add(AccountUpdateAccountDetail);

        Trigger_Status__c PrdRegCalculateAMEXAcceptRejectCode = new Trigger_Status__c();
        PrdRegCalculateAMEXAcceptRejectCode.Name = 'PrdRegCalculateAMEXAcceptRejectCode';
        PrdRegCalculateAMEXAcceptRejectCode.Active__c = true;
        tsList.add(PrdRegCalculateAMEXAcceptRejectCode);

        Trigger_Status__c PrdRegAmexProdRegValidation = new Trigger_Status__c();
        PrdRegAmexProdRegValidation.Name = 'PrdRegAmexProdRegValidation';
        PrdRegAmexProdRegValidation.Active__c = true;
        tsList.add(PrdRegAmexProdRegValidation);
        
        Trigger_Status__c updateCaseComplimentTemplateValue = new Trigger_Status__c();
        updateCaseComplimentTemplateValue.Name = 'updateCaseComplimentTemplateValue';
        updateCaseComplimentTemplateValue.Active__c = true;
        tsList.add(updateCaseComplimentTemplateValue);

        Trigger_Status__c populateBasicAutoCaseValues = new Trigger_Status__c();
        populateBasicAutoCaseValues.Name = 'CaseTriggerPopulateBasicAutoCaseValues';
        populateBasicAutoCaseValues.Active__c = true;
        tsList.add(populateBasicAutoCaseValues);

        Trigger_Status__c autoCaseProcess = new Trigger_Status__c();
        autoCaseProcess.Name = 'autoCaseProcess';
        autoCaseProcess.Active__c = true;
        tsList.add(autoCaseProcess);

        Trigger_Status__c trgCaseFieldUpdates = new Trigger_Status__c();
        trgCaseFieldUpdates.Name = 'trgCaseFieldUpdates';
        trgCaseFieldUpdates.Active__c = true;
        tsList.add(trgCaseFieldUpdates);
        
        Trigger_Status__c updateCaseFields = new Trigger_Status__c();
        updateCaseFields.Name = 'updateCaseFields';
        updateCaseFields.Active__c = true;
        tsList.add(updateCaseFields);
        
        Trigger_Status__c caseStatusUpdated = new Trigger_Status__c();
        caseStatusUpdated.Name = 'caseStatusUpdated';
        caseStatusUpdated.Active__c = true;
        tsList.add(caseStatusUpdated);
        
        Trigger_Status__c fetchCongaEmailTemplateId = new Trigger_Status__c();
        fetchCongaEmailTemplateId.Name = 'fetchCongaEmailTemplateId';
        fetchCongaEmailTemplateId.Active__c = true;
        tsList.add(fetchCongaEmailTemplateId);
        
        Trigger_Status__c CaseTriggerCloseCase = new Trigger_Status__c();
        CaseTriggerCloseCase.Name = 'CaseTriggerCloseCase';
        CaseTriggerCloseCase.Active__c = true;
        tsList.add(CaseTriggerCloseCase);
        
        Trigger_Status__c postToChatterFeed = new Trigger_Status__c();
        postToChatterFeed.Name = 'postToChatterFeed';
        postToChatterFeed.Active__c = true;
        tsList.add(postToChatterFeed);
        
        Trigger_Status__c assignCaseOwner = new Trigger_Status__c();
        assignCaseOwner.Name = 'assignCaseOwner';
        assignCaseOwner.Active__c = true;
        tsList.add(assignCaseOwner);
        
        Trigger_Status__c CaseTriggerUpdateCaseSLA = new Trigger_Status__c();
        CaseTriggerUpdateCaseSLA.Name = 'CaseTriggerUpdateCaseSLA';
        CaseTriggerUpdateCaseSLA.Active__c = true;
        tsList.add(CaseTriggerUpdateCaseSLA);
        
        Trigger_Status__c CaseTriggerUpdateCaseEscalatedTo = new Trigger_Status__c();
        CaseTriggerUpdateCaseEscalatedTo.Name = 'CaseTriggerUpdateCaseEscalatedTo';
        CaseTriggerUpdateCaseEscalatedTo.Active__c = true;
        tsList.add(CaseTriggerUpdateCaseEscalatedTo);

        Trigger_Status__c contactCeateAccount = new Trigger_Status__c();
        contactCeateAccount.Name = 'ContactCeateAccount';
        ContactCeateAccount.Active__c = true;
        tsList.add(contactCeateAccount);

        Trigger_Status__c SubmitForFinalisation = new Trigger_Status__c();
        SubmitForFinalisation.Name = 'SubmitForFinalisation';
        SubmitForFinalisation.Active__c = true;
        tsList.add(SubmitForFinalisation);
        
        Trigger_Status__c RecoveryInvokeLoyaltyPostService = new Trigger_Status__c();
        RecoveryInvokeLoyaltyPostService.Name = 'RecoveryInvokeLoyaltyPostService';
        RecoveryInvokeLoyaltyPostService.Active__c = true;
        tsList.add(RecoveryInvokeLoyaltyPostService);
        Trigger_Status__c RecoveryTriggerUpdateCaseRecoveryValue = new Trigger_Status__c();
        RecoveryTriggerUpdateCaseRecoveryValue.Name = 'RecoveryTriggerUpdateCaseRecoveryValue';
        RecoveryTriggerUpdateCaseRecoveryValue.Active__c = true;
        tsList.add(RecoveryTriggerUpdateCaseRecoveryValue);

        Trigger_Status__c updateRecoveryType = new Trigger_Status__c();
        updateRecoveryType.Name = 'updateRecoveryType';
        updateRecoveryType.Active__c = true;
        tsList.add(updateRecoveryType);

        Trigger_Status__c setFulfilledBy = new Trigger_Status__c();
        setFulfilledBy.Name = 'setFulfilledBy';
        setFulfilledBy.Active__c = true;
        tsList.add(setFulfilledBy);

        Trigger_Status__c handleRecoveryTrigger = new Trigger_Status__c();
        handleRecoveryTrigger.Name = 'handleRecoveryTrigger';
        handleRecoveryTrigger.Active__c = true;
        tsList.add(handleRecoveryTrigger);

        
        Trigger_Status__c UpdateCaseOnClos = new Trigger_Status__c();
        UpdateCaseOnClos.Name = 'CaseTriggerUpdateCaseOnClose';
        UpdateCaseOnClos.Active__c = true;
        tsList.add(UpdateCaseOnClos);
        
        Trigger_Status__c linkCaseToContact = new Trigger_Status__c();
        linkCaseToContact.Name = 'ContactAttachCase';
        linkCaseToContact.Active__c = true;
        tsList.add(linkCaseToContact);

        Trigger_Status__c ContactUpdateContact = new Trigger_Status__c();
        ContactUpdateContact.Name = 'ContactUpdateContact';
        ContactUpdateContact.Active__c = true;
        tsList.add(ContactUpdateContact);

        Trigger_Status__c PostToChatter = new Trigger_Status__c();
        PostToChatter.Name = 'RecoveryTriggerPostToChatter';
        PostToChatter.Active__c = true;
        tsList.add(PostToChatter);

        Trigger_Status__c CaseTriggerCalculateEmergencyExpense = new Trigger_Status__c();
        CaseTriggerCalculateEmergencyExpense.Name = 'CaseTriggerCalculateEmergencyExpense';
        CaseTriggerCalculateEmergencyExpense.Active__c = true;
        tsList.add(CaseTriggerCalculateEmergencyExpense);

        Trigger_Status__c CaseTriggerupdateContactBlankEmail = new Trigger_Status__c();
        CaseTriggerupdateContactBlankEmail.Name = 'CaseTriggerupdateContactBlankEmail';
        CaseTriggerupdateContactBlankEmail.Active__c = true;
        tsList.add(CaseTriggerupdateContactBlankEmail);
        
        Trigger_Status__c CaseTriggerpopulateonCaseCreate = new Trigger_Status__c();
        CaseTriggerpopulateonCaseCreate.Name = 'CaseTriggerpopulateonCaseCreate';
        CaseTriggerpopulateonCaseCreate.Active__c = true;
        tsList.add(CaseTriggerpopulateonCaseCreate);

        Trigger_Status__c SetAuditFieldsOnCase = new Trigger_Status__c();
        SetAuditFieldsOnCase.Name = 'SetAuditFieldsOnCase';
        SetAuditFieldsOnCase.Active__c = true;
        tsList.add(SetAuditFieldsOnCase);

        Trigger_Status__c CaseTriggerDeleteAffectedPassengers = new Trigger_Status__c();
        CaseTriggerDeleteAffectedPassengers.Name = 'CaseTriggerDeleteAffectedPassengers';
        CaseTriggerDeleteAffectedPassengers.Active__c = true;
        tsList.add(CaseTriggerDeleteAffectedPassengers);

        Trigger_Status__c CaseTriggerUpdateTECHFields = new Trigger_Status__c();
        CaseTriggerUpdateTECHFields.Name = 'CaseTriggerUpdateTECHFields';
        CaseTriggerUpdateTECHFields.Active__c = true;
        tsList.add(CaseTriggerUpdateTECHFields);
        
        Trigger_Status__c EmailMessageHelper = new Trigger_Status__c();
        EmailMessageHelper.Name = 'EmailMessageHelper';
        EmailMessageHelper.Active__c = true;
        tsList.add(EmailMessageHelper);
        
        Trigger_Status__c CaseTriggerPostNotification = new Trigger_Status__c();
        CaseTriggerPostNotification.Name = 'CaseTriggerPostNotification';
        CaseTriggerPostNotification.Active__c = true;
        tsList.add(CaseTriggerPostNotification);
        
        Trigger_Status__c GlobalEventUpdateAuditFields = new Trigger_Status__c();
        GlobalEventUpdateAuditFields.Name = 'GlobalEventTriggerUpdateAuditFields';
        GlobalEventUpdateAuditFields.Active__c = true;
        tsList.add(GlobalEventUpdateAuditFields);
    
    Trigger_Status__c Contentdocumentlinkstatus = new Trigger_Status__c();
        Contentdocumentlinkstatus.Name = 'ContentDocLinkTriggerCheck';
        Contentdocumentlinkstatus.Active__c = true;
        tsList.add(Contentdocumentlinkstatus);
    
    

        Trigger_Status__c CaseTriggerUpdateRecContact    = new Trigger_Status__c();
        CaseTriggerUpdateRecContact .Name = 'CaseTriggerUpdateRecContact';
        CaseTriggerUpdateRecContact .Active__c = true;
        tsList.add(CaseTriggerUpdateRecContact  );
        
        Trigger_Status__c SpecialCondition = new Trigger_Status__c();
        SpecialCondition.Name = 'SpecialConditionsTrigger';
        SpecialCondition.Active__c = true;
        tsList.add(SpecialCondition);
        
        Trigger_Status__c contactDedupe = new Trigger_Status__c();
        contactDedupe.Name = 'QACManagerContactDupCheck';
        contactDedupe.Active__c = true;
        tsList.add(contactDedupe);

        Trigger_Status__c acrPrimary = new Trigger_Status__c();
        acrPrimary.Name = 'ACRPrimaryContact';
        acrPrimary.Active__c = true;
        tsList.add(acrPrimary);
        
        Trigger_Status__c caseTriggerAssignVIPCaseUsingAssignmentRule = new Trigger_Status__c();
        caseTriggerAssignVIPCaseUsingAssignmentRule.Name = 'assignVIPCaseUsingAssignmentRule';
        caseTriggerAssignVIPCaseUsingAssignmentRule.Active__c = true;
        tsList.add(caseTriggerAssignVIPCaseUsingAssignmentRule);

        Trigger_Status__c caseTriggerCaseStream = new Trigger_Status__c();
        caseTriggerCaseStream.Name = 'QCC_CaseStream';
        caseTriggerCaseStream.Active__c = true;
        tsList.add(caseTriggerCaseStream);

        try{
            Database.Insert(tsList);
        }Catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return tsList;
    }
    
    // Get Account Revenue Custom setting
    public static List<Account_Revenue__c> getAccountRevenueCSetting(){
        List<Account_Revenue__c> customSetting = new List<Account_Revenue__c>();
        
        Account_Revenue__c ar1 = new Account_Revenue__c();
        ar1.Name = 'Marketing Acquisition & Sales Team';
        ar1.Maximum__c = 199999;
        ar1.Minimum__c = 0;
        customSetting.add(ar1);
        
        Account_Revenue__c ar2 = new Account_Revenue__c();
        ar2.Name = 'New Business Development Team';
        ar2.Minimum__c = 1000000;
        ar2.Maximum__c = 2147483647;   
        customSetting.add(ar2);
        
        Account_Revenue__c ar3 = new Account_Revenue__c();
        ar3.Name = 'MAS Team';
        ar3.Minimum__c = 200000;
        ar3.Maximum__c = 299999;   
        customSetting.add(ar3);    
        
        try{
            Database.Insert(customSetting);    
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return customSetting;
    } 
    
    // AEQCC Product registration extensions
    public static List<AEQCC_Variance__c> getrelatedCustObjRecs(){
        List<AEQCC_Variance__c> conList = New List<AEQCC_Variance__c>();
        List<Product_Registration__c> Prodreglist = new List<Product_Registration__c>();
        
        Product_Registration__c Pr = new Product_Registration__c(name = 'Test Product Registration',Account__c='0019000001Q7EID');
        AEQCC_Variance__c Aeq = new AEQCC_Variance__c (Reporting_Period__c = 'Jan-Oct',Product_Link__c='a2cO00000013Djs',CurrencyIsoCode='AU');
        try{
            Database.Insert(Pr);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        
        try{
            Database.Insert(Aeq);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        for(AEQCC_Variance__c aev:pr.AEQCC_Variance__r){
            conList.add(aev); 
        }        
        prodregextensions controllerTest = new prodregextensions(new ApexPages.StandardController(pr));     
        controllerTest.getrelatedCustObjRecs();
        return conList;
    }
    
    // AEQCC Rebate extensions
    public static List<AEQCC_Rebates__c> getrelatedCustObjRecs1(){
        List<AEQCC_Rebates__c> Reblist = New List<AEQCC_Rebates__c>();
        List<Product_Registration__c> Prodreglist = new List<Product_Registration__c>();
        
        Product_Registration__c Pr = new Product_Registration__c(name = 'Test AEQCC REBATE',Account__c='0019000001Q7EID');
        AEQCC_Rebates__c Aeqreb = new AEQCC_Rebates__c (Rebate_Year__c = '2015',Rebate_Tier__c ='2 %',Rebate_term__c='Jul-Dec',Rebate_Payment__c=753,Cheque_Amount__c=826.61,Rebate_Sent_to__c='Adam Simon Po Box 103 Port Melbourne Vic 3207',Prod_Reg_Link__c='a0G9000001BfHSj');
        try{
            Database.Insert(Pr);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        
        try{
            Database.Insert(Aeqreb);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        for(AEQCC_Rebates__c aereb:pr.AEQCC_Rebates__r ){
            Reblist.add(aereb); 
        }        
        prodregextensions controllerTest = new prodregextensions(new ApexPages.StandardController(pr));     
        controllerTest.getrelatedCustObjRecs();
        return Reblist;
    }
    
    // Crate Case type Custom settings
    public static List<QBD_Case_Type__c > getCaseTypeCSetting(){
        List<QBD_Case_Type__c > customSetting = new List<QBD_Case_Type__c >();
        
        customSetting.add(new QBD_Case_Type__c (Name = 'New QBD Registration', PickList_value__c = 'New QBD Registration'));
        customSetting.add(new QBD_Case_Type__c (Name = 'New Traveller', PickList_value__c = 'New Traveller'));
        
        try{
            Database.Insert(customSetting);    
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return customSetting;
    }  
    
    // Crate Case subtype Custom settings
    public static List<QBD_Case_Subtype__c> getCaseSubtypeCSetting(){
        List<QBD_Case_Subtype__c> customSetting = new List<QBD_Case_Subtype__c>();
        
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Agency Account Identified', PickList_value__c = 'Agency Account Identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Duplicate Members identified', PickList_value__c = 'Duplicate Members identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Duplicate QBD Registration Identified', PickList_value__c = 'Duplicate QBD Registration Identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Duplicate QBD Traveller identified', PickList_value__c = 'Duplicate QBD Traveller identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Last Name Mismatch', PickList_value__c = 'Last Name Mismatch'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Member updated with QBD Traveller', PickList_value__c = 'Existing Member updated with QBD Traveller details'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple accounts - Aquire membership', PickList_value__c = 'Multiple matching accounts with Aquire membership'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple Accounts Identified', PickList_value__c = 'Multiple Accounts Identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple Agency Accounts Identified', PickList_value__c = 'Multiple Agency Accounts Identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple QBD Accounts identified', PickList_value__c = 'Multiple QBD Accounts identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'New QBD Traveller added', PickList_value__c = 'New QBD Traveller added'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'No Account identified', PickList_value__c = 'No Account identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'No matching accounts Aquire membership', PickList_value__c = 'No matching accounts with Aquire membership'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'No QBD Account identified', PickList_value__c = 'No QBD Account identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'QBD Registration add New Customer', PickList_value__c = 'QBD Registration added for New Customer'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'QBD Registration update Customer', PickList_value__c = 'QBD Registration updated for Existing Customer'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Unique Account Identified', PickList_value__c = 'Unique Account Identified'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'New Member', PickList_value__c = 'New Member'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Existing Travel Arranger', PickList_value__c = 'Existing Travel Arranger'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Unique Member identified by email', PickList_value__c = 'Unique Member identified by email'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Unique Member identified by name', PickList_value__c = 'Unique Member identified by name'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Unidentified Error', PickList_value__c = 'Unidentified Error'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Duplicate Members identified by email', PickList_value__c = 'Duplicate Members identified by email'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple Travel Arrangers - manual', PickList_value__c = 'Multiple Travel Arrangers - manual'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple Travel Arrangers - auto', PickList_value__c = 'Multiple Travel Arrangers - auto'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple Travellers identified by name', PickList_value__c = 'Multiple Travellers identified by name')); 
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple Travellers - manual', PickList_value__c = 'Multiple Travellers - manual'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Multiple Travellers - auto', PickList_value__c = 'Multiple Travellers - auto'));
        customSetting.add(new QBD_Case_Subtype__c(Name = 'Unique Traveller identified by name', PickList_value__c = 'Unique Traveller identified by name'));   
        
        Database.Insert(customSetting);   
        
        return customSetting;
    }   
    
    // Crate Case subtype Custom settings
    public static List<Regex_Validator__c> getRegexValidatorCSetting(){
        List<Regex_Validator__c> customSetting = new List<Regex_Validator__c>();
        
        customSetting.add(new Regex_Validator__c(Name = 'Email', Regex__c = '(^([^\\s<>\\\\]+)@([^\\s<>\\\\]+))(.)*$'));
        
        try{
            Database.Insert(customSetting);    
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        return customSetting;
    }

    public static Account createAccount(){
        createQantasConfigDataAccRecType();
        Account acc = new Account(Name = 'Sample Acc', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                  RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                  Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                  Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,ABN_Tax_Reference__c = '12345678901'
                                 );
        return acc;
    }

    //GRAPHITE-154/155: Contact Model Redesign - Method for creating Person Account
    public static Account createPersonAccount(){
        createQantasConfigDataAccRecType();
        Account acc = new Account(Name = 'Sample Acc [person]', Active__c = true, Aquire__c = true, Type = 'Person Account', 
                                  RecordTypeId = personRecordTypeId, Migrated__c = false, 
                                  Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                  Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,ABN_Tax_Reference__c = '12345678901'
                                 );
        return acc;
    }

    public static Account createAccountOfQantasCorporateEmailAccount(){
        createQantasConfigDataAccRecType();
        Account acc = new Account(Name = 'QantasCorporateEmailAccount', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                  RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                  Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                  Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N',ABN_Tax_Reference__c = '12345678901' 
                                 );
        return acc;
    }
    
    
   

    public static Contact createContact(Id accId){
       Contact con = new Contact(FirstName = 'FirstContact',LastName='ContTest1', Email='test1contact@duptest.com', AccountId = accId,
                                 MailingCity = 'Sydney', MailingState = 'NSW', MailingPostalCode = '2000', MailingCountry = 'AU',  MailingStreet = 'Hill Road', Phone = '0444444444',
                                 Job_Role__c = 'Manager',Job_Title__c = 'MR');
         return con; 
    }

//GRAPHITE-934 Create new method to generate contact record with Record Type = Individual Contact 
    public static Contact createIndividualContact(Id accId){ 
        Id recordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact')); 
        Contact con = new Contact( 
            RecordTypeId = recordTypeId, 
            FirstName = 'FirstContact', 
            LastName='ContTest1', 
            Email='test1contact@duptest.com', 
            AccountId = accId, 
            MailingCity = 'Sydney', 
            MailingState = 'NSW', 
            MailingPostalCode = '2000', 
            MailingCountry = 'AU', 
            MailingStreet = 'Hill Road', 
            Phone = '0444444444', 
            Job_Role__c = 'Manager', 
            Job_Title__c = 'MR' 
        ); 
        return con; 
    } 


    public static Opportunity CreateOpportunity(Id accId){
        Opportunity opp = new Opportunity(Name='OppTest1',AccountId = accId,Type ='SME Product',Proposed_Revenue_Amount__c = 100,
                                          CloseDate = System.today(),StageName = 'Invalid',CurrencyIsoCode = 'AUD',RecordTypeId = businessGovRTypeId,
                                          Sub_Type_Level_1__c = 'Aquire'
                                          );
         return opp; 
    }

    public static Contract__c createContract(Id accId,Id oppId){
        Contract__c cont = new Contract__c(Name = 'TestContrat',Account__c = accId,CurrencyIsoCode = 'AUD',Opportunity__c = oppId,
                                          RecordTypeId = signedByCustId, Status__c = 'Signed by Customer',
                                           Type__c = 'Corporate Airfares',QL_Effective_Tier__c ='Tier 1',QL_Discount_Model__c='Tiered'
                                          );
       
        return cont;
    }
    
    public static Product_Registration__c createProductReg(Id accId){
        Product_Registration__c pReg = new Product_Registration__c(name = 'Test AEQCC REBATE',Account__c=accId);
        return pReg;
    }
    
    public static AEQCC_Rebates__c createAeqccRebate(Id pRegId){
        AEQCC_Rebates__c Aeqreb = new AEQCC_Rebates__c (Rebate_Year__c = '2015',Rebate_Tier__c ='2 %',Rebate_term__c='Jul-Dec',Rebate_Payment__c=753,Cheque_Amount__c=826.61,Rebate_Sent_to__c='Adam Simon Po Box 103 Port Melbourne Vic 3207',Prod_Reg_Link__c= pRegId);
        return Aeqreb;
    }
    
    

    public static Case CreateCase(Id accId){
        Case caseObj = new Case(
            AccountId = accId,
            Status = 'Working',
            Origin = 'Phone');
        return caseObj;     
    }
    
    public static QantasConfigData__c createQantasConfigData( String name, String value ){
        QantasConfigData__c objConfigData = new QantasConfigData__c();
        objConfigData.Name = name;
        objConfigData.Config_Value__c = value;
        return objConfigData;
    }

    public static QCC_BookingCodeMappings__c createQantasBookingData( String name, String value ){
        QCC_BookingCodeMappings__c objBookingData = new QCC_BookingCodeMappings__c();
        objBookingData.Name = name;
        objBookingData.Value__c = value;
        return objBookingData;
    }
    

    public static AirlineCarrierCodes__c createAirlineCarrierData( String name, String value ){
        AirlineCarrierCodes__c objAirlineData = new AirlineCarrierCodes__c();
        objAirlineData.Name = name;
        objAirlineData.Value__c = value;
        return objAirlineData;
    }
    
    public static void insertQantasConfigData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type', 'Aquire Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg QBD Registration Rec Type', 'QBD Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Del Log SME Account Rec Type','SME Account'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('AccListner Type Direct Stream','Direct Stream'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case SystemAdmin RecordType','System Admin Request'));
        // Added by Qantas CC Team -- Start
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Bounced Back RecType', 'CCC Email Bounced Back'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Case RecType', 'CCC Case'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Complaint RecType', 'CCC Complaints'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case OTRS RecType', 'CCC On The Spot Recovery'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Further Action RecType', 'CCC Further Action Required'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Insurance Letter RecType', 'CCC Insurance Letter Case'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Baggage RecType', 'CCC Baggage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Medical RecType', 'CCC Medical'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Query RecType', 'CCC Query'));        
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Compliment Type', 'Compliment'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Complaint Type', 'Complaint'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Baggage Type', 'Baggage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Recovery EFT RecType', 'EFT Recovery'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Further Action Required Type', 'Further Action Required'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Medical Assistance Type', 'Medical-Assistance Provided'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Query Type', 'Query'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case On The Spot Recovery Type','On The Spot Recovery'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Loyalty_Queue','Manila'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Origin Event','Event'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusOpen','Open'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Type Event','Events'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Subject Event','Proactive Recovery for Event'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Group Event','Event'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Priority Medium','Medium'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Event RecType','CCC Event'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Offload RecType','CCC Offload'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC On The Spot Recovery RecType', 'CCC On The Spot Recovery'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('DaysOlderToDeleteOffloadPassengers', '0'));
        //GRAPHITE-1152: Case Status -Enhancement
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Elite Process RecType', 'QCC Elite Process'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Assistance RecType', 'CCC VIP Assistance'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Disruption RecType', 'Disruption'));
        //CRM-4804 added CCC Refund Recordtype
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Refund RecType', 'CCC Cover Refund Approval'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_TicketingQueue', 'CCC_Ticketing'));
        //GRAPHITE- 1380 - Add "Resolved" status to handle the new QCC Case lifecycle
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_CaseStatusResolved', 'Resolved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_CaseStatusReplyReceived', 'Reply Received'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseResolutionMethod_AutoClosed', 'Case auto closed'));
        /*** Suggested Recvoery Begin ****/
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Recovery Type 1', '1'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Recovery Type 2', '2'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Non-Tier FF', 'Non-tiered'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Bronze FF', 'Bronze'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Silver FF', 'Silver'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Gold FF', 'Gold'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Platinum FF', 'Platinum'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Platinum One FF', 'Platinum One'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusReopened', 'Reopened'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('None Value', 'None'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Point Calculation Type 1', 'Tier'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Point Calculation Type 2', 'Tier and Flight Duration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Flight Duration Range 1', '0-4'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Flight Duration Range 2', '4-10'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Flight Duration Range 3', '10+'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Qantas Points Type', 'Qantas Points'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('No Goodwill Type', 'No Goodwill'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved', 'Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Apology Type', 'Apology'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryType', 'Qantas Points'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SubmitForFinalisaton', 'Submit for Finalisation'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusSubmitForFinalisaton', 'Submit for Finalisation'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusAwaitingCustomerResponse', 'Awaiting Customer Response'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recovery Submitted Fail Message', 'Case and Recoveries creation is failed.'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recovery Submitted Success Message', 'Cases and Recoveries have been created successfuly.'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recovery Submitted Error Message', 'Error: Cases and Recoveries have been already submitted.'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recovery Submitted Initializing', 'Cases And Recoveries are Initializing.'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusInitiated', 'Initiated'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalisation Declined', 'Finalisation Declined'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalised', 'Finalised'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusOpen', 'Open'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryPStatusQuedForPaymentPrcsng', 'Queued for Payment Processing'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recovery Submitted No Passenger Msg', 'Error: There is no affected Passenger.'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recovery DQC Lounge Passes', 'Domestic Qantas Club Lounge Passes'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recovery IB Lounge Passes', 'International Business Lounge Passes'));
        
        /*** Suggested Recvoery End ****/
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Acc acrUpdateRecordType', 'Person Account'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Compliment RecType', 'CCC Compliment'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Baggage RecType', 'CCC Baggage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_Red App', 'Red App'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Qantas', 'Qantas.com'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Exception Queue', 'CCC Exception Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recent Case Duration', '30'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseGroupDF', 'Delayed Flight'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseGroupFCQ', 'Flight Cancelled by Qantas'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseGroupPBNS', 'Proof of Boarding or No Show'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed', 'Closed'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Insurance Letter Type', 'Insurance Letter'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('OrgWideAddress', '0D2N00000004EXCKA2'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Insurance Queue', 'Insurance_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseBlankTemplate', 'a0VN00000044nye'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseQueryTemplate', 'a0VN00000044MrH'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseEFTAuthorisationTemplate', 'a0VN00000044bOD'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseEFTAuthorisationNoReceiptTemplate', 'a0VN00000044oIh'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseMedicalTemplate', 'a0VN00000044ur6'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Medical Patient Type', 'Medical-Patient'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryError', 'Recovery Error'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CC/EFT Refund Status', 'Submit for Finalisation'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Recovery Templates', 'EFT Refund,Credit Card Refund'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_PreventChatterDelete', 'Chatter post can not be deleted. Please contact admin if needed'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Migrated Case RecType', 'QCC Migrated Case'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Post-Flight', 'A/C Downgrade,Air Turn Back,Baggage,Catering,IFE Failure - Full,IFE Failure - Partial,Lights,Miscellaneous,Strike Action,Other,Diversion Due to Mechanical,Diversion Due to Medical,Diversion Due to Weather,Diversion Due to Other'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Pre-Flight', 'Flight Cancellation'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_DelayBaggage', 'Delayed Baggage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_DelayBaggageHighQueue', 'Baggage_Delayed_Queue_High'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Group Contact Name', 'CCC'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusReceived', 'Received'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('InternationalFlightLimit', '399'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('DomesticFlightLowerLimit', '400'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('DomesticFlightHigherLimit', '4000'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('InternationalDelayLimitInMinutes', '120'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('DomesticDelayLimitInMinutes', '60'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC-UTCActualArriDateTime__c', 'Actual_Arrival_UTC__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC-UTCActualDepaDateTime__c', 'Actual_Departure_UTC__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC-UTCEstimatedArrDateTime__c', 'Estimated_Arrival_UTC__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC-UTCEstimatedDepDateTime__c', 'Estimated_Departure_UTC__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC-UTCScheduledArrDateTime__c', 'Scheduled_Arrival_UTC__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC-UTCScheduledDepTime__c', 'Scheduled_Depature_UTC__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_AutoCloseDelayVal', 'Flight Delay between 5 and 20 Hours,Flight Delay Greater than 20 Hours,Flight Delay Less than 5 Hours'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('DaysOlderToDeleteFlightTrackers', '7'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FlightCancellationTimeCheck', '30'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_DelayEventThreshold', '30'));
         
         
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Qantas Customer Care Email', 'qantasdevrel3@gmail.com'));

        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_CancellationEventThreshold', '4320'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case_IssueRootCause_Other', 'Other'));
        //critical ueues 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC Critical Queue', 'Critical_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Advocacy Queue', 'Advocacy_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC ExCo Queue', 'ExCo_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC Emirates Queue', 'Emirates_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC EU Compensation Queue', 'EU_Compensation_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode Domestic', 'Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeDomestic', 'Emergency Expense - Domestic Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeInternational', 'Emergency Expense - International Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeNotEligible', 'Not Eligible for Emergency Expenses'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Voice_RecordTypeDevName', 'CCC_Voice'));
        
        //Hours
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Sydney BusinessHours', 'Sydney Business Hours'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Auckland BusinessHours', 'Auckland Business Hours'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Cape Town BusinessHours', 'Capetown Business Hours'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Hobart BusinessHours', 'Hobart Business Hours'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Manila BusinessHours', 'Manila Business Hours'));
        
        // Added by Qantas CC Team -- End

        //Custom Object Event
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Auto-Closed CloseAction', 'Event Auto-Closed'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Assigned Status', 'Assigned'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Closed Status', 'Closed'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Open Status', 'Open'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Domestic IntDom', 'Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event International IntDom', 'International'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Active Record Type', 'Flight Event - Active'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Offload Record Type', 'Flight Event - Offload'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Global Record Type', 'Global Event'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Closed Record Type', 'Flight Event - Closed'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Close Action Recovery And Comms', 'Recoveries created and comms sent'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Close Action Comms sent', 'Comms sent'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_AutoCloseQueueName', 'Auto_closed_Events'));
        //End Custom Object Event

        // Custom Object Affected Passenger
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Affected Passenger Non-Tiered', 'Non-Tiered'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Affected Passenger Query', 'QCC Affected Passenger For Insurance Letter'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Flight Status Pre', 'BOARDING-OPEN , BOARDING , BOARDING-FINAL-CALL , BOARDING-CLOSE'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Event Flight Status Post', 'DEPARTED , LANDED'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC EventPassenger', 'QCC EventPassenger'));

        // API CONFIG
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIValidationLevel', 'NUMBER'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIPartnerID', 'CCARE01'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FinalLegStatus', 'CANCELLED, LANDED'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FristLegStatus', 'BOARDING-OPEN, BOARDING, BOARDING-FINAL-CALL,BOARDING-CLOSE,DEPARTED,ESTIMATED, CANCELLED'));
        //FFT Codes
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFBR', 'Bronze'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFSL', 'Silver'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFLS', 'Silver'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFGD', 'Gold'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFLG', 'Gold'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFPL', 'Platinum'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFPO', 'Platinum One'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCBR', 'Qantas Club Bronze'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCSL', 'Qantas Club Silver'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCLS', 'Qantas Club Lifetime Silver'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CLBR', 'Chairmans Lounge'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CLSL', 'Chairmans Lounge'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CLLS', 'Chairmans Lounge'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CLGD', 'Chairmans Lounge'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CLLG', 'Chairmans Lounge'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CLPL', 'Chairmans Lounge'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CLPO', 'Chairmans Lounge'));

        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_CJM_Queue', 'CJM Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EventsAssigned', 'Assigned Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EventCostQueue', 'Cost Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EventClosedQueue', 'Closed Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FreightLowRange', '3000'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FreightHighRange', '7000'));

        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_PlaceHolderAccRectype', 'Placeholder'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_PlaceHolderAcc', 'Null'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_GenericConDescription', 'CCC - Placeholder for Cases where customers have not provided Frequent Flyer details.'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_ContactEmail', 'noreplycustomercare@qantas.com.au  '));

        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Individual Contact', 'Individual Contact')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Case Disruption', 'Disruption')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Specific Needs RecType', 'Specific Needs'));

        //New trigger framework QantasConfigData Values.
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_QCC_Elite_Process', 'QCC_Elite_Process'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Exclude Priority ExCo_Queue', 'High'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Exclude Priority EU_Compensation_Queue', 'High')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCCase-Chairmans Lounge', 'VIP')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCCase-Chairmans Lounge Platinum One', 'VIP')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCCase-Platinum One', 'VIP')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Completely destroyed', '100000')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Dent / pushed in', '66')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Frame crushed', '100000'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Handle broken', '52')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Wheel snapped or broken off x 1', '41')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Wheel snapped or broken off x 2', '82')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Wheel snapped or broken off x 3', '123')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Wheel snapped or broken off x 4', '164')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Zip - broken pull', '12'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Zip - completely replace', '130')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Zip - replace sliders and tab', '55')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('ArticleJourney', 'Article Curation')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusNew', 'New')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GSA_Sales and Service_Type', 'GSA')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GSA_Service_Type', 'GSA'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_Knowledge_Request', 'Knowledge_Request')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SLAProcess_QACE', 'Qantas Agency Connect Entitlement Process')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Profile_QantasCCTeamLead', 'Qantas CC Team Lead')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Profile_QantasCCConsultant', 'Qantas CC Consultant')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Profile_QantasCCOperationalM', 'Qantas CC Operational Manager')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Product_CargoClientAirlines', 'Cargo - Client Airlines')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_Contact', 'Non_Agency_Contact')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Type_FreightCountry', 'Freight-Country')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_QANTASFREIGHT', 'Qantas_Freight')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_Ticketing_Authority', 'Ticketing_Authority')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_QDPPortalSupport', 'QAC_Contact_Us_Support')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_QDPPortal_Support', 'QDP_Portal_Support')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_AUSalesSupport', 'QIC_Sales_Support_Escalation_Queue')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Type_Claims', 'Claims')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Type_InternalADMACM', 'Internal - ADM/ACM')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_Invoicing', 'Freight_Invoicing')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Type_BillingDiscrepancy', 'Billing Discrepancy')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('EmailTriggerLoopCount', '2')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseTriggerLoopCount', '4')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('ColonSymbol', ':')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CustFollowUpIssueRootCause', 'Customer Follow Up')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('DuplicateCaseIssueType', 'Duplicate Case')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('ForwardedEmailPrefix', 'FW:')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RepliedEmailPrefix', 'RE:')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('EmailAddress_EmployeeComm', 'employeecomm@qantas.com.au')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Origin_FRTSalesSupport', 'FRT Sales Support')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_FreightSalesSupport', 'Freight_Sales_Support_AU_Queue')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_SN_WaitingForCustomer', 'QCC_Specific_Needs_Waiting_for_Customer')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_SN_WaitingForInternal', 'QCC_Specific_Needs_Waiting_for_Internal')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_VIP_WaitingForCustomer', 'QCC_VIP_Waiting_for_Customer')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_VIP_WaitingForInternal', 'QCC_VIP_Waiting_for_Internal')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_WaitingForCustomer', 'QCC_Waiting_for_Customer')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_WaitingForInternal', 'QCC_Waiting_for_Internal')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_AgencyDevelopment', 'Agency_Development')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_SHRQACFR', 'SHR_Qantas_Agency_Connect_FR')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_SHRQACIT', 'SHR_Qantas_Agency_Connect_IT')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_SHRQACSG', 'SHR_Qantas_Agency_Connect_SG')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_SHRQACUS', 'SHR_Qantas_Agency_Connect_US')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_SHRQACZA', 'SHR_Qantas_Agency_Connect_ZA')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_SHRQISSalesSupport', 'SHR_QIS_Sales_Support')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_SMECustomerSupport', 'SME_Customer_Support')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SubType_General', 'General')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SubType_GeneralEnquiry', 'General Enquiry')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SubType_SalesSupportQuery', 'Sales Support Query')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Type_CustomerQuery', 'Customer Query')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Type_SpecialMoves', 'Special Moves')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseApprovalStatusApproved', 'Approved')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseSubTypeChannelAgencyPC', 'Channel Agency Payment Contract')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCVIPEmailCaseOwnerDevName', 'QCC_VIP_Email_Enquiries')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT CCC Insurance Letter Case', 'QCC_Insurance_Letter_Case')); 

        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCOriginVIPServiceTeam', 'VIP Service Team Email Enquiries')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTClaims', 'FRT Claims')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTExportSplMoves', 'FRT Export Spl Moves')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTPhone', 'FRT Phone')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTSplMoves', 'FRT Spl Moves')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_Webchat', 'Webchat')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CasePriorityHigh', 'High')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusAutoclosed', 'Auto-closed')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusOnHold', 'On Hold'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('EmailSubQCC', 'Qantas Customer Care')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('freightLowPriorityCaseUpgrade', 'Medium')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('freightMediumPriorityCaseUpgrade', 'High')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCCase-Platinum', 'Platinum')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Locks', '40')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCost-Trolley', '58')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_Frequent_Flyer_Request', 'Frequent_Flyer_Request')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_QCC_Specific_Needs', 'QCC_Specific_Needs')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Priority Customer Reply', 'Customer Reply')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Priority Internal Escalation', 'Internal Escalation')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Status Waiting for Customer', 'Waiting for Customer')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Status Waiting for Internal', 'Waiting for Internal')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCVIPEmailCaseOwner', 'VIP Email Enquiries')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCSSUEmailEnquiriesCaseOrigin', 'SSU Email Enquiries')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCSSUEmailEnquiriesCaseOriginDevName', 'QCC_SSU_Email_Enquiries')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Baggage_VIP', 'QCC Entitlement VIP Baggage')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Baggage_Platinum', 'QCC Entitlement Platinum Baggage')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Baggage_Gold', 'QCC Entitlement Gold Baggage')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Medical_VIP', 'QCC Entitlement VIP CCAT / Medical')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Medical_Platinum', 'QCC Entitlement Platinum CCAT / Medical')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Medical_Gold', 'QCC Entitlement Gold CCAT / Medical')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_Disruption_VIP', 'QCC Entitlement VIP Disruption')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_Elite_Process_VIP', 'QCC Entitlement VIP Elite Process')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Complaints_VIP', 'QCC Entitlement VIP Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Complaints_Platinum', 'QCC Entitlement Platinum Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Complaints_Gold', 'QCC Entitlement Gold Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GOLD', 'Gold'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Origin Specific Needs', 'Specific Needs Email Enquiries')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Query_VIP', 'QCC Entitlement VIP Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Query_Platinum', 'QCC Entitlement Platinum Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Query_Gold', 'QCC Entitlement Gold Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Further_Action_Required_VIP', 'QCC Entitlement VIP Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Further_Action_Required_Platinum', 'QCC Entitlement Platinum Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Further_Action_Required_Gold', 'QCC Entitlement Gold Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Compliment_VIP', 'QCC Entitlement VIP Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Compliment_Platinum', 'QCC Entitlement Platinum Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Compliment_Gold', 'QCC Entitlement Gold Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_Insurance_Letter_Case_VIP', 'QCC Entitlement VIP Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_Insurance_Letter_Case_Platinum', 'QCC Entitlement Platinum Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_Insurance_Letter_Case_Gold', '	QCC Entitlement Gold Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Refund_VIP', 'QCC Entitlement VIP Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Refund_Platinum', 'QCC Entitlement Platinum Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_Refund_Gold', 'QCC Entitlement Gold Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_Assistance_VIP', 'QCC Entitlement VIP Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCAT_VIP', 'QCC Entitlement VIP CCAT / Medical')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCAT_Platinum', 'QCC Entitlement Platinum CCAT / Medical')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCAT_Gold', 'QCC Entitlement Gold CCAT / Medical')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_PLATINUM_ONE_EMAIL_ENQ', 'Platinum One Email Enquiries')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('BusinessUnitQCC', 'QCC')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('WheelSnappedOrBrokenOff1', 'Wheel snapped or broken off x 1')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('WheelSnappedOrBrokenOff2', 'Wheel snapped or broken off x 2')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('WheelSnappedOrBrokenOff3', 'Wheel snapped or broken off x 3')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('WheelSnappedOrBrokenOff4', 'Wheel snapped or broken off x 4')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Handle_broken', 'Handle broken')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Locks', 'Locks')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Trolley', 'Trolley')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Zip - broken pull', 'Zip - broken pull')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Zip - replace sliders and tab', 'Zip - replace sliders and tab')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Zip - completely replace', 'Zip - completely replace')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Dent / pushed in', 'Dent / pushed in')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Frame crushed', 'Frame crushed')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Completely destroyed', 'Completely destroyed')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Exception_Queue_API_NAME', 'CCC_Exception_Queue')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QAC Website Origin', 'QAC Website')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Role', 'Role')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Frequent Flyer Tier', 'Frequent Flyer Tier')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC SENSITIVE CASE', 'SENSITIVE CASE')); 

        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_Web', 'Web')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_FreightAccount', 'Freight_Account')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_QCCQANTASFreight', 'Qantas_Freight')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTCustService', 'FRT Cust Service')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Status_Open', 'Open')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTBookings', 'FRT Bookings')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_FreightFeedback', 'Freight_Feedback')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Status_AutoClosed', 'Auto Closed')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_FreightShipment', 'Freight_Shipment')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Priority_Premium', 'Premium')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_FreightQuery', 'Freight_Query')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Freight_CSU_AU_Queue', 'Freight_CSU_AU_Queue')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Priority_Low', 'Low')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Priority_Urgent', 'Urgent')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SubjectLineInCase', 'Automatic reply:')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('WebCaseType_FGE', 'Freight - General Enquiries')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FreightTypeInQHQR', 'Mail Suffix')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Type_InvalidCase', 'Invalid Case')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('WebCaseType_FTATQ', 'Freight - Track and trace query')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('WebCaseType_GUF', 'Freight - Give us feedback')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('DescriptionFrom', 'From:')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('DescriptionMailTo', 'mailto:')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('BusinessUnitFreight', 'Freight')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('BusinessUnitOthers', 'Others')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_AutoEmail', 'Auto Email')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('On the Spot Recovery', 'On the Spot Recovery')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Status_AssignedToPricingForFareFiling', 'Assigned to Pricing for Fare Filing')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_DealSupportRequest', 'Deal_Support_request')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Status_CompletePendingPRISMDealLoad', 'Complete - Pending PRISM Deal Load')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CBR_AsiaSG', 'Asia-SG')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Status_AssignedDealSupportDealSheet', 'Assigned - Deal Support - Deal Sheet')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CBR_UKEMEIA', 'UKEMEIA')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CBR_NorthAmericaNZ', 'North America-NZ')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_CCCRefund', 'CCC_Refund')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_CCCInsuranceLetterCase', 'QCC_Insurance_Letter_Case')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_CustomerConnect', 'Customer_Connect')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_OtherRecovery', 'Other_Recovery'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_AgencySignedByCustomer', 'Agency_Signed_by_Customer')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('ApprovalStatus_Approved', 'Approved')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseSubType_ChannelAgencyPC', 'Channel Agency Payment Contract')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_AccountMaintenance', 'Account_Maintenance')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_Asset_AgencyCredit', 'Agency_Credit')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_AgencyCredit', 'Agency_Credit')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Status_ClosedApproved', 'Closed - Approved')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Status_ClosedRejected', 'Closed - Rejected')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Status_InProgress', 'In Progress')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SLAProcess_FE', 'freight entitlement sla process')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('AssignCaseOwner_LogicOne', 'Qantas.com;Red App;Specific Needs Email Enquiries;SSU Email Enquiries;VIP Service Team Email Enquiries;GMC')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('MilestoneType_OwnershipAssignment_Name', 'Ownership Assignment')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('MilestoneType_CaseClosure_Name', 'Case Closure')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('MilestoneType_CaseResolution_Name', 'Case Resolution')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case_Assigned_Status', 'Assigned')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RT_ServiceRequest', 'QIC_Service_request')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Freight_Claims_Queue', 'Freight_Claims_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Queue_DealSupportRequest', 'Deal_Support_Request_Queue'));

        //Recovery Project QantasConfigData values
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryPStatusException', 'Exception'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryPStatusSubmitForFinalisation', 'Submitted for Finalisation'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryPStatusSubmitToFinance', 'Submitted to Finance'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusPendingRecovery', 'Pending Recovery'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RType_HotelVoucher', 'QF_HOTEL_voucher'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RType_WineVoucher', 'QF_WINE_voucher'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusProcessing', 'Processing'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusNew', 'New'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusPendingApproval', 'Pending Approval'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusAwaitingCustomer', 'Awaiting Customer'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusDeclined', 'Declined'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFurtherActionRequired', 'Further Action Required'));

        //CRM-9185
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('currenciesToRoundToWholeNumber', 'KRW;HKD;CLP;JPY;TWD;ZAR;XPF'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('currenciesToRoundToNearest10', 'IDR;INR;PHP;THB'));
        
        //CRM-8862
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Non FF Contact Duplicate Rule Name', 'QCC_Non_FF_Contact_Duplicate_Rule'));
        
        // Config Data for Account Recordtype
        lstConfigData.add(createQantasConfigData('Account RecType1','Agency Account;Charter Account;Customer Account;Global Account;Other Account;Prospect Account;Regional Account;'));
        lstConfigData.add(createQantasConfigData('Account RecType2',''));
        lstConfigData.add(createQantasConfigData('Account RecType3',''));

        // Config Data for Delay Code
        lstConfigData.addAll(createDelayCode());
        
        insert lstConfigData;
    }

    public static QantasConfigData__c createConfigData(String iDes, String iName, String iVal){
        QantasConfigData__c data = new QantasConfigData__c();
        data.Name = iName;
        data.Config_Description__c = iDes;
        data.Config_Value__c = iVal;
        return data;
    }

    public static List<QantasConfigData__c> createDelayCode(){
        List<QantasConfigData__c> listConfigData = new List<QantasConfigData__c>();
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_860_APT GOV','Airport & Govt Auth - IMMIGRATION CUSTOMS STAFF AND/OR CASA AND/OR LAW ENFORCEMENT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_861_APT GOV','Airport & Govt Auth - RESTRICTIONS AT DEPARTURE PORT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_880_APT GOV','Airport & Govt Auth - RESTRICTIONS AT DESTINATION AIRPORT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_891_APT GOV','Airport & Govt Auth - CUSTOMER OR BAG INFORMATION PROCESSING (APP APIS & AAA)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_350_COMM','Aircraft Cleaning - AIRCRAFT CLEANING - LATE OR INCOMPLETE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_351_CLEANING','Aircraft Cleaning - SERVICE DELIVERY IMPACTED BY STAFF SHORAGE (OFF-SCHEDULE)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_352_CLEANING','Aircraft Cleaning - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (ROSTERS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_353_CLEANING','Aircraft Cleaning - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (SICKNESS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_354_CLEANING','Aircraft Cleaning - VEHICLE SHORTAGE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_355_CLEANING','Aircraft Cleaning - VEHICLE BREAKDOWN'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_580_IT','Auto Equipment - AUTO SYSTEMS EQUIPMENT FAILURE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_60_APT INF','Apt Infrastructure - NO GATE AVAILABLE DUE TO OWN AIRCRAFT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_61_NO GATE','Apt Infrastructure - NO GATE AVAILABLE DUE TO OTHER CARRIER'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_870_APT INF','Apt Infrastructure - AIRCRAFT GROUND POSITIONING DUE AIRPORT INFRASTRUCTURE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_871_APT INF','Apt Infrastructure - TRANSPORT CUSTMRS/BAGS BETWEEN TERMINALS DUE INFRASTRUCTURE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_872_APT INF','Apt Infrastructure - AIRPORT EXTERNAL FACILITIES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_873_APT INF','Apt Infrastructure - TERMINAL FACILITIES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_30_AIRPORTS','Airport Services - AIRPORT PROCEDURAL ERROR'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_31_AIRPORTS','Airport Services - SHORTAGE OF BUSES FOR STAND-OFF OPERATIONS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_33_NO DELAY','Airport Services - NO DELAY CODE ALLOCATED '));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_34_NO DELAY','Airport Services - DELAY CODE ALLOCATION ERROR (IOC USE ONLY)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_110_AIRPORTS','Airport Services - LATE CHECK-IN'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_112_COMM','Airport Services - LATE CHECK-IN AFTER DEADLINE DUE RES/TICKETING/CRS ERROR'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_113_COMM','Airport Services - LATE PAX CLEARANCE TO LOAD CONTROL'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_114_AIRPORTS','Airport Services - LATE PROCESSING OF STAFF & STANDBY CUSTOMERS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_115_AIRPORTS','Airport Services - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (OFF SCHEDULE)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_116_AIRPORTS','Airport Services - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (ROSTERS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_117_AIRPORTS','Airport Services - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (SICKNESS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_131_COMM','Airport Services - INTERCEPTING OVER-SIZE CABIN BAGS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_132_COMM','Airport Services - CHECK-IN ERROR - CUSTOMER & BAGS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_135_CHCK IN','Airport Services - SELF-SERVICE CHECK-IN ERROR - CUSTOMER & BAGS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_160_COMM','Airport Services - APPROVED CUSTOMER CONVENIENCE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_826_AP AUTH','Airport Services - SECURITY SCREENING'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_852_AIRPORTS','Airport Services - SECURITY SCREENING'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_921_ROTATION','Airport Services - THROUGH CHECK-IN ERROR NON-QF TO QF'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_922_AIRPORTS','Airport Services - THROUGH CHECK-IN ERROR QF TO QF (CUSTOMER & BAGS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_990_MISC','Airport Services - MISCELLANEOUS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_314_COMM','Acft/Ramp Handling - LATE RAMP CLEARANCE TO LOAD CONTROL'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_315_COMM','Acft/Ramp Handling - BAGGAGE COUNT DISCREPANCY - SYSTEM / ACTUAL'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_320_COMM','Acft/Ramp Handling - LATE COMPLETION OF LOADING  '));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_321_COMM','Acft/Ramp Handling - LATE COMPLETION OF BAGGAGE MAKE-UP'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_323_COMM','Acft/Ramp Handling - RE-LOAD OVER STOWED FREIGHT - LOADING ERROR FROM UPLINE PORT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_324_AIRPORTS','Acft/Ramp Handling - SPECIAL LOAD - ELTRC WHCHR, LSTCK'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_326_HEVY FRT','Acft/Ramp Handling - LATE COMPLETION OF LOADING DUE TO HEAVY FREIGHT LOAD'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_330_RAMP','Acft/Ramp Handling - AGSE - SHORTAGE OF EQUIPMENT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_331_RAMP','Acft/Ramp Handling - AGSE - BREAKDOWN OF EQUIPMENT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_332_RAMP','Acft/Ramp Handling - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (OFF SCHEDULE)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_333_RAMP','Acft/Ramp Handling - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (ROSTERS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_334_RAMP','Acft/Ramp Handling - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (SICKNESS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_381_AIRPORTS','Acft/Ramp Handling - ULD - LACK OF OR U/S (BAGGAGE ONLY)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_940_ROTATION','Aircrew Rotation - CABIN CREW ROTATION'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_950_ROTATION','Aircrew Rotation - FLIGHT CREW ROTATION'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_952_ROTATION','Aircrew Rotation - ENTIRE CREW ROTATION'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_810_AP AUTH','Air Traffic Services - AIR TRAFFIC SERVICES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_815_INB ATC','Air Traffic Services - INBOUND ATC HOLDING ON INBOUND FLIGHT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_820_AIR TRAF','Air Traffic Services - ATC STAFF SHORTAGES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_830_AIR TRAF','Air Traffic Services - ATFM'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_890_AP AUTH','Air Traffic Services - ATC GROUND MOVEMENT CONTROL'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_150_COMM','Boarding - BOARDING - SEARCH & LOCATE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_151_COMM','Boarding - BOARDING - OFFLOAD CUSTOMER &/OR BAGS AT QF REQUEST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_152_COMM','Boarding - BOARDING - QANTAS CLUB / CHAIRMANS LOUNGE / VIP ROOM'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_153_BOARDING','Boarding - BOARDING - OFFLOAD CUSTOMER &/OR BAGS AT PAX REQUEST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_161_BOARDING','Boarding - SPECIAL HANDLING - OTHER'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_162_BOARDING','Boarding - WHEELCHAIRS - BOARDING 1 OR 2'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_163_BOARDING','Boarding - WHEELCHAIRS - BOARDING 3+'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_164_BOARDING','Boarding - UNMR - BOARDING 1 OR 2'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_165_BOARDING','Boarding - UNMR - BOARDING 3+'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_854_BOARDING','Boarding - AIRPORT ASSESSMENT FOR UPLIFT OF CUSTOMER (INTOX/ABUSIVE)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_913_BOARDING','Boarding - CONNECTING LOAD - LOCAL AIRPORT APPROVED'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_660_CREW','Cabin Crew - CABIN CREW LATE TO AIRCRAFT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_661_CREW','Cabin Crew - CABIN CREW GALLEY CHECKS & PRE-DEPARTURE PROCEDURES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_662_CREW','Cabin Crew - CUSTOMER SEATING PROBLEM (ONBOARD)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_664_CREW','Cabin Crew - CABIN CREW LATE TO COMMENCE BOARDING'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_665_CREW','Cabin Crew - CABIN BAGGAGE STOWAGE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_667_CREW','Cabin Crew - CABIN CREW TRANSPORT - LATE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_668_CREW','Cabin Crew - CABIN CREW - CUSTOMER HEAD COUNT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_670_CREW','Cabin Crew - CABIN CREW SHORTAGE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_671_CREW','Cabin Crew - CABIN CREW SICKNESS - AWAITING STANDBY CREW'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_680_CREW','Cabin Crew - CUSTOMERS SLOW TO DEBOARD'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_681_CREW','Cabin Crew - CABIN CREW REQUEST FOR CUSTOMER REQUIREMENTS/MANIFEST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_685_CCREW','Cabin Crew - CABIN CREW IMPEDING FISH BONE CLEANING'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_140_COMM','Commercial - OVER SALES - CLEARING'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_141_COMM','Commercial - COMMERCIAL OPERATIONS PROCEDURAL ERROR'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_142_COM','Commercial - RESERVATIONS ERROR'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_510_TECH','Damage to Aircraft - AIRCRAFT DAMAGE - INFLIGHT AND TAXI OPERATIONS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_511_TECH','Damage to Aircraft - CABIN DAMAGE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_512_DAMAGE','Damage to Aircraft - AIRCRAFT CHANGE CONSEQUENCE OF DAMAGE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_520_TECH','Damage to Aircraft - AIRCRAFT DAMAGE - QF GROUND OPERATIONS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_522_TECH','Damage to Aircraft - AIRCRAFT DAMAGE - NON QF GROUND OPERATIONS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_12_ENG','Engineering - RETURN TO BLOCKS (RTB) - TECHNICAL'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_13_ENG','Engineering - AIR TURNBACK (ATB) - TECHNICAL'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_20_ENG','Engineering - FUELLING - ENGINEERS PROCEDURES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_21_ENG','Engineering - ENGINEERING CONTROLLED TECHNICAL EQUIPMENT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_22_ENG','Engineering - ENGINEERING STAFF SHORTAGE DUE ROSTERS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_23_ENG','Engineering  - ENGINEERING STAFF SHORTAGES DUE SICKNESS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_24_ENG','Engineering - ENGINEERING ERRORS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_25_MECH','Engineering - ENGINEERING STAFF SHORTAGE DUE OFF-SCHEDULE OPERATIONS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_167_ENG','Engineering - CUSTOMER CONVENIENCE ITEM - AS AUTHORISED BY PFPP'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_410_TECH','Engineering - AIRCRAFT DEFECTS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_411_TECH','Engineering - CABIN DEFECTS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_412_ENG','Engineering - APU UNSERVICABLE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_420_TECH','Engineering - SCHEDULED MAINTENANCE - LATE RELEASE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_430_TECH','Engineering - UNSCHEDULED MAINTENANCE / SPECIAL CHECKS / LACK OF STAFF'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_440_TECH','Engineering - AIRCRAFT SPARES - ESTABLISHED'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_442_TECH','Engineering  - AIRCRAFT SPARES - NONE HELD AT DEPARTURE PORT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_450_TECH','Engineering - AIRCRAFT CARRIAGE REQUIREMENTS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_460_TECH','Engineering - AIRCRAFT CHANGE - TECHNICAL REASONS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_ENR_ENR','Enroute delays - ENROUTE DELAYS FOR CONSEQUENTIAL DELAY MAPPING'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_210_FREIGHT','Freight & Mail - FREIGHT & MAIL - INCOMPLETE DOCUMENTATION'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_211_FREIGHT','Freight & Mail - FREIGHT & MAIL - INCORRECTLY PRESENTED'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_220_FREIGHT','Freight & Mail - FREIGHT & MAIL - LATE POSITIONING'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_240_FREIGHT','Freight & Mail - FREIGHT & MAIL - INADEQUATE PACKING'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_250_FREIGHT','Freight & Mail - FREIGHT & MAIL - OVER SALES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_380_FREIGHT','Freight & Mail - FREIGHT & MAIL - LACK OF / OR U/S ULD'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_610_FOP','Flight Operations - FLIGHT PLAN - LATE OR INCOMPLETE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_611_OPS','Flight Operations - FLIGHT LIBRARY DISCREPANCY OR ERROR'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_630_CREW','Flight Operations - FLIGHT CREW LATE TO BOARD'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_631_CREW','Flight Operations - FLIGHT CREW CHECKS AND DEPARTURE PROCEDURES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_632_CREW','Flight Operations - FLIGHT CREW MEL INTERPRETATION/PROCEDURES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_640_CREW','Flight Operations - FLIGHT CREW SHORTAGE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_641_CREW','Flight Operations - FLIGHT CREW SICKNESS - AWAITING STANDBY CREW'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_650_CREW','Flight Operations - FLIGHT CREW SPECIAL REQUEST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_651_CREW','Flight Operations - BOARDING HELD AT FLIGHT CREW REQUEST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_652_CREW','Flight Operations - CLARIFICATION OF DOCUMENTATION (LOADSHEET/NOTOC/GENDEC)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_360_FUEL','Fuelling - FUELLING / DE-FUELLING (SUPPLIER RELATED ONLY)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_310_COMM','Load Control - AIRCRAFT DOCUMENTS - LATE OR INACCURATE WGT & BALANCE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_311_COMM','Load Control - LOAD CONTROL - CHANGE OF PROCEDURES'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_313_COMM','Load Control - REVISED BAGGAGE LOAD - INCLUDING RELOAD'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_391_LOC','Load Control - PDA FAILURE OR SHORTAGE (COBHAM 717 ONLY)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_392_LOC','Load Control - LOAD CONTROL - RESOURCE SHORTAGE / OFF SCHEDULE OPERATIONS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_40_MEDICAL','Medical  - ASSESSED MEDICAL FITNESS TO TRAVEL/MEDLINK'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_41_MEDICAL','Medical - INVOLUNTARY MEDICAL OFFLOAD'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_42_MEDICAL','Medical - VOLUNTARY MEDICAL OFFLOAD AT CUSTOMER REQUEST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_166_MEDICAL','Medical - INSTALLATION / REMOVAL OF APPROVED MEDICAL EQUIPMENT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_0_DEPT','No Group Allocated - EARLY DEPARTURE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_970_INDU','No Group Allocated - INDUSTRIAL ACTION WITHIN QF'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_980_INDU','No Group Allocated - INDUSTRIAL ACTION OUTSIDE QF'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_997_NGR','No Group Allocated - UNPLANNED FLIGHT (IOC USE ONLY)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_998_COMM','No Group Allocated - CANCELLED FLIGHT (IOC USE ONLY)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_10_OPS','Network & Airline Op - RETURN TO BLOCKS (RTB) - NON TECHNICAL'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_11_OPS','Network & Airline Op - AIR TURNBACK (ATB) - NON TECHNICAL'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_90_ROTATION','Network & Airline Op - SCHEDULE RESTRAINT - INSUFFICIENT GROUND TIME'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_118_OPS','Network & Airline Op - IOC CONSOLIDATION OF CUSOMTERS FROM OTHER CARRIERS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_168_OPS','Network & Airline Op - IOC DELAY APPROVED FOR CUSTOMER CONVENIENCE OUTSIDE PFPP'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_620_OPS','Network & Airline Op - OPERATIONAL REQUIREMENT - WEATHER CHANGE/FORECAST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_622_OPS','Network & Airline Op - OPERATIONS REQUIREMENTS - LOAD INCL FUEL REQUIREMENT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_910_IOC','Network & Airline Op - CONNECTING LOAD - OPERATIONS CONTROL APPROVED'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_960_COMM','Network & Airline Op - IOC - RESCHEDULE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_961_COMM','Network & Airline Op - IOC - CONSOLIDATION OF CUSTOMERS EX QF FLIGHTS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_964_COMM','Network & Airline Op - IOC - CONSOLIDATION OF PAX FROM OTHER CARRIERS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_966_OPS','Network & Airline Op - IOC - REROUTE/DIVERSION'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_370_CATERING','Catering - CATERING (QF) - LATE OR INCOMPLETE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_371_CATERING','Catering - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (OFF SCHEDULE)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_372_CATERING','Catering - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (ROSTERS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_373_CATERING','Catering - SERVICE DELIVERY IMPACTED BY STAFF SHORTAGES (SICKNESS)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_374_CATERING','Catering - CATERING - VEHICLE SHORTAGE'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_375_CATERING','Catering - CATERING - VEHICLE BREAKDOWN'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_930_ROTATION','Rotation - AIRCRAFT ROTATION'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_50_SAFETY','Safety - DELAYED DEPARTURE DUE SAFETY INCIDENTS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_819_CBS','Security - CHECKED BAG SCREENING (X-RAY MACHINE FAILURE)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_850_SECURITY','Security - MANDATORY SECURITY / THREATS / SECURITY DIRECTION'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_851_SECURITY','Security - OFFLOAD CUSTOMER &/OR BAGS AT GOVERNMENT AUTHORITY REQUEST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_710_WEATHER','Weather - DEPARTURE STATION BELOW AIRCRAFT OPERATING LIMITS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_715_WEA','Weather - INBOUND WEATHER HOLDING ON INBOUND FLIGHT (IOC USE ONLY)'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_720_WEATHER','Weather - DESTINATION STATION BELOW OPERATING LIMITS'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_730_WEA','Weather - OPERATIONS REQUIREMENT - WEATHER CHANGE/FORECAST'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_750_WEATHER','Weather - DE-ICING AIRCRAFT'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_770_WEATHER','Weather - GROUND HANDLING IMPAIRED BY ADVERSE WEATHER'));
        listConfigData.add(createConfigData('DelayCode','QCC_DelayCode_892_WEATHER','Weather - AIRCRAFT HELD AWAITING ATC CLEARANCE DUE WEATHER'));
        
        System.debug('Size of delay code config data : '+listConfigData.size());
        return listConfigData;
    }
    
    
    public static List<QBD_Online_Office_ID__c> createQBDOnlineOfficeId(){
        List<QBD_Online_Office_ID__c> lstQBDOff = new List<QBD_Online_Office_ID__c>();
        for(Integer i = 1; i<=4; i++){
            QBD_Online_Office_ID__c qbdOffice = new QBD_Online_Office_ID__c();
            qbdOffice.Name = String.valueOf(i);
            qbdOffice.GDS_QBR_Discount_Code__c = 'GBD000'+String.valueOf(i);
            qbdOffice.Key_Contact_Office_ID__c = 'KeyOff000'+String.valueOf(i);
            qbdOffice.Qantas_Club_Discount_Code__c = 'QCD000'+String.valueOf(i);
            lstQBDOff.add(qbdOffice);
        }
        return lstQBDOff;
    }
    
    public static Product_Registration__c createProductRegistration(Id accId, String type){
        Product_Registration__c objPrdReg = new Product_Registration__c();
        objPrdReg.Stage_Status__c = 'Active';
        objPrdReg.Account__c = accId;
        if(type == 'Acquire'){
            objPrdReg.RecordTypeId = aquireRecordTypeId;
            objPrdReg.Membership_Number__c  = '12345';
        }
        else if(type == 'AEQCC'){
            objPrdReg.RecordTypeId = amexRecordTypeId;
            //objPrdReg.Process_Status__c = 'Pending';
        }
        else if(type == 'QBD Registration')
            objPrdReg.RecordTypeId = qbdRecordTypeId;
        objPrdReg.Active__c = true;
        
        return objPrdReg;
    }

    public static Asset createAsset(Id accId,Id contactId, Id contractId,String recordTypeName,String schemeType){
        Asset objAsset = new Asset();
        objAsset.Name ='TestAsset';
        objAsset.Scheme_Currency__c = 'AUD';
        objAsset.Scheme_Type__c = schemeType;
        objAsset.Scheme_Discount_Type__c = recordTypeName;
        objAsset.Renewals__c = 'Coordinator';
        objAsset.Fulfilment__c = 'Individual';
        objAsset.AccountId = accId;
        objAsset.ContactId = contactId;
        objAsset.Mailing_Name_1__c = 'Test';
        objAsset.Scheme_Cost_Center__c  = '176275';
        if(recordTypeName == 'Corporate Scheme')
            objAsset.Contract__c =contractId;
        objAsset.RecordTypeId = GenericUtils.getObjectRecordTypeId('Asset', recordTypeName);
        return objAsset;
    }
    
    public static Account_Logs_Tracker__c createAccountLogsTracker(String objName, String fieldLabel, String value, String name){
        Account_Logs_Tracker__c accLog = new Account_Logs_Tracker__c();
        accLog.Field_Label__c = fieldLabel;
        accLog.Active__c = true;
        accLog.Object__c = objName;
        accLog.Value__c = value;
        accLog.Name = name;
        return accLog;
    }
    
    public static List<Trigger_Status__c>createAccountTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c trgStatus = new Trigger_Status__c();
        trgStatus.Name = 'AccountAirlineLeveltrigger';
        trgStatus.Active__c = false;
        lsttrgStatus.add(trgStatus);
        
        Trigger_Status__c AccountTeam = new Trigger_Status__c();
        AccountTeam.Name = 'AccountTeam';
        AccountTeam.Active__c = false;
        lsttrgStatus.add(AccountTeam);
        
        Trigger_Status__c AccountEligibilityLogTrigger = new Trigger_Status__c();
        AccountEligibilityLogTrigger.Name = 'AccountEligibilityLogTrigger';
        AccountEligibilityLogTrigger.Active__c = false;
        lsttrgStatus.add(AccountEligibilityLogTrigger);
        
        Trigger_Status__c AccountDeleteTrigger = new Trigger_Status__c();
        AccountDeleteTrigger.Name = 'AccountDeleteTrigger';
        AccountDeleteTrigger.Active__c = false;
        lsttrgStatus.add(AccountDeleteTrigger);

        Trigger_Status__c AccountUpdateAccountDetail = new Trigger_Status__c();
        AccountUpdateAccountDetail.Name = 'AccountUpdateAccountDetail';
        AccountUpdateAccountDetail.Active__c = false;
        lsttrgStatus.add(AccountUpdateAccountDetail);

        return lsttrgStatus;
    }

     public static List<Trigger_Status__c>createAccountTriggerSettingasTrue(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c trgStatus = new Trigger_Status__c();
        trgStatus.Name = 'AccountAirlineLeveltrigger';
        trgStatus.Active__c = true;
        lsttrgStatus.add(trgStatus);
        
        Trigger_Status__c AccountTeam = new Trigger_Status__c();
        AccountTeam.Name = 'AccountTeam';
        AccountTeam.Active__c = true;
        lsttrgStatus.add(AccountTeam);
        
        Trigger_Status__c AccountEligibilityLogTrigger = new Trigger_Status__c();
        AccountEligibilityLogTrigger.Name = 'AccountEligibilityLogTrigger';
        AccountEligibilityLogTrigger.Active__c = true;
        lsttrgStatus.add(AccountEligibilityLogTrigger);
        
        Trigger_Status__c AccountDeleteTrigger = new Trigger_Status__c();
        AccountDeleteTrigger.Name = 'AccountDeleteTrigger';
        AccountDeleteTrigger.Active__c = true;
        lsttrgStatus.add(AccountDeleteTrigger);

        Trigger_Status__c AccountUpdateAccountDetail = new Trigger_Status__c();
        AccountUpdateAccountDetail.Name = 'AccountUpdateAccountDetail';
        AccountUpdateAccountDetail.Active__c = true;
        lsttrgStatus.add(AccountUpdateAccountDetail);
         
        Trigger_Status__c updateRelatedRecordsOnOwnerChange = new Trigger_Status__c();
        updateRelatedRecordsOnOwnerChange.Name = 'updateRelatedRecordsOnOwnerChange';
        updateRelatedRecordsOnOwnerChange.Active__c = true;
        lsttrgStatus.add(updateRelatedRecordsOnOwnerChange);

        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createContactTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c ContactCeateAccount = new Trigger_Status__c();
        ContactCeateAccount.Name = 'ContactCeateAccount';
        ContactCeateAccount.Active__c = true;
        lsttrgStatus.add(ContactCeateAccount);
        
        Trigger_Status__c AccconRshipUpdate = new Trigger_Status__c();
        AccconRshipUpdate.Name = 'AccconRshipUpdate';
        AccconRshipUpdate.Active__c = true;
        lsttrgStatus.add(AccconRshipUpdate);


        Trigger_Status__c ContactAttachCase = new Trigger_Status__c();
        ContactAttachCase.Name = 'ContactAttachCase';
        ContactAttachCase.Active__c = true;
        lsttrgStatus.add(ContactAttachCase);

        Trigger_Status__c ContactUpdateContact = new Trigger_Status__c();
        ContactUpdateContact.Name = 'ContactUpdateContact';
        ContactUpdateContact.Active__c = true;
        lsttrgStatus.add(ContactUpdateContact);

        return lsttrgStatus;
    }
    
    public static List<Trigger_Status__c>createProductRegTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c CreateOpportunities = new Trigger_Status__c();
        CreateOpportunities.Name = 'CreateOpportunities';
        CreateOpportunities.Active__c = true;
        lsttrgStatus.add(CreateOpportunities);

        Trigger_Status__c updateActivateCheckBox = new Trigger_Status__c();
        updateActivateCheckBox.Name = 'prdreg.updateActivateCheckBox';
        updateActivateCheckBox.Active__c = true;
        lsttrgStatus.add(updateActivateCheckBox);

        Trigger_Status__c PrdRegUpdateAmexDetailsOnAquire = new Trigger_Status__c();
        PrdRegUpdateAmexDetailsOnAquire.Name = 'PrdRegUpdateAmexDetailsOnAquire';
        PrdRegUpdateAmexDetailsOnAquire.Active__c = true;
        lsttrgStatus.add(PrdRegUpdateAmexDetailsOnAquire);

        Trigger_Status__c PrdRegCalculateAMEXAcceptRejectCode = new Trigger_Status__c();
        PrdRegCalculateAMEXAcceptRejectCode.Name = 'PrdRegCalculateAMEXAcceptRejectCode';
        PrdRegCalculateAMEXAcceptRejectCode.Active__c = true;
        lsttrgStatus.add(PrdRegCalculateAMEXAcceptRejectCode);
        

        Trigger_Status__c PrdRegUpdateRelatedAquireMembers = new Trigger_Status__c();
        PrdRegUpdateRelatedAquireMembers.Name = 'PrdRegUpdateRelatedAquireMembers';
        PrdRegUpdateRelatedAquireMembers.Active__c = true;
        lsttrgStatus.add(PrdRegUpdateRelatedAquireMembers);

        Trigger_Status__c PrdRegUpdateMembershipNumberonAccount = new Trigger_Status__c();
        PrdRegUpdateMembershipNumberonAccount.Name = 'PrdRegUpdateMembershipNumberonAccount';
        PrdRegUpdateMembershipNumberonAccount.Active__c = true;
        lsttrgStatus.add(PrdRegUpdateMembershipNumberonAccount);
        
        Trigger_Status__c PrdRegProcessAMEXEligibility = new Trigger_Status__c();
        PrdRegProcessAMEXEligibility.Name = 'PrdRegProcessAMEXEligibility';
        PrdRegProcessAMEXEligibility.Active__c = true;
        lsttrgStatus.add(PrdRegProcessAMEXEligibility);

        Trigger_Status__c AccountMultipleQBRCaseCreation = new Trigger_Status__c();
        AccountMultipleQBRCaseCreation.Name = 'PrdRegMultipleQBRCaseCreation';
        AccountMultipleQBRCaseCreation.Active__c = true;
        lsttrgStatus.add(AccountMultipleQBRCaseCreation);
        
        Trigger_Status__c PrdRegAmexProdRegValidation = new Trigger_Status__c();
        PrdRegAmexProdRegValidation.Name = 'PrdRegAmexProdRegValidation';
        PrdRegAmexProdRegValidation.Active__c = true;
        lsttrgStatus.add(PrdRegAmexProdRegValidation);
         
        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createCaseTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c populateBasicAutoCaseValues = new Trigger_Status__c();
        populateBasicAutoCaseValues.Name = 'CaseTriggerPopulateBasicAutoCaseValues';
        populateBasicAutoCaseValues.Active__c = true;
        lsttrgStatus.add(populateBasicAutoCaseValues);
        
        Trigger_Status__c CaseHotwordQueueRoutingTrigger = new Trigger_Status__c();
        CaseHotwordQueueRoutingTrigger.Name = 'CaseHotwordQueueRoutingTrigger';
        CaseHotwordQueueRoutingTrigger.Active__c = true;
        lsttrgStatus.add(CaseHotwordQueueRoutingTrigger);
        
        Trigger_Status__c updateCaseCompliment = new Trigger_Status__c();
        updateCaseCompliment.Name = 'updateCaseComplimentTemplateValue';
        updateCaseCompliment.Active__c = true;
        lsttrgStatus.add(updateCaseCompliment);
       
        Trigger_Status__c updateCaseFields = new Trigger_Status__c();
        updateCaseFields.Name = 'updateCaseFields';
        updateCaseFields.Active__c = true;
        lsttrgStatus.add(updateCaseFields);
        
        Trigger_Status__c fetchCongaEmail = new Trigger_Status__c();
        fetchCongaEmail.Name = 'fetchCongaEmailTemplateId';
        fetchCongaEmail.Active__c = true;
        lsttrgStatus.add(fetchCongaEmail);
        
        Trigger_Status__c autoCaseProcess = new Trigger_Status__c();
        autoCaseProcess.Name = 'autoCaseProcess';
        autoCaseProcess.Active__c = true;
        lsttrgStatus.add(autoCaseProcess);
        
        Trigger_Status__c caseStatusUpdated = new Trigger_Status__c();
        caseStatusUpdated.Name = 'caseStatusUpdated';
        caseStatusUpdated.Active__c = true;
        lsttrgStatus.add(caseStatusUpdated);
        
        Trigger_Status__c CaseTriggerCloseCase = new Trigger_Status__c();
        CaseTriggerCloseCase.Name = 'CaseTriggerCloseCase';
        CaseTriggerCloseCase.Active__c = true;
        lsttrgStatus.add(CaseTriggerCloseCase);
        
        Trigger_Status__c assignCaseOwner = new Trigger_Status__c();
        assignCaseOwner.Name = 'assignCaseOwner';
        assignCaseOwner.Active__c = true;
        lsttrgStatus.add(assignCaseOwner);
        
        Trigger_Status__c postToChatterFeed = new Trigger_Status__c();
        postToChatterFeed.Name = 'postToChatterFeed';
        postToChatterFeed.Active__c = true;
        lsttrgStatus.add(postToChatterFeed);
        
        Trigger_Status__c CaseTriggerUpdate = new Trigger_Status__c();
        CaseTriggerUpdate.Name = 'CaseTriggerUpdateCaseSLA';
        CaseTriggerUpdate.Active__c = true;
        lsttrgStatus.add(CaseTriggerUpdate);
        
        Trigger_Status__c CaseEscalatedTo = new Trigger_Status__c();
        CaseEscalatedTo.Name = 'CaseTriggerUpdateCaseEscalatedTo';
        CaseEscalatedTo.Active__c = true;
        lsttrgStatus.add(CaseEscalatedTo);
        
        Trigger_Status__c UpdateCaseOnClos = new Trigger_Status__c();
        UpdateCaseOnClos.Name = 'CaseTriggerUpdateCaseOnClose';
        UpdateCaseOnClos.Active__c = true;
        lsttrgStatus.add(UpdateCaseOnClos);

        Trigger_Status__c SubmitForFinalisation = new Trigger_Status__c();
        SubmitForFinalisation.Name = 'SubmitForFinalisation';
        SubmitForFinalisation.Active__c = true;
        lsttrgStatus.add(SubmitForFinalisation);

        Trigger_Status__c trgCaseFieldUpdates = new Trigger_Status__c();
        trgCaseFieldUpdates.Name = 'trgCaseFieldUpdates';
        trgCaseFieldUpdates.Active__c = false;
        lsttrgStatus.add(trgCaseFieldUpdates);

        Trigger_Status__c CaseTriggerCalculateEmergencyExpense = new Trigger_Status__c();
        CaseTriggerCalculateEmergencyExpense.Name = 'CaseTriggerCalculateEmergencyExpense';
        CaseTriggerCalculateEmergencyExpense.Active__c = true;
        lsttrgStatus.add(CaseTriggerCalculateEmergencyExpense);

        Trigger_Status__c CaseTriggerupdateContactBlankEmail = new Trigger_Status__c();
        CaseTriggerupdateContactBlankEmail.Name = 'CaseTriggerupdateContactBlankEmail';
        CaseTriggerupdateContactBlankEmail.Active__c = true;
        lsttrgStatus.add(CaseTriggerupdateContactBlankEmail);

        Trigger_Status__c CaseTriggerpopulateonCaseCreate = new Trigger_Status__c();
        CaseTriggerpopulateonCaseCreate.Name = 'CaseTriggerpopulateonCaseCreate';
        CaseTriggerpopulateonCaseCreate.Active__c = true;
        lsttrgStatus.add(CaseTriggerpopulateonCaseCreate);

        Trigger_Status__c SetAuditFieldsOnCase = new Trigger_Status__c();
        SetAuditFieldsOnCase.Name = 'SetAuditFieldsOnCase';
        SetAuditFieldsOnCase.Active__c = true;
        lsttrgStatus.add(SetAuditFieldsOnCase);

        Trigger_Status__c CaseTriggerDeleteAffectedPassengers = new Trigger_Status__c();
        CaseTriggerDeleteAffectedPassengers.Name = 'CaseTriggerDeleteAffectedPassengers';
        CaseTriggerDeleteAffectedPassengers.Active__c = true;
        lsttrgStatus.add(CaseTriggerDeleteAffectedPassengers);

        Trigger_Status__c CaseTriggerUpdateTECHFields = new Trigger_Status__c();
        CaseTriggerUpdateTECHFields.Name = 'CaseTriggerUpdateTECHFields';
        CaseTriggerUpdateTECHFields.Active__c = true;
        lsttrgStatus.add(CaseTriggerUpdateTECHFields);

        Trigger_Status__c CaseTriggerPostNotification = new Trigger_Status__c();
        CaseTriggerPostNotification.Name = 'CaseTriggerPostNotification';
        CaseTriggerPostNotification.Active__c = true;
        lsttrgStatus.add(CaseTriggerPostNotification);
        
        Trigger_Status__c CaseTriggerUpdateRecContact = new Trigger_Status__c();
        CaseTriggerUpdateRecContact.Name = 'CaseTriggerUpdateRecContact';
        CaseTriggerUpdateRecContact.Active__c = true;
        lsttrgStatus.add(CaseTriggerUpdateRecContact);

        Trigger_Status__c trgTradeSiteResponses = new Trigger_Status__c();
        trgTradeSiteResponses.Name = 'trgTradeSiteResponses';
        trgTradeSiteResponses.Active__c = true;
        lsttrgStatus.add(trgTradeSiteResponses);
        
        Trigger_Status__c CaseTriggeragencyCreditFulfilment = new Trigger_Status__c();
        CaseTriggeragencyCreditFulfilment.Name = 'CaseTriggeragencyCreditFulfilment';
        CaseTriggeragencyCreditFulfilment.Active__c = true;
        lsttrgStatus.add(CaseTriggeragencyCreditFulfilment);
       
        //GRAPHITE-1151
        Trigger_Status__c CaseStream = new Trigger_Status__c();
        CaseStream.Name = 'QCC_CaseStream';
        CaseStream.Active__c = true;
        lsttrgStatus.add(CaseStream);

        //GRAPHITE-409, GRAPHITE-927: Enforces running the assignment rule for VIP cases
        Trigger_Status__c assignVIPCaseUsingAssignmentRule = new Trigger_Status__c();
        assignVIPCaseUsingAssignmentRule.Name = 'assignVIPCaseUsingAssignmentRule';
        assignVIPCaseUsingAssignmentRule.Active__c = true;
        lsttrgStatus.add(assignVIPCaseUsingAssignmentRule);
        
        //
        Trigger_Status__c assetCreationTrigger = new Trigger_Status__c();
        assetCreationTrigger.Name = 'AssetCreationTrigger';
        assetCreationTrigger.Active__c = true;
        lsttrgStatus.add(assetCreationTrigger);

        Trigger_Status__c CaseTriggerV1 = new Trigger_Status__c();
        CaseTriggerV1.Name = 'CaseTriggerV1';
        CaseTriggerV1.Active__c = false;
        lsttrgStatus.add(CaseTriggerV1);

        Trigger_Status__c CaseTriggerV2 = new Trigger_Status__c();
        CaseTriggerV2.Name = 'CaseTriggerV2';
        CaseTriggerV2.Active__c = true;
        lsttrgStatus.add(CaseTriggerV2);

        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createAttachmentTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c attTriggerEligiblityCheckAttachmentDel = new Trigger_Status__c();
        attTriggerEligiblityCheckAttachmentDel.Name = 'AttTriggerEligiblityCheckAttachmentDel';
        attTriggerEligiblityCheckAttachmentDel.Active__c = true;
        lsttrgStatus.add(attTriggerEligiblityCheckAttachmentDel);
        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createContentTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c attTriggerEligiblityCheckAttachmentDel = new Trigger_Status__c();
        attTriggerEligiblityCheckAttachmentDel.Name = 'ContDocTriggerEligiblityCheckContDel';
        attTriggerEligiblityCheckAttachmentDel.Active__c = true;
        lsttrgStatus.add(attTriggerEligiblityCheckAttachmentDel);
        return lsttrgStatus;
    }

    public static List<Trigger_Status__c> createAffectedPassengerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c isAffectedPassenger = new Trigger_Status__c();
        isAffectedPassenger.Name = 'isAffectedPassenger';
        isAffectedPassenger.Active__c = false;
        lsttrgStatus.add(isAffectedPassenger);
        return lsttrgStatus;
    }

    public static List<Trigger_Status__c> createFlightFailureSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c FltFlrTrgCheckDuplicateFF = new Trigger_Status__c();
        FltFlrTrgCheckDuplicateFF.Name = 'FltFlrTrgCheckDuplicateFF';
        FltFlrTrgCheckDuplicateFF.Active__c = true;
        lsttrgStatus.add(FltFlrTrgCheckDuplicateFF);
        Trigger_Status__c FltFlrTrgAddFailureCodePassEvt = new Trigger_Status__c();
        FltFlrTrgAddFailureCodePassEvt.Name = 'FltFlrTrgAddFailureCodePassEvt';
        FltFlrTrgAddFailureCodePassEvt.Active__c = true;
        lsttrgStatus.add(FltFlrTrgAddFailureCodePassEvt);
        Trigger_Status__c FltFlrTrgUpdateEmailCom = new Trigger_Status__c();
        FltFlrTrgUpdateEmailCom.Name = 'FltFlrTrgUpdateEmailCom';
        FltFlrTrgUpdateEmailCom.Active__c = true;
        lsttrgStatus.add(FltFlrTrgUpdateEmailCom);

        Trigger_Status__c FltFlrTrgFlightFailureDeleteCheck = new Trigger_Status__c();
        FltFlrTrgFlightFailureDeleteCheck.Name = 'FltFlrTrgFlightFailureDeleteCheck';
        FltFlrTrgFlightFailureDeleteCheck.Active__c = true;
        lsttrgStatus.add(FltFlrTrgFlightFailureDeleteCheck);
        return lsttrgStatus;
    }

     public static List<Trigger_Status__c>createRecoveryTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();

        Trigger_Status__c updateRecoveryType = new Trigger_Status__c();
        updateRecoveryType.Name = 'updateRecoveryType';
        updateRecoveryType.Active__c = true;
        lsttrgStatus.add(updateRecoveryType);
        
        Trigger_Status__c setFulfilledBy = new Trigger_Status__c();
        setFulfilledBy.Name = 'setFulfilledBy';
        setFulfilledBy.Active__c = true;
        lsttrgStatus.add(setFulfilledBy);
       
        Trigger_Status__c handleRecoveryTrigger = new Trigger_Status__c();
        handleRecoveryTrigger.Name = 'handleRecoveryTrigger';
        handleRecoveryTrigger.Active__c = true;
        lsttrgStatus.add(handleRecoveryTrigger);
        
        Trigger_Status__c InvokeLoyaltyPostService = new Trigger_Status__c();
        InvokeLoyaltyPostService.Name = 'RecoveryInvokeLoyaltyPostService';
        InvokeLoyaltyPostService.Active__c = true;
        lsttrgStatus.add(InvokeLoyaltyPostService);
        
        Trigger_Status__c UpdateCaseRecoveryValue = new Trigger_Status__c();
        UpdateCaseRecoveryValue.Name = 'RecoveryTriggerUpdateCaseRecoveryValue';
        UpdateCaseRecoveryValue.Active__c = true;
        lsttrgStatus.add(UpdateCaseRecoveryValue);
        
        Trigger_Status__c RecoveryTriggerPostToChatter = new Trigger_Status__c();
        RecoveryTriggerPostToChatter.Name = 'RecoveryTriggerPostToChatter';
        RecoveryTriggerPostToChatter.Active__c = true;
        lsttrgStatus.add(RecoveryTriggerPostToChatter);

        Trigger_Status__c routeCaseOnRecoveryPaymentUpdate = new Trigger_Status__c();
        routeCaseOnRecoveryPaymentUpdate.Name = 'routeCaseOnRecoveryPaymentUpdate';
        routeCaseOnRecoveryPaymentUpdate.Active__c = true;
        lsttrgStatus.add(routeCaseOnRecoveryPaymentUpdate);

        Trigger_Status__c getSuggestedRange = new Trigger_Status__c();
        getSuggestedRange.Name = 'getSuggestedRange';
        getSuggestedRange.Active__c = true;
        lsttrgStatus.add(getSuggestedRange);

        Trigger_Status__c recoveryTriggerUpdateCaseRecoveryEvent = new Trigger_Status__c();
        recoveryTriggerUpdateCaseRecoveryEvent.Name = 'RecoveryTriggerUpdateCaseRecoveryEvent';
        recoveryTriggerUpdateCaseRecoveryEvent.Active__c = true;
        lsttrgStatus.add(recoveryTriggerUpdateCaseRecoveryEvent);

        Trigger_Status__c isNotFrequentFlyerMember = new Trigger_Status__c();
        isNotFrequentFlyerMember.Name = 'isNotFrequentFlyerMember';
        isNotFrequentFlyerMember.Active__c = true;
        lsttrgStatus.add(isNotFrequentFlyerMember);

        Trigger_Status__c isFrequentFlyerMember = new Trigger_Status__c();
        isFrequentFlyerMember.Name = 'isFrequentFlyerMember';
        isFrequentFlyerMember.Active__c = true;
        lsttrgStatus.add(isFrequentFlyerMember);

        Trigger_Status__c RecoveryTriggerSubmitForFinalisation = new Trigger_Status__c();
        RecoveryTriggerSubmitForFinalisation.Name = 'RecoveryTriggerSubmitForFinalisation';
        RecoveryTriggerSubmitForFinalisation.Active__c = true;
        lsttrgStatus.add(RecoveryTriggerSubmitForFinalisation);
        
        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createAssetTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c calculateFeesAndDiscounts = new Trigger_Status__c();
        calculateFeesAndDiscounts.Name = 'AssetCalculateFeesandDiscounts';
        calculateFeesAndDiscounts.Active__c = true;
        lsttrgStatus.add(calculateFeesAndDiscounts);

        Trigger_Status__c AssetConvertingAssetType  = new Trigger_Status__c();
        AssetConvertingAssetType .Name = 'AssetConvertingAssetType ';
        AssetConvertingAssetType .Active__c = true;
        lsttrgStatus.add(AssetConvertingAssetType );
        return lsttrgStatus;
    }
    
    public static List<Trigger_Status__c>createContractTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c ContractTrigger = new Trigger_Status__c();
        ContractTrigger.Name = 'ContractTrigger';
        ContractTrigger.Active__c = true;
        lsttrgStatus.add(ContractTrigger);
        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createEventTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c EventTriggerGetPassengers = new Trigger_Status__c();
        EventTriggerGetPassengers.Name = 'EventTriggerGetPassengers';
        EventTriggerGetPassengers.Active__c = true;
        lsttrgStatus.add(EventTriggerGetPassengers);
        
        Trigger_Status__c updateEventFields = new Trigger_Status__c();
        updateEventFields.Name = 'EventTriggerUpdateEventFields';
        updateEventFields.Active__c = true;
        lsttrgStatus.add(updateEventFields);

        Trigger_Status__c EventTriggerArrivingAtDestination = new Trigger_Status__c();
        EventTriggerArrivingAtDestination.Name = 'EventTriggerArrivingAtDestination';
        EventTriggerArrivingAtDestination.Active__c = true;
        lsttrgStatus.add(EventTriggerArrivingAtDestination);

        Trigger_Status__c EventTriggerGetFlightInfo = new Trigger_Status__c();
        EventTriggerGetFlightInfo.Name = 'EventTriggerGetFlightInfo';
        EventTriggerGetFlightInfo.Active__c = true;
        lsttrgStatus.add(EventTriggerGetFlightInfo);

        Trigger_Status__c EventTriggerCreateRecovery = new Trigger_Status__c();
        EventTriggerCreateRecovery.Name = 'EventTriggerCreateRecovery';
        EventTriggerCreateRecovery.Active__c = true;
        lsttrgStatus.add(EventTriggerCreateRecovery);
        
        Trigger_Status__c eventTriggerUpdateAffectedPassenger = new Trigger_Status__c();
        eventTriggerUpdateAffectedPassenger.Name = 'EventTriggerUpdateAffectedPassenger';
        eventTriggerUpdateAffectedPassenger.Active__c = true;
        lsttrgStatus.add(eventTriggerUpdateAffectedPassenger);

        Trigger_Status__c eventTriggerCreateTaskforEvent = new Trigger_Status__c();
        eventTriggerCreateTaskforEvent.Name = 'EventTriggerCreateTaskforEvent';
        eventTriggerCreateTaskforEvent.Active__c = true;
        lsttrgStatus.add(eventTriggerCreateTaskforEvent);

        Trigger_Status__c EventTriggerCreateEventComms = new Trigger_Status__c();
        EventTriggerCreateEventComms.Name = 'EventTriggerCreateEventComms';
        EventTriggerCreateEventComms.Active__c = true;
        lsttrgStatus.add(EventTriggerCreateEventComms);

        Trigger_Status__c EventTriggerSendCommsOnEventClosure = new Trigger_Status__c();
        EventTriggerSendCommsOnEventClosure.Name = 'EventTriggerSendCommsOnEventClosure';
        EventTriggerSendCommsOnEventClosure.Active__c = true;
        lsttrgStatus.add(EventTriggerSendCommsOnEventClosure);

        Trigger_Status__c EventTriggerAutoCloseEvent = new Trigger_Status__c();
        EventTriggerAutoCloseEvent.Name = 'EventTriggerAutoCloseEvent';
        EventTriggerAutoCloseEvent.Active__c = true;
        lsttrgStatus.add(EventTriggerAutoCloseEvent);

        Trigger_Status__c GlobalEventTriggerUpdateAuditFields = new Trigger_Status__c();
        GlobalEventTriggerUpdateAuditFields.Name = 'GlobalEventTriggerUpdateAuditFields';
        GlobalEventTriggerUpdateAuditFields.Active__c = true;
        lsttrgStatus.add(GlobalEventTriggerUpdateAuditFields);

        Trigger_Status__c EventTriggerPostEventClosedAction = new Trigger_Status__c();
        EventTriggerPostEventClosedAction.Name = 'EventTriggerPostEventClosedAction';
        EventTriggerPostEventClosedAction.Active__c = true;
        lsttrgStatus.add(EventTriggerPostEventClosedAction);

        Trigger_Status__c EventTriggerDelayCostsCompletedAction = new Trigger_Status__c();
        EventTriggerDelayCostsCompletedAction.Name = 'EventTriggerDelayCostsCompletedAction';
        EventTriggerDelayCostsCompletedAction.Active__c = true;
        lsttrgStatus.add(EventTriggerDelayCostsCompletedAction);

        Trigger_Status__c EventTriggerUpdateEventCost = new Trigger_Status__c();
        EventTriggerUpdateEventCost.Name = 'EventTriggerUpdateEventCost';
        EventTriggerUpdateEventCost.Active__c = true;
        lsttrgStatus.add(EventTriggerUpdateEventCost);

        Trigger_Status__c EventTriggerValidateEvent = new Trigger_Status__c();
        EventTriggerValidateEvent.Name = 'EventTriggerValidateEvent';
        EventTriggerValidateEvent.Active__c = true;
        lsttrgStatus.add(EventTriggerValidateEvent);
            
        Trigger_Status__c EventTriggerConvertRecordtype = new Trigger_Status__c();
        EventTriggerConvertRecordtype.Name = 'EventTriggerConvertRecordtype';
        EventTriggerConvertRecordtype.Active__c = true;
        lsttrgStatus.add(EventTriggerConvertRecordtype);
            
        Trigger_Status__c EventTriggerManualAddStop = new Trigger_Status__c();
        EventTriggerManualAddStop.Name = 'EventTriggerManualAddStop';
        EventTriggerManualAddStop.Active__c = true;
        lsttrgStatus.add(EventTriggerManualAddStop);

        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createAffectedPassengerTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();

        Trigger_Status__c isAffectedPassenger = new Trigger_Status__c();
        isAffectedPassenger.Name = 'isAffectedPassenger';
        isAffectedPassenger.Active__c = true;
        lsttrgStatus.add(isAffectedPassenger);

        Trigger_Status__c PassengerUpdateAirportName = new Trigger_Status__c();
        PassengerUpdateAirportName.Name = 'PassengerUpdateAirportName';
        PassengerUpdateAirportName.Active__c = true;
        lsttrgStatus.add(PassengerUpdateAirportName); 
        
        Trigger_Status__c RollupPassengerBasedonTier = new Trigger_Status__c();
        RollupPassengerBasedonTier.Name = 'RollupPassengerBasedonTier';
        RollupPassengerBasedonTier.Active__c = true;
        lsttrgStatus.add(RollupPassengerBasedonTier);

        Trigger_Status__c PassengerTriggerCreateOffloadCase = new Trigger_Status__c();
        PassengerTriggerCreateOffloadCase.Name = 'PassengerTriggerCreateOffloadCase';
        PassengerTriggerCreateOffloadCase.Active__c = true;
        lsttrgStatus.add(PassengerTriggerCreateOffloadCase);

        Trigger_Status__c PassengerTriggerCreateDisruptionCase = new Trigger_Status__c(); 
        PassengerTriggerCreateDisruptionCase.Name = 'PassengerTriggerCreateCase'; 
        PassengerTriggerCreateDisruptionCase.Active__c = true; 
        lsttrgStatus.add(PassengerTriggerCreateDisruptionCase); 
        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createEmailMessageTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();

        Trigger_Status__c EmailMessageHelper = new Trigger_Status__c();
        EmailMessageHelper.Name = 'EmailMessageHelper';
        EmailMessageHelper.Active__c = true;
        lsttrgStatus.add(EmailMessageHelper);

        Trigger_Status__c EmailMessageTriggerLoungePassNonFFM = new Trigger_Status__c();
        EmailMessageTriggerLoungePassNonFFM.Name = 'EmailMessageTriggerLoungePassNonFFM';
        EmailMessageTriggerLoungePassNonFFM.Active__c = false;
        lsttrgStatus.add(EmailMessageTriggerLoungePassNonFFM);
        
        
        Trigger_Status__c EmailMessageTriggerV1 = new Trigger_Status__c();
        EmailMessageTriggerV1.Name = 'EmailMessageTriggerV1';
        EmailMessageTriggerV1.Active__c = false;
        lsttrgStatus.add(EmailMessageTriggerV1);

        
        Trigger_Status__c EmailMessageTriggerV2 = new Trigger_Status__c();
        EmailMessageTriggerV2.Name = 'EmailMessageTriggerV2';
        EmailMessageTriggerV2.Active__c = true;
        lsttrgStatus.add(EmailMessageTriggerV2);
        
        Trigger_Status__c processCaseEmailMessage = new Trigger_Status__c(Name='processCaseEmailMessage', Active__c=true);
        lsttrgStatus.add(processCaseEmailMessage);

        Trigger_Status__c captureFirstOutboundEmail = new Trigger_Status__c(Name='captureFirstOutboundEmail', Active__c=true);
        lsttrgStatus.add(captureFirstOutboundEmail);
        
        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createFlightTrackerTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();

        Trigger_Status__c FlightTrackerTriggerPopulateUTCFields = new Trigger_Status__c();
        FlightTrackerTriggerPopulateUTCFields.Name = 'FlightTrackerTriggerPopulateUTCFields';
        FlightTrackerTriggerPopulateUTCFields.Active__c = true;
        lsttrgStatus.add(FlightTrackerTriggerPopulateUTCFields);

        Trigger_Status__c validateFlightEventCreation = new Trigger_Status__c();
        validateFlightEventCreation.Name = 'validateFlightEventCreation';
        validateFlightEventCreation.Active__c = true;
        lsttrgStatus.add(validateFlightEventCreation);

        Trigger_Status__c FlightMovementCreateFlightTrackerEvent = new Trigger_Status__c();
        FlightMovementCreateFlightTrackerEvent.Name = 'FlightMovementCreateFlightTrackerEvent';
        FlightMovementCreateFlightTrackerEvent.Active__c = true;
        lsttrgStatus.add(FlightMovementCreateFlightTrackerEvent);

        return lsttrgStatus;
    }
    
    public static List<Trigger_Status__c>createEventCommunicationTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();

        Trigger_Status__c EvtCommsTrgLinkPassengerWithComms = new Trigger_Status__c();
        EvtCommsTrgLinkPassengerWithComms.Name = 'EvtCommsTrgLinkPassengerWithComms';
        EvtCommsTrgLinkPassengerWithComms.Active__c = true;
        lsttrgStatus.add(EvtCommsTrgLinkPassengerWithComms);

        return lsttrgStatus;
    }

    public static List<Trigger_Status__c>createGlobalEventTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();

        Trigger_Status__c updateAuditFields = new Trigger_Status__c();
        updateAuditFields.Name = 'GlobalEventTriggerUpdateAuditFields';
        updateAuditFields.Active__c = true;
        lsttrgStatus.add(updateAuditFields);

        return lsttrgStatus;
    }
    
     public static List<Trigger_Status__c>createContentdocumentLinkTriggerSetting(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();

        Trigger_Status__c contentdocumentlinkstg = new Trigger_Status__c();
        contentdocumentlinkstg.Name = 'ContentDocLinkTriggerCheck';
        contentdocumentlinkstg.Active__c = true;
        lsttrgStatus.add(contentdocumentlinkstg);

        return lsttrgStatus;
    }
   
    
    public static void createQantasConfigDataAccRecType(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Account RecType1','Agency Account;Charter Account;Customer Account;Global Account;Other Account;Prospect Account;Regional Account;'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Account RecType2',''));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Account RecType3',''));
        upsert lstConfigData;
    }
    

    public static void createEnableValidationRuleSetting(){
        Map<String,Id> mapProfile = new Map<String, Id>();
        for(Profile objProfile: [Select Name, Id from Profile]){
            mapProfile.put(objProfile.Name, objProfile.Id);
        }

        List<EnableValidationRule__c> lstEnableValidation = new List<EnableValidationRule__c>();

        EnableValidationRule__c settings = new EnableValidationRule__c();
        settings.SetupOwnerId = UserInfo.getOrganizationId();
        settings.VR_To_enforce_the_No_Second_Active_AMEX__c = true;
        settings.VR_To_Prevent_Editing_AMEX_Product_In_UI__c = true;
        settings.VR_MandatoryCheck_Active_PublicScheme__c = true;
        settings.VR_MandatoryCheck_BefActivation_CorpSch__c = true;
        settings.VR_To_Check_If_Status_Not_RevretedBack__c = true;
        settings.VR_To_Prevent_Changing_the_Scheme_Types__c = true;
        settings.VR_To_Prevent_Editing_StartDate__c = true;
        settings.VR_To_Prevent_Past_StartDate_On_Pub_SCH__c = true;
        settings.VR_To_Prevent_Updating_Inactive_Asset__c = true;
        settings.VR_To_Prevent_WEndDT_Lessthan_WStartDT__c = true;
        settings.VR_To_Prevent_Wavier_Dates_Missing__c = true;
        settings.VR_To_prevent_WEndDT_Lowerthan_SchEndDT__c = true;
        settings.VR_to_Prevent_Setting_Status_to_Active__c = true;
        settings.VR_MandatoryCheck_Active_Scheme_Contact__c = true;
        settings.VR_To_Check_PubSch_EndDT_Lessthan_StarDT__c = true;
        settings.VR_To_Prevent_Inactivate_Corp_Scheme__c = true;
        settings.VR_To_Prevent_WavStrDT_High_of_Sch_StrDT__c = true;
        settings.VR_To_Check_SchemeCostCenter_CorpScheme__c = true;
        settings.VR_To_Check_SchemeCostCenter_OnConversio__c = true;
        settings.VR_manual_creation_alternate_preferred__c = false;
        settings.VR_Received_Date_Cannot_Change__c = false;
        settings.VR_Description_field_is_locked_QCC__c = false;
        settings.VR_QCC_Cannot_edit_cases_not_owned_by_us__c = false;
        settings.PreventAttachmentDelete__c = false;
        settings.PreventChatterDeletion__c = false;
        lstEnableValidation.add(settings);

        EnableValidationRule__c adminSettings = new EnableValidationRule__c();
        adminSettings.SetupOwnerId = mapProfile.get('Data Administrator');
        adminSettings.VR_To_enforce_the_No_Second_Active_AMEX__c = true;
        adminSettings.VR_To_Prevent_Editing_AMEX_Product_In_UI__c = false;
        adminSettings.VR_MandatoryCheck_Active_PublicScheme__c = true;
        adminSettings.VR_MandatoryCheck_BefActivation_CorpSch__c = true;
        adminSettings.VR_To_Check_If_Status_Not_RevretedBack__c = true;
        adminSettings.VR_To_Prevent_Changing_the_Scheme_Types__c = true;
        adminSettings.VR_To_Prevent_Editing_StartDate__c = true;
        adminSettings.VR_To_Prevent_Past_StartDate_On_Pub_SCH__c = true;
        adminSettings.VR_To_Prevent_Updating_Inactive_Asset__c = true;
        adminSettings.VR_To_Prevent_WEndDT_Lessthan_WStartDT__c = true;
        adminSettings.VR_To_Prevent_Wavier_Dates_Missing__c = true;
        adminSettings.VR_To_prevent_WEndDT_Lowerthan_SchEndDT__c = true;
        adminSettings.VR_to_Prevent_Setting_Status_to_Active__c = true;
        adminSettings.VR_MandatoryCheck_Active_Scheme_Contact__c = true;
        adminSettings.VR_To_Check_PubSch_EndDT_Lessthan_StarDT__c = true;
        adminSettings.VR_To_Prevent_Inactivate_Corp_Scheme__c = true;
        adminSettings.VR_To_Prevent_WavStrDT_High_of_Sch_StrDT__c = true;
        adminSettings.VR_To_Check_SchemeCostCenter_CorpScheme__c = true;
        adminSettings.VR_To_Check_SchemeCostCenter_OnConversio__c = true;
        adminSettings.VR_manual_creation_alternate_preferred__c = false;
        adminSettings.VR_Received_Date_Cannot_Change__c = false;
        adminSettings.VR_Description_field_is_locked_QCC__c = false;
        adminSettings.VR_QCC_Cannot_edit_cases_not_owned_by_us__c = false;
        adminSettings.PreventAttachmentDelete__c = false;
        adminSettings.PreventChatterDeletion__c = false;
        lstEnableValidation.add(adminSettings);

        /*EnableValidationRule__c sysadminSettings = new EnableValidationRule__c();
        sysadminSettings.SetupOwnerId = mapProfile.get('System Administrator');
        sysadminSettings.VR_To_enforce_the_No_Second_Active_AMEX__c = true;
        sysadminSettings.VR_To_Prevent_Editing_AMEX_Product_In_UI__c = true;
        lstEnableValidation.add(sysadminSettings);*/

        upsert lstEnableValidation;
    }

    public static void createDisableValidationRuleSetting(){
       List<EnableValidationRule__c> lstEnableValidation = new List<EnableValidationRule__c>();

        EnableValidationRule__c settings = new EnableValidationRule__c();
        settings.SetupOwnerId = UserInfo.getUserId();
        settings.VR_To_enforce_the_No_Second_Active_AMEX__c = false;
        settings.VR_To_Prevent_Editing_AMEX_Product_In_UI__c = false;
        settings.VR_MandatoryCheck_Active_PublicScheme__c = false;
        settings.VR_MandatoryCheck_BefActivation_CorpSch__c = false;
        settings.VR_To_Check_If_Status_Not_RevretedBack__c = false;
        settings.VR_To_Prevent_Changing_the_Scheme_Types__c = false;
        settings.VR_To_Prevent_Editing_StartDate__c = false;
        settings.VR_To_Prevent_Past_StartDate_On_Pub_SCH__c = false;
        settings.VR_To_Prevent_Updating_Inactive_Asset__c = false;
        settings.VR_To_Prevent_WEndDT_Lessthan_WStartDT__c = false;
        settings.VR_To_Prevent_Wavier_Dates_Missing__c = false;
        settings.VR_To_prevent_WEndDT_Lowerthan_SchEndDT__c = false;
        settings.VR_to_Prevent_Setting_Status_to_Active__c = false;
        settings.VR_MandatoryCheck_Active_Scheme_Contact__c = false;
        settings.VR_To_Check_PubSch_EndDT_Lessthan_StarDT__c = false;
        settings.VR_To_Prevent_Inactivate_Corp_Scheme__c = false;
        settings.VR_To_Prevent_WavStrDT_High_of_Sch_StrDT__c = false;
        settings.VR_To_Check_SchemeCostCenter_CorpScheme__c = false;
        settings.VR_To_Check_SchemeCostCenter_OnConversio__c = false;
        settings.VR_manual_creation_alternate_preferred__c = false;
        settings.VR_Received_Date_Cannot_Change__c = false;
        settings.VR_Description_field_is_locked_QCC__c = false;
        settings.VR_QCC_Cannot_edit_cases_not_owned_by_us__c = false;
        settings.PreventAttachmentDelete__c = false;
        settings.PreventChatterDeletion__c = false;
        lstEnableValidation.add(settings);

        

        upsert lstEnableValidation;
    }

    public static EnableValidationRule__c createEnableValidationRuleSettingQCC(Id setUpId){
        
        EnableValidationRule__c settings = new EnableValidationRule__c();
        settings.SetupOwnerId = setUpId;
        settings.VR_To_enforce_the_No_Second_Active_AMEX__c = true;
        settings.VR_To_Prevent_Editing_AMEX_Product_In_UI__c = true;
        settings.VR_MandatoryCheck_Active_PublicScheme__c = true;
        settings.VR_MandatoryCheck_BefActivation_CorpSch__c = true;
        settings.VR_To_Check_If_Status_Not_RevretedBack__c = true;
        settings.VR_To_Prevent_Changing_the_Scheme_Types__c = true;
        settings.VR_To_Prevent_Editing_StartDate__c = true;
        settings.VR_To_Prevent_Past_StartDate_On_Pub_SCH__c = true;
        settings.VR_To_Prevent_Updating_Inactive_Asset__c = true;
        settings.VR_To_Prevent_WEndDT_Lessthan_WStartDT__c = true;
        settings.VR_To_Prevent_Wavier_Dates_Missing__c = true;
        settings.VR_To_prevent_WEndDT_Lowerthan_SchEndDT__c = true;
        settings.VR_to_Prevent_Setting_Status_to_Active__c = true;
        settings.VR_MandatoryCheck_Active_Scheme_Contact__c = true;
        settings.VR_To_Check_PubSch_EndDT_Lessthan_StarDT__c = true;
        settings.VR_To_Prevent_Inactivate_Corp_Scheme__c = true;
        settings.VR_To_Prevent_WavStrDT_High_of_Sch_StrDT__c = true;
        settings.VR_To_Check_SchemeCostCenter_CorpScheme__c = true;
        settings.VR_To_Check_SchemeCostCenter_OnConversio__c = true;
        settings.VR_manual_creation_alternate_preferred__c = true;
        settings.VR_Received_Date_Cannot_Change__c = true;
        settings.VR_Description_field_is_locked_QCC__c = true;
        settings.VR_QCC_Cannot_edit_cases_not_owned_by_us__c = true;
        settings.VR_QCC_Restrict_Editing_Contact_Name__c = true;
        settings.PreventAttachmentDelete__c = true;
        settings.PreventChatterDeletion__c = true;
        return settings;
    }
    
    public static SchemeFees__c createSchemeFeesSetting( String recName, Integer oneYrPoint, Integer twoYrPoint,
                                                        String recCurrency, 
                                                Integer joinFeePoint, Integer publishOneYrFee, Integer publishTwoYrFee, 
                                                Integer publishFourYrFee, Integer publishFourYrFeePoint, Integer joinFee, 
                                                String schemeType)
    {
        SchemeFees__c objSchmeFee = new SchemeFees__c();
        objSchmeFee.Name = recName;
        objSchmeFee.X1_Year_Membership_Fee_Points__c = oneYrPoint;
        objSchmeFee.X2_Year_Membership_Fee_points__c = twoYrPoint;
        objSchmeFee.Currency__c = recCurrency;
        objSchmeFee.Join_Fee_Points__c = joinFeePoint;
        objSchmeFee.Published_1_Year_Membership_Fee__c = publishOneYrFee;
        objSchmeFee.Published_2_Year_Membership_Fee__c = publishTwoYrFee;
        objSchmeFee.Published_4_Year_Membership_Fee__c = publishFourYrFee;
        objSchmeFee.Published_4_Year_Membership_Fee_Points__c = publishFourYrFeePoint;
        objSchmeFee.Published_Join_Fee__c =  joinFee;
        objSchmeFee.Scheme_Type__c = schemeType;
        if(schemeType == 'NZD'){
            objSchmeFee.Join_Fee_Exculde_GST__c = true;
        }
        objSchmeFee.Membership_Fee_Exclude_GST__c = false;
        return objSchmeFee;
    }

    public static Case createCaseWithCodingValues(String recordType, String type, String caseGroup, String category, String subCategory, String classification) {
        Case objCase = new Case();
        objCase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', recordType);
        System.debug('Case recordtype id = '+objCase.RecordTypeId);
        objCase.Type = type;
        if(caseGroup == 'Complaint') {
            objCase.Email_Template__c = 'Complaint Template';
        }
        objCase.Group__c = caseGroup;
        objCase.Category__c = category;
        objCase.Sub_Category__c = subCategory;
        objCase.Classification__c = classification;
        objCase.Description = 'Sample Case';
        objCase.Contact_Email__c = 'test@sample.com';
        objCase.Customer_Location__c = 'Metro';
        objCase.Origin = 'Email';
        return objCase;
    }
    
    public static List<Case> insertCases(List<Contact> contacts, String recordType, String type, String caseGroup, String category, String subCategory, String classification) {
        List<Case> caseList = new List<Case>();
        for(Integer i = 0; i < contacts.size(); i++) {
            Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, caseGroup, category, subCategory, classification);
            cs.ContactId = contacts[i].id;
            if(cs.Type == 'Insurance Letter') {
                cs.Origin = 'Qantas.com';
            }
            //cs.Origin = 'Red App';
            caseList.add(cs);
        }
        insert caseList;
        return caseList;
        
    }
    
    public static List<Case> assertCase(List<Case> caseList, Integer templateCount) {
        List<Case> cases = [Select Id, Template_to_be_used__c, First_Compliment_Date__c FROM Case WHERE Id = :caseList];
        for(Integer i = 0; i < cases.size(); i++) {
            cases[i].First_Compliment_Date__c = Date.newInstance(2016, 12, 01);
        }
        return cases;
    }


    public static Case_Category__c createCaseCategory(String type, String caseGroup, String category, String subCategory, String classification) {
        Case_Category__c objCase = new Case_Category__c();
        objCase.Type__c = type;
        objCase.Group__c = caseGroup;
        objCase.Category__c = category;
        objCase.Sub_Category__c = subCategory;
        objCase.Classification__c = classification;
        return objCase;
    }
    
    public static List<Case_Category__c> insertCaseCategories(List<Case> cases, String type, String caseGroup, String category, String subCategory, String classification) {
        List<Case_Category__c> caseList = new List<Case_Category__c>();
        for(Integer i = 0; i < cases.size(); i++) {
            Case_Category__c cs = TestUtilityDataClassQantas.createCaseCategory(type, caseGroup, category, subCategory, classification);
            cs.Case__c = cases[i].id;
            caseList.add(cs);
        }
        //insert caseList;
        return caseList;
    }

    public static List<Recovery__c> insertRecoveries(List<Case> cases) {
        List<Recovery__c> recoveriesList = new List<Recovery__c>();
        for(Integer i = 0; i < cases.size(); i++) {
            Recovery__c rec = new Recovery__c();
            rec.Case_Number__c = cases[i].Id;
            rec.Contact__c = cases[i].ContactId;
            rec.Status__c = 'New';
            rec.Process_Status__c = 'New';
            rec.Investigated_By__c = UserInfo.getUserId();
            recoveriesList.add(rec);
        }
        insert recoveriesList;
        return recoveriesList;
    }

    public static List<Recovery__c> insertRecoverieswithRecType(List<Case> cases, String recRecTypeId, String prcsStatus, String type) {
        List<Recovery__c> recoveriesList = new List<Recovery__c>();
        for(Integer i = 0; i < cases.size(); i++) {
            Recovery__c rec = new Recovery__c();
            rec.Case_Number__c = cases[i].Id;
            rec.RecordTypeId = recRecTypeId;
            rec.Contact__c = cases[i].ContactId;
            rec.Process_Status__c = prcsStatus;
            rec.Type__c = type;
            rec.Investigated_By__c = UserInfo.getUserId();
            recoveriesList.add(rec);
        }
        insert recoveriesList;
        return recoveriesList;
    }

   public static List<Qantas_API__c> createQantasAPI( ){
        List<Qantas_API__c> lstQantas = new List<Qantas_API__c>();
        
        Qantas_API__c qantasAPI = new Qantas_API__c();
        qantasAPI.Name = 'QCC_CAPToken';
        qantasAPI.ClientId__c = 'test';
        qantasAPI.ClientSecret__c = 'testsecret';
        qantasAPI.EndPoint__c = 'https://api-stage.qantas.com/customer/oauth/token';
        qantasAPI.GrantType__c = 'client_credentials';
        qantasAPI.Method__c = 'GET';
        qantasAPI.Token__c = 'Bearer test';
        lstQantas.add(qantasAPI);
       
       Qantas_API__c qantasAPI1 = new Qantas_API__c();
        qantasAPI1.Name = 'QCC_LoyaltyAPI';
        qantasAPI1.EndPoint__c = 'https://api-stage.qantas.com/loyalty/members/v1';
        qantasAPI1.Method__c = 'GET';
        lstQantas.add(qantasAPI1);
       
       Qantas_API__c qantasAPI2 = new Qantas_API__c();
        qantasAPI2.Name = 'QCC_BookingSummaryAPI';
        qantasAPI2.EndPoint__c = 'https://api-stage.qantas.com/customer/capcre/v1/';
        qantasAPI2.Method__c = 'GET';
        lstQantas.add(qantasAPI2);
       
       Qantas_API__c qantasAPI3 = new Qantas_API__c();
        qantasAPI3.Name = 'QCC_LoyaltyToken';
        qantasAPI3.ClientId__c = 'test';
        qantasAPI3.ClientSecret__c = 'testsecret';
        qantasAPI3.EndPoint__c = 'https://api-stage.qantas.com/loyalty/oauth/token';
        qantasAPI3.GrantType__c = 'client_credentials';
        qantasAPI3.Method__c = 'GET';
        qantasAPI3.Token__c = 'Bearer test';
        lstQantas.add(qantasAPI3);
       
       Qantas_API__c qantasAPI4 = new Qantas_API__c();
        qantasAPI4.Name = 'QCC_BookingToken';
        qantasAPI4.ClientId__c = 'test';
        qantasAPI4.ClientSecret__c = 'testsecret';
        qantasAPI4.EndPoint__c = 'https://api-stage.qantas.com/booking/oauth/token';
        qantasAPI4.GrantType__c = 'client_credentials';
        qantasAPI4.Method__c = 'GET';
        qantasAPI4.Token__c = 'Bearer test';
        lstQantas.add(qantasAPI4);
       
       Qantas_API__c qantasAPI5 = new Qantas_API__c();
        qantasAPI5.Name = 'QCC_CAPDetailsAPI';
        qantasAPI5.EndPoint__c = 'https://api-stage.qantas.com/customer/capcre/v1/details';
        qantasAPI5.Method__c = 'POST';
        lstQantas.add(qantasAPI5);
       
       Qantas_API__c qantasAPI6 = new Qantas_API__c();
        qantasAPI6.Name = 'QCC_CAPCustomerTransAPI';
        qantasAPI6.EndPoint__c = 'https://api-stage.qantas.com/customer/capcre/v1/transaction/summary';
        qantasAPI6.Method__c = 'POST';
        lstQantas.add(qantasAPI6);
       
       Qantas_API__c qantasAPI7 = new Qantas_API__c();
        qantasAPI7.Name = 'QCC_CAPBookingAPI';
        qantasAPI7.EndPoint__c = 'https://api-stage.qantas.com/customer/capcre/v1/customer/products';
        qantasAPI7.Method__c = 'POST';
        lstQantas.add(qantasAPI7);
       
       Qantas_API__c qantasAPI8 = new Qantas_API__c();
        qantasAPI8.Name = 'QCC_CAPPNRRetrieve';
        qantasAPI8.EndPoint__c = 'https://api-stage.qantas.com/booking/capcre/v1/';
        qantasAPI8.Method__c = 'GET';
        lstQantas.add(qantasAPI8);

        Qantas_API__c qantasAPI9 = new Qantas_API__c();
        qantasAPI9.Name = 'QCC_CAPFlightInfoRetrieve';
        qantasAPI9.EndPoint__c = 'https://api-stage.qantas.com/flight/capcre/v1/';
        qantasAPI9.Method__c = 'GET';
        lstQantas.add(qantasAPI9);

        Qantas_API__c qantasAPI10 = new Qantas_API__c();
        qantasAPI10.Name = 'QCC_FlightToken';
        qantasAPI10.EndPoint__c = 'https://api-stage.qantas.com/customer/oauth/token';
        qantasAPI10.clientId__c = '712c7c5f';
        qantasAPI10.GrantType__c = 'client_credentials';
        qantasAPI10.Method__c = 'GET';
        qantasAPI10.Token__c = 'Bearer 3524dae790f5513eae26cdf64764e59ca8b3bb25';
        lstQantas.add(qantasAPI10);

        Qantas_API__c qantasAPI11 = new Qantas_API__c();
        qantasAPI11.Name = 'QCC_CAPPassengersRetrieve';
        qantasAPI11.EndPoint__c = 'https://api-stage.qantas.com/flight/capcre/v1/';
        qantasAPI11.Method__c = 'GET';
        lstQantas.add(qantasAPI11);

        Qantas_API__c qantasAPI12 = new Qantas_API__c();
        qantasAPI12.Name = 'QCC_OPLAToken';
        qantasAPI12.EndPoint__c = 'https://qccare.getsandbox.com/opla';
        qantasAPI12.clientId__c = '712c7c5f';
        qantasAPI12.GrantType__c = 'client_credentials';
        qantasAPI12.Method__c = '';
        qantasAPI12.Token__c = 'Bearer 3524dae790f5513eae26cdf64764e59ca8b3bb25';
        lstQantas.add(qantasAPI12);

        Qantas_API__c qantasAPI13 = new Qantas_API__c();
        qantasAPI13.Name = 'QCC_OPLAAPI';
        qantasAPI13.EndPoint__c = 'https://qccare.getsandbox.com/opla';
        qantasAPI13.Method__c = 'POST';
        lstQantas.add(qantasAPI13);
       
        Qantas_API__c qantasAPI14 = new Qantas_API__c();
        qantasAPI14.Name = 'QCC_FlightDisruptionsAPI';
        qantasAPI14.EndPoint__c = 'https://api-stage.qantas.com/customer/capcre/v1/';
        qantasAPI14.Method__c = 'GET';
        lstQantas.add(qantasAPI14);
       
        Qantas_API__c qantasAPI15 = new Qantas_API__c();
        qantasAPI15.Name = 'QCC_CAPToken_FlightDisruptions';
        qantasAPI15.EndPoint__c = 'https://api-stage.qantas.com/api/token';
        qantasAPI15.Method__c = 'POST';
        qantasAPI15.ClientId__c = 'test';
        qantasAPI15.ClientSecret__c = 'testsecret';
        qantasAPI15.GrantType__c = 'client_credentials'; 
        qantasAPI15.Token__c = 'Bearer 3524dae790f5513eae26cdf64764e59ca8b3bb25';
        lstQantas.add(qantasAPI15);
       
        Qantas_API__c qantasAPI16 = new Qantas_API__c();
        qantasAPI16.Name = 'QCC_FlightDisruptionsCommAPI';
        qantasAPI16.EndPoint__c = 'https://api-stage.qantas.com/booking/capcre/v1/';
        qantasAPI16.Method__c = 'GET';
        lstQantas.add(qantasAPI16);

        Qantas_API__c qantasAPI17 = new Qantas_API__c();
        qantasAPI17.Name = 'QCC_CustomerRetrieveFlightsToken';
        qantasAPI17.EndPoint__c = 'https://api-stage.qantas.com/api/token';
        qantasAPI17.Method__c = 'POST';
        qantasAPI17.ClientId__c = 'test';
        qantasAPI17.ClientSecret__c = 'testsecret';
        qantasAPI17.GrantType__c = 'client_credentials';
        qantasAPI17.Token__c = 'Bearer 3524dae790f5513eae26cdf64764e59ca8b3bb25';
        lstQantas.add(qantasAPI17);

        Qantas_API__c qantasAPI18 = new Qantas_API__c();
        qantasAPI18.Name = 'QCC_CustomerRetrieveFlightsAPI';
        qantasAPI18.EndPoint__c = 'https://api-stage.qantas.com/customer/capcre/v1/{ffNo}/product/flights?timeQualifier=ScheduleDeparture&fromTimestamp={fromTimestamp}&toTimestamp={toTimestamp}';
        qantasAPI18.Method__c = 'GET';
        qantasAPI18.ClientId__c = 'test_clientid';
        qantasAPI18.ClientSecret__c = 'test_secret';
        qantasAPI18.GrantType__c = 'test_granttype';
        lstQantas.add(qantasAPI18);
       
        Qantas_API__c qantasAPI19 = new Qantas_API__c();
        qantasAPI19.Name = 'QCC_LoyaltyAccrualAPI';
        qantasAPI19.EndPoint__c = 'https://api-stage.qantas.com/loyalty/members';
        qantasAPI19.Method__c = 'GET';
        lstQantas.add(qantasAPI19);
         
        Qantas_API__c qantasAPI20 = new Qantas_API__c();
        qantasAPI20.Name = 'QCC_FeeWaiverAPI';
        qantasAPI20.EndPoint__c = 'https://api-stage.qantas.com/customer/capcre/v1/';
        qantasAPI20.Method__c = 'GET';
       	qantasAPI20.ClientId__c = 'test_clientid';
        qantasAPI20.ClientSecret__c = 'test_secret';
        qantasAPI20.GrantType__c = 'test_granttype';
        qantasAPI20.Token__c = 'Bearer 3524dae790f5513eae26cdf64764e59ca8b3bb25';
        lstQantas.add(qantasAPI20);

        return lstQantas;
    }

    public static List<APXTConga4__Conga_Email_Template__c> createCongaEmailTemplates(){
        List<APXTConga4__Conga_Email_Template__c> templates = new List<APXTConga4__Conga_Email_Template__c>();
        APXTConga4__Conga_Email_Template__c complaintTemplate = new APXTConga4__Conga_Email_Template__c();
        complaintTemplate.Type__c = 'Complaint';
        complaintTemplate.Group__c = 'In-Flight';
        complaintTemplate.Category__c = 'In-Flight Entertainment';
        complaintTemplate.Sub_category__c = '';
        complaintTemplate.Classification__c = '';
        complaintTemplate.Email_Template__c = 'Complaint Template';
        templates.add(complaintTemplate);

        APXTConga4__Conga_Email_Template__c farTemplate = new APXTConga4__Conga_Email_Template__c();
        farTemplate.Type__c = 'Complaint';
        farTemplate.Group__c = 'Flight Disruptions';
        farTemplate.Category__c = 'Downgrade';
        farTemplate.Sub_category__c = 'QF Booking Throughfare';
        farTemplate.Classification__c = '';
        farTemplate.Email_Template__c = 'Complaint Template';
        templates.add(farTemplate);

        APXTConga4__Conga_Email_Template__c insuranceTemplate = new APXTConga4__Conga_Email_Template__c();
        insuranceTemplate.Type__c = 'Insurance Letter';
        insuranceTemplate.Group__c = 'Delayed Flight';
        insuranceTemplate.APXTConga4__Name__c = 'QCC Delayed Flight';
        insuranceTemplate.APXTConga4__Template_Group__c = 'QCC Insurance Template';
        templates.add(insuranceTemplate);

        APXTConga4__Conga_Email_Template__c baggageTemplate = new APXTConga4__Conga_Email_Template__c();
        baggageTemplate.Type__c = 'Baggage';
        baggageTemplate.Email_Template__c = 'Qantas Not Liable';
        templates.add(baggageTemplate);

        return templates;
    }

    public static List<APXTConga4__Conga_Template__c> createCongaTemplates(){
        List<APXTConga4__Conga_Template__c> templates = new List<APXTConga4__Conga_Template__c>();
        
        APXTConga4__Conga_Template__c insuranceTemplate = new APXTConga4__Conga_Template__c();
        insuranceTemplate.Email_Template_Name__c = 'QCC Delayed Flight';
        insuranceTemplate.APXTConga4__Template_Group__c = 'QCC Insurance Template';
        templates.add(insuranceTemplate);

        return templates;
    }

    public static Event__c createEventWithValues(String recordType, String status, String delayFailureCode, String intOrDom) {
        Event__c newEvent = new Event__c();
        newEvent.RecordTypeId = GenericUtils.getObjectRecordTypeId('Event__c', recordType);//'012O0000000AwY4IAK';
        //System.debug('Event recordtype id = '+objEvent.RecordTypeId);
        newEvent.Status__c = status;
        newEvent.DelayFailureCode__c = delayFailureCode;
        newEvent.IntDom__c = intOrDom;
        newEvent.GoldBusiness__c = 1;
        newEvent.GoldEconomy__c = 2;
        newEvent.GoldFirstClass__c = 3;
        newEvent.GoldPremiumEconomy__c = 4;
        newEvent.NonTieredBusiness__c = 5;
        newEvent.NonTieredEconomy__c = 6;
        newEvent.NonTieredFirstClass__c = 7;
        newEvent.NonTieredPremiumEconomy__c = 8;
        newEvent.PlatinumBusiness__c = 9;
        newEvent.PlatinumEconomy__c = 10;
        newEvent.PlatinumFirstClass__c = 11;
        newEvent.PlatinumPremiumEconomy__c = 12;
        newEvent.Platinum1SSUBusiness__c = 13;
        newEvent.Platinum1SSUEconomy__c = 14;
        newEvent.Platinum1SSUFirstClass__c = 15;
        newEvent.Platinum1SSUPremiumEconomy__c = 16;
        newEvent.SilverBusiness__c = 17;
        newEvent.SilverEconomy__c = 18;
        newEvent.SilverFirstClass__c = 19;
        newEvent.SilverPremiumEconomy__c = 20;
        newEvent.BronzeBusiness__c = 21;
        newEvent.BronzeEconomy__c = 22;
        newEvent.BronzeFirstClass__c = 23;
        newEvent.BronzePremiumEconomy__c = 24;
        return newEvent;
    }

    public static Affected_Passenger__c createAffectedPassengerWithValues(Id contactId){
        Affected_Passenger__c passenger = new Affected_Passenger__c();
        passenger.Affected__c = true;
        passenger.Name = 'AFDP-TEST';
        passenger.Passenger__c = contactId;
        passenger.Email__c = 'afftest@testabc.com';
        passenger.Cabin__c ='First Class'; 
        passenger.FF_Tier__c = 'Silver';
        passenger.FrequentFlyerTier__c ='Silver';
        passenger.Cabin__c ='Premium Economy'; 
        passenger.FF_Tier__c = 'Gold';
        passenger.FrequentFlyerTier__c = 'Gold';
        return passenger;
    }

    public static void createCongaQueries() {
        APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c();
        congaQuery.APXTConga4__Name__c = 'QCC Affected Passenger For Insurance Letter';
        congaQuery.APXTConga4__Query__c = 'select firstname__c, lastname__c, Ticket_Number__c, Fare_Total__c, Refund_Amount__c, Booking_Change_Fee__c, Cancellation_Fee__c from Affected_Passenger__c where Case__c = \'{pv0}\'';
        insert congaQuery;
    }
    //creating test data for special conditions
    public static List<QEC_Special_Condition__c> getSpecialConditions(){
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        List<QEC_Special_Condition__c> splconditionList = new List<QEC_Special_Condition__c>();
        for(Integer i=0;i<3;i++){
            QEC_Special_Condition__c condition1 = new QEC_Special_Condition__c(QEC_Baggagecode__c='ABCDE',QEC_BlockRevenueTarget__c=2.0,QEC_Blocksize__c='TEMP',QEC_Cancellation__c='As per published',
                                                                               QEC_Conditions__c='NIL',QEC_DayofWeek__c='TUESDAY',QEC_Discount__c=13.22,QEC_FarebasisFarerulenumber__c='354',QEC_FareBasis__c='TEST',QEC_History__c=False,
                                                                               QEC_Flightnumber__c='QEC225',QEC_FromDate__c =System.today() + 5,QEC_HourDay__c='Hours',QEC_KgPc__c='Kg',QEC_Network__c='Domestic',QEC_NoShow__c='Allowed',QEC_Numberofpieces__c=12,
                                                                               QEC_Route__c='SINGAPORE',QEC_TimefromDeparture__c=12.30,QEC_ToDate__c = System.today() +10,QEC_Type__c='Additional Baggage', Proposal__c=proposalList[0].id);
            splconditionList.add(condition1);
        }
        return splconditionList;
    }
    //Test data creation for TMC starts here
    public static List<Agency_Info__c> getTMC(){
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        List<Account> agencyaccList = new List<Account>(); 
        List<Agency_Info__c> tmcList = new List<Agency_Info__c>();
        Integer QIC = 1234567;
        for(Integer i=1; i<4; i++){ 
            Account acc = new Account(Name = 'SampleAgent'+i, Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                      RecordTypeId = agencyRecordTypeId, Migrated__c = false, 
                                      Qantas_Industry_Centre_ID__c = string.valueOf(QIC), IATA_Number__c = string.valueOf(QIC),
                                      Agency__c = 'Y', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' 
                                     );
            agencyaccList.add(acc);
            QIC = QIC + i;            
        } 
        try{
            Database.Insert(agencyaccList);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
       Integer i = 0;
       for (Account acc : agencyaccList){
           Agency_Info__c tmc = new Agency_Info__c(Account__c = acc.Id, PCC__c = 'aaa'+i, Active__c = true, Code__c = 'Sabre');
           tmcList.add(tmc);
           i = i+1;
       }
        try{
            Database.Insert(tmcList);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        return tmcList;
    }    
    //Test data creation for TMC ends here
    //
    //creating test data for airport codes
    public static List<Airport_Code__c> createAirportCode(){
        List<Airport_Code__c> codeList = new List<Airport_Code__c>();
        Airport_Code__c src = new Airport_Code__c();
        src.Name = 'SYD';
        Airport_Code__c dest = new Airport_Code__c();
        dest.Name = 'PER';
        codeList.add(src);
        codeList.add(dest);
        insert codeList;
        return codeList;
    }
    public static List<Fare_Structure__c> getFareStructures() {
        List<Fare_Structure__c> fareList = new List<Fare_Structure__c>();
        for (Integer i=0;i<3;i++) {
            Fare_Structure__c fs = new Fare_Structure__c(Name = 'J'+i, Active__c = true, Cabin__c = 'Business', 
                                                     Category__c = 'Mainline', Market__c = 'Australia', 
                                                     ProductCode__c = 'DOM-0001'+i, Qantas_Published_Airfare__c = 'JBUS',
                                                     Segment__c = 'Domestic');
          fareList.add(fs);  
        }
        return fareList;
    }
    public static List<Knowledge__kav> insertArticles(){
        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        for(Integer i=0;i<3;i++){
            Knowledge__kav k= new Knowledge__kav();
            k.title ='Test '+i;
            k.Classification__c='National Memo';
            k.UrlName='testURL'+i;
            k.Answer__c ='test Article';
            k.Visible_in_Noticeboard__c =true;
            articles.add(k);
        }
        insert articles;
        return articles;
    }
    public static void insertTopics()
    {
        Network networkDetails=[SELECT Id FROM Network where Name='Knowledge iQ'];
        //ConnectApi.Topic topic = ConnectApi.Topics.createTopic(networkDetails.Id,'Test topic','');
        Topic t = new Topic();
        t.name ='Test Topic';
        t.NetworkId = networkDetails.Id;
        insert t;
        ConnectApi.ManagedTopic mangtopic1 = ConnectApi.ManagedTopics.createManagedTopic(networkDetails.Id,t.Id,ConnectApi.ManagedTopicType.Navigational);
    }
   
}