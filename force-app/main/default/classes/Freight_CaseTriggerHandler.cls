/*----------------------------------------------------------------------------------------------------------------------
Author:        Abhijeet P
Company:       TCS
Description:   Class to be invoked from Case Trigger, all Logics has been restricted for Freight RecordType
Test Class:    FreightAllTileControllerTest, Freight_CaseTriggerHandlerTest
************************************************************************************************
History
************************************************************************************************
10-Aug-2017    Abhijeet P              Initial Design
17 Jan 2022    Navpreet Kaur           autoAssignCaseToCSUQueue
15 Feb 2022    Navpreet Kaur           autoAssignPriorityAsPremium
1 March 2022   Navpreet Kaur           autoAssignPriorityAsPremiumManualAccounts
28 March 2022  Navpreet Kaur           assignUrgentPriorityForCasesWithHotWords
11 April 2022  Navpreet Kaur           freightCreditCardMasking
17 May 2022    Navpreet Kaur           freightAssociateAcctsWeb2Case
-----------------------------------------------------------------------------------------------------------------------*/

public class Freight_CaseTriggerHandler {
    
    // To retrieve RecordtypeId of Freight Cases
    static Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
    static map<string,string> mapRecordTypeVsCategory = recordTypeUtility.returnRecordTypeSettingMap('Freight', 'Case');    
    static Map<String, String> freight_rectypeMap = new Map<String, String>();
    public Freight_CaseTriggerHandler(){
        
        Map<String, Schema.RecordTypeInfo> caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        
        for(String recType: caseRT.keySet()) 
        {
            if(caseRT.get(recType).getDeveloperName().contains('Freight'))
            {
                freight_rectypeMap.put(caseRT.get(recType).getRecordTypeId(),caseRT.get(recType).getDeveloperName());
            }   
        }
    }
    //Commented the method as it's been replaced by the caseTriggerNavigator Class CRM-7420
   /* @future //CRM-6699: Converted to Asyn method
    public static void futureMethodsHandler(list<String> newSerCase, List<String> oldSerCase)
    {
        //CRM-6699: Converted to Asyn method
        list<Case> caseNewList=new List<Case>();
        Map<Id, Case> caseOldMap=new Map<Id, Case>();
        
        system.debug('>>> the value of newSerCase'+newSerCase);
        
        //CRM-6699: Converted to Asyn method
        if(newSerCase!=null && newSerCase.size()>0)
        {
            for(String getStr: newSerCase)
            {
                system.debug('the value of getStr before desearlizing'+getStr);
                caseNewList.add((Case)Json.deserialize(getStr, System.Type.forName('Case')));
                system.debug('the value of getStr after desearlizing'+(Case)Json.deserialize(getStr, System.Type.forName('Case')));
            }
        }
        system.debug('>>> the value of caseNewList'+caseNewList);
        //CRM-6699: Converted to Asyn method
        if(oldSerCase!=null && oldSerCase.size()>0)
        {
            for(String Str: oldSerCase)
            {
                  Case createC=new Case();
                  system.debug('the value of createC before desearlizing'+createC);
                    createC=(Case)Json.deserialize(Str, System.Type.forName('Case'));
                    caseOldMap.put(createC.id,createC);
                    system.debug('the value of createC after desearlizing'+createC);
                
            }
        }
        system.debug('the value of caseOldMap'+caseOldMap);

        
        if(caseNewList!=null && caseNewList.size()>0 && caseOldMap.isEmpty()==false)
        {
            assignEntitlement1(caseNewList,caseOldMap);  
            assignEntitlement(caseNewList,caseOldMap); 
            autoChangeStatus(caseNewList,caseOldMap);
            autoChangeStatus1(caseNewList,caseOldMap);
            autoMilestonCompletion(caseNewList,caseOldMap);
            autoMilestonCompletionforservicerequest(caseNewList,caseOldMap);
            autoAssignPriorityAsPremiumManualAccounts(caseNewList,caseOldMap);

            autoAssignPriorityAsPremiumManualAccounts(caseNewList,caseOldMap);
        }
        if(caseNewList!=null && caseNewList.size()>0)
        {
            assignRecordTypeWebToCase(caseNewList);
            autoAssignCaseToCSUQueue(caseNewList); //FCRM-860
            autoAssignPriorityAsPremium(caseNewList);  //FCRM-880
            assignUrgentPriorityForCasesWithHotWords(caseNewList); //FCRM-894
            freightMaskCreditCard(caseNewList); //FCRM-902
            freightAssociateAcctsWeb2Case(caseNewList); 
            autoCloseAuotmaticReplayCases(caseNewList);    
        }
        
    }*/
/*--------------------------------------------------------------------------------------      
Method Name:        assignEntitlement for Service Request
Description:        Method for creation or assignment Entitlement for Account
Parameter:          Case New List & Old Map 
--------------------------------------------------------------------------------------*/
    public static void assignEntitlement1(list<Case> caseNewList, Map<Id, Case> caseOldMap)
    {
        
        // set of accountIds to determing Entitlement Assignment for Account
        Set<Id> accountIds = new Set<Id>();
        map<Id,Account> accountMap = new Map<Id,Account>();
        List<Entitlement> entitlementsToInsert = new List<Entitlement>();
        Map<Id, Entitlement> accEntitlementMap = new Map<Id,Entitlement>();
        Id caseRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();        
        
        // Iterating Trigger.New to retieve distinct AccountIds and distinct Port Ids
        for (Case eachCase : caseNewList) {
            if(eachCase.RecordTypeId == caseRtId && eachCase.AccountId != null){
                accountIds.add(eachCase.AccountId);
                
            }
        }
        
        if(!accountIds.isEmpty()) 
        {
            for (Entitlement ent : [SELECT AccountId,Name FROM Entitlement
                                    WHERE AccountId in :accountIds]) 
            {
                accEntitlementMap.put(ent.AccountId, ent);
               
            }
            
            string slaLabel = Label.Qantas_Agency_Connect_Entitlement_Process;
            // Querying Entitlemnet Process
            SlaProcess process = [SELECT Id,Name FROM SlaProcess WHERE Name =: slaLabel]; 
            Id accountRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
            
            for(Account acc : [Select Id, Name, BillingCountry, BillingCountryCode,RecordTypeId from Account where Id in: accountIds]){
                if(acc != null && acc.BillingCountryCode == 'AU' && acc.RecordTypeId==accountRtId)
                {
                    if(!accEntitlementMap.containsKey(acc.Id))
                    {
                        Entitlement myEnt = new Entitlement();
                        myEnt.Name = acc.Name + ' - Entitlement';   
                        myEnt.SlaProcessId   = process.Id;
                        myEnt.StartDate     = Date.today().addDays(-1);
                        myEnt.Enddate     = Date.newInstance(2099, 12, 31);
                        myEnt.AccountId     = acc.id;
                        entitlementsToInsert.add(myEnt);
                    }
                }
                accountMap.put(acc.Id, acc);
               
            }
            
            if (!entitlementsToInsert.isEmpty()) {
                insert entitlementsToInsert;
                
                for(Entitlement ent : entitlementsToInsert) {
                    accEntitlementMap.put(ent.AccountId, ent);
                }
                
                
            }
            
            // Assignement of ENtitlement to Case to associate required Milestone with Case
            for(Case eachCase : caseNewList) 
            {
                if(eachCase.RecordTypeId == caseRtId )
                {
                    if(eachCase.AccountId != null && (accountMap != null && !accountMap.isEmpty() && accountMap.get(eachCase.AccountId).BillingCountryCode == 'AU'&& accountMap.get(eachCase.AccountId).RecordTypeId == accountRtId )) 
                    {
                        eachCase.EntitlementId = accEntitlementMap.get(eachCase.AccountId).Id;
                        
                    }
                }  
            }
            
        }
    }
    
/*--------------------------------------------------------------------------------------      
Method Name:        assignEntitlement
Description:        Method for creation or assignment Entitlement for Account
Parameter:          Case New List & Old Map 
--------------------------------------------------------------------------------------*/
    public static void assignEntitlement(list<Case> caseNewList, Map<Id, Case> caseOldMap){
        
        
        system.debug('the value of caseOldMap'+caseOldMap);
        // set of accountIds to determing Entitlement Assignment for Account
        Set<Id> accountIds     = new Set<Id>();
        
        // set of Port Ids to determing Entitlement Assignment for Account
        Set<Id> distinctPortIds = new Set<Id>();
        
        // Iterating Trigger.New to retieve distinct AccountIds and distinct Port Ids
        for (Case eachCase : caseNewList) {
            if(mapRecordTypeVsCategory.keySet().contains(eachCase.RecordTypeId)){
                accountIds.add(eachCase.AccountId);
                distinctPortIds.add(eachCase.Freight_Port__c);
            }
        }
        
        // Removing null values from sets, in case relevant fields are not populated for Case
        accountIds.remove(null);
        distinctPortIds.remove(null);
        
        // To Identify whether Freight Account is associated with any Entitlement or not
        // If Entitlement exist for Account, relevant entitlement will be associated with Account
        // Else respective Entitlement record created for Account
        if (!accountIds.isEmpty()) {
            Map<Id, Entitlement> entitlementMap = new Map<Id, Entitlement>();
            
            for (Entitlement eachEntitlement : [SELECT AccountId,Name FROM Entitlement
                                                WHERE AccountId in :accountIds]) {
                                                    entitlementMap.put(eachEntitlement.AccountId, eachEntitlement);
                                                }
            
            string slaLabel = Label.Freight_SLA_Process;
            // Querying Entitlemnet Process
            SlaProcess process = [SELECT Name FROM SlaProcess
                                  WHERE Name =: slaLabel]; 
            
            List<Entitlement> entitlementsToInsert = new List<Entitlement>();
            
            for (Account eachAccount : [SELECT Id, Name FROM Account WHERE Id IN: accountIds]) {
                
                if (entitlementMap.containsKey(eachAccount.Id)) {
                    continue;
                }
                
                // New Entitlement records creation data
                entitlementsToInsert.add(new Entitlement(
                    // Entitlement is based on Account Name + Entitlement
                    Name       = eachAccount.Name + ' - Entitlement',        
                    SlaProcessId   = process.Id,
                    StartDate     = Date.today().addDays(-1),   
                    Enddate     = Date.newInstance(2099, 12, 31),   
                    AccountId     = eachAccount.id
                ));
            }
            
            // Insertion of required Entitlements
            if (!entitlementsToInsert.isEmpty()) {
                insert entitlementsToInsert;
                
                for (Entitlement eachEntitlement : entitlementsToInsert) {
                    entitlementMap.put(eachEntitlement.AccountId, eachEntitlement);
                }
            }
            
            // To hold PortId vs State code map
            map<Id, string> portIdVsStateCodeMap = new map<Id, string>();
            
            // Retrieving States for relevant Stations or Port Code
            for(Airport_Code__c eachCode : [SELECT Id, Name, Freight_Station_Name__c, Freight_Airport_State_Code__c
                                            FROM Airport_Code__c
                                            WHERE Id IN: distinctPortIds ]){
                                                portIdVsStateCodeMap.put(eachCode.Id, eachCode.Freight_Airport_State_Code__c);                                  
                                            }
            
            // Assignement of ENtitlement to Case to associate required Milestone with Case
            for (Case eachCase : caseNewList) {
                if(mapRecordTypeVsCategory.keySet().contains(eachCase.RecordTypeId)){
                    
                    // Assigning Entitlment to the Case
                    if (eachCase.AccountId == null) {
                        continue;
                    }
                    eachCase.EntitlementId = entitlementMap.get(eachCase.AccountId).Id;
                    
                    // Assigning State Code to Case based on Port selected
                    if(eachCase.Freight_Port__c != null){
                        if(portIdVsStateCodeMap.get(eachCase.Freight_Port__c) != null)
                            eachCase.Freight_Port_State_Code__c = portIdVsStateCodeMap.get(eachCase.Freight_Port__c);
                    }
                    else{
                        eachCase.Freight_Port_State_Code__c = '';
                    }
                }  
            }
        }
    }
    
    
    
/*--------------------------------------------------------------------------------------      
Method Name:        autoChangeStatus
Description:        Auto Changing status of Case while updation of Case
Parameter:          Case New List & Old Map 
--------------------------------------------------------------------------------------*/  
    public static void autoChangeStatus(list<Case> caseNewList, Map<Id, Case> caseOldMap){
        
          
        for (Case eachCase : caseNewList) {
            // Freight Recordtype verification 
            if(mapRecordTypeVsCategory.keySet().contains(eachCase.RecordTypeId)){
                
                // to auto change status of Cases based on auto Assignment
                if(eachCase.Status == 'Open' ){
                    if(caseOldMap.get(eachCase.Id) != null ){
                        if(eachCase.OwnerId != caseOldMap.get(eachCase.Id).OwnerId){
                            //eachCase.Status = 'Assigned';  //Commenting this Logic as it has been updated and amended as part of FCRM-876 
                        }
                    }  
                }
                
                // Updation Reopening Time stamp based on Case Status change
                if(eachCase.Status == 'Reopened' && caseOldMap.get(eachCase.Id).Status != 'Reopened'){
                    eachCase.Reopened_Date__c = system.now();
                }
            }
            if(freight_rectypeMap.containsKey(eachCase.recordtypeId) && eachCase.Freight_AWB_Number__c!=null && !eachCase.Freight_AWB_Number__c.startswith('081')
               && eachCase.Freight_AWB_Number__c!=caseOldMap.get(eachCase.Id).Freight_AWB_Number__c)
            {
                eachCase.Product__c ='Cargo - Client Airlines';
               
            }
        }
    }
    
    
/*--------------------------------------------------------------------------------------      
Method Name:        autoChangeStatus
Description:        Auto Changing status of Case while updation of Case
Parameter:          Case New List & Old Map 
--------------------------------------------------------------------------------------*/  
    public static void autoChangeStatus1(list<Case> caseNewList, Map<Id, Case> caseOldMap){
        
        Id caseRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        for (Case eachCase : caseNewList) {
            // service request Recordtype verification 
            if(eachCase.RecordTypeId == caseRtId){
                // Updation Reopening Time stamp based on Case Status change
                if(eachCase.Status == 'Reopened' && caseOldMap.get(eachCase.Id).Status != 'Reopened'){
                    eachCase.Reopened_Date__c = system.now();
                }
            }
        }
    }
    
/*--------------------------------------------------------------------------------------      
Method Name:        assignRecordTypeWebToCase
Description:        Update Recordtypes coming 
Parameter:          Case New List
--------------------------------------------------------------------------------------*/  
     public static void assignRecordTypeWebToCase(list<Case> caseNewList){
        
        
        
        String freight_Query = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Query').getRecordTypeId();
        String freight_Shipment = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Shipment').getRecordTypeId();
        String freight_feedback = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Feedback').getRecordTypeId();
        String freight_Claims = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Claims').getRecordTypeId(); 
        String Freight_Email_to_Case =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Email_to_Case').getRecordTypeId(); 
        String Freight_Invoicing =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Invoicing').getRecordTypeId(); 
        String Freight_Track_Trace_Exceptions = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Track_Trace_Exceptions').getRecordTypeId();
        String Qantas_Freight = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
        
        
        for(Case eachCase : caseNewList){
            if(eachCase.Freight_WebToCaseType__c != '' && eachCase.Origin == 'Web'){
                
                if(eachCase.Freight_WebToCaseType__c == 'Freight - General Enquiries'){  
                    eachCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Query').getRecordTypeId();
                    eachCase.Priority = 'Low';
                    eachCase.Status = 'Open';
                }
                else if(eachCase.Freight_WebToCaseType__c == 'Freight - Track and trace query'){  
                    eachCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Shipment').getRecordTypeId();
                    eachCase.Priority = 'Low';
                    eachCase.Status = 'Open';
                }
                else if(eachCase.Freight_WebToCaseType__c == 'Freight - Give us feedback'){
                    eachCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Feedback').getRecordTypeId();
                    eachCase.Priority = 'Low';
                    eachCase.Status = 'Open';
                }
            }
            if(freight_rectypeMap.containsKey(eachCase.recordtypeId) && eachCase.Freight_AWB_Number__c!=null && !eachCase.Freight_AWB_Number__c.startswith('081'))
            {
                eachCase.Product__c ='Cargo - Client Airlines';
                eachCase.Airline__c=''; //FCRM-866 If AWB is non-081, the airline should be null
                
            }
        }
        
    }
    
    
/*--------------------------------------------------------------------------------------      
Method Name:        autoMilestonCompletion
Description:        Auto completion of Milestoins based on status change of Case
Parameter:          Case New List & Old Map 
--------------------------------------------------------------------------------------*/  
     
    public static void autoMilestonCompletion(list<Case> caseNewList, Map<Id, Case> caseOldMap){
    
    
        // Record Type Filtering Logic to be introduced
        
        DateTime completionDate     = System.now();
        set<Id> ownerAssignIdSet     = new set<Id>();
        set<Id> caseClosureIdSet    = new set<Id>();
        set<Id> caseResolutionIdSet    = new set<Id>();
        set<Id> caseReopenIdSet      = new set<Id>();
        
        for (Case eachCase : caseNewList) {
            
            // Freight Recordtype verification 
            if(mapRecordTypeVsCategory.keySet().contains(eachCase.RecordTypeId)){
                
                if(eachCase.Status == 'Assigned' && caseOldMap.get(eachCase.Id).Status != 'Assigned'){
                    ownerAssignIdSet.add(eachCase.Id);
                }
                else if(eachCase.Status == 'Closed' && caseOldMap.get(eachCase.Id).Status != 'Closed'){
                    caseClosureIdSet.add(eachCase.Id);
                }
                else if(eachCase.Status == 'Resolved' && caseOldMap.get(eachCase.Id).Status != 'Resolved'){
                    caseResolutionIdSet.add(eachCase.Id);
                }
                
                else if(eachCase.Status == 'Reopened' && caseOldMap.get(eachCase.Id).Status != 'Reopened'){
                    caseReopenIdSet.add(eachCase.Id);
                }
            }    
        }
        
        if(ownerAssignIdSet.size() > 0){
            Freight_MilestoneUtils.completeMilestone(ownerAssignIdSet, 'Ownership Assignment', completionDate);
        }
        
        if(caseClosureIdSet.size() > 0){
            Freight_MilestoneUtils.completeMilestone(caseClosureIdSet, 'Case Closure', completionDate);
        }
        
        if(caseResolutionIdSet.size() > 0){
            Freight_MilestoneUtils.completeMilestone(caseResolutionIdSet, 'Case Resolution', completionDate);
        }
        
        if(caseReopenIdSet.size() > 0){
            completionDate   = null;
            Freight_MilestoneUtils.completeMilestone(caseReopenIdSet, 'Case Resolution', completionDate);
        }
        
    }
    
/*--------------------------------------------------------------------------------------      
Method Name:        autoMilestonCompletion
Description:        Auto completion of Milestoins based on status change of Case
Parameter:          Case New List & Old Map 
--------------------------------------------------------------------------------------*/ 
     
    public static void autoMilestonCompletionforservicerequest(list<Case> caseNewList, Map<Id, Case> caseOldMap){
    
    
        // Record Type Filtering Logic to be introduced
        
        DateTime completionDate     = System.now();
        set<Id> ownerAssignIdSet     = new set<Id>();
        set<Id> caseClosureIdSet    = new set<Id>();
        set<Id> caseReopenIdSet      = new set<Id>();
        set<Id> caseClosureBothIdSet = new set<Id>();
        Id caseRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        for (Case eachCase : caseNewList) {
            
            // Service RequestRecordtype verification 
            //if(mapRecordTypeVsCategory.keySet().contains(eachCase.RecordTypeId)){
            
            if(eachCase.Status == 'In Progress' && caseOldMap.get(eachCase.Id).Status != 'In Progress' && eachCase.RecordTypeId ==caseRtId){
                ownerAssignIdSet.add(eachCase.Id);
                
            }
            else if(eachCase.Status == 'Closed - Approved' && caseOldMap.get(eachCase.Id).Status != 'Closed - Approved' && eachCase.RecordTypeId ==caseRtId){
                caseClosureIdSet.add(eachCase.Id);
            }
            
            else if(eachCase.Status == 'Closed - Rejected' && caseOldMap.get(eachCase.Id).Status != 'Closed - Rejected' && eachCase.RecordTypeId ==caseRtId){
                caseClosureIdSet.add(eachCase.Id);
            }
            else if(eachCase.Status == 'Closed' && caseOldMap.get(eachCase.Id).Status != 'Closed' && eachCase.RecordTypeId ==caseRtId){
                caseClosureIdSet.add(eachCase.Id);
            }
            
            else if(eachCase.Status == 'Auto Closed' && caseOldMap.get(eachCase.Id).Status != 'Auto Closed' && eachCase.RecordTypeId ==caseRtId){
                //ownerAssignIdSet.add(eachCase.Id);
                caseClosureBothIdSet.add(eachCase.Id);
                
            }    
            
            else if(eachCase.Status == 'Reopened' && caseOldMap.get(eachCase.Id).Status != 'Reopened'&& eachCase.RecordTypeId ==caseRtId){
                caseReopenIdSet.add(eachCase.Id);
            }
            
            
            // }    
        }
        
        
        
        
        if(ownerAssignIdSet.size() > 0){
            Freight_MilestoneUtils.completeMilestone(ownerAssignIdSet, 'Ownership Assignment', completionDate);
        }
        
        if(caseClosureIdSet.size() > 0){
            Freight_MilestoneUtils.completeMilestone(caseClosureIdSet, 'Case Closure', completionDate);
        }
        
        if(caseClosureBothIdSet.size() > 0){
            Freight_MilestoneUtils.completeMilestoneAutoClosed(caseClosureBothIdSet,  completionDate);
        }
        
        
        if(caseReopenIdSet.size() > 0){
            completionDate = null;
            
            Freight_MilestoneUtils.completeMilestoneForReopenCase(caseReopenIdSet, 'Case Closure',completionDate);
        }
        
        
        
    }
/*--------------------------------------------------------------------------------------      
Method Name:        autoAssignCaseToCSUQueue
TestMethod Name:    testautoAssignCaseToCSUQueue
Description:        This method automates the case assignment for the mentioned ports and Case Record Types to Freight CSU AU Queue
Parameter:          Case New List  
Jira Story:         FCRM-860
Date Implemented:   17 Jan 2022
Sprint Freight      151
--------------------------------------------------------------------------------------*/ 
    public static void autoAssignCaseToCSUQueue(list<Case> caseNewList)
    {
    
        
        Map<string,Freight_Ports__mdt> mapPorts=Freight_Ports__mdt.getAll();
        List<Case> listCases=new List<Case>();
        List<Id> listPortIds=new List<Id>();
        Group FreightCSU=[select id,name,DeveloperName from group where type='Queue' and name='Freight CSU AU Queue' limit 1];
        Map<ID,Airport_Code__c> listAirportCodes;
        
        if(caseNewList!=null && caseNewList.size()>0)
        {
            for(Case newCase:caseNewList)
            { 
                if(newCase.recordtypeid!=null && freight_rectypeMap.containsKey(newCase.recordtypeid))
                {
                    listCases.add(newCase);
                    listPortIds.add(newCase.Freight_Port__c);
                }   
            }
        }

        if(listPortIds!=null && listPortIds.size()>0)
        listAirportCodes=new Map<ID,Airport_Code__c>([select id,Name from Airport_Code__c where ID IN:listPortIds]);
        
        
        if(listCases!=null && listCases.size()>0)
        {
            for(Case newFreightCase: listCases)
            {
                for(Freight_Ports__mdt portsMdt:mapPorts.values())
                {
                    if(newFreightCase.Freight_Port__c!=null && portsMdt.Port_Code__c.contains(listAirportCodes.get(newFreightCase.Freight_Port__c).Name))
                    {
                        newFreightCase.ownerid=FreightCSU.id;
                    }
                }
            }
        }   
        
    }
/*--------------------------------------------------------------------------------------      
Method Name:        autoAssignPriorityAsPremium
TestMethod Name:    testautoAssignCaseToCSUQueue
Description:        This method automates the case Priority to be Premium based on the Account details in the case Description
Parameter:          Case New List  
Jira Story:         FCRM-880
Date Implemented:   15 Feb 2022
Sprint Freight      153
--------------------------------------------------------------------------------------*/
  public static void autoAssignPriorityAsPremium(list<Case> caseNewList)
    {
    
        List<case> listFrtCases=new List<case>();
        List<ID> freightRTs=new List<ID>();
        Map<string,Freight_Premium_Account__mdt> MapCompName=new Map<string,Freight_Premium_Account__mdt>();
        Map<string,Account> listEmails=new Map<string,Account>();
        list<String> descLines=new list<String>();
        List<String> columnValues = new List<String>();
        List<String> columnValuesSplited = new List<String>();
        Map<String,Case> caseAcctEmail=new Map<String,Case>(); 
        List<String> listDesc=new List<String>();
        
        Map<string,Freight_Premium_Account__mdt> mapAccounts=Freight_Premium_Account__mdt.getAll();
        
        for(Case caseRecs:caseNewList)
        {
            if(freight_rectypeMap.containsKey(caseRecs.recordtypeid))  
            {
                System.debug('Frieght case trigger');
                listFrtCases.add(caseRecs);
                 System.debug('Frieght case trigger listFrtCases'+listFrtCases);
            }
            
        }
        if(mapAccounts.isEmpty()==false)
        {
            for(Freight_Premium_Account__mdt mapValues :mapAccounts.values())
            {
                MapCompName.put(mapValues.Premium_Accounts__c,mapValues);
                System.debug('Frieght case trigger MapCompName'+MapCompName);
            }
        }
        
      
       
        if(listFrtCases!=null && listFrtCases.size()>0)
        {
            for(Case newRec: listFrtCases)
            {
                System.debug('Frieght case trigger '+newRec);
                if(newRec.suppliedemail!=null && (newRec.origin=='FRT Bookings' || newRec.origin=='FRT Cust Service'))
                 {
                     if(MapCompName.containskey(newRec.suppliedemail.split('@').get(1).trim()))
                     {
                            newRec.priority='Premium';
                     }
                 } 
                
                if((newRec.origin=='FRT Bookings' || newRec.origin=='FRT Cust Service') && newRec.Description!=null)
                {
                
                    descLines=newRec.Description.split('\n');
                    
                    if(descLines!=null && descLines.size()>0)
                    {
                        for (String strSplit: descLines)
                        {
                            if(strSplit.contains('From:'))
                            {
                                listDesc.addAll(strSplit.split(' '));
                            }   
                        } 
                    }
                   
                    if(listDesc!=null && listDesc.size()>0)
                    {
                        for(String strDesc :listDesc)
                        {
                            if(strDesc.contains('<') && strDEsc.contains('>'))
                            {
                                strDesc=strDesc.replace('<','').replace('>','');
                                strDesc=strDesc.split('@').get(1).trim();
                                
                                
                                if(MapCompName.containskey(strDesc))
                                {
                                    newRec.priority='Premium';
                                }
                            }
                        }
                    }
                } 
                if(newRec.origin=='Web' && newRec.suppliedemail!=null)
                {
                    if(MapCompName.containskey(newRec.suppliedemail.split('@').get(1).trim()))
                    {
                        newRec.priority='Premium';
                    }
                } 
            }
        }
        
    }
/*--------------------------------------------------------------------------------------      
Method Name:        autoAssignPriorityAsPremiumManualAccounts
TestMethod Name:    testautoAssignCaseToCSUQueue
Description:        This method automates the case Priority to be Premium based on the Account Changed Manually
Parameter:          Case New List & Old Map 
Jira Story:         FCRM-887
Date Implemented:   1 March 2022
Sprint Freight      154
--------------------------------------------------------------------------------------*/
    public static void autoAssignPriorityAsPremiumManualAccounts(list<Case> caseNewList, Map<Id, Case> caseOldMap)
    {
        
        List<case> listFrtCases=new List<case>();
        Id Accountid= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        map<Id, Case> caseFrtOldMap=new map<Id, Case>();
        List<string> listCompName=new List<string>();
        List<Account> premAccounts;
        
        
        for(Case caseRecs:caseNewList)
        {
            if(freight_rectypeMap.containsKey(caseRecs.recordtypeid))  
            {
                listFrtCases.add(caseRecs);
            } 
        }
        
        for(Case oldCases :caseOldMap.values())
        {
            if(freight_rectypeMap.containsKey(oldCases.recordtypeid))  
            {
                caseFrtOldMap.put(oldCases.id,oldCases);  
            }
        }
        
        Map<string,Freight_Premium_Account__mdt> mapAccounts=Freight_Premium_Account__mdt.getAll();
        for(Freight_Premium_Account__mdt mapValues :mapAccounts.values())
        {
            listCompName.add('%'+mapValues.Premium_Accounts__c);
        }
        if(listCompName!=null && listCompName.size()>0)
        {
            premAccounts=[select id,Email__c from Account where recordtypeid =:Accountid and Email__c like :listCompName];
        }
        
        Map<Id,Account> mapPremiumAccts=new Map<Id,Account>(premAccounts);
        
        if(listFrtCases!=null && listFrtCases.size()>0)
        {
            for(Case caseRecs: listFrtCases)
            {
                if(caseRecs.origin=='FRT Bookings' || caseRecs.origin=='FRT Cust Service')
                {
                    if(caseRecs.accountid!=null && caseFrtOldMap.get(caseRecs.id).accountid!=null  && !(caseFrtOldMap.get(caseRecs.id).accountid.equals(caseRecs.accountid)) && mapPremiumAccts.containskey(caseRecs.accountid))
                    {
                        caseRecs.priority='Premium';
                    }
                    else if(caseFrtOldMap.get(caseRecs.id).accountid==null && caseRecs.accountid!=null && mapPremiumAccts.containskey(caseRecs.accountid))
                    {
                        caseRecs.priority='Premium';
                    }
                } 
            }
        }
        
    }
/*--------------------------------------------------------------------------------------      
Method Name:        assignUrgentPriorityForCasesWithHotWords
TestMethod Name:    testassignUrgentPriorityForCasesWithHotWords
Description:        This method automates the case Priority to be Urgent based on Hot words 
Parameter:          Case New List  
Jira Story:         FCRM-894
Date Implemented:   28 March 2022
Sprint Freight      156
--------------------------------------------------------------------------------------*/
    public static void assignUrgentPriorityForCasesWithHotWords(list<Case> caseNewList)
    {
    
       
        List<case> listFrtCases=new List<case>();
        List<string> listDesc=new List<string>();
        List<string> listSubj=new List<string>();
        Map<string,List<String>> mapCaseDesc;
        Map<string,List<String>> mapCaseSubj;
        Id QCCHotWords_RTID= Schema.SObjectType.QCC_Hotword_Queue_Routing__c.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        List<QCC_Hotword_Queue_Routing__c> listHotWords=new List<QCC_Hotword_Queue_Routing__c>();
        Map<string,List<String>> mapHotWords=new Map<string,List<String>>();
        Map<string,string> listUpdateCases=new Map<string,string>();
        List<String> strHotMails=new List<String>();
        Set<String> strHotWrds=new Set<String>();
        List<String> listDescCase=new List<String>();
        List<Case> lstUpdate=new List<Case>();
        String constStrIgnore='Retail '+'Booking '+'Confirmation';
        
        try
        {
            
            
            listHotWords =[select id,name,Hot_words__c,freight_Type__c,Priority__c from QCC_Hotword_Queue_Routing__c where RecordTypeId=:QCCHotWords_RTID];
            
            
            if(listHotWords!=null && listHotWords.size()>0)
            {
                for(QCC_Hotword_Queue_Routing__c getHotWrds :listHotWords)
                {
                    // Code is being commented as part of Jira FCRM - 943
                   /* if(getHotWrds.freight_Type__c.contains('Hot Word'))
                    {
                        strHotWrds.addAll(getHotWrds.Hot_words__c.split(','));
                    }
                    else
                    {
                        strHotMails.addAll(getHotWrds.Hot_words__c.split(',')); 
                    }*/
                      if(getHotWrds.freight_Type__c.contains('Mail Suffix'))
                        {
                            strHotMails.addAll(getHotWrds.Hot_words__c.split(','));
                        } 
                    
                }    
            }
            
            
            
            
            if(caseNewList!=null && caseNewList.size()>0)
            {
                system.debug('the value of freight_rectypeMap'+freight_rectypeMap.keyset());
                for(Case getCs :caseNewList)
                {
                     system.debug('the value of getCs.recordtypeid'+getCs.recordtypeid);
                    if(freight_rectypeMap.containsKey(getCs.recordtypeid) && (getCs.origin=='FRT Bookings' || getCs.origin=='FRT Cust Service') && getCs.Description!=null)
                    {
                        system.debug('@@@ within the if check before split');
                        listDesc=getCs.Description.split('\n');
                        system.debug('@@@ the value of description'+listDesc);
                        for(String strSplit: listDesc)
                        {   
                            if(strSplit.containsignoreCase('From:'))
                            {
                                system.debug('@@@ the listDescCase has from: assignment'+strSplit);
                                listDescCase.addAll(strSplit.split(' '));    
                            }
                            // Code is being commented as part of Jira FCRM - 943
                           /* else
                            {
                                for(string strHwrds :strHotWrds)
                                {
                                    if(strSplit.containsIgnoreCase(strHwrds) && !getCs.Subject.containsIgnoreCase(constStrIgnore))
                                    {
                                        getCs.priority='Urgent';
                                        
                                    } 
                                }
                            } */
                            
                        }
                        
                        
                        if(listDescCase!=null && listDescCase.size()>0)
                        {
                            system.debug('@@@ the listDescCase has from:'+listDescCase);
                            for(String getEach :listDescCase)
                            {
                                if(getEach.contains('<') && getEach.contains('>'))
                                {
                                    system.debug('@@@ the listDescCase contains <>'+getEach);
                                    getEach=getEach.replace('<','').replace('>','');
                                    
                                       if(getEach.contains('mailto:'))
                                        {
                                            system.debug('@@@ the getEach contains mailto');
                                          getEach=getEach.substringBefore('mailto:');
                                          system.debug('@@@ the getEach value mailto'+getEach);
                                        }
                                        
                                        if(getEach.contains('@'))
                                        {
                                            system.debug('@@@ the getEach contains @');
                                           getEach=getEach.substringAfter('@');
                                          system.debug('@@@ the getEach value @'+getEach);
                                        }
                                    for(string strHems :strHotMails)
                                    {
                                        system.debug('@@@ strHotMails values'+strHotMails);
                                        if(strHems.containsIgnoreCase(getEach) && getCs.priority!='Premium')
                                        {
                                            system.debug('@@@ urgent priority check');
                                            getCs.priority='Urgent';
                                            
                                        } 
                                     }  
                                }
                            }
                        }      
                    }
                    // Code is being commented as part of Jira FCRM - 943
                    /*if(freight_rectypeMap.containsKey(getCs.recordtypeid) && (getCs.origin=='FRT Bookings' || getCs.origin=='FRT Cust Service') && getCs.Subject!=null)
                    {
                        listSubj=getCs.Subject.split(' ');
                        if(listSubj!=null && listSubj.size()>0)
                        {
                            integer index=1;
                            String fltCan='';
                            
                            for(string getSub :listSubj)
                            {
                                if(index<listSubj.size())
                                {
                                    fltCan=listSubj[index-1]+' '+listSubj[index];    
                                } 
                                for(string strHwrds :strHotWrds)
                                {
                                    if((getSub.containsIgnoreCase(strHwrds) || fltCan.containsIgnoreCase(strHwrds)) && !getCs.Subject.containsIgnoreCase(constStrIgnore))
                                    {
                                        getCs.priority='Urgent';
                                        
                                    }   
                                }
                                index++;
                            }     
                        }
                    } */
                }
            } 
            
        }
        Catch(Exception e)
        {
            System.debug('Exception Occurred'+e);
        } 
        
        
    }
/*--------------------------------------------------------------------------------------      
Method Name:        freightCreditCardMasking
TestMethod Name:    testassignUrgentPriorityForCasesWithHotWords
Description:        This method checks the credit card details in the Email-to-Case and Mask them
Parameter:          Case New List  
Jira Story:         FCRM-902
Date Implemented:   11 April 2022
Sprint Freight      157
--------------------------------------------------------------------------------------*/
   
    public static void freightMaskCreditCard(List<Case> caselist)
    {
        try
        {
        
            Boolean hasCardInfo;
            Boolean isUpdate = false;
            
            if(caselist!=null && caselist.size()>0)
            {
                for(Case getEach :caselist){
                    hasCardInfo = false;
                    
                    if(getEach!= null){
                        
                        if(getEach.Origin!=null && getEach.Description != null && ((getEach.Origin=='FRT Bookings'|| getEach.Origin=='FRT Cust Service') && freight_rectypeMap.containsKey(getEach.recordtypeid))){ 
                            
                            String str = getEach.Description;
                            str= str.replace('\n',' ');
                            if( getEach.Description.contains('-XXXX-XXXX-XXXX'))
                            {
                                hasCardInfo = true;
                            }
                            List<String> spiltStr = str.split(' ');
                            for(String s : spiltStr)
                            {
                                String s1 = s;
                                s= s.replace('\n','');
                                s= s.replace('\r','');
                                s= s.trim();
                                
                                Boolean isAusPhoneNumberWithplus = s.startsWith('+61')||s.startsWith('0')||s.startsWith('61')||s.startsWith('+');
                                Boolean isPhoneNumber;
                                
                                if(isAusPhoneNumberWithplus){
                                    isPhoneNumber =  true;
                                    continue;
                                }
                                
                                if(s.contains('http')) {    //skip the masking logic for urls
                                    continue;
                                }
                                s = s.replaceAll('\\D','');
                                Pattern p=Pattern.compile('^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35*\\d{3})*\\d{11}|(?:2131|1800|35*\\d{3})*\\d{15})$');
                                Matcher m = p.matcher(s);
                           
                                if(m.matches()){
                                    hasCardInfo = true;
                                    
                                    integer i =s.length();
                                    String s2 = s.substring(2, i);
                                    String s3 = s.replace(s2, '-XXXX-XXXX-XXXX');
                                    String strChanged = str.replace(s1, s3);
                                    getEach.Description = strChanged;
                                    isUpdate= true;
                                    if(isUpdate)
                                    {
                                        getEach.HasCreditCard__c = true;
                                    }
                                }
                            }
                            //Jira CRM-5358 Mask Credit Card number with spaces
                            Map<String, String> maskedStrMap = QCC_CaseUtility.maskCreditCardAndUATPCardNumbersSeparatedBySpaces(str);
                            String originalDes = getEach.Description;
                            for (String mskdStr : maskedStrMap.keySet())
                            {
                                originalDes = originalDes.replace(mskdStr, maskedStrMap.get(mskdStr));
                                hasCardInfo = true;
                            }
                            getEach.Description = hasCardInfo ? originalDes : getEach.Description;
                            
                        }
                    }
                    
                    getEach.HasCreditCard__c = hasCardInfo;
                }
            }
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e.getmessage());
        }
        
    }
/*--------------------------------------------------------------------------------------      
Method Name:        freightAssociateAcctsWeb2Case
TestMethod Name:    testfreightAssociateAcctsWeb2Case
Description:        This method assign the accounts to Cases created from Freight Portal
Parameter:          Case New List  
Jira Story:         FCRM-908
Date Implemented:   17 May 2022
Sprint Freight      159,160
--------------------------------------------------------------------------------------*/
    public static void freightAssociateAcctsWeb2Case(List<Case> caselist)
    {
        try
        {
            system.debug('@@@ in the freightAssociateAcctsWeb2Case');
            
            Id AccountRTId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            Id ContactRTId= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
            Map<String,Case> mapCases=new Map<String,Case>();
            Set<String> setEmails=new Set<string>();
            Map<String,List<Contact>> mapContacts;
            Map<String,List<Account>> mapAccounts;
            List<Id> listAccountIds=new List<Id>();
            List<Contact> fetchContacts=new List<Contact>();
            set<Id> setAccountIds=new set<Id>();
            set<Id> setAcctsIds=new set<Id>();
            Boolean flgAcctAssigned=false;
            Map<string,ID> matchedAcctByName = new Map<string,ID>();
            List<Case> updateCaseList=new List<Case>();
            List<ID> caseIds=new List<ID>();
            List<Case> casesRetList=new List<Case>();
            
           /* if(caselist!=null && caselist.size()>0)
            {
                for(Case getCase:caselist)
                {
                    caseIds.add(getCase.id); 
                }   
            }
          casesRetList=[select id,casenumber,suppliedemail,suppliedcompany,origin,accountid,contactid,recordtypeid from case where ID IN:caseIds]; */
          if(caselist!=null && caselist.size()>0)
          {
              for(Case getCase:caselist)
                {
                    if(freight_rectypeMap.containsKey(getCase.recordtypeId) && getCase.origin=='Web' && getCase.SuppliedEmail!=null)
                    {
                        setEmails.add(getCase.suppliedemail);
                        mapCases.put(getCase.CaseNumber,getCase);   
                    }
                }   
          }
          
          system.debug('@@@ in the setEmails debug'+setEmails);

          if(setEmails!=null && setEmails.size()>0)
          fetchContacts=[select id,email,accountid,account.name from contact where recordtypeid=:ContactRTId and account.recordtypeid=:AccountRTId and email IN:setEmails];
          
             system.debug('@@@ the value of fetchContacts'+fetchContacts);
            if(mapCases.isEmpty()==false && (fetchContacts!=null && fetchContacts.size()>0))
            {
                for(Case csmap:mapCases.values())
                {
                    for(contact cont:fetchContacts)   
                    {
                        if(csmap.SuppliedEmail.equalsIgnoreCase(cont.email))
                        {
                            if(mapContacts==null)
                            {
                                mapContacts=new Map<String,List<Contact>>();
                                mapcontacts.put(csmap.casenumber,new List<contact>());
                            }
                            if(mapContacts!=null && !mapContacts.containskey(csmap.CaseNumber))
                            {
                                mapContacts.put(csmap.CaseNumber,new list<contact>());
                                mapcontacts.get(csmap.CaseNumber).add(cont);
                            }
                            if(mapContacts!=null && mapContacts.get(csmap.casenumber)!=null)
                            {
                                mapcontacts.get(csmap.CaseNumber).add(cont);
                            }   
                        }
                    }
                }
            }
          if(mapcontacts.isEmpty()==false && mapCases.isEmpty()==false)
          {
              for(case caseEach:mapCases.values())
              {
                  if(mapcontacts.get(caseEach.casenumber).size()==1)
                  {
                     for(Contact conEach:mapcontacts.get(caseEach.casenumber))
                     {
                          caseEach.accountid=conEach.accountid;
                          updateCaseList.add(caseEach);
                          flgAcctAssigned=true;
                     }
                  }
                  else
                  {
                      for(Contact contEach:mapcontacts.get(caseEach.casenumber))
                      {
                         setAccountIds.add(contEach.AccountId);
                      }
                  }
                  if(flgAcctAssigned==false && setAccountIds.size()==1)
                  {
                      for(Id getAcctId:setAccountIds)
                      {
                         caseEach.accountid=getAcctId;  
                         updateCaseList.add(caseEach); 
                         flgAcctAssigned=true;
                      } 
                  }
                  else if(setAccountIds.size()>1)
                  {
                      setAcctsIds.addAll(setAccountIds);         
                  }
              }
          }
          if(setAccountIds.size()>1)
          {
            Map<Id,Account> mapFetchAccounts=new Map<Id,Account>([select id,name from account where id IN :setAcctsIds and recordtypeid=:AccountRTId]);
            if(mapCases.isEmpty()==false)
            {
              for(Case getCases:mapCases.values())
              {
                  for(Contact getConts:mapcontacts.get(getCases.casenumber))
                  {
                     if(mapFetchAccounts.containskey(getConts.accountid))
                     {
                         if(mapAccounts==null)
                            {
                                mapAccounts=new Map<String,List<Account>>();
                                mapAccounts.put(getCases.casenumber,new List<Account>());
                            }
                            if(mapAccounts!=null && !mapAccounts.containskey(getCases.CaseNumber))
                            {
                                mapAccounts.put(getCases.CaseNumber,new list<Account>());
                                mapAccounts.get(getCases.CaseNumber).add(mapFetchAccounts.get(getConts.accountid));
                            }
                            if(mapAccounts!=null && mapAccounts.get(getCases.casenumber)!=null)
                            {
                                mapAccounts.get(getCases.CaseNumber).add(mapFetchAccounts.get(getConts.accountid));
                            }   
                     }
                  }
                 if(mapAccounts.isEmpty()==false)
                 {
                     for(Account acct:mapAccounts.get(getCases.CaseNumber))
                     {
                         if(acct.name.contains(getCases.SuppliedCompany))
                         {
                             matchedAcctByName.put(getCases.CaseNumber,acct.id);
                             break;
                         }
                     }
                 }
                 if(flgAcctAssigned==false && matchedAcctByName.containskey(getCases.CaseNumber))
                 {
                    getCases.AccountId=matchedAcctByName.get(getCases.CaseNumber);
                    updateCaseList.add(getCases);
                 }
              }
            }  
          }
          
          if(updateCaseList!=null && updateCaseList.size()>0)
          {
              update updateCaseList;
          }
            
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e.getmessage());
        }
    }
    public static void autoCloseAuotmaticReplayCases(List<Case> caselist){
          
        if(caselist!=null && caselist.size()>0){
            for(Case c : caselist){
                if(c.subject!= null && c.Subject.containsIgnoreCase('Automatic reply:') && (c.Origin=='FRT Bookings' || c.Origin=='FRT Cust Service') && freight_rectypeMap.containsKey(c.recordtypeid)){
                    c.Status ='Auto Closed';
                    c.type='Invalid Case';
                }
            }
        }
    }
}