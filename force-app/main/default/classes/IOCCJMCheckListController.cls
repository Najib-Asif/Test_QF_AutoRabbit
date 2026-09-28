public with sharing class IOCCJMCheckListController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCheckListOptions(){
        List<String> lstOptions = new List<String>();
        Set<String> setOption = new Set<String>();
		for(IOCCheckList__mdt objIOCCheck: [select Id, Label, HelpText__c, ValidType__c from IOCCheckList__mdt])
        {
            if(String.isNotBlank(objIOCCheck.ValidType__c)){
                for( String failure: objIOCCheck.ValidType__c.split(';')){
                    setOption.add(failure.trim());
                }
            }
        }
        lstOptions.addAll(setOption);
        system.debug(lstOptions); 
        lstOptions.sort();
        return lstOptions;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getAccessVal(){
        Profile objProfile = [select Id, Name from profile where Id =: userInfo.getProfileId()];
        String createProfile = CustomSettingsUtilities.getConfigDataMap('IOCChecklistcreateProfile');
        if(createProfile.contains(objProfile.Name)){
            return false;
        }
        return true;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getDynnamicOptions(String recordId, String checklistType){
        system.debug('checklistType###'+checklistType);
        system.debug('recordId###'+recordId);
        List<String> lstOptions = new List<String>();
        Set<String> setExisting = new Set<String>();
        UserRole objRole = [select Id, DeveloperName, Name from UserRole where Id =: userInfo.getUserRoleId()];
        for(EventActionPlan__c objActionPlan: [select Id, Name from EventActionPlan__c 
                                                Where FlightEvent__c =: recordId])
        {
            setExisting.add(objActionPlan.Name);
        }

		for(IOCCheckList__mdt objIOCCheck: [select Id, Label, HelpText__c,WriteAccessProfiles__c, ValidType__c from 
                                             IOCCheckList__mdt where Label NOT IN: setExisting order by Label])
        {
            if(String.isNotBlank(objIOCCheck.WriteAccessProfiles__c) && objIOCCheck.WriteAccessProfiles__c.contains(objRole.DeveloperName)){
			    lstOptions.add(objIOCCheck.Label);
            }
		} 
        system.System.debug(lstOptions); 
        return lstOptions;
    }

    @AuraEnabled(cacheable=true)
    public static List<ActionPlanWrapper> getAllList(String recordId){
        system.debug('recordId###'+recordId);
        UserRole objRole = [select Id, DeveloperName, Name from UserRole where Id =: userInfo.getUserRoleId()];
        List<ActionPlanWrapper> lstActionPlanWrapper = new List<ActionPlanWrapper>();
        lstActionPlanWrapper = onLoad(recordId, objRole.DeveloperName);
        system.debug('final wrapper...'+lstActionPlanWrapper);
        return lstActionPlanWrapper;
    }

    @AuraEnabled
    public static String createAllEvents(String recordId, String checklistType){
        UserRole objRole = [select Id, DeveloperName, Name from UserRole where Id =: userInfo.getUserRoleId()];
        //Profile objProfile = [select Id, Name from Profile where Id =: userInfo.getProfileId()];
        onChangeofOption(recordId, checklistType, objRole.DeveloperName);
        return 'success';
    }

   

    @AuraEnabled
    public static String createCurrentActionItem(EventActionPlan__c objActionPlan, String comments, Boolean isComplete, String checklistType){
        system.debug('objActionPlan'+objActionPlan);
        system.debug('comments'+comments);
        system.debug('isComplete'+isComplete);
        objActionPlan.Comments__c = comments;
        if(isComplete && objActionPlan.CompletedDateTime__c == Null){
            objActionPlan.CompletedDateTime__c = system.now();
        }else if(!isComplete){
            objActionPlan.CompletedDateTime__c = Null;
        }
        objActionPlan.ActionCompleted__c = isComplete;
        system.debug('All Field '+objActionPlan);
        update objActionPlan;
        return 'Success';
    }

    @AuraEnabled
    public static String createDynamicActionItem(String name, String  recordId){

        IOCCheckList__mdt objIOCCheck = [select Id, Label, HelpText__c, ValidType__c, OwnerQueueUserName__c,
                                         Priority__c from IOCCheckList__mdt Where Label =: name limit 1];

        EventActionPlan__c objEvtAct = new EventActionPlan__c();
        objEvtAct.Name = objIOCCheck.Label;
        objEvtAct.FlightEvent__c = recordId;
        objEvtAct.Description__c = objIOCCheck.HelpText__c;
        objEvtAct.Priority__c = objIOCCheck.Priority__c;
        objEvtAct.Comments__c = '';
        objEvtAct.ActionCompleted__c = false;
        if(String.isNotBlank(objIOCCheck.OwnerQueueUserName__c)){
            Group objQueue =  [SELECT Id FROM Group where Type='Queue' and DeveloperName =: objIOCCheck.OwnerQueueUserName__c];
            objEvtAct.OwnerId = objQueue.Id;
        }
        insert objEvtAct;
        return 'success';
    }

    @AuraEnabled
    public static String deleteDynamicRecord(EventActionPlan__c objActionPlan){
        system.debug('objActionPlan###'+objActionPlan);
        delete objActionPlan;
        return 'success';
    }

    public static List<ActionPlanWrapper> onLoad(String recordId, String profileName){
        List<EventActionPlan__c> lstEvtAction = queryAll(recordId);
        List<ActionPlanWrapper> lstActPlanWrapper = new List<ActionPlanWrapper>();
        //List<EventActionPlan__c> lstfalseEvtAction = new List<EventActionPlan__c>();
        Map<String, IOCCheckList__mdt> mapIOCMetadata = queryAllIOCCheckList();
        for(EventActionPlan__c objActionPlan: lstEvtAction){
            ActionPlanWrapper actPlanWrapper = new ActionPlanWrapper();
            String actPlanName = objActionPlan.Name;
            objActionPlan = getAccessLevel(objActionPlan, mapIOCMetadata.get(objActionPlan.Name),  profileName);
            actPlanWrapper.actionPlan = objActionPlan;
            system.debug('test..'+actPlanName);
            actPlanWrapper.completeAction = 'NA';
            if(mapIOCMetadata.get(actPlanName) != null && !String.isBlank(mapIOCMetadata.get(actPlanName).Flow_Action__c))
            	actPlanWrapper.completeAction = mapIOCMetadata.get(actPlanName).Flow_Action__c;
            if(objActionPlan != Null && objActionPlan.HasAccess__c){
                lstActPlanWrapper.add(actPlanWrapper);
            }
            System.debug('on load.final..'+actPlanWrapper.completeAction);
        }
        //lstActPlanWrapper.addAll(lstfalseEvtAction);
        return lstActPlanWrapper;
    }

    public static void onChangeofOption(String recordId, String option, String profileName){
        List<EventActionPlan__c> lstEvtAction = new List<EventActionPlan__c>();
        List<EventActionPlan__c> lstDelete = new List<EventActionPlan__c>();
        List<EventActionPlan__c> lstRetEvtAction = queryAll(recordId);
        Set<String> setActPlan = new Set<String>();
        Map<String, IOCCheckList__mdt> mapIOCMetadata = queryAllIOCCheckList();

        for(EventActionPlan__c objActionPlan: lstRetEvtAction){
            objActionPlan = getAccessLevel(objActionPlan, mapIOCMetadata.get(objActionPlan.Name),  profileName);
            if(objActionPlan != Null){
                setActPlan.add(objActionPlan.Name);
            }   
        }
        
        for(IOCCheckList__mdt objIOCCheck: mapIOCMetadata.values())
        {
            if(String.isNotBlank(objIOCCheck.ValidType__c) && objIOCCheck.ValidType__c.contains(option) && (setActPlan.size() == 0 ||
            !setActPlan.contains(objIOCCheck.Label))){
                EventActionPlan__c objEvtAct = new EventActionPlan__c();
                objEvtAct.Name = objIOCCheck.Label;
                objEvtAct.FlightEvent__c = recordId;
                objEvtAct.Description__c = objIOCCheck.HelpText__c;
                objEvtAct.OptionSelected__c = option;
                objEvtAct.ActionCompleted__c = false;
                objEvtAct.Comments__c = '';
                objEvtAct.Priority__c = objIOCCheck.Priority__c;

                if(String.isNotBlank(objIOCCheck.OwnerQueueUserName__c)){
                    Group objQueue =  [SELECT Id FROM Group where Type='Queue' and DeveloperName =: objIOCCheck.OwnerQueueUserName__c];
                    objEvtAct.OwnerId = objQueue.Id;
                }
                lstEvtAction.add(objEvtAct);
            }   
        }
        delete lstDelete;
        insert lstEvtAction;

        Event__c objEvt = new Event__c();
        objEvt.ActionType__c = option;
        objEvt.Id = recordId;
        //update objEvt;
    }

    public static List<EventActionPlan__c> queryAll(String recordId){
        List<EventActionPlan__c> lstEvtAction = new List<EventActionPlan__c>();
        lstEvtAction = [select Id, Name, ActionCompleted__c, CompletedDateTime__c, Priority__c, OwnerId, 
                        Comments__c, OptionSelected__c, Description__c, FlightEvent__c, Owner.Name
                        from EventActionPlan__c Where FlightEvent__c =: recordId ORDER BY Priority__c]; 
        return lstEvtAction; 
    }

    public static Map<String, IOCCheckList__mdt> queryAllIOCCheckList(){
        Map<String, IOCCheckList__mdt> mapIOCMetadata = new Map<String, IOCCheckList__mdt>();

        for(IOCCheckList__mdt objIOCCheck: [select Id, Label, HelpText__c, ValidType__c, WriteAccessProfiles__c, Flow_Action__c,
                                            ReadAccessProfiles__c, OwnerQueueUserName__c, Priority__c from IOCCheckList__mdt])
        {
            mapIOCMetadata.put(objIOCCheck.Label, objIOCCheck);
        }
        system.debug('io checklist metadaat...'+mapIOCMetadata);
        return mapIOCMetadata;
    }

    public static EventActionPlan__c getAccessLevel(EventActionPlan__c objActionPlan, IOCCheckList__mdt objMetadata, String profileName){
        system.debug('profileName###'+profileName);
        system.debug('objMetadata###'+objMetadata);
        system.debug('objActionPlan###'+objActionPlan);
        if(objMetadata != null && String.isNotBlank(objMetadata.WriteAccessProfiles__c) && 
           objMetadata.WriteAccessProfiles__c.contains(profileName)){
            objActionPlan.HasAccess__c = true;
        }else if(objMetadata != null && String.isNotBlank(objMetadata.ReadAccessProfiles__c) && objMetadata.ReadAccessProfiles__c.contains(profileName)){
            objActionPlan.HasAccess__c = false;
        }else{
            return null;
        }
        return objActionPlan;
    }

    @AuraEnabled
    public static String UpdateRecords(List<EventActionPlan__c> recordstoUpdate){
        system.debug('recordstoUpdate###'+recordstoUpdate);
        try {
            update recordstoUpdate;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return 'success';
    }
    
    public class ActionPlanWrapper {
        @AuraEnabled public EventActionPlan__c actionPlan { get; set; } // The Action Plan record
        @AuraEnabled public String completeAction { get; set; } // Flow to be redirected
    }

}