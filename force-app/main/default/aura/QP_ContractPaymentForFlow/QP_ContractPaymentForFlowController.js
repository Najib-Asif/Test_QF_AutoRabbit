({
    doInit : function(component, event, helper){
        
        console.log('inside doInit');
        console.log('Contract Id?'+ component.get("v.FileRecordId"));
        var docId = component.get("v.contentDocumentRecId");
        
        if(component.get("v.FileRecordId"))
        {
            var message = 'Records Creation Successful. Please upload Contract File';
            
            component.set("v.confirmSuccess", true);
            component.set("v.successMessage", message);
            
            /*var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: message,
                type: "success"
            });
            toastEvent.fire(); */                   
        }
        if(component.get("v.FileRecordId") && (docId == '' || docId == null))
        {
            var message = 'No Files attached. Please review!';
            var fileId = component.find("fileId");
            var fileerrorNoteText = component.find("fileErr");
            $A.util.addClass(fileId,'slds-has-error');
            $A.util.addClass(fileerrorNoteText,'errorNoteClass');
            $A.util.removeClass(fileerrorNoteText,'none');
            setTimeout($A.getCallback(function(){
                document.getElementById("fileErr").focus();
                component.set("v.showSpinner", false);
            }),1000);
            
            /*var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: message,
                type: "error"
            });
            toastEvent.fire();*/
        }
    },
    handleOnChange : function(component, event, helper) {
        component.set("v.selectedRecordId",event.getParams("fields").value);
    },
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    UploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files");  
        //var fileName = uploadedFiles[0].name; 
        console.log('FILE SIZE**'+uploadedFiles.length);
        
        var errorfound = false;
        if(uploadedFiles.length > 0)
        {
            var strFileNames = '';
            
            // getting uploaded file names
            for(var i=0; i<uploadedFiles.length; i++) {
                strFileNames += uploadedFiles[i].name + ", ";
            }
            var documentId = uploadedFiles[0].documentId;
            component.set("v.contentDocumentRecId", documentId);
            component.set("v.fileName",uploadedFiles[0].name);
            
            // Showing Success message
            component.find("notifLib").showToast({
                "variant": "success",
                "title": "File Upload Successful",
                "message": uploadedFiles[0].name + " Uploaded Successfully!"
            });
            component.find("fileId").set("v.disabled",true);
            //$A.get("e.force:refreshView").fire();
        }
    },
    handleConfirm : function(component, event, helper)
    {
        // Do final validations here if any additional logic needs to be checked
        // For now I have validated only Lookup
        
        component.set("v.showSpinner", true);
        var action1 = component.get("c.contractCheck");
        action1.setParams({
            accountId : component.get("v.accountId"),
            contType : component.get("v.contType"),
            startDate : component.get("v.startDate"),
            endDate : component.get("v.endDate") });
        action1.setCallback(this, function(response1) { 
            var state1 = response1.getState();
            if(state1 == "SUCCESS") {
                var output1 = response1.getReturnValue();
                if(output1 == true) {
                    var action = component.get("c.createRecord");
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        var output = response.getReturnValue();
                        console.log('output contract**'+ JSON.stringify(output));
                        if(output && component.isValid() && state == "SUCCESS")
                        {
                            var message = 'Validation successful. Please click the Next button';
                            
                            component.set("v.opptyRTId", output.opptyRTId);
                            component.set("v.quoteRTId", output.quoteRTId);
                            component.set("v.cpIncentiveRTId", output.cpIncentiveRTId);
                            component.set("v.cpTechFundRTId", output.cpTechFundRTId);
                            component.set("v.showSpinner", false);
                            
                            component.set("v.confirmSuccess", true);
                            component.set("v.successMessage", message);
                            
                            component.find("notifLib").showToast({
                                "variant": "success",
                                "title": "Validation Successful",
                                "message": message
                            });
                        } 
                    });
                    $A.enqueueAction(action);
                }
                else {
                    component.set("v.showSpinner", false);
                    component.find("notifLib").showToast({
                        "variant": "error",
                        "title": "Validation Failed",
                        "message": "A contract already exists for this period. Please select a different period or a different Contract Type"
                    });                   
                }
            }
        });
        $A.enqueueAction(action1);
    },
    
    removeFile : function(component, event)
    {
        var action = component.get("c.deleteFile");
        action.setParams({
            "fileId": component.get("v.contentDocumentRecId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.contentDocumentRecId", null);
                component.set("v.fileName",null);
                component.find("fileId").set("v.disabled",false);
            }
            else {
                component.find("notifLib").showToast({
                    "variant": "error",
                    "title": "File Deletion error",
                    "message": "Could not delete file"
                });
            }
        })
        $A.enqueueAction(action);
        
    },
    
    handleStatusChange : function (component, event) 
    {
        console.log('Flow started**');
        
        if(event.getParam("status") === "FINISHED"){
            console.log('Running');
            var outputVariables = event.getParam("outputVariables");
            console.log(outputVariables) ;
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if(outputVar.name === "createdContractId") {
                    console.log('File Record Id **'+outputVar.value);
                    component.set("v.FileRecordId", outputVar.value);
                }  
            }
        }        
    } 
    
})