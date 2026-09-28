({
    getRelatedDocuments : function(component, event) {
        //component.set("v.caseId", "5000w000004yxGDAAY");
        //var urlParam = component.get("v.pageReference").state.c__caseId;
        this.showSpinner(component);
        var action = component.get("c.getRelatedDocs");
        //component.set("v.caseId", "Hello");
        /*action.setParams({
            recordId : component.get("v.recordId")
        });*/
        action.setParams({
            caseId : component.get("v.caseId")
        });
        /*action.setParams({
            caseId : urlParam
        });*/
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                console.log("SUCCESS");
                component.set('v.cdList', response.getReturnValue());
            }
            else if(state === "INCOMPLETE") 
            {
                console.log("INCOMPLETE");
            }
            else if(state === "ERROR")
            {
                console.log("ERROR");
                var errors = response.getError();
                if(errors)
                {
                    if (errors[0] && errors[0].message) 
                    {
                        console.log("Error message: " +  errors[0].message);
                    }
                }
                else
                {
                    console.log("Unknown error");
                }
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);        
    },
     
    deleteDoc : function(component, event, documentId) {
        this.showSpinner(component);
        var action = component.get("c.deleteDoc");
        action.setParams({ docId : documentId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var returnValue =response.getReturnValue();
                console.log('returnValue '+returnValue);
                //alert(returnValue);
                //Hide spinner
                this.hideSpinner(component);
                if(returnValue === true)
                {
                	//showToast
                    var toastSuccess = $A.get("e.force:showToast");
                    toastSuccess.setParams({
                        message: 'File was deleted.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success'
                    });
                    toastSuccess.fire();  
                }
                else if(returnValue === false)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message:'Failed to delete the file',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                    });
                    toastEvent.fire();
                }

            }
            else if(state === "INCOMPLETE") 
            {
                alert("Incomplete");
                console.log("INCOMPLETE");
            }
            else if(state === "ERROR")
            {
                alert("Error");
                var errors = response.getError();                
                if(errors){
                    if (errors[0] && errors[0].message) {
                        //alert("Error "+errors[0].message);
                        console.log("Error message: " +  errors[0].message);
                    }
                }else{
                    console.log("Unknown error");                  
                }                
            }
        });
        $A.enqueueAction(action);  
    },
     
    downloadDocument : function(component, event, docId) {
        var action = component.get("c.getDocURL");
        action.setParams({
            docId : docId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": response.getReturnValue()
                });
                urlEvent.fire();
            }else if(state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +  errors[0].message);
                    }
                }else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  
    },
        //Redirect To Case/EmailMessage Record
    viewFileDetails: function (component, event, docId) {
        //var recId = event.currentTarget.getAttribute("data-Id");
        //console.log('OKkk '+recId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": docId,
            "slideDevName": "Detail"
        });
        navEvt.fire();
    },
    editFileDetails : function(component, event, docId) {
    var editRecordEvent = $A.get("e.force:editRecord");
    editRecordEvent.setParams({
         "recordId": docId
   });
        //this.getRelatedDocuments(component, event);
    editRecordEvent.fire();
    $A.get("e.force:refreshView").fire();  
	},
    openModel: function(component, event, docId) {
        // Set isRemove attribute to true
        component.set("v.isRemove", true);
    },
    displayToast : function(component, event, docId) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: 'Content Document Link was deleted.',
            duration:' 5000',
            key: 'info_alt',
            type: 'success'
        });
        toastEvent.fire();
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})