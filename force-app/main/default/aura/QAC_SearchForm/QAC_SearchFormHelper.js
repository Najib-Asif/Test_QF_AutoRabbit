({
    displayToast : function(myTitle,myMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : myTitle,
            message: myMessage,
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 8000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();	
    },
    
    localSearchAction : function(component,event){
        var cmpEvent = component.getEvent("bubblingEvent");
        var locAction = component.get("c.getLocalSearchCases");
        locAction.setParams({
            "pnrNum": component.get("v.pnrNumber")
        });		
        
        locAction.setCallback(this, function(response) {
            component.set("v.showSpinner", false);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var output = response.getReturnValue();
                if(output.length > 0)
                {
                    component.set("v.localAvailable",true);
                    cmpEvent.setParams({"ComponentAction" : 'showPassengers'});
                    cmpEvent.fire();                    
                    
                    component.set("v.localCases",output);
                }
                else{
                    component.set("v.localAvailable",false);
                }
            }
            else {
                console.log("Local Failed with state: " + state);
                this.displayToast('Connection Not Found','Please contact system administrator for resolution');
            }
            console.log("L Local Bool"+component.get("v.localAvailable"));
            console.log("L Cap Bool"+component.get("v.capAvailable"));            
        });
        $A.enqueueAction(locAction);		
    },	
    
    searchCapAction : function(component,event) 
    {
        console.log('Inside the search cap action');
        var action = component.get("c.invokeCallout");
        var cmpEvent = component.getEvent("bubblingEvent");
        
        // CAP SEARCH AND ACTION
        action.setParams({
            "lastName": component.get("v.lastName"),
            "pnrNumber": component.get("v.pnrNumber")
        });
        
        action.setCallback(this, function(response) {
            component.set("v.showSpinner", false);
            component.set("v.pnrInformation",null);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var output = response.getReturnValue();
                if(output.pointSales)
                {
                    console.log("inside Cap Search o/p..");
                    component.set("v.capAvailable",true);
                
                    
                        console.log('inside the case view false');
                        cmpEvent.setParams({"ComponentAction" : 'showPassengers'});
                    
                        cmpEvent.fire();
                        console.log('print the output'+output);	
                        component.set("v.pnrInformation",output);
                }
                else{
                    component.set("v.capAvailable",false);
                    if(!component.get("v.localAvailable")){
                        cmpEvent.setParams({"ComponentAction" : 'showSearch'});
                        cmpEvent.fire();    
                        this.displayToast('Information Not Found','PNR not found in CAP Database');
                    }
                }
            }
            else {
                console.log("CAP Failed with state: " + state);
                this.displayToast('Connection Not Found','Please contact system administrator for resolution');
            }
            
            // Fire Local and Cap Search Results as App Event
            this.setAppEvent(component,event);
            console.log("C Local Bool"+component.get("v.localAvailable"));
            console.log("C Cap Bool"+component.get("v.capAvailable"));                        
        });
        $A.enqueueAction(action);	
    },
    setAppEvent : function(component,event)
    {
        component.set("v.showSpinner", false);
	    var action = component.get("c.getRecordTypeId");
	    action.setCallback(this, function(response) {
		    var state = response.getState();
    		if (state === "SUCCESS") 
            {
                var recTypeId = response.getReturnValue();
                var capOutput = component.get("v.pnrInformation");
                var localOutput = component.get("v.localCases");
    		
                var appEvent = $A.get("e.c:QAC_DataSharingEvent");
                appEvent.setParams({
                    "pnrInformation" : capOutput,
                    "recordTypeId" : recTypeId,
                    "localCases" : localOutput
                });
                appEvent.fire();
            }
        });
        $A.enqueueAction(action);        
    }
})