/*-----------------------------------------------------------------------------------------
    Author: Nga Do
    Company: Capgemini
    Description: 
    Inputs: 
    Test Class: QCC_EventSubmitRecoveriesBatchableTest
    ***************************************************************************************
    History:
    ***************************************************************************************
    15-May-2018
 ------------------------------------------------------------------------------------------*/
global class QCC_EventSubmitRecoveriesBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful {
    
    String query;
    String eventId;
    String messageResult;
    List<Case> listCaseCreated;
    List<Recovery__c> listRecoveryCreated;
    
    
    /*--------------------------------------------------------------------------------------       
    Method Name:        QCC_EventSubmitRecoveriesBatchable
    Description:        submit recovery for specific event
    Parameter:          set Id of Event
    --------------------------------------------------------------------------------------*/
    global QCC_EventSubmitRecoveriesBatchable(String eventId) {
        this.messageResult = '';
        this.eventId = eventId;
        listCaseCreated = new List<Case>();
        listRecoveryCreated = new List<Recovery__c>();
    }
    
    /*--------------------------------------------------------------------------------------       
    Method Name:        start
    Description:        Create Case and Recovery for specific event
    Parameter:          Database.BatchableContext
    --------------------------------------------------------------------------------------*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // build Query String get all the affected passenger by event Id
        
        query = 'SELECT Id, Name, Passenger__c,Passenger__r.name, TECH_OfferedQantasPoints__c, Passenger__r.LastName, FirstName__c, LastName__c, ' 
                +   ' Event__c, Email__c, Cabin__c, Passenger__r.Frequent_Flyer_Tier__c, FrequentFlyerTier__c, FrequentFlyerNumber__c'
                +   ' FROM' 
                +   ' Affected_Passenger__c'
                +   ' WHERE' 
                +   ' Event__c =: eventId'
                +   ' AND' 
                +   ' Affected__c = true'
                +   ' AND'
                +   ' RecoveryIsCreated__c = false AND EventCommunication__c != Null';
        return Database.getQueryLocator(query);
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        execute
    Description:        Create Case and Recovery for list affected passenger
    Parameter:          Database.BatchableContext
    --------------------------------------------------------------------------------------*/
    global void execute(Database.BatchableContext BC, List<Affected_Passenger__c> scope) {
        Map<String, Case> mapNewCases = new Map<String, Case>();
        Map<String, Recovery__c> mapNewRecoveries = new Map<String, Recovery__c>();
        // get Id RecordType QCC Event of Case
        Id caseOriginRecTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Event RecType'));
        Id travelVoucherRecRT=Schema.SObjectType.Recovery__c.getRecordTypeInfosByName().get('Travel Voucher Recovery').getRecordTypeId();

        QCC_GenericUtils.ContactWrap conWrap    = QCC_GenericUtils.fetchContactForNonFFCases();         
        Integer     numberCaseInNonFFContact    = conWrap.count;
        //Cost__c objCost = [Select Id from Cost__c where FlightEvent__c =: eventId limit 1];
        //Map<String, String> mapCommnetByAffectedPassenger = new Map<String, String>();
        for(Affected_Passenger__c passenger : scope){
            //====================creating Case==================
            //CRM-8800 Only create recovery if passenger email is not blank
            if(passenger.TECH_OfferedQantasPoints__c>0 && String.isNotBlank(passenger.Email__c))
            {
                
                //Thom Phan - update non FF contact for passenger.Passenger__c which is used to update for newCase.ContactId and newRecovery.Contact__c also
                if(String.isBlank(passenger.Passenger__c) || passenger.Passenger__c == Null){
                    if(numberCaseInNonFFContact >= 10000){
                        conWrap = QCC_GenericUtils.fetchContactForNonFFCases();
                        numberCaseInNonFFContact = conWrap.count;
                    }else{
                        numberCaseInNonFFContact = numberCaseInNonFFContact + 1;
                    }
                    passenger.Passenger__c = conWrap.objCon.ID;
                }
                
                if(passenger.Passenger__c!=null && passenger.Passenger__r.name!=null && String.isNotBlank(passenger.Passenger__r.name) && !passenger.Passenger__r.name.containsIgnoreCase('Null'))
                {
                    
                        // init the Case recovery
                Case newCase = new Case();
                
                // record type = event
                newCase.RecordTypeId = caseOriginRecTypeId;
                // case origin = event
                newCase.Origin = CustomSettingsUtilities.getConfigDataMap('Case Origin Event');
                system.debug('>>> passenger value'+passenger);
                system.debug('>>> passenger contact value'+passenger.Passenger__c);
                system.debug('>>> passenger contact name value'+passenger.Passenger__r.name);
               system.debug('>>> the value of passenger.FrequentFlyerNumber__c'+passenger.FrequentFlyerNumber__c);
                if (String.isEmpty(passenger.FrequentFlyerNumber__c) && passenger.Passenger__c != Null && String.isNotBlank(passenger.Passenger__c) && passenger.Passenger__r.name!=null && !passenger.Passenger__r.name.containsIgnoreCase('null'))
                {
                    newCase.Status = 'Pending Recovery';
                }
                else
                {
                     // status = closed
                    newCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusOpen');
                }
                
                // case tyoe = event
                newCase.Type = CustomSettingsUtilities.getConfigDataMap('Case Type Event');
                // Contact = related passenger record (contact)
                newCase.ContactId = passenger.Passenger__c;
                // event = related event - not exist in object case
                newCase.Event__c = passenger.Event__c;
                // contact email = related affected passenger email
                newCase.Contact_Email__c = passenger.Email__c;
                // subject = proactive recovery for event
                newCase.Subject = CustomSettingsUtilities.getConfigDataMap('Case Subject Event');
                // cabin = the related affected passenger cabin
                newCase.Cabin_Class__c = passenger.Cabin__c;
                // ff tier = related passenger record(contact)
                newCase.FF_Tier__c = passenger.FrequentFlyerTier__c;
                // group = Event
                newCase.Group__c = CustomSettingsUtilities.getConfigDataMap('Case Group Event');
                // Priority = medium
                newCase.Priority = CustomSettingsUtilities.getConfigDataMap('Case Priority Medium');
                // add case to map
                
                // map First name, Last Name from Passenger to Case
                newCase.First_Name__c = passenger.FirstName__c;
                newCase.Last_Name__c = passenger.LastName__c;
                
                mapNewCases.put(passenger.Id, newCase);
                
                //==================creating Recovery=======================
                // init the new recovery
                
                    
                Recovery__c newRecovery = new Recovery__c();
                newRecovery.TECH_Proactive__c = true;

                //CRM-8800 define Qantas Points Recovery for FF Contacts
                if(String.isNotBlank(passenger.FrequentFlyerNumber__c))
                {
                    // type = 'Qantas Points' for FF Contacts
                    newRecovery.Type__c = CustomSettingsUtilities.getConfigDataMap('RecoveryType');
                    // Quantity (Amount__c) = Offered Qantas Points from the Affected Passenger record
                    newRecovery.Amount__c = passenger.TECH_OfferedQantasPoints__c;
                }//CRM-8800 define Travel Vouchers Recovery for NON FF Contacts
                else if ( String.isEmpty(passenger.FrequentFlyerNumber__c) && String.isNotBlank(passenger.Passenger__c) && passenger.Passenger__r.name!=null && !passenger.Passenger__r.name.contains('null'))
                {
                    // type = 'Travel Voucher' for Non FF contacts
                    newRecovery.Type__c = CustomSettingsUtilities.getConfigDataMap('RecoveryTypeNonFF');
                    newRecovery.recordtypeid=travelVoucherRecRT;
                    newRecovery.Process_Status__c='Approved';

                    newRecovery.Monetary_Value__c = passenger.TECH_OfferedQantasPoints__c;
                    newRecovery.Status__c='Approved'; // Recovery Status
                    newRecovery.Original_Currency__c='AUD Australian Dollar';
                    newRecovery.Recovery_Reason__c='Gesture of Goodwill';
                    newRecovery.Cost_Centre_Account_Number__c='Customer Care : Ex Gratia Passenger (309276 : 718017)';
                    newRecovery.Refund_Cost_Centre__c='309276	(Customer Care)';
                    newRecovery.Refund_Account__c='718017	(Ex Gratia Passenger)';
                    
                }
                else
                {
                    // type = 'Qantas Points' for other null contact
                    newRecovery.Type__c = CustomSettingsUtilities.getConfigDataMap('RecoveryType');
                }
                
                
                // Contact = related passenger contact
                newRecovery.Contact__c = passenger.Passenger__c;
                
                //status = 'Submit for Finalisation' if affected passenger record Frequent Flyer Tier is not Blank and not 'Non-Tiered'
                if(!String.isBlank(passenger.FrequentFlyerTier__c)
                   && passenger.FrequentFlyerTier__c != CustomSettingsUtilities.getConfigDataMap('Affected Passenger Non-Tiered')
                   && passenger.Passenger__c != Null){
                       
                       newRecovery.Status__c =  CustomSettingsUtilities.getConfigDataMap('RecoveryStatusInitiated');
                       
                   }

                   //commenting as the Travel Voucher Recoveries Need to be Approved Status
                // status = Awaiting Customer Response (if Affected Passenger record Frequent Flyer Tier is blank or 'Non-Tiered')
                /*if(passenger.Passenger__c == Null || String.isBlank(passenger.FrequentFlyerTier__c) 
                   || passenger.FrequentFlyerTier__c == CustomSettingsUtilities.getConfigDataMap('Affected Passenger Non-Tiered')){
                       
                       newRecovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusAwaitingCustomer');
                   }*/
                // add new Recovery into map
                mapNewRecoveries.put(passenger.Id, newRecovery);
            
                }
            
            }
        }
        
        
        try{
            if(!mapNewCases.isEmpty()){
                // insert new Case
                //insert mapNewCases.values();
                Database.SaveResult[] getCaseResult =Database.insert( mapNewCases.values(),false);
                if(getCaseResult!=null && getCaseResult.size()>0)
                {
                    for(Database.SaveResult getCaseRes:getCaseResult)
                    {
                        system.debug('>>> Print Case insert results'+getCaseRes);
                    }
                }
                listCaseCreated.addAll(mapNewCases.values());

            }
            //Decimal totalPoint =  0;
            // get the Id of new case set into new Recovery
            if(!mapNewRecoveries.isEmpty()){
                    for(Affected_Passenger__c passenger : scope){
                    if(mapNewCases.containsKey(passenger.Id)
                        && mapNewRecoveries.containsKey(passenger.Id)
                        && mapNewCases.get(passenger.Id).Id != null){

                        // case = newly created Case 
                        mapNewRecoveries.get(passenger.Id).Case_Number__c = mapNewCases.get(passenger.Id).Id;
                        // update RecoveryIsCreated in Affected Passenger = true;
                        passenger.RecoveryIsCreated__c = true;
                        //totalPoint += passenger.TECH_OfferedQantasPoints__c;
                    }
                     Passenger.sendEmail__c = true;
                }

                //objCost.Total_Recovery_Points__c = totalPoint;
                //update objCost;
                //insert new recovery
                Database.SaveResult[] getResult=Database.insert(mapNewRecoveries.values(), false);
                
                if(getResult!=null)
                {
                    for(Database.SaveResult getRes: getResult)
                    {
                        system.debug('>>> the result'+getRes);
                    }
                }
                

                listRecoveryCreated.addAll(mapNewRecoveries.values());
                // update Affected Passenger
                Database.update(scope, false);

                //call RoyaltyAPI QUEUE
                Set<Id> setRecoveryId = new Set<Id>();

                for(Recovery__c objRecovery : mapNewRecoveries.values()){
                    if(objRecovery.Id != null && objRecovery.Type__c==CustomSettingsUtilities.getConfigDataMap('RecoveryType')){
                        setRecoveryId.add(objRecovery.Id);
                    }
                }
                System.debug('===============setRecoveryId' + setRecoveryId);
                if(setRecoveryId!=null && setRecoveryId.size()>0)
                {
                    ID jobID = System.enqueueJob(new QCC_RevoveriesCallLoyaltyAPIQueue(setRecoveryId));
                }
                
            }
            }catch(Exception ex){
                messageResult = CustomSettingsUtilities.getConfigDataMap('Recovery Submitted Fail Message');
            }
        
    }
    
    /*--------------------------------------------------------------------------------------       
    Method Name:        finish
    Description:        check status of batch job, and pos status to chatter
    Parameter:          Database.BatchableContext
    --------------------------------------------------------------------------------------*/
    global void finish(Database.BatchableContext BC) {

        Event__c objectEvent = [SELECT Id, RecoveryIsCreated__c FROM Event__c WHERE Id =: eventId];
        // update Recovery Is Created.
        if(String.isBlank(messageResult)){
            AsyncapexJob aJob = [SELECT Id, Status FROM AsyncapexJob WHERE Id =: BC.getJobId()];
            system.debug('aJob$$$'+aJob);
            if(aJob.Status == 'Completed' 
                && !listRecoveryCreated.isEmpty() 
                && !listCaseCreated.isEmpty()){
                
                objectEvent.RecoveryIsCreated__c = true;
                update objectEvent;

                messageResult = CustomSettingsUtilities.getConfigDataMap('Recovery Submitted Success Message');

            }else if(aJob.Status == 'Failed'){
                messageResult = CustomSettingsUtilities.getConfigDataMap('Recovery Submitted Fail Message');
            }
        }
        ///////////////////////////
        System.debug(messageResult);
        // post to event chatter
        if(!Test.isRunningTest() ){
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, objectEvent.id, ConnectApi.FeedElementType.FeedItem, messageResult); 
        }
    }
    
}