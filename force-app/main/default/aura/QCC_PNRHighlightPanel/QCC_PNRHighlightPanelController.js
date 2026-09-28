({
    getButtonDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value1111###',params.isContactPage);
        console.log('Param Value2222###',params.isDisable);
        component.set("v.isContactPage", params.isContactPage);
        component.set("v.isShowButton", params.isDisable);
    },
    createCase : function(component, event, helper) {
        console.log('Inside Create Case',component.getEvent("createCaseEvent"));
        var myEvent = component.getEvent("createCaseEvent");
        myEvent.fire();
    },
    
    addtoCase : function(component, event, helper){
        console.log('Inside Add Case',component.getEvent("addToCaseEvent"));
        var myEvent = component.getEvent("addToCaseEvent");
        myEvent.fire();
    },
    //Added for ADT-23 
    redirectToARD : function(component, event, helper){
        var currUrl = component.get("v.ardURL");
        helper.gotoURL(currUrl);
    },
    doInit : function(component, event, helper){
        helper.getUrl(component);
    }
    //end for ADT-23
})