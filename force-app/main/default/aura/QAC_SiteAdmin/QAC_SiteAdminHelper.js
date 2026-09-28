({
    runControllerMethods : function(component,event,action,buttonName) 
    {
        action.setParams({
            "strIATA" : component.get("v.strIATA")
        });
        
        action.setCallback(this,function(data){
            component.set("v.showSpinner", false);
            
            //get the response state
            var state = data.getState();
            // get return value from controller
            var output = data.getReturnValue();
            component.set("v.buttonName",buttonName);
            console.log("output**"+JSON.stringify(output));
            
            //check if result is successful
            if(state == "SUCCESS")
            {
                if(output)
                {
                    if(output.accDetails != null)
                    {
                        component.set("v.messageError", false);
                        component.set("v.message",null);
                        component.set("v.sfAccount", output.accDetails);
                        
                        /*if((!$A.util.isEmpty(output.accDetails.Email__c)) && output.accDetails.Tradesite__c && output.accDetails.Active__c){
                            component.set("v.isDisabled",false);                        
                        }*/
						
						if((!$A.util.isEmpty(output.accDetails.Email__c)) && output.accDetails.Active__c){
                            component.set("v.isDisabled",false);                        
                        }
                        else{
                            component.set("v.isDisabled",true);                                                    
                        }
                        
                        // Do this for Account Div to be visible
                        var accInfoDiv = component.find("accInfoDiv");
                        $A.util.removeClass(accInfoDiv,'toggle');
                        
                        // Do this for Button Div to be visible
                        var buttonDiv = component.find("buttonDiv");
                        $A.util.removeClass(buttonDiv,'toggle');
                        
                        // Do this for LDAP Div to be hidden
                        var LDAPInfoDiv = component.find("LDAPInfoDiv");
                        $A.util.addClass(LDAPInfoDiv,'toggle');
                        
                        var activeSections = ['A'];
                        component.set("v.activeSections", activeSections);                    
                    }
                    else{
                        console.log("no account**");
                        component.set("v.messageError", true);
                        component.set("v.message","Account not found in SALESFORCE");
                        
                        // Do this for Account Div to be hidden
                        var accInfoDiv = component.find("accInfoDiv");
                        $A.util.addClass(accInfoDiv,'toggle');
                        
                        // Do this for Button Div to be hidden
                        var buttonDiv = component.find("buttonDiv");
                        $A.util.addClass(buttonDiv,'toggle');
                        
                        // Do this for LDAP Div to be visible
                        var LDAPInfoDiv = component.find("LDAPInfoDiv");
                        $A.util.addClass(LDAPInfoDiv,'toggle');
                    }
                    
                    if(output.ldapDetails != null){
                        
                        if(output.ldapResponse.split('_')[0] == 'Pass'){
                            component.set("v.messageError", false);
                            component.set("v.message",null);
                        }
                        
                        component.set("v.LSite",output.ldapDetails);
                        
                        // Do this for LDAP Div to be visible
                        var LDAPInfoDiv = component.find("LDAPInfoDiv");
                        $A.util.removeClass(LDAPInfoDiv,'toggle');
                        
                        // Do this for Account Div to be visible
                        var accInfoDiv = component.find("accInfoDiv");
                        $A.util.removeClass(accInfoDiv,'toggle');
                        
                        // Do this for Button Div to be visible
                        var buttonDiv = component.find("buttonDiv");
                        $A.util.removeClass(buttonDiv,'toggle');
                        
                        var activeSections = ['A','B'];
                        component.set("v.activeSections", activeSections);   
                        
                        if(output.ldapResponse == 'Fail_SetAsMessage'){
                            component.set("v.messageError", true);
                            component.set("v.message",output.ldapDetails.sfMessage);
                            
                            // Do this for LDAP Div to be visible
                            var LDAPInfoDiv = component.find("LDAPInfoDiv");
                            $A.util.addClass(LDAPInfoDiv,'toggle');
                        }
                    }
                }
            } 
            else if(state == "ERROR"){
                console.log('Exception'+output);
            }
        });
        $A.enqueueAction(action);        
    }
})