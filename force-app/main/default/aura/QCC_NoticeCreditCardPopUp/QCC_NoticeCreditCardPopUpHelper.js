({
    getHasCreditCardvalue : function(component, event, helper){
    
        console.log("*******");
        console.log("*******");
        console.log("*******");
        var action = component.get("c.hasCreditCard");    
        console.log("*******",component.get("v.recordId"));
        var caseRecordId = component.get("v.recordId");
        action.setParams({ caseId : caseRecordId }); 
      
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log("*******#####");
            if (state === "SUCCESS") {
                 console.log("#####");
                console.log("%%%%%%%%%%%: ",response.getReturnValue());
                console.log("%%%%%%%%%%%: ");
                var hasCredit = response.getReturnValue();
                console.log("%%%%%%%%%%%: ",hasCredit);
                 console.log("#####");
				//component.set("v.isOpen",hasCredit);
				// toast function
                if(hasCredit){
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                title: "Informative Message",
                message: "This case description contains masked credit card details",
                type: "warning"
              
            });
        toastEvent.fire();
                }
            }else{
               console.log("##### Fail"); 
            }
            
        });
        $A.enqueueAction(action);	
	},
})