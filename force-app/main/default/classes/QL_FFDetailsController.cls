/*----------------------------------------------------------------------------------------------------------------------
Author:        Priyadharshini Vellingiri
Company:       TCS
Description:   Apex Class for FF Detail display on the Contact layout
Inputs:
Test Class:    QL_FFDetailsControllerTest
************************************************************************************************
History
************************************************************************************************
27-APR-2018    Priyadharshini Vellingiri Initial Design
JIRA : CRM 3092 
13-Oct-2021    Manjula Ravikumar 
JIRA : CRM-5003 | Member API V2 Changes | Introduced differnt callouts and modified wrapper references 
-----------------------------------------------------------------------------------------------------------------------*/
public class QL_FFDetailsController { 
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchCustomerDetail
    Description:        Fetches the QCC Customer information to display
    Parameter:          RecordId 
    --------------------------------------------------------------------------------------*/    
    @AuraEnabled
    public static BannerWrapper fetchCustomerDetail(String recId, Boolean isPageLoad){ 
        try{
            BannerWrapper bannerWrap = new BannerWrapper();
            system.debug('CaseID####'+recId);
            Id conId;
            
            Contact objCon = fetchContact(recId);
            System.debug('objConiiiiii'+objCon);
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
                QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(objCon.Frequent_Flyer_Number__c);
                System.debug('loyaltyProfileResponse=======> ' + loyaltyProfileResponse);
                /*if(loyaltyResponse != Null){
                    if(objCon.Points_Balance__c != loyaltyResponse.pointBalance){	
                        objCon.Points_Balance__c = loyaltyResponse.pointBalance;	
                        isChanged = true;	
                    }*/  /*CRM-5003*/
               if(loyaltyAccountResponse != Null){
                    if(objCon.Points_Balance__c != loyaltyAccountResponse.pointBalance){
                        objCon.Points_Balance__c = loyaltyAccountResponse.pointBalance;
                        isChanged = true;
                    }
                     if(loyaltyAccountResponse.statusCredits != Null && objCon.Status_Credits__c != loyaltyAccountResponse.statusCredits.lifetime){
                        objCon.Status_Credits__c = loyaltyAccountResponse.statusCredits.lifetime;
                        isChanged = true;
                    }
                }
                
                /*	
                    if(objCon.Year_of_Joining__c != Date.valueOf(loyaltyResponse.dateOfJoining) || 	
                        objCon.QCC_Frequent_Flyer_Anniversary_Date__c != Date.valueOf(loyaltyResponse.dateOfJoining))	
                    {	
                        objCon.Year_of_Joining__c = Date.valueOf(loyaltyResponse.dateOfJoining);	
                        objCon.QCC_Frequent_Flyer_Anniversary_Date__c = Date.valueOf(loyaltyResponse.dateOfJoining);	
                        isChanged = true;	
                    }
               */ /*CRM--5003*/

                   if(loyaltyProgramResponse != null){
                    programWrapperList.add(loyaltyProgramResponse);
                    for(QCC_LoyaltyResponseWrapper.programs programRecord: programWrapperList) {
                    if(programRecord.enrolmentDate != Null && objCon.Year_of_Joining__c != Date.valueOf(programRecord.enrolmentDate) ||
                        objCon.QCC_Frequent_Flyer_Anniversary_Date__c != Date.valueOf(programRecord.enrolmentDate))
                    {
                        objCon.Year_of_Joining__c = Date.valueOf(programRecord.enrolmentDate);
                        objCon.QCC_Frequent_Flyer_Anniversary_Date__c = Date.valueOf(programRecord.enrolmentDate);
                        isChanged = true;
                    }
                }
                }   

                    

                    if(objCon.Birthdate !=  Date.valueOf(/*loyaltyResponse*/loyaltyProfileResponse.dateOfBirth)){
                        objCon.Birthdate = Date.valueOf(/*loyaltyResponse*/loyaltyProfileResponse.dateOfBirth);
                        isChanged = true;
                    }
                
                  /*   if(loyaltyResponse.programDetails != Null && loyaltyResponse.programDetails.size()>0){	
                        for(QCC_LoyaltyResponseWrapper.programDetails program: loyaltyResponse.programDetails){*/ /*CRM-5003*/

                    if(programWrapperList != Null && programWrapperList.size()>0){
                        for(QCC_LoyaltyResponseWrapper.programs program: programWrapperList){
                            if(program.programCode != 'QFF'){
                                OtherProducts otherProdInfo = new OtherProducts();
                                otherProdInfo.programName = program.programName;
                                otherProdInfo.programCode = program.programCode;
                                lstOtherProducts.add(otherProdInfo);
                            }
                            if(program.programCode == 'QFF' && loyaltyTierResponse != null &&
                                objCon.Frequent_Flyer_tier__c != CustomSettingsUtilities.getConfigDataMap(/*program.tierCode*/ loyaltyTierResponse.qantasFrequentFlyerTier.tierCode)
                                )
                            {
                                objCon.Frequent_Flyer_tier__c = CustomSettingsUtilities.getConfigDataMap(/*program.tierCode*/loyaltyTierResponse.qantasFrequentFlyerTier.tierCode);
                                isChanged = true;
                            }
                        } 
                    }
                    system.debug('aaaaaaaaaaaaa'+objCon.Frequent_Flyer_tier__c);
                    String setting = 'QCCFF_SC-'+objCon.Frequent_Flyer_tier__c;
                    system.debug('ssssssssssssss'+setting);
                    Integer nextLevel = String.isBlank(CustomSettingsUtilities.getConfigDataMap(setting))?/*loyaltyResponse*/loyaltyAccountResponse.statusCredits.lifetime:Integer.valueOf(CustomSettingsUtilities.getConfigDataMap(setting));
                    Integer remaining = nextLevel-/*loyaltyResponse*/loyaltyAccountResponse.statusCredits.lifetime;
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
            if(isChanged){
                try{
                    update objCon;
                }catch(Exception ex){
                    CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController', 
                                            'fetchCustomerDetail', String.valueOf(''), String.valueOf(''),false,'', ex);
                }
            }
            
            return bannerWrap;
        }catch(Exception ex){
            system.debug('ex######'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController', 
                                    'fetchCustomerDetail', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
       // return null;
    }

   /*--------------------------------------------------------------------------------------      
    Method Name:        fetchContact
    Description:        Fetch all the Contact Info
    Parameter:          
    --------------------------------------------------------------------------------------*/    
    public static Contact fetchContact(String recId){
        Id conId;
        Contact objCon;
            Id ContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
                if(recId.startsWith('003')){
                    conId = recId;
                }
                else if(recId.startsWith('500')){
            Case objCase = [select Id, ContactId from Case where Id =: recId];
                    conId = objCase.ContactId;
                }
                System.debug('conIddddd'+conId);
                if(conId != null){
                    objCon = [select Id, Name, FirstName, LastName, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c, 
                                    Points_Balance__c, Status_Credits__c, MobilePhone, Preferred_Phone_Number__c, 
                                    Preferred_Email__c, QCC_Status_credits_till_next_Level__c, Birthdate,
                                    QCC_Frequent_Flyer_Anniversary_Date__c,Year_of_Joining__c,
                                    MailingCity,MailingStreet,MailingState,MailingPostalCode ,CountryName__c 
                                    from Contact where Id =: conId
                     		  AND RecordTypeId = :ContRecordTypeId];      
                    System.debug('objConnnnn'+objCon);         
                              
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
        try{
            Contact objCon = fetchContact(recId);
            Integer disruptionsCount = 0;

            QCC_CAPTransactionWrapper.CAPTransactionRequest requestInfo = new QCC_CAPTransactionWrapper.CAPTransactionRequest();
            requestInfo.system_x = 'CAPCRE_CC';
            requestInfo.firstName = objCon.FirstName;
            requestInfo.surName = objCon.LastName;
            requestInfo.qantasFFNo = objCon.Frequent_Flyer_Number__c;
            requestInfo.version = '1.0';

            QCC_CAPTransactionWrapper.CAPTransactionResponse disruptionResponse = QCC_InvokeCAPAPI.invokeTransactionCAPAPI(requestInfo);
            if(disruptionResponse != null){
                disruptionsCount = disruptionResponse.flightDelayDomesticCount+disruptionResponse.flightDelayInternationalCount;
            }

            Date lastyr = system.today().addMonths(-12);
            Integer caseCount = [ Select count() from case where contactId =: objCon.Id and 
                                 CreatedDate >: lastyr];

            BannerWrapper bannerWrap = new BannerWrapper();
            bannerWrap.caseCount = caseCount;
            bannerWrap.disruptionsCount = disruptionsCount;
            return bannerWrap;
        }catch(Exception ex){
            system.debug('ex######'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController', 
                                    'fetchCaseSummary', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
      //  return null;
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
    Method Name:        saveRecovery
    Description:        Creates a Recovery record by pre-populating some vales from Case
    Parameter:          Id of Case
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String saveRecovery(Id recId) {
        try {
            System.debug('Recovery ' + recId);
            Case cs = [SELECT Id, ContactId FROM Case WHERE Id = :recId];
            Recovery__c rec = new Recovery__c();
            rec.Case_Number__c = cs.Id;
            rec.Contact__c = cs.ContactId;
            //Jira:CDP2-671
            rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusNew');
            rec.Investigated_By__c = UserInfo.getUserId();
            insert rec;
            return rec.Id;
        } catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController', 
                                     'saveRecovery', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
      //  return null;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        isConsultant
    Description:        Checks whether the current user is Consultant or not
    Parameter:          Id of User
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean isConsultant(Id userId) {
        try {
        
            User user = [SELECT Id, Profile_Name__c FROM User WHERE Id = :userId ];
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
    public static Boolean isCaseClosed(Id recId) {
        String rid = recId;
        try {
            if(rid.startsWith('500')){
                Case cs = [SELECT Id, Status FROM Case WHERE Id = :recId];
                if(cs.Status == 'Closed') {
                    return true;
                }
            }
        } catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CustomerDetailController', 'QCC_CustomerDetailController', 
                                        'isCaseClosed', String.valueOf(''), String.valueOf(''),false,'', ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return false;
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
            
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem, 'Case Escalated By '+ cs.Owner.Name);            
           
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
}