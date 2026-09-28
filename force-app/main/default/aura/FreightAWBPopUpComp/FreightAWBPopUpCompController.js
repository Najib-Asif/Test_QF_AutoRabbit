({
    doInit : function(component, event, helper){
        var action = component.get("c.getBeforeAWBDetails");
        //alert(component.get("c.getBeforeAWBDetails"));
        action.setParams({
            "CaseId" : component.get("v.recordId"),
            "newportvalue" : component.get("v.case.Port_Override_Flag__c")
        });
        console.log("caseId :" + component.get("v.recordId")); 
        $A.get('e.force:refreshView').fire();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.BeforeAWB", response.getReturnValue());
                 //var unittype = response.getReturnValue();
                 //alert("unittype"+unittype);
                // var unitlist = JSON.parse(unittype);
                // alert("unitlist"+unitlist);
                var reInit = component.get("c.refresh");//CRM 8575
                $A.enqueueAction(reInit);
            }
        });
        $A.enqueueAction(action);
    },
    
    doAWB : function(component, event, helper) {
        component.set("v.showSpinner", true);
        //$A.util.removeClass(component.find('spinner'),"slds-hide");
        var action = component.get("c.getRecordUpdate");
        action.setParams({
            "CaseId" : component.get("v.recordId")
            
        });
        action.setCallback(this, function(response) {
            var output = response.getReturnValue();
            component.set("v.showSpinner", false);
            //$A.util.addClass(component.find('spinner'),"slds-hide");
            component.set("v.messageError", false);
            // to check the parsed list is Not Null
            if (output && output.LatestStatusString){
                var latestString = output.LatestStatusString;
                var lsList = JSON.parse(latestString);
                lsList = lsList.sort((a,b) => { //Added as a part of CRM-8457
                    if (Date.parse(a.transactionDateUtc) > Date.parse(b.transactionDateUtc)) {
                    return -1;
                } else {
                                     return 1;
                                     }
                                     });
                component.set("v.isOpen", true);
                component.set("v.showTable",true);
                
                
            }
            else{
                component.set("v.isOpen", true);
                component.set("v.message", output.msg);
                component.set("v.showTable",false);
            }
            // alert("response.getState()"+response.getState());
            var state = response.getState();
            // alert("state"+state);
            if(component.isValid() && state == "SUCCESS" && output.isSuccess){
                // alert("stateif");  
                // $A.get("e.force:closeQuickAction").fire();
                component.set("v.isOpen", true);
                component.set("v.ApexController", output);		
                var arr=component.set("v.lsList",lsList);
                $A.get('e.force:refreshView').fire();
            } 
            else if (state == "ERROR" || !output.isSuccess) {
                //  alert("stateelse");
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
    },
    
    refresh: function(component, event, helper) { //CRM 8575
        var action = component.get("c.getBeforeAWBDetails");
        action.setParams({
            "CaseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));  
        // $A.get('e.force:refreshView').fire();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.BeforeAWB", response.getReturnValue());  
            }
        });
        $A.get('e.force:refreshView').fire();      
        $A.enqueueAction(action);
    },
    //Error fixing 9610
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType == "LOADED") {
            console.log("Record Loaded");
        } else if (eventParams.changeType == "CHANGED") {
            console.log("Record Changed");
        } else if (eventParams.changeType == "REMOVED") {
            console.log("Record Removed");
        } else if (eventParams.changeType == "ERROR") {
            console.log("Error: " + eventParams.error);
        }
    }
    
    
    
})