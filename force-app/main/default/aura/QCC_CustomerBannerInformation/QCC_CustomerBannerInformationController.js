({
    doInit : function(component, event, helper) {        
        console.log('line #1');
        helper.checkProfiles(component, event, helper);        
        var recID = component.get("v.recordId");
        console.log('rrrrrrrrrrrrrrrrrrrrrrrrr',recID);        
        if(recID.startsWith("003")){
            component.set("v.onContact", true);
        }
        //This will show the Create Recovery,Escalate button and Email Button, and Start Work and Resolved Case buttons on Case Page only.
        if(recID.startsWith("500")){
            component.set("v.onCase", true);
            //13-Feb-2020  GRAPHITE-1748 | Added switch for "Start Work" & "Resolve Case" Case Actions
            helper.checkButtonSwitch(component);
        }
        helper.getContact(component, true);        
        //helper.getCaseSummary(component, true);
        
        //Get Case details if the record is a Case
        if(recID.startsWith("500")){
            helper.getCaseStatus(component);
            helper.getCaseOwner(component);
            helper.getCaseRecordType(component);
        }

        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log(userId);

        var action = component.get("c.isConsultant");
        action.setParams({
            "userId": userId
        });
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("State of isConsultant call ",state);
            if(state === "SUCCESS"){
                var isConsultant = response.getReturnValue();
                component.set("v.isConsultant", isConsultant);
                console.log("In Consultant ", isConsultant);
            }else if (state === "ERROR") {
                var errorMsg = response.getError();;
                console.log(errorMsg);
                var error = "Error";
            } else if (state === "INCOMPLETE") {
                var errorMsg = "No resonse from server";
                console.log(errorMsg);
                var error = "Error";
            }
        }); 
        $A.enqueueAction(action);
                
    },
    
    doOnChange : function(component, event, helper) {
        //helper.getContact(component, false);
        console.log("doOnChange");
        $A.enqueueAction(component.get('c.doInit'));
        //helper.getCaseStatus(component);
    },

    displayPassenger : function(component, event, helper) {
        var modalBody;
        
        $A.createComponents([
            ["c:QCC_DisplayPAX",{"recordId": component.get("v.recordId")}],
        ],
            function(components, status){
                if (status === "SUCCESS") {
                    modalBody = components[0]; 
                    component.find('overlayPassenger').showCustomModal({
                        header: "Passenger List",
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "my-modal,my-custom-class,my-other-class"
                    }).then(function (overlay) {
                        modalBody.set('v.overlayPassenger', overlay);
                    });
                }
            });
    },
            
    handleRecordUpdate: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            //$A.get('e.force:refreshView').fire();
        }
        if(eventParams.changeType === "CHANGED") {

            $A.get('e.force:refreshView').fire();
        }
    },
    /*sendDatatoChild: function(component, event) {
        var contactInfo = event.getParam("value");
        console.log("In render Method", contactInfo);
        var custComp = component.find("customerComponet");
        custComp.contactMethod(contactInfo.objContact); 
        var ffComp = component.find("FFComponet");
        ffComp.ffMethod(contactInfo.objContact); 
        var caseComp = component.find("CaseComponet");
        caseComp.caseMethod(contactInfo); 
    },*/
})