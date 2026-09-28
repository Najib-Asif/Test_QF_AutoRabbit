({
    doInit : function(component, event, helper) {
        var recID = component.get("v.recordId");
        var action = component.get("c.fetchEmailContent");
        action.setParams({
            "recId": recID,
        });
        
        action.setCallback(this, function(response) {
            console.log('return Value###', response.getReturnValue());
            component.set("v.emailBody",  response.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    onChange : function(component, event, helper) {
        var recID = component.get("v.recordId");
        var option =component.find('select').get('v.value');
        var action = component.get("c.fetchEmailContent");
        action.setParams({
            "recId": recID,
            "emailtemplateType":  option
        });
        
        action.setCallback(this, function(response) {
            console.log('return Value###', response.getReturnValue());
            component.set("v.emailBody",  response.getReturnValue());
        });
        
        $A.enqueueAction(action);
    }
})