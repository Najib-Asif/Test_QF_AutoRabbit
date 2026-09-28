({
    doInit : function(component, event, helper){
        var action = component.get("c.getPayRecord");
        
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));  
        
        action.setCallback(this, function(response) {
            var output = response.getReturnValue();
            
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.existingSP",output);
            } 
        });
        $A.enqueueAction(action);
    },
    doPay : function(component, event, helper) {
        
        var action = component.get("c.ValidatePayment");
        
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));
        
        action.setCallback(this, function(response) {
            var output = response.getReturnValue();
            console.log('output :'+JSON.stringify(output));
            
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS" && output)
            {
                //$A.get("e.force:closeQuickAction").fire();
                helper.displayToast(output.isSuccess, output.isSuccess, output.msg, 3000);                
                $A.get('e.force:refreshView').fire();
            } else if (state == "ERROR") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    // Did not catch on the Server Side
                    helper.displayToast('error', 'Exception Found', errors[0].message, 3000);                
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    refresh : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
    },
    toggleMenu : function(component, event, helper) {
        component.set("v.menuSwitch", !component.get("v.menuSwitch"));   
    },
    editValue : function(component, event, helper){ 
        component.set("v.editFields", !component.get("v.editFields"));
        console.log("editfieldvalue1:" + component.get("v.editFields")); 
    },
    updateValue : function(component, event, helper){
        console.log("insideupdatevaluemethod");
        var payType;  
        var emdNum;  
        var ptCheck = component.find('editFormPtValue').get('v.value');
        var enCheck = component.find('editFormEnValue').get('v.value');
        
        var action = component.get("c.UpdatePayment");
        
        if(ptCheck != null && ptCheck != ''  ){
            if((ptCheck == 'Card' || ptCheck == 'EMD' ) && enCheck != null  ){
                
                action.setParams({
                    "caseId" : component.get("v.recordId"),
                    "payType" : component.find('editFormPtValue').get('v.value'),
                    "emdNum" : component.find('editFormEnValue').get('v.value')   
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state == "SUCCESS"){
                        component.set("v.editFields", !component.get("v.editFields"));
                        $A.get('e.force:refreshView').fire();
                    } 
                });  
            }
            else if(ptCheck == 'Credit'){
                action.setParams({
                    "caseId" : component.get("v.recordId"),
                    "payType" : component.find('editFormPtValue').get('v.value')    
                });
                action.setCallback(this, function(response) {
                    var output = response.getReturnValue();
                    var state = response.getState();
                    
                    if(state == "SUCCESS" ){
                        component.set("v.editFields", !component.get("v.editFields"));
                        $A.get('e.force:refreshView').fire();
                    } 
                    else if(state == "ERROR"){
                        var errors = response.getError();
                        if (errors[0] && errors[0].message) {
                            helper.displayToast('error', 'Exception Found', errors[0].message, 3000);                
                        }                        
                    }
                });                  
            }
                else{
                    helper.displayToast('Error', 'Mandatory field is missing', 'Please Select : EMD Number', 3000);  
                }  
        }
        else{
            helper.displayToast('Error', 'Mandatory field is missing', 'Please Select : Payment Type', 3000);  
        }
        $A.enqueueAction(action);  
    }
    
})