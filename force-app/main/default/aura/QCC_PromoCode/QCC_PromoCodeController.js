({
    doInit : function(component, event, helper) {  
          
        var recID = component.get("v.recordId");
        console.log('===promocode doinit()====recID===',recID);        
        /*if(recID.startsWith("003")){
            //component.set("v.onContact", true);
            console.log('===promocode doinit()====contact===');      
        }
        if(recID.startsWith("500")){
            //component.set("v.onCase", true);
            console.log('===promocode doinit()====case===');
        }
        helper.getContact(component, true);  
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('===promocode doinit()==userId==' + userId);
*/
        var action = component.get("c.getPromotions");
        action.setParams({
            "recordSFId": recID
        });
        
        action.setCallback(this, function(response) {
			var state = response.getState();
			
            console.log('getPromotions() response state is: ' + state);
            if(state === "SUCCESS"){
				console.log('getPromotions() response is: ' +  response.getReturnValue());
                component.set("v.promodetails",response.getReturnValue()); 
            }else if (state === "ERROR") {
                var errorMsg = response.getError();
                console.log(errorMsg);
            } else if (state === "INCOMPLETE") {
                var errorMsg = "No resonse from getPromotions()";
                console.log(errorMsg);
                var error = "Error";
            }
        });
		$A.enqueueAction(action);
                
    },
})