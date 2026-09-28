/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   APex Class for Customer Detail display on the Service console panel
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
30-OCT-2017    Praveen Sampath               Initial Design
23-Nov-2017    Purushotham                   Added saveRecovery method 
24-Nov-2017    Anupam                        Added escalateCase method
25-Nov-2017    Purushotham                   Added isConsultant method
26-Nov-2017    Anupam                        Updated fetchCustomerDetail method
27-Nov-2017    Purushotham                   Added isCaseClosed method
19-Dec-2017    Anupam                        Updated fetchRecordTypeValues for Radio buttons
19-Jan-2018    Felix                         Update fetchCustomerDetail to perform DML in Queueable Apex so the panel load regardless of DML errors
14-Feb-2018    Praveen Sampath               Removed Queueable and made the update synchronous
27-Nov-2019    Leslie May Padilla            Since introducing the private sharing model between B2B and B2C (instead of having Public Read/Write),
                                                need to set the background process to updates/refreshes the contact record to bypass sharing when any user is viewing a record that they don't own
                                                To fix, have added the "without sharing" key word.
13-Feb-2020    Lora Mae Dapulang             GRAPHITE-1748 | Switch for "Start Work" and "Resolve Case" buttons
13-Oct-2021    Manjula Ravikumar             CRM-5003 | Member API V2 Changes | Introduced differnt callouts and modified wrapper references 
15-Nov-2021    Pradnya Unde                  Fetches the promotions to display on case/contact record
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class QCC_CustomerDetailController {

    /*--------------------------------------------------------------------------------------
    Method Name:        fetchCustomerDetail
    Description:        Fetches the QCC Customer information to display
    Parameter:          RecordId
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static BannerWrapper fetchCustomerDetail(String recId, Boolean isPageLoad){
         BannerWrapper bannerWrap = new BannerWrapper();
         
        try{
            system.debug('CaseID####'+recId);
            Id conId;

            Contact objCon = fetchContact(recId);
            System.debug('objCon ==========> ' + objCon);
            if(objCon == Null){
                //Added by Anupam to handle empty contactid from Case
                return null;
            }
            
            Boolean isChanged = false;
            List<OtherProducts> lstOtherProducts = new List<OtherProducts>();
             /* Introduced 4 different API callouts as part of Member API V2 changes CRM - 5003 */
            List<QCC_LoyaltyResponseWrapper.programs> programWrapperList = new List<QCC_LoyaltyResponseWrapper.programs>();
            if(objCon != Null && objCon.Frequent_Flyer_Number__c != Null && isPageLoad){
                /*QCC_LoyaltyResponseWrapper loyaltyResponse = QCC_InvokeCAPAPI.invokeLoyaltyAPI(objCon.Frequent_Flyer_Number__c);*/ /*CRM-5003*/
                QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount loyaltyAccountResponse = QCC_InvokeCAPAPI.invokeLoyaltyAccountAPI(objCon.Frequent_Flyer_Number__c);
                System.debug('loyaltyAccountResponse=======> ' + loyaltyAccountResponse);
                QCC_LoyaltyResponseWrapper.Programs loyaltyProgramResponse = QCC_InvokeCAPAPI.invokeLoyaltyProgramAPI(objCon.Frequent_Flyer_Number__c);
                System.debug('loyaltyProgramResponse=======> ' + loyaltyProgramResponse);
                QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTierResponse = QCC_InvokeCAPAPI.invokeLoyaltyTierAPI(objCon.Frequent_Flyer_Number__c);
                System.debug('loyaltyTierResponse=======> ' + loyaltyTierResponse);
                /*if(loyaltyResponse != Null){*/ /*CRM-5003*/
                if(loyaltyAccountResponse != Null){
                    /*if(objCon.Points_Balance__c != loyaltyResponse.pointBalance){ 
                        objCon.Points_Balance__c = loyaltyResponse.pointBalance;
                    }*/  /*CRM - 5003 */
                    if(objCon.Points_Balance__c != loyaltyAccountResponse.pointBalance){
                        objCon.Points_Balance__c = loyaltyAccountResponse.pointBalance;
                        isChanged = true;
                    }
                     //Commenting to remap the field for correct Frequent Flyer Banner Information INC2400534
                    /* if(loyaltyAccountResponse.statusCredits != Null && objCon.Status_Credits__c != loyaltyAccountResponse.statusCredits.lifetime){
                        objCon.Status_Credits__c = loyaltyAccountResponse.statusCredits.lifetime;
                        isChanged = true;
                    }*/
                    //Replacement code to remap the field for correct Frequent Flyer Banner Information INC2400534
                    if(loyaltyAccountResponse.statusCredits != Null && objCon.Status_Credits__c != loyaltyAccountResponse.statusCredits.total){
                        objCon.Status_Credits__c = loyaltyAccountResponse.statusCredits.total;
                        isChanged = true;
                    }
                }
                
                /* if(loyaltyResponse.dateOfJoining != Null && objCon.Year_of_Joining__c != Date.valueOf(loyaltyResponse.dateOfJoining) ||  
                        objCon.QCC_Frequent_Flyer_Anniversary_Date__c != Date.valueOf(loyaltyResponse.dateOfJoining))   
                    {   
                        objCon.Year_of_Joining__c = Date.valueOf(loyaltyResponse.dateOfJoining);    
                        objCon.QCC_Frequent_Flyer_Anniversary_Date__c = Date.valueOf(loyaltyResponse.dateOfJoining);    
                        isChanged = true;   
                    }*/  /*CRM-5003*/
                if(loyaltyProgramResponse != null) {
                    if(loyaltyProgramResponse.enrolmentDate != Null && objCon.Year_of_Joining__c != Date.valueOf(loyaltyProgramResponse.enrolmentDate)) 
                        
                    {
                        objCon.Year_of_Joining__c = Date.valueOf(loyaltyProgramResponse.enrolmentDate);
                       //Commenting to remap the field for correct Frequent Flyer Banner Information INC2400534
                        //objCon.QCC_Frequent_Flyer_Anniversary_Date__c = Date.valueOf(loyaltyProgramResponse.enrolmentDate);
                        isChanged = true;
                    }  
                     //Adding If block to remap the field for correct Frequent Flyer Banner Information INC2400534
                    if(loyaltyProgramResponse.expiryDate!=null && objCon.QCC_Frequent_Flyer_Anniversary_Date__c != Date.valueOf(loyaltyProgramResponse.expiryDate))
                    {
                        objCon.QCC_Frequent_Flyer_Anniversary_Date__c = Date.valueOf(loyaltyProgramResponse.expiryDate);
                        isChanged = true;
                    }
                }   

                    /** Removed by BAU (CRM-3112)
                    if(objCon.Birthdate != Null && objCon.Birthdate !=  Date.valueOf(loyaltyResponse.dateOfBirth)){
                        objCon.Birthdate = Date.valueOf(loyaltyResponse.dateOfBirth);
                        isChanged = true;
                    }*/

                    // Check Contact QCC_TECH_Member_Tier_Downgrade_Date__c before updating Contact Frequentflyer Tier by Loyalty Tier Response.
                    // If QCC_TECH_Member_Tier_Downgrade_Date__c is Null or less than Today, sync Frequent Flyer Tier
                    system.debug(objCon.QCC_TECH_Member_Tier_Downgrade_Date__c +' downgrade date vs date today ' + Date.today());
                    boolean isUpdateTier = false;
                    if(objCon.QCC_TECH_Member_Tier_Downgrade_Date__c == null || objCon.QCC_TECH_Member_Tier_Downgrade_Date__c <= Date.today()){
                        isUpdateTier = true;
                    }
                   /* if(loyaltyResponse.programDetails != Null && loyaltyResponse.programDetails.size()>0){    
                        for(QCC_LoyaltyResponseWrapper.programDetails program: loyaltyResponse.programDetails){
                   */ /*CRM-5003*/
                    programWrapperList.add(loyaltyProgramResponse);
                    if(programWrapperList != Null && programWrapperList.size()>0){
                        for(QCC_LoyaltyResponseWrapper.programs program: programWrapperList) {
                            if(program.programCode != 'QFF' && program.accountStatus=='ACTIVE'){
                                OtherProducts otherProdInfo = new OtherProducts();
                                otherProdInfo.programName = program.programName;
                                otherProdInfo.programCode = program.programCode;
                                lstOtherProducts.add(otherProdInfo);
                            }
                            /*if (loyaltyResponse.tier.code =='CLPO' && isUpdateTier)*/ /*CRM-5003*/
                            if (loyaltyTierResponse != null && loyaltyTierResponse.qantasFrequentFlyerTier.effectiveTier =='CHAIRMANS_LOUNGE_PLATINUM_ONE' && isUpdateTier)
                            {
                                //String formattedString = String.format('Chairman\'\'{0} {1}', new String[]{'s', 'Lounge Platinum One'});
                                objCon.Frequent_Flyer_Tier__c= System.Label.QCC_CL_P1;
                                isChanged = true;
                            }
                            else
                            {
                            if(program.programCode!='CL' && program.programCode=='QFF' &&
                                   objCon.Frequent_Flyer_tier__c != CustomSettingsUtilities.getConfigDataMap(/*program.tierCode) CRM-5003*/loyaltyTierResponse.qantasFrequentFlyerTier.effectiveTier) && isUpdateTier)
                                    {
                                        String effectiveTier = loyaltyTierResponse.qantasFrequentFlyerTier.effectiveTier;
                                        String tierDescription = loyaltyTierResponse.qantasFrequentFlyerTier.tierDescription;
                                        System.debug('tierDescription===========> ' + tierDescription);
                                        if (effectiveTier != null && (effectiveTier.equalsIgnoreCase('SILVER') || effectiveTier.equalsIgnoreCase('GOLD')))
                                        {
                                            if (tierDescription != null && 
                                                (tierDescription.equals('Frequent Flyer Lifetime Gold') || tierDescription.equals('Frequent Flyer Lifetime Silver')))
                                            {
                                                effectiveTier = 'LIFETIME_' + effectiveTier;   
                                            }
                                        }
                                        objCon.Frequent_Flyer_tier__c = CustomSettingsUtilities.getConfigDataMap(/*program.tierCode) CRM-5003*/effectiveTier);
                                        isChanged = true;
                                    }

                            //Chairman's Lounge Functionality
                            else if(program.programCode=='CL' && program.accountStatus=='ACTIVE' && isUpdateTier)
                            {
                            objCon.Frequent_Flyer_tier__c = System.Label.QCC_Chairmans_Lounge;
                                isChanged = true;
                            }
                            }
                        }
                    }

                    //CRM-8740
                    if (loyaltyTierResponse != null && loyaltyTierResponse.qantasFrequentFlyerTier != null
                            && loyaltyTierResponse.qantasFrequentFlyerTier.lifetimeTier != null && !String.isEmpty(loyaltyTierResponse.qantasFrequentFlyerTier.lifetimeTier)) {
                        objCon.Profile_Membership_Lifetime_Tier__c = CustomSettingsUtilities.getConfigDataMap('QCC FF Lifetime Tier ' + loyaltyTierResponse.qantasFrequentFlyerTier.lifetimeTier);
                        isChanged = true;
                    }
                    system.debug('aaaaaaaaaaaaa'+objCon.Frequent_Flyer_tier__c);
                       String setting = 'SC-'+objCon.Frequent_Flyer_tier__c;
                      //String setting = objCon.Frequent_Flyer_tier__c;
                    system.debug('ssssssssssssss'+setting);
                    /* Integer statusCredit = loyaltyResponse.statusCredits != Null && loyaltyResponse.statusCredits.lifetime != Null? loyaltyResponse.statusCredits.lifetime: 0;*/ /*CRM-5003*/
                    //Commenting to remap the field for correct Frequent Flyer Banner Information INC2400534
                    //Integer statusCredit = loyaltyAccountResponse.statusCredits != Null && loyaltyAccountResponse.statusCredits.lifetime != Null? loyaltyAccountResponse.statusCredits.lifetime: 0;
                    
                    //Adding replacement code to remap the field for correct Frequent Flyer Banner Information INC2400534
                  Integer statusCredit=0;
                  Integer remaining ;
                    if(loyaltyAccountResponse!=null && loyaltyAccountResponse.statusCredits != Null && loyaltyAccountResponse.statusCredits.total != Null) 
                    {
                        statusCredit=loyaltyAccountResponse.statusCredits.total; 
                    }
                    
                    Integer nextLevel = String.isBlank(CustomSettingsUtilities.getConfigDataMap(setting))?statusCredit:Integer.valueOf(CustomSettingsUtilities.getConfigDataMap(setting));
                    
                    //Adding If condition to perform not null check for correcting the Frequent Flyer Banner Information INC2400534
                    if(nextLevel!=null && statusCredit!=null)
                    {
                        remaining = nextLevel-statusCredit;
                    }
                    
                    if(objCon.QCC_Status_credits_till_next_Level__c != remaining){
                        objCon.QCC_Status_credits_till_next_Level__c = remaining;
                        isChanged = true;
                    }

                    // Execute Queueable Apex to update the Contact and LoyaltyProgram in the background
                    //System.enqueueJob(new QCC_UpdateLoyaltyAndContactFFQueueable( objCon));
            }
            bannerWrap.objContact = objCon;
            bannerWrap.lstOtherProducts = lstOtherProducts;
            system.debug('bannerWrap##########'+bannerWrap);
            if(isChanged && objCon.LastName != 'Null'){
                try{
                    update objCon;

                }catch(Exception ex){
                    CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                            'fetchCustomerDetail', String.valueOf(''), String.valueOf(''),false,'', ex);
                }
            }
            //QDCUSCON-4985 - Start
            if(recId.startsWith('500')){
                Case objCase = [select Id, ContactId, First_Name__c, Last_Name__c, Contact_Email__c, Contact_Phone__c,
                                    Frequent_Flyer_Tier__c, Frequent_Flyer_Number__c from Case where Id =: recId];
                bannerWrap.objContact.LastName = objCase.Last_Name__c;
                bannerWrap.objContact.FirstName = objCase.First_Name__c;
                bannerWrap.objContact.Preferred_Email__c = objCase.Contact_Email__c;
                bannerWrap.objContact.Preferred_Phone_Number__c = objCase.Contact_Phone__c;
            }
            //QDCUSCON-4985 - End
            //return bannerWrap;
        }catch(Exception ex){
            system.debug('ex######'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                    'fetchCustomerDetail', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return bannerWrap;
    }

   /*--------------------------------------------------------------------------------------
    Method Name:        fetchContact
    Description:        Fetch all the Contact Info
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static Contact fetchContact(String recId){
        Id conId;
        Contact objCon;

        if(recId.startsWith('003')){
            conId = recId;
        }
        else if(recId.startsWith('500')){
            Case objCase = [select Id, ContactId from Case where Id =: recId];
            conId = objCase.ContactId;
        }

        if(conId != null){
            objCon = [select Id, Name, FirstName, LastName, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c,
                              Points_Balance__c, Status_Credits__c, MobilePhone, Preferred_Phone_Number__c,
                              Preferred_Email__c, QCC_Status_credits_till_next_Level__c, Birthdate,
                              QCC_Frequent_Flyer_Anniversary_Date__c,Year_of_Joining__c,
                              MailingCity,MailingStreet,MailingState,MailingPostalCode ,CountryName__c, CAP_ID__c,QCC_TECH_Member_Tier_Downgrade_Date__c,
                              Profile_Membership_Lifetime_Tier__c,Profile_Membership_Customer_Type_Desc__c /**CRM-10216 fetch additonal fields to render additional FF Info */
                              from Contact where Id =: conId];

        }
        return objCon;
    }


    /*--------------------------------------------------------------------------------------
    Method Name:        fetchCaseSummary
    Description:        Fetches the All recordtype of case
    Parameter:
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static BannerWrapper fetchCaseSummary(String recId){
         BannerWrapper bannerWrap =  new BannerWrapper();
        try{
            Contact objCon = fetchContact(recId);
            Integer disruptionsCount = 0;
            
           /* QCC_CAPTransactionWrapper.CAPTransactionRequest requestInfo = new QCC_CAPTransactionWrapper.CAPTransactionRequest();
            requestInfo.system_x = 'CAPCRE_CC';
            requestInfo.firstName = objCon.FirstName;
            requestInfo.surName = objCon.LastName;
            requestInfo.qantasFFNo = objCon.Frequent_Flyer_Number__c;
            requestInfo.version = '1.0';
            //requestInfo.qantasUniqueID = objCon.CAP_ID__c;

            QCC_CAPTransactionWrapper.CAPTransactionResponse disruptionResponse = QCC_InvokeCAPAPI.invokeTransactionCAPAPI(requestInfo);
            if(disruptionResponse != null){
                //disruptionsCount = disruptionResponse.flightDelayDomesticCount == null?0:disruptionResponse.flightDelayDomesticCount +disruptionResponse.flightDelayInternationalCount== null?0: disruptionResponse.flightDelayInternationalCount;
                disruptionsCount = disruptionResponse.flightDelayDomesticCount+disruptionResponse.flightDelayInternationalCount;
            }*/

            Date lastyr = system.today().addMonths(-12);
            //Jira: CRM-4955
            Integer caseCount = [ Select count() from case where contactId =: objCon.Id and ParentId = '' and
                                 CreatedDate >: lastyr];
          //  BannerWrapper bannerWrap = new BannerWrapper();
            //QDCUSCON-4985 - Start
            if(recId.startsWith('500')){
                bannerWrap.objContact = objCon;
            }
            //QDCUSCON-4985 - End
            bannerWrap.caseCount = caseCount;
            bannerWrap.disruptionsCount = disruptionsCount;
           // return bannerWrap;
        }catch(Exception ex){
            system.debug('ex######'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                    'fetchCaseSummary', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
            
        }
        //return null;
         return bannerWrap;
    }



    /*--------------------------------------------------------------------------------------
    Class Name:        BannerWrapper
    Description:        Wrapper to display on the page
    Parameter:
    --------------------------------------------------------------------------------------*/
    public class BannerWrapper{
        @AuraEnabled public Contact objContact;
        @AuraEnabled public Integer caseCount;
        @AuraEnabled public Integer disruptionsCount;
        @AuraEnabled public List<OtherProducts> lstOtherProducts;
    }

    public class OtherProducts{
        @AuraEnabled public String programName;
        @AuraEnabled public String programCode;

    }

    /*--------------------------------------------------------------------------------------
    Method Name:        fetchRecordTypeValues
    Description:        Fetches the All recordtype of case
    Parameter:
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<RecordType> fetchRecordTypeValues(){
        List<RecordType> rtNames = new List<RecordType>();
        List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo rt : recordtypes){
            if(!rt.isMaster() && rt.isAvailable())
             rtNames.add(new RecordType(Id = rt.getRecordTypeId(),Name = rt.getName()));
        }
        return  rtNames;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        caseRecordType
    Description:        Fetches the recordtype of case
    Parameter:
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String caseRecordType(String recId){
        String rid = recId;
        try {
            List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();
            if(rid.startsWith('500')){
                Case cs = [SELECT Id, Status, RecordTypeId, RecordType.Name FROM Case WHERE Id = :recId];
                return cs.RecordType.Name;
            }
        } catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                     'caseRecordType', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }

        return  '';
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        saveRecovery
    Description:        Creates a Recovery record by pre-populating some vales from Case
    Parameter:          Id of Case
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String saveRecovery(Id recId) {
        try {
            User user = [SELECT Id, Profile_Name__c FROM User WHERE Id = :userinfo.getUserId()];
            if(user.Profile_Name__c != 'Qantas Pre Journey CC Consultant') {
            System.debug('Recovery ' + recId);
            Case cs = [SELECT Id,Group__c,Type,EmergencyExpenseStage__c,Recommended_Emergency_Expense__c,
                       Actual_Emergency_Expense__c, ContactId FROM Case WHERE Id = :recId];
            Recovery__c rec = new Recovery__c();
            rec.Case_Number__c = cs.Id;
            rec.Contact__c = cs.ContactId;
            rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusNew');
            rec.Investigated_By__c = UserInfo.getUserId();

            if( cs.Group__c == 'Delayed Baggage' && cs.Type == 'Baggage' ){
               rec.Stage__c = cs.EmergencyExpenseStage__c;
                rec.Monetary_Value__c = cs.Recommended_Emergency_Expense__c;
                if(cs.Actual_Emergency_Expense__c != Null){
                    rec.Monetary_Value__c = cs.Actual_Emergency_Expense__c;
                }
            }

            insert rec;
            return rec.Id;
    }
    }catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                     'saveRecovery', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        isConsultant
    Description:        Checks whether the current user is Consultant or not
    Parameter:          Id of User
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean isConsultant(Id userId) {
        try {
            User user = [SELECT Id, Profile_Name__c FROM User WHERE Id = :userId];
            //CRM-11908 Update metadata rerferences
            if(user.Profile_Name__c == 'Qantas CC Consultant' || user.Profile_Name__c == 'PT1' || user.Profile_Name__c == 'QCC Contact Center Agent Hobart' || 
                user.Profile_Name__c == 'QCC Contact Center Agent Manila' || user.Profile_Name__c == 'QCC Contact Center Agent Capetown' || user.Profile_Name__c == 'QCC Contact Center Agent Suva' 
                || user.Profile_Name__c == 'QCC Contact Center Agent Auckland' || 
                user.Profile_Name__c == 'QCC Contact Center Agent Mumbai') {
                return true;
            }
        } catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                     'isConsultant', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return false;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        isCaseClosed
    Description:        Checks whether the Case is Closed or not
    Parameter:          Id of User
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String isCaseClosed(Id recId) {
        String rid = recId;
        try {
            if(rid.startsWith('500')){
                Case cs = [SELECT Id, Status FROM Case WHERE Id = :recId];
                //if(cs.Status == 'Closed') {
                return cs.Status;                       //GRAPHITE-1151 - return the Case Status instead of a Boolean
                //}
            }
        } catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                    'isCaseClosed', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        isCaseInQueue
    Description:        Checks whether the Case is Closed or not
    Parameter:          Id of User
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean isCaseInQueue(Id recId) {
        String rid = recId;
        try {
            if(rid.startsWith('500')){
                Case cs = [SELECT Id, Status , OwnerId FROM Case WHERE Id = :recId];
                if(string.valueOf(cs.OwnerId).startsWith('00G')) {
                    return true;
                }
            }
        } catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                     'isCaseInQueue', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return false;
    }


    /*--------------------------------------------------------------------------------------
    Method Name:        escalateCase
    Description:        Escalates a case and updates the Chatter feed.
    Parameter:          Record Id of Case
    Future:             To add logic to assign the case to Team Lead of the Component.- Done 26-11-2017
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String escalatingCase(Id recId) {
        try {
            System.debug('Case Id '+recId);
            User user = [SELECT Id, ManagerId, Location__c, Manager.Name FROM User where id = :UserInfo.getUserId()];
            Case cs = [SELECT Id, ContactId, IsEscalated, Owner.Name, OwnerId  FROM Case WHERE Id = :recId];

            System.debug('ID of Case + value of Escalated'+ cs.Id + cs.IsEscalated);
            /********************************************************************************************************************/
            if(!Test.isRunningTest()) {
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem, 'Case Escalated By '+ cs.Owner.Name);
            }
            /********************************************************************************************************************/
            //Added by Purushotham
            cs.Escalated_From__c = cs.Owner.Name;
            cs.Escalated_From_Location__c = user.Location__c;
            //cs.Escalated_To__c = user.Manager.Name;
            //cs.IsEscalated = true; // Commented by Anupam
            cs.OwnerId = user.ManagerId;
            update cs;
            return cs.Id +','+cs.IsEscalated;
        } catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController',
                                     'saveRecovery', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        return null;
    }

     @AuraEnabled
    public static Boolean getProfileToHideForContact(){
        Boolean check = false;
        Id pflId = UserInfo.getProfileId();
        Profile partnerProfile = [Select Id, Name From Profile Where id =:pflId Limit 1];
        System.debug(System.Label.QCC_ProfileHide);
        if(partnerProfile != null){
           String pfls = System.Label.QCC_ProfileHide;
           List<String> prflsNameList = pfls.split(',');
           check = prflsNameList.contains(partnerProfile.name);
        }
        return check;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        getSwitchforStartWorkandResolveCase
    Description:        Get the value of the switch from a custom label
    --------------------------------------------------------------------------------------*/
    // 13-Feb-2020  GRAPHITE-1748 | Added switch for "Start Work" & "Resolve Case" Case Actions
    @AuraEnabled
    public static Boolean getSwitchforStartWorkandResolveCase(Id recId){
        Boolean displayButtons = false;
        //Get the value of the switch from the custom label
        String switchStatus = Label.QCC_StarWork_ResolveCase_Switch.toLowerCase();
        system.debug('###switchStatus: ' + switchStatus);
        
        //Get QCC Case Recordtype to be used to diplay the buttons
        List<String> allQccCaseRecordTypes = Label.QCC_All_QCC_Case_RecordType.split(';');
        
        //Get current Case's Record Type
        Case caseRecord = [SELECT Id, Status, RecordTypeId, RecordType.DeveloperName FROM Case WHERE Id = :recId];
        String caseRT = caseRecord.RecordType.DeveloperName;
        system.debug('###caseRT: ' + caseRT);

        if(allQccCaseRecordTypes.contains(caseRT) && switchStatus == 'true'){
            displayButtons = true;            
        }        
        system.debug('###displayButtons: ' + displayButtons);
        return displayButtons;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        escalateCase
    Description:        Escalates a case and updates the Chatter feed.
    Parameter:          Record Id of Case
    Future:             To add logic to assign the case to Team Lead of the Component.- Done 26-11-2017
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean userHasCustomPermission(String customPermission) {
      
        Boolean hasCustomPermission = false;

        hasCustomPermission = FeatureManagement.checkPermission(customPermission);
        system.debug('###  QCC_CustomerDetailController - userHasCustomPermission : ' + hasCustomPermission);

        return hasCustomPermission;
    }
     /*--------------------------------------------------------------------------------------
    Method Name:        getPromotions
    Description:        Fetches the promotions to display on case/contact record
    Parameter:          recordSFId
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static QCC_RewardsWrapper.PromoRewards getPromotions(String recordSFId){

        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');

        if(String.isBlank(token)) 
            return null;
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyPromoAPI');
        String endpoint = qantasAPI.EndPoint__c + getFFNumber(recordSFId) + '/bonus/rewards';
        //String endpoint = 'https://api-stage.qantas.com/loyalty/memberAccount/v1/1984630754/bonus/rewards';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET'); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse httpResponse = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (httpResponse.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            httpResponse = http.send(req);
        }
        if(httpResponse.getStatusCode() == 200){
            //String resp  = '{ "bonusRewards": [ { "voucherCode": "PROMO09S12AB56", "offer": "VACCINE_BONUS", "selectedReward": "QF FLIGHT VOUCHER", "expiryDate": "2022-03-31", "selectedDate": "2021-09-24" } ] }';
            //String resp = '{ "bonusRewards": [ { "rewardOptions": [ "QANTAS_POINTS" ], "activeOfferCount": 0, "expiryDate": "2021-09-30", "offer": "LOYALTY_BONUS" }, { "rewardOptions": [ "COMPLIMENTARY_GOLD_MEMBERSHIP_REWARD" ], "activeOfferCount": 0, "expiryDate": "2021-09-30", "offer": "LOYALTY_BONUS" }, { "rewards": [ "P1_REWARD_BONUS_75K" ], "activeOfferCount": 0, "expiryDate": "2021-09-30", "offer": "LOYALTY_BONUS" }, { "voucherCode": "PROMO09S12AB56", "offer": "VACCINE_BONUS", "selectedReward": "QF FLIGHT VOUCHER", "expiryDate": "2022-03-31", "selectedDate": "2021-09-24" } ] }';
            String resp = httpResponse.getBody();
            QCC_RewardsWrapper.PromoRewards promoReward = new QCC_RewardsWrapper.PromoRewards();

            QCC_RewardsWrapper wrapper = QCC_RewardsWrapper.parse(resp);
            for(QCC_RewardsWrapper.BonusRewards reward : wrapper.bonusRewards) {
                if(reward.offer == 'VACCINE_BONUS') {
                    promoReward.promoCode = reward.voucherCode;
                    promoReward.promoType = reward.selectedReward;
                    promoReward.promoExpiryDate = reward.expiryDate;
                }                
            } 
            return promoReward;
        }else{
            System.debug('response: else ');
        }
        return null;        
    }

    private static String getFFNumber(String recordSFId) {
        if(null == recordSFId) return '';

        try {
            if(recordSFId.startsWith('003')) {
                return [SELECT Id, Frequent_Flyer_Number__c FROM Contact WHERE Id =: recordSFId LIMIT 1].Frequent_Flyer_Number__c;
            } else if(recordSFId.startsWith('500')) {
                Case theCase = [SELECT Id, Contact.Frequent_Flyer_Number__c FROM Case WHERE Id =: recordSFId LIMIT 1];
                return theCase.Contact.Frequent_Flyer_Number__c;
            }
        }
        catch(Exception exp) {
            return '';
        }        
        return '';
    }
}