({
    doInit : function(component, event, helper) {
        helper.getObjectType(component);
        helper.getPicklistMap(component);
        helper.getFieldMap(component);
        /*helper.getFares(component);*/
        helper.getSpecialConditions(component);
    },
    tileSelected : function(component, event, helper) {
        var typeSelected = event.getSource().get("v.value");
        component.set("v.selectedType",typeSelected);
        var fields = component.get("v.fieldMap")[typeSelected];
        var fieldList = fields.split(",");
        component.set("v.fields",fieldList);
    },
    handleSuccess : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Record Created",
            "message": "Record ID: " + event.getParam("id")
        });
    },
    onLoad : function(component, event, helper) {
        var fields = event.getParam("fields");
        fields["origin__c"] = component.get("v.origin");
    },
    fareChange : function(component,event,helper) {
        var newValue = event.getParam("value");
        component.set("v.selectedFare", newValue);
    },
    cabinChange : function(component, event, helper) {
        var newValue = event.getParam("value");
        component.set("v.selectedCabin", newValue);
    },
    handleRefresh : function(component, event, helper) {
        helper.getSpecialConditions(component);
    },
    handleInputText : function(component, event, helper)
    {  
        var evtED = event.getParam("enabledisable");
        var evtOD = event.getParam("origindestination");
        switch(evtOD)
        {
            case "Origin":
                component.set("v.originEnDiP",evtOD);
                component.set("v.setBoolO",evtED);
                break;
            case "Destination":
                component.set("v.destinationEnDiP",evtOD);
                component.set("v.setBoolD",evtED);
                break;
        }
    },
})
//<!-- Controller  --><!-- Controller  -->