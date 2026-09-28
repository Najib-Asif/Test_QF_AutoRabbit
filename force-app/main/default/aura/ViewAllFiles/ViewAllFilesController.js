({
    //Get Related Docs
    doInit : function(component, event, helper) {       
        //var myPageRef = component.get("v.pageReference");
        //var id = myPageRef.state.c__caseId;       
        //component.set("v.caseId", id); 
        //cmp.set("v.caseId", caseId);
        //component.set("v.caseId", thecaseId);
        //console.log(component.get("v.pageReference").state.caseId);
        document.title = "Files | Salesforce";
        //console.log(component.get("v.pageReference").state.c__caseId);
        //component.set("v.caseId", component.get("v.pageReference").state.c__caseId);
        component.set("v.caseId", component.get("v.recordId"));
        //var theParam = component.get("v.pageReference").state.c__caseId;
        //console.log(theParam);
        helper.getRelatedDocuments(component, event); 
    },
     
    //Redirect To User Record
    handleRedirectToUserRecord: function (component, event, helper) {
        var recordId = event.currentTarget.getAttribute("data-Id");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "Detail"
        });
        navEvt.fire();
    },
    //Redirect To Case/EmailMessage Record
    handleRedirectToRecord: function (component, event, helper) {
        var recId = event.currentTarget.getAttribute("data-Id");
        console.log('OKkk '+recId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId,
            "slideDevName": "Detail"
        });
        navEvt.fire();
    },
     
    //Preview Selected File
    handleSelectedDocPreview : function(component,event,helper){ 
        $A.get('e.lightning:openFiles').fire({
            recordIds: [event.currentTarget.getAttribute("data-Id")]
        });
    },
     
    //Handle Selected Action
    handleSelectedAction: function(component, event, helper) {
        var docId = event.getSource().get("v.value");
        var selectedMenuValue = event.detail.menuItem.get("v.value");
        switch(selectedMenuValue) {
            case "Delete":
                component.set("v.docConId", docId);
                component.set("v.isDelete", "true");
                //helper.deleteDocument(component, event, docId);
                break;
            case "Download":
                helper.downloadDocument(component, event, docId);
                break;
            case "View":
                helper.viewFileDetails(component, event, docId);
                break;
            case "Edit":
                helper.editFileDetails(component, event, docId);
                break;
            case "Remove":
                //helper.editFileDetails(component, event, docId);
                component.set("v.docConId", docId);
                helper.openModel(component, event, docId);
                break;
        }
    },
    
    deleteDocument: function(component, event, helper) {
        component.set("v.isDelete", "false");
        component.set("v.isRemove", "false");
        var docId = component.get("v.docConId");
        //alert(docId);
        helper.deleteDoc(component, event, docId);
    },
    
    closeDeleteModel: function(component, event, helper) {
        // Set isRemove attribute to false  
        component.set("v.isRemove", false);
        component.set("v.isDelete", false);
    },

    viewAllFiles: function(component, event, helper) {
        // Set isRemove attribute to false  
        component.set("v.isModalOpen", true);
        component.set("v.isRemove", false);
        component.set("v.isDelete", false);
    },

    closeAllFiles: function(component, event, helper) {
        // Set isRemove attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.isRemove", false);
        component.set("v.isDelete", false);
    },
    
    removeFromRecord: function(component, event, helper) {
        // Set isRemove attribute to false
        //Add code to call apex method or do some processing
        //component.set("v.isRemove", false);
        /*component.set("v.isRemove", true);
        let docConId = component.get("v.docConId");
        console.log('docConId==> '+docConId);
        var action = component.get("c.removeFromRecord");
        //action.setParams({docId : docConId});
        action.setCallback(this, function(response) 
		{ 
            var state = response.getState();
            if (state === "SUCCESS") 
            {               
                var returnValue =response.getReturnValue();
                console.log('returnValue '+returnValue);
                //component.set("v.msg", returnValue );
            }
            else if (state === "INCOMPLETE") {
                // do something
                console.log('INcomplete ');
            }
            else if (state === "ERROR") {
                console.log('Error ');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  */
        component.set("v.isRemove", false);
        let docConId = component.get("v.docConId");
        var action = component.get("c.removeRecord"); 
        action.setParams({docId : docConId});
        action.setCallback(this, function(response) 
        {        
        	var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() === true)
                {
                	helper.displayToast();
                    //helper.getRelatedDocuments(component, event);    
                }
                else if(response.getReturnValue() === false)
                {
                 	alert('Cannot remove record');   
                }
            }
        });        
        $A.enqueueAction(action);        
    }
})