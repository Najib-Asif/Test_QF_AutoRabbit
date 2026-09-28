/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Test Class for AssetTrigger Helper
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
05-Mar-2019    Praveen Sampath   InitialDesign

Modified By : Venkata Suresh Kumar (TCS Team), 02-Mar-2026
Desc : Remediated test class failures. Updated createCurrentActionItemPositiveTest(), and createCurrentActionItemNegativeTest() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class IOCCJMCheckListControllerTest {
    
    @testSetup
    static void createTestData(){
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIValidationLevel','NUMBER'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIPartnerID','DIAMD01'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IOCChecklistcreateProfile','System Administrator'));
        insert lstConfigData;
        
        Event__c newEvent1  = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Open', 'Flight Delay','Domestic');
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepDate__c = System.today();
        newEvent1.Actual_Arrival_UTC__c = System.now();
        newEvent1.Estimated_Arrival_UTC__c = System.now();
        newEvent1.Operational_Carrier__c = 'QF';
        newEvent1.FlightNumber__c = 'QF0001';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        insert newEvent1;
        System.assert(newEvent1.Id != Null, 'Issue in Creating new Event');
    }
    
    static testMethod void pageLoadTest(){
        test.startTest();
        List<String> lstOptions = IOCCJMCheckListController.getCheckListOptions();
        system.assert(lstOptions.size()>0, 'No Checklist available for the Event');
        
        Boolean accessLevel = IOCCJMCheckListController.getAccessVal();
        system.assert(accessLevel != Null, 'Access level is not returned');
        test.stopTest();
    }
    
    static testMethod void getDynnamicOptionsTest(){
        Event__c objEvt = [Select Id from Event__c limit 1];
        test.startTest();
        List<String> lstOptions = IOCCJMCheckListController.getDynnamicOptions(objEvt.Id, 'Delay 1+');        
        List<IOCCJMCheckListController.ActionPlanWrapper> lstActPlan = IOCCJMCheckListController.getAllList(objEvt.Id);
        system.assert(lstActPlan.size()==0, 'ActionPlan available for the Event');
        IOCCJMCheckListController.createAllEvents(objEvt.Id, 'Delay 1+');
        test.stopTest();
    }
    
    static testMethod void createCurrentActionItemPositiveTest(){
        Event__c objEvt = [Select Id from Event__c limit 1];
        EventActionPlan__c objActionPlan = new EventActionPlan__c();
        objActionPlan.Name = 'Brief CSM';
        objActionPlan.ActionCompleted__c = true;
        objActionPlan.Comments__c = 'Completed';
        objActionPlan.FlightEvent__c = objEvt.Id;
        insert objActionPlan;
        test.startTest();
        EventActionPlan__c objActPlan = [select Id, Name, ActionCompleted__c, Comments__c, FlightEvent__c from EventActionPlan__c limit 1];
        
        String res = IOCCJMCheckListController.createCurrentActionItem(objActionPlan, 'Completed', true, 'test' );
        system.assert(res == 'Success', 'Exception in updating event');
        
        String response = IOCCJMCheckListController.createDynamicActionItem('CJL: Meals*', objEvt.Id);
        system.assert(response == 'success', 'Exception in creating event');
        
        String delRes = IOCCJMCheckListController.deleteDynamicRecord(objActPlan);
        system.assert(delRes == 'success', 'Exception in deleting event');
        test.stopTest();
    }
    static testMethod void createCurrentActionItemNegativeTest(){
        Event__c objEvt = [Select Id from Event__c limit 1];
        EventActionPlan__c objActionPlan = new EventActionPlan__c();
        objActionPlan.Name = 'Brief CSM';
        objActionPlan.ActionCompleted__c = true;
        objActionPlan.Comments__c = 'Completed';
        objActionPlan.FlightEvent__c = objEvt.Id;
        insert objActionPlan;
        test.startTest();
        EventActionPlan__c objActPlan = [select Id, Name, ActionCompleted__c, Comments__c, FlightEvent__c from EventActionPlan__c limit 1];
        
        String res = IOCCJMCheckListController.createCurrentActionItem(objActionPlan, 'Completed', false, 'test' );
        system.assert(res == 'Success', 'Exception in updating event');
        
        String response = IOCCJMCheckListController.createDynamicActionItem('CJL: Meals*', objEvt.Id);
        system.assert(response == 'success', 'Exception in creating event');
        
        String delRes = IOCCJMCheckListController.deleteDynamicRecord(objActPlan);
        system.assert(delRes == 'success', 'Exception in deleting event');
        test.stopTest();
    }
    
    static testMethod void UpdateRecordsTest(){            
        Event__c objEvt = [Select Id from Event__c limit 1];
        List<EventActionPlan__c> lstofevt = new List<EventActionPlan__c>();
        EventActionPlan__c objActionPlan = new EventActionPlan__c();
        objActionPlan.Name = 'Brief CSM';
        objActionPlan.ActionCompleted__c = true;
        objActionPlan.Comments__c = 'Completed';
        objActionPlan.FlightEvent__c = objEvt.Id;
        lstofevt.add(objActionPlan);
        insert lstofevt;
        test.startTest();
        objActionPlan.Comments__c = 'Completed Successfully';
        Update objActionPlan;
        EventActionPlan__c objActPlan = [select Id, Name, ActionCompleted__c, Comments__c, FlightEvent__c from EventActionPlan__c limit 1];
        String res = IOCCJMCheckListController.UpdateRecords(lstofevt);
    }
    
    static testMethod void testGetAccessLevelHasaccessTrue()
    {
        string profileName ='QF_QDC_CJM';
        Event__c objEvt = [Select Id from Event__c limit 1];
        List<EventActionPlan__c> lstofevt = new List<EventActionPlan__c>();
        EventActionPlan__c objActionPlan = new EventActionPlan__c();
        objActionPlan.Name = 'Brief CSM';
        objActionPlan.ActionCompleted__c = true;
        objActionPlan.Comments__c = 'Completed';
        objActionPlan.FlightEvent__c = objEvt.Id;
        objActionPlan.HasAccess__c = true;
        lstofevt.add(objActionPlan);
        insert lstofevt; 
        
        IOCCheckList__mdt objInsert = new IOCCheckList__mdt(Label=objActionPlan.Name,HelpText__c ='Send oncarriage details to aircraft and airport if rebooking was completed less than 1 hr before estimated departure',
                                                            ValidType__c='Delay over 3 hours INT ;Overnight;Delay under 3 hours INT;', WriteAccessProfiles__c='QF_QDC_CJM;',
                                                            ReadAccessProfiles__c='',OwnerQueueUserName__c='CCC_CJO_Queue',Priority__c=100);
        
        Test.startTest();
        IOCCJMCheckListController.getAccessLevel(lstofevt[0], objInsert, profileName);
        Test.stopTest();
    }
    
    static testMethod void testGetAccessLevelHasaccessfalse()
    {
        string profileName ='QF_QDC_Commercial_Ops';
        Event__c objEvt = [Select Id from Event__c limit 1];
        List<EventActionPlan__c> lstofevt = new List<EventActionPlan__c>();
        EventActionPlan__c objActionPlan = new EventActionPlan__c();
        objActionPlan.Name = 'Brief CSM';
        objActionPlan.ActionCompleted__c = true;
        objActionPlan.Comments__c = 'Completed';
        objActionPlan.FlightEvent__c = objEvt.Id;
        objActionPlan.HasAccess__c = false;
        lstofevt.add(objActionPlan);
        insert lstofevt; 
        
        IOCCheckList__mdt objInsert = new IOCCheckList__mdt(Label=objActionPlan.Name,HelpText__c ='Send oncarriage details to aircraft and airport if rebooking was completed less than 1 hr before estimated departure',
                                                            ValidType__c='Delay over 3 hours INT ;Overnight;Delay under 3 hours INT;', WriteAccessProfiles__c='',
                                                            ReadAccessProfiles__c='QF_QDC_Commercial_Ops;',OwnerQueueUserName__c='CCC_CJO_Queue',Priority__c=100);
        //insert objInsert;
        EventActionPlan__c objEAP = new EventActionPlan__c();
        Test.startTest();
        objEAP = IOCCJMCheckListController.getAccessLevel(lstofevt[0], objInsert, profileName);
        Test.stopTest();
    }
    static testMethod void testGetAccessLevelHasaccessNull()
    {
        string profileName ='QF_QDC_Commercial_Ops';
        Event__c objEvt = [Select Id from Event__c limit 1];
        List<EventActionPlan__c> lstofevt = new List<EventActionPlan__c>();
        EventActionPlan__c objActionPlan = new EventActionPlan__c();
        objActionPlan.Name = 'Brief CSM';
        objActionPlan.ActionCompleted__c = true;
        objActionPlan.Comments__c = 'Completed';
        objActionPlan.FlightEvent__c = objEvt.Id;
        objActionPlan.HasAccess__c = false;
        lstofevt.add(objActionPlan);
        insert lstofevt; 
        
        IOCCheckList__mdt objInsert = new IOCCheckList__mdt(Label=objActionPlan.Name,HelpText__c ='Send oncarriage details to aircraft and airport if rebooking was completed less than 1 hr before estimated departure',
                                                            ValidType__c='Delay over 3 hours INT ;Overnight;Delay under 3 hours INT;', WriteAccessProfiles__c='',
                                                            ReadAccessProfiles__c='',OwnerQueueUserName__c='CCC_CJO_Queue',Priority__c=100);
        //insert objInsert;
        EventActionPlan__c objEAP = new EventActionPlan__c();
        Test.startTest();
        objEAP = IOCCJMCheckListController.getAccessLevel(lstofevt[0], objInsert, profileName);
        Test.stopTest();
    }
    
    static testMethod void credeleteDynamicRecordTest(){
        Event__c objEvt = [Select Id from Event__c limit 1];
        system.debug('List of event'+objEvt);
        List<EventActionPlan__c> lstofevtactplan = new List<EventActionPlan__c>();
        EventActionPlan__c objActionPlan = new EventActionPlan__c();
        objActionPlan.Name = 'Brief CSM';
        objActionPlan.ActionCompleted__c = true;
        objActionPlan.Comments__c = 'Completed';
        objActionPlan.FlightEvent__c = objEvt.Id;
        lstofevtactplan.add(objActionPlan); 
        
        Test.startTest();
        insert lstofevtactplan;        
        delete lstofevtactplan;
        Test.stopTest();
    }
}