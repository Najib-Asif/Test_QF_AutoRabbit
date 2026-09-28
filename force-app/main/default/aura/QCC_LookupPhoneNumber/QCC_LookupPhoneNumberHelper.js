({
	  
    executeAction : function(component) {
        component.set("v.isLoading", true);
        var action = component.get("c.lookupCustomer");
        action.setParams({
            "ffNumber": component.get("v.ffNumber"),
            "PhNumber": component.get("v.PhNumber")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result=[];
                var res = response.getReturnValue();
                if(res !== null){
                    
                if(res[0] == "NameMismatch") {
                    result = res;
                } else {
                    for(var i=0;i<res.length;i++)
                    result.push(JSON.parse(res[i]));
                }
            }
                if(result != null && result != 'NameMismatch') {
                    component.set("v.displaySearchResults",true);
                    var caseId = component.get("v.recId");
                    if(caseId){
                        this.showCaseSearchModal(component, result);
                    }else{
                    	
                        component.set("v.currentList", result);
                        var cL = component.get("v.currentList");
                        
                    }
                } else {
                    this.showNotFoundModal(component, result);
                }
                
            } else if (state === "ERROR") {
                var errors = response.getError();    
                
            } else {
                
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
         
    saveContactClient:function(component , contact){
        
        if(contact.Id){
            var workspace = component.find("workspace");
            var lightningAppExternalEvent = $A.get("e.c:QCC_Search_Contact_LE_Integration");
            lightningAppExternalEvent.setParams({'data':contact});
            lightningAppExternalEvent.fire();
            workspace.openTab({
                recordId: contact.Id,
                focus: true
            });
            return null;
        }
        var action = component.get("c.saveIt");
        action.setParams({
            "contact": contact
        });
        action.setCallback(this, function(response){
            if(!response) {
                this.displayError(component ,  'Unexpected error' , 'Error' , '7000' , 'An unexpected error occurred. Please manually create the customer\'s profile');
            }
            if(response.getState() === "SUCCESS"){
                component.set("v.isOpen", false);
                var workspace = component.find("workspace");
                var record = response.getReturnValue();
                if(record){
                    if(record.Id){
                        var lightningAppExternalEvent = $A.get("e.c:QCC_Search_Contact_LE_Integration");
                        lightningAppExternalEvent.setParams({'data':record});
                        lightningAppExternalEvent.fire();
                        workspace.openTab({
                            recordId: record.Id,
                            focus: true

                        })
                    }else{
                        this.displayError(component ,  'Unexpected error' , 'Error' , '7000' , 'An unexpected error occurred. Please manually create the customer\'s profile');
                    }
                    
                }else{
                    this.displayError(component ,  'Unexpected error' , 'Error' , '7000' , 'An unexpected error occurred. Please manually create the customer\'s profile');
                }

            }else{
                this.displayError(component ,  'Unexpected error' , 'Error' , '7000' , 'An unexpected error occurred. Please manually create the customer\'s profile');
            }
        });
        $A.enqueueAction(action); 
    },    //navigate to contact

    displayError:function(component , title , type , duration , message){

        component.set("v.displaySearchResults", false);
        
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                "title": title,
                "type" : type,
                "duration" : duration,
                "message": message
            });
            toastEvent.fire();
        }else{
            component.set("v.message", message);
        }

        
        component.set("v.currentList", null);
        
        
        return;
    }
})