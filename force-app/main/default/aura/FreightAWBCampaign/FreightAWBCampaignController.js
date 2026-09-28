({
    doInit : function(component, event, helper){
        var action = component.get("c.getBeforeAWBDetailsCampMember");
        
        action.setParams({
            "CampaignMemberId" : component.get("v.recordId")
        });
        console.log("CampaignMemberId :" + component.get("v.recordId"));  
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.BeforeAWB", response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    
    doAWB : function(component, event, helper) {
        
        component.set("v.showSpinner", true);
        //$A.util.removeClass(component.find('spinner'),"slds-hide");
        
        var action = component.get("c.getRecordUpdateCampMember");
        
        action.setParams({
            "CampaignMemberId" : component.get("v.recordId")
        });
        console.log("CampaignMemberId :" + component.get("v.recordId"));
        
        action.setCallback(this, function(response) {
            
            var output = response.getReturnValue();
            component.set("v.showSpinner", false);
            //$A.util.addClass(component.find('spinner'),"slds-hide");
            component.set("v.messageError", false);
            
            // to check the parsed list is Not Null
            if (output && output.LatestStatusString){
                var latestString = output.LatestStatusString;
                var lsList = JSON.parse(latestString);
                component.set("v.isOpen", true);
                component.set("v.showTable",true);
            }
            else{
                component.set("v.isOpen", true);
                component.set("v.message", output.msg);
                component.set("v.showTable",false);
            }
            
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS" && output.isSuccess){
                
                // $A.get("e.force:closeQuickAction").fire();
                component.set("v.isOpen", true);
                component.set("v.ApexController", output);				
                component.set("v.lsList",lsList);
                $A.get('e.force:refreshView').fire();
            } 
            else if (state == "ERROR" || !output.isSuccess) {
                
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    
                    // Did not catch on the Server Side
                    component.set("v.message", errors[0].message);
                    component.set("v.messageError", true);
                    component.set("v.isOpen", false);
                } 
                else if ( !output.isSuccess ) {
                    
                    // Did catch on the Server Side
                    component.set("v.message", output.msg);
                    component.set("v.messageError", true);
                    component.set("v.isOpen", false);
                }
                var reInit = component.get("c.doInit");
                $A.enqueueAction(reInit);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
        
        // to refresh the Base method after close.
        var reInit = component.get("c.doInit");
        $A.enqueueAction(reInit);
    }
})