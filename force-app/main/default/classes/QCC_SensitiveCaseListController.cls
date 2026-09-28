/*-----------------------------------------------------------------------------------------
    Author: Nga Do
    Company: Capgemini
    Description: 
    Inputs: 
    Test Class: QCC_SensitiveCaseListControllerTest
    ***************************************************************************************
    History:
    ***************************************************************************************
    08-June-2018
 ------------------------------------------------------------------------------------------*/
public without sharing class QCC_SensitiveCaseListController {

    private final sObject mysObject;
    public List<Case> caseList;
    private Set<Id> contactIds;
    public Boolean isDisplay;
    public List<SensitiveCaseWrapper> sensitiveCaseWrapperList;

    public ApexPages.StandardSetController sensitiveCaseList{ get; set;}

    public Boolean isSensitiveCase {get; set;}

    public void initSensitiveCaseLayout(){
        isSensitiveCase = true;
        initPage();
    }

    public void initNonSensitiveCaseLayout(){
        isSensitiveCase = false;
        initPage();
    }

    public void initPage(){
        contactIds = new Set<Id>();

        system.debug('#####mysObject######' + mysObject);
        Schema.SObjectType objectType = mysObject.getSObjectType();
        if( objectType == Schema.Account.sObjectType){
            // get contact by Account
            String accountId = (Id)mysObject.get('Id');

            // get all contact related in ACR
            if(isSensitiveCase){
                contactIds = getIdContactACR(accountId);
            }
            else {
                contactIds = getIdContactACRNonSensitive(accountId);
            }

        }else{
            contactIds.add((Id)mysObject.get('Id'));
        }
        List<Case> caseList = [SELECT Id, 
                                    CaseNumber, 
                                    Group__c, 
                                    LastModifiedDate, 
                                    RecordTypeId, 
                                    Status, 
                                    RecordType.Name,
                                    Contact.Name,
                                    Description,
                                    Type,
                                    Category__c,
                                    Sub_Category__c,
                                    Classification__c
                                FROM Case 
                                WHERE Sensitive__c = :isSensitiveCase 
                                AND ContactId IN: contactIds
                                ORDER BY LastModifiedDate desc];
        sensitiveCaseList = new ApexPages.StandardSetController(caseList);
        sensitiveCaseList.setPageNumber(1);
        sensitiveCaseList.setPageSize(5);
    }
    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public QCC_SensitiveCaseListController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        getSensitiveCaseWrapperList
    Description:        initial list Case wapper
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public List<SensitiveCaseWrapper> getSensitiveCaseWrapperList(){

        sensitiveCaseWrapperList = new List<SensitiveCaseWrapper>();
        Integer index = 0;
        for(Case objCase : (List<Case>)sensitiveCaseList.getRecords()){
            SensitiveCaseWrapper sensitiveCaseWrapper = new SensitiveCaseWrapper();
            sensitiveCaseWrapper.objCase = objCase;
            sensitiveCaseWrapper.groupContact = GenericUtils.getCaseContactGroup(objCase.RecordTypeId);
            index = index + 1;
            sensitiveCaseWrapper.index = (sensitiveCaseList.getPageNumber() -1 )*5 + index;
            sensitiveCaseWrapperList.add(sensitiveCaseWrapper);
        }

        system.debug('#####mysObject######' + mysObject);
        return sensitiveCaseWrapperList;
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        getIsDisplay
    Description:        checking if the sensitive case list will be view by login user
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public Boolean getIsDisplay() {
        Id idsObject = (Id)mysObject.get('Id');
        Schema.SObjectType objectType = mysObject.getSObjectType();
        // if the list in account page,
        // user login will able to see the list when user login is owner of Account
        if(objectType == Schema.Account.sObjectType){
            Account currentAccount = [SELECT Id, OwnerId FROM Account WHERE Id =: idsObject];

            if(currentAccount.OwnerId == UserInfo.getUserId()){
                 return true;
            }
            return false;
        }
        // if the list in account page,
        // user login will able to see the list when user login is owner of Account that related to contact in ACR
        if(objectType == Schema.Contact.sObjectType){
            
            //Set<Id> ownerIdSets = getOwnerIdAccountACR(idsObject);
            Set<Id> ownerIdSets = new Set<Id>();
            if(isSensitiveCase){
                ownerIdSets = getOwnerIdAccountACR(idsObject);
            } else {
                ownerIdSets = getOwnerIdAccountACRNonSensitive(idsObject);
            }
            
            if(ownerIdSets.contains(UserInfo.getUserId())){
                return true;
            }
            return false;
        }
        return false;
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        getOwnerIdAccountACR
    Description:        get owner of all account related to contact in ACR
    Parameter:          Id of Contact
    --------------------------------------------------------------------------------------*/
    private Set<Id> getOwnerIdAccountACR(String contactId){
        Set<Id> setIdAccountOwner = new Set<Id>();
        List<AccountContactRelation> listACR = [SELECT Id, Account.OwnerId, ContactId FROM AccountContactRelation WHERE ContactId =: contactId];
        for(AccountContactRelation objACR : listACR){
            setIdAccountOwner.add(objACR.Account.OwnerId);
        }
        return setIdAccountOwner;
    }

    private Set<Id> getOwnerIdAccountACRNonSensitive(String contactId){
        Set<Id> setIdAccountOwner = new Set<Id>();
        List<AccountContactRelation> listACR = QCC_CaseNotificationHelper.getAccountContactRelations(new List<String>{contactId}, '');
        for(AccountContactRelation objACR : listACR){
            setIdAccountOwner.add(objACR.Account.OwnerId);
        }
        return setIdAccountOwner;
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        getIdContactACR
    Description:        get all Contact related to Account in ACR
    Parameter:          Id of Contact
    --------------------------------------------------------------------------------------*/
    private Set<Id> getIdContactACR(String accountId){
        Set<Id> contactIdSet = new Set<Id>();
        List<AccountContactRelation> listACR = [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId =: accountId];
        for(AccountContactRelation objACR : listACR){
            contactIdSet.add(objACR.ContactId);
        }
        return contactIdSet;
    }

    private Set<Id> getIdContactACRNonSensitive(String accountId){
        Set<Id> contactIdSet = new Set<Id>();
        List<AccountContactRelation> listACR = QCC_CaseNotificationHelper.getAccountContactRelations(new List<String>(), accountId);

        for(AccountContactRelation objACR : listACR){
            contactIdSet.add(objACR.ContactId);
        }
        return contactIdSet;
    }

    public Integer pageNumber 
    {
        get {
            return sensitiveCaseList.getPageNumber();
        }
        set;
    }

    public Boolean hasNext 
    {
        get{
        return sensitiveCaseList.getHasNext();
        }
        set;
    }
    
    public Boolean hasPrevious 
    {
        get{
        return sensitiveCaseList.getHasPrevious();
        }
        set;
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        previous
    Description:        go to previous page
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public void previous(){
        sensitiveCaseList.previous();
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        next
    Description:        go to next page
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public void next(){
        sensitiveCaseList.next();
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        getTotalRecord
    Description:        get total records of list case
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public Integer getTotalRecord(){
        return sensitiveCaseList.getResultSize();
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        getTotalPages
    Description:        get total pages of list case
    Parameter:          
    --------------------------------------------------------------------------------------*/
    Public Integer getTotalPages(){
     Decimal totalSize = sensitiveCaseList.getResultSize();
     Decimal pageSize = sensitiveCaseList.getPageSize();
     Decimal pages = totalSize/pageSize;
     return (Integer)pages.round(System.RoundingMode.CEILING);
    }

    /*--------------------------------------------------------------------------------------       
    Class Name:        SensitiveCaseWrapper
    Description:       define list case display
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class SensitiveCaseWrapper {
        public Case objCase{get; set;}
        public String groupContact{get; set;}
        public Integer index{get; set;}

        public SensitiveCaseWrapper(){
            objCase = new Case();
            groupContact = '';
        }
    }
}