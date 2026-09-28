({
    doInit: function (component, event, helper) {
        helper.getOrgWideAndCaseType(component);
        
        var action = component.get("c.userSessionId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retval = response.getReturnValue();
                component.set("v.sessionId", retval);
            }else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
        });
        
        var server = component.get("c.orgServerURLs");
        server.setCallback(this,function(response){
            var state2 = response.getState();
            if(state2 === "SUCCESS"){
                var retval2 = response.getReturnValue();
                component.set("v.serverUrl", retval2);
                
            }else if (state2 === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + errors[0].message);
                
            } else {
                console.log("Unknown error");
            }
            
        });
        
        var contactInfo = component.get("c.genericContactInfo");
        contactInfo.setCallback(this,function(response){
            var state3 = response.getState();
            if(state3 === "SUCCESS"){
                var retval3 = response.getReturnValue();
                component.set("v.contactId", retval3);
                
            }else if (state3 === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + errors[0].message);
                
            } else {
                console.log("Unknown error");
            }
            
        });

        var congaQueryInfo = component.get("c.getCongaQueryAffectedPassenger");
        congaQueryInfo.setCallback(this,function(response){
            var state4 = response.getState();
            if(state4 === "SUCCESS"){
                var retval4 = response.getReturnValue();
                component.set("v.affectedPassCongaQueryId", retval4);
                
            }else if (state4 === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + errors[0].message);
                
            } else {
                console.log("Unknown error");
            }
            
        });
        
        console.log('enqueueAction');
        $A.enqueueAction(action);
        $A.enqueueAction(server);
        $A.enqueueAction(contactInfo);
        $A.enqueueAction(congaQueryInfo);
        
        console.log('done Init');
    }, 
    /*requestInfo: function (component, event, helper) {
        
        var caseId               = component.get("v.recordId"); 
        var ContactId            = component.get("v.contactId");
        var CongaEmailTemplateId = component.get("v.caseF.Conga_Email_Template_ID__c");
        var CongaTemplateId      = component.get("v.caseF.Conga_Template_ID__c");
        var sessionId            = component.get("v.sessionId");
        var serverUrl            = component.get("v.serverUrl");
        var caseType             = component.get("v.caseF.Type");
        var caseGroup            = component.get("v.caseF.Group__c");
        var caseContactEmail     = component.get("v.caseF.Contact_Email__c");
        var OrgWideId 			 = component.get("v.OrgWideAddress");
        var refundType			 = component.get("v.caseF.Refund_Type__c");
        
        console.log("caseId: "+caseId);
        console.log("ContactId: "+ContactId);
        console.log("CongaEmailTemplateId: "+CongaEmailTemplateId);
        console.log("sessionId: "+sessionId);
        console.log("serverUrl: "+serverUrl);
        console.log("caseContactEmail: "+caseContactEmail);
        
        if(caseType == 'Insurance Letter' && caseGroup == 'Booking Cancelled by Customer' && refundType == null) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title"     : "Error!",
                "message"   : "Please select a refund type for this insurance letter.",
                "duration"  : 10,
                "type"      : "error"
            });
            resultsToast.fire();
        }
        else {
            var action = component.get("c.getCaseValues");
            
            action.setParams({
                "recId"     :caseId,
                "insType"   :caseType,
                "fromIntegration": false,
                "cs": null
                
            }); 
            
            action.setCallback(this, function(a) {
                
                var msg = a.getReturnValue();
                console.log('Return Value from Apex'+msg)
                //var arr = msg.split(",");
                //console.log('Array of return getCaseValues'+arr[0]+' to '+ arr[1]);
                if(msg == 'No'){
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title"     : "Validation Error!",
                        "message"   : "Some error has occured please check case chatter feed for more information.",
                        "duration"  : 10,
                        "type"      : "error"
                    });
                    resultsToast.fire(); 
                    $A.get('e.force:refreshView').fire();  
                }else{
                    var url = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl='+serverUrl+     
                        '&id='+caseId+
                        '&EmailToId='+ContactId+
                        '&EmailAdditionalTo='+caseContactEmail+
                        '&EmailRelatedToId='+caseId+
                        '&CongaEmailTemplateId='+CongaEmailTemplateId+
                        '&TemplateId='+CongaTemplateId+  
                        '&EmailTemplateAttachments=1'+
                        '&CongaEmailTemplateGroup=QCC_Insurance_Letters,Request_Information'+
                        '&TemplateGroup=QCC_Insurance_Letters'+
                        '&EmailFromId='+OrgWideId+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        '&MFTSValue0=true'+
                        '&LiveEditEnable=1'+
                        '&DefaultPDF=1'+
                        '&DS7=';
                    
                    console.log("URL: "+url);        
                    window.open(url,"", "width=800,height=600");   
                }
            });
            $A.enqueueAction(action);
        }
        
    },*/
    showEmailTemplateList: function(component, event, helper){
        console.log('call affected Passegner');
        var isRecType = component.get("v.RecType");

        //check if the Case record type is Insurance Letter
        if(isRecType != null && isRecType){
            var recId = component.get("v.recordId");
            console.log('record id = '+recId);
            var hasCaseAffectedPassenger = component.get("c.hasCaseAffectedPassenger");
            hasCaseAffectedPassenger.setParams({
                "caseRecId": recId
            });
            hasCaseAffectedPassenger.setCallback(this,function(response){
                var state5 = response.getState();
                if(state5 === "SUCCESS"){
                    var retval5 = response.getReturnValue();
                    console.log('hasAffectedPassenger: '+ retval5);
                    //only perform when there's passenger
                    if(retval5){

                        var caseType             = component.get("v.caseF.Type");
                        var caseGroup            = component.get("v.caseF.Group__c");
                        var refundType           = component.get("v.caseF.Refund_Type__c");

                        if(caseType == 'Insurance Letter' && caseGroup == 'Booking Cancelled by Customer' && refundType == null) {
                            helper.displayToastMessage("error","Error!", "Please select a refund type for this insurance letter.", 10);
                        }else{ 
                            helper.getEmailTemplates(component);
                        }

                    }else{
                        helper.displayToastMessage('error',"There's no Passenger", "Case has no passenger", 10);
                    }
                    
                }else if (state5 === "ERROR") {
                    var errors = response.getError();
                    console.log("Error message: " + errors[0].message);
                    
                } else {
                    console.log("Unknown error");
                }
                
            });
            $A.enqueueAction(hasCaseAffectedPassenger);
        }else{

            var caseType             = component.get("v.caseF.Type");
            var caseGroup            = component.get("v.caseF.Group__c");
            var refundType           = component.get("v.caseF.Refund_Type__c");

            if(caseType == 'Insurance Letter' && caseGroup == 'Booking Cancelled by Customer' && refundType == null) {
                helper.displayToastMessage("error","Error!", "Please select a refund type for this insurance letter.", 10);
            }else{ 
                helper.getEmailTemplates(component);
            }
            
        }

        // var caseType             = component.get("v.caseF.Type");
        // var caseGroup            = component.get("v.caseF.Group__c");
        // var refundType           = component.get("v.caseF.Refund_Type__c");

        // if(caseType == 'Insurance Letter' && caseGroup == 'Booking Cancelled by Customer' && refundType == null) {
        //     var resultsToast = $A.get("e.force:showToast");
        //     resultsToast.setParams({
        //         "title"     : "Error!",
        //         "message"   : "Please select a refund type for this insurance letter.",
        //         "duration"  : 10,
        //         "type"      : "error"
        //     });
        //     resultsToast.fire();
        // }else{ 
        //     helper.getEmailTemplates(component);
        // }
    },
    selectEmailTemplate : function(component, event, helper){ 
        if(event !== undefined && event.getParam("emailTemplateName") !== undefined){
            component.set("v.emailTemplateName", event.getParam("emailTemplateName"));
            component.set("v.sfEmailTemplateName", event.getParam("sfEmailTemplateName")); 
            var eventCaseId  = event.getParam("caseId"); 
            var caseId       = component.get("v.caseF.Id");
            if(eventCaseId === caseId){
                helper.getSfEmailTemplateId(component);
            }         
        }        
    },
    selectManualInsuranceLetter : function(component, event, helper){
        console.log('selectManualInsuranceLetter');
        var isRecType = component.get("v.RecType");

        //check if the Case record type is Insurance Letter
        if(isRecType != null && isRecType){
            var recId = component.get("v.recordId");
            console.log('record id = '+recId);
            var hasCaseAffectedPassenger = component.get("c.hasCaseAffectedPassenger");
            console.log('record id 2 = '+recId);
            hasCaseAffectedPassenger.setParams({
                "caseRecId": recId
            });
            console.log('record id 3 = '+recId);
            hasCaseAffectedPassenger.setCallback(this,function(response){
                var state5 = response.getState();
                if(state5 === "SUCCESS"){
                    var retval5 = response.getReturnValue();
                    console.log('hasAffectedPassenger: '+ retval5);
                    //only perform when there's passenger
                    if(retval5){

                        component.set("v.sfEmailTemplateName", "Insurance Letter");
                        helper.getSfEmailTemplateId(component, true);

                    }else{
                        helper.displayToastMessage('error',"There's no Passenger", "Case has no passenger", 10);
                    }
                    
                }else if (state5 === "ERROR") {
                    var errors = response.getError();
                    console.log("Error message: " + errors[0].message);
                    
                } else {
                    console.log("Unknown error");
                }
                
            });
            $A.enqueueAction(hasCaseAffectedPassenger);
        }else{
            component.set("v.sfEmailTemplateName", "Insurance Letter");
            helper.getSfEmailTemplateId(component, true);
        }
        
        
        // component.set("v.sfEmailTemplateName", "Insurance Letter");
        // helper.getSfEmailTemplateId(component, true);     
    }
})