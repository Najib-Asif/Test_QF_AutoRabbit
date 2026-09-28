({
    handleRecordLoaded: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") 
        {
            console.log("Record is loaded successfully.");
            var pnr = component.get("v.currentRecord").PNR_number__c;
            var caseNum = component.get("v.currentRecord").CaseNumber;
            
            var action = component.get("c.getAllPNRCases");
            action.setParams({
                "pnrNum" : pnr,
                "caseNum" : caseNum
            });
            
            action.setCallback(this, function(data) {
                component.set("v.AllPNRCases", data.getReturnValue());
                component.set("v.totalRecords",component.get("v.AllPNRCases").length);
            });
            $A.enqueueAction(action);	
        } 
        else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } 
            else if(eventParams.changeType === "REMOVED") {
                // record is deleted
            }
                else if(eventParams.changeType === "ERROR") {
                    // there’s an error while loading, saving, or deleting the record
                }
    },
    toggleTable : function(component, event, helper){
        
        var baseCount = component.get("v.numberOfRecordsVisible");
        
        if(component.get("v.toggleCount") == baseCount){
            component.set("v.toggleCount",component.get("v.totalRecords"));        
        }
        else{
            component.set("v.toggleCount",baseCount);        
        }
        
        var buttonstate = component.get('v.buttonstate');
        component.set('v.buttonstate', !buttonstate);
    }    
})