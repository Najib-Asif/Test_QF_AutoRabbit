({
    getContact : function(component, onPageLoad) {
        var recID = component.get("v.recordId");
        console.log(recID);
        var action = component.get("c.fetchCustomerDetail");
        action.setParams({
            "recId": recID,
            "isPageLoad": onPageLoad
        });   
        action.setCallback(this, function(response) {
            this.doLayout(response, component);
        });


        var action1 = component.get("c.fetchCaseSummary");
        action1.setParams({
            "recId": recID
        });
        
        action1.setCallback(this, function(response) {
            this.doCaseLayout(response, component);
        });
        $A.enqueueAction(action1); 
        $A.enqueueAction(action);       
    },
    
    doLayout: function(response, component) {
        var state = response.getState();
        //console.log("State####",state);
        if(state === "SUCCESS"){
            var contactInfo = response.getReturnValue();
            //this condition will check whether there is a Contact present on the Case or not if yes Contact Banner will be rendered
            //Otherwise it will be Hidden
            console.log('!!Contact Response recvd: '+JSON.stringify(contactInfo));
            if(contactInfo != null){
                component.set("v.objCon", contactInfo);
                //console.log("In render Method", contactInfo);
                var custComp = component.find("customerComponet");
                //QDCUSCON-4985 - Start
                //only Name from Case if the component is on Case.
                if(component.get('v.onCase')){
                    contactInfo.objContact.Name = contactInfo.objContact.FirstName+' '+contactInfo.objContact.LastName;
                }
                //QDCUSCON-4985 - End
                custComp.contactMethod(contactInfo.objContact); 
                console.log('hhhhhhhhhhh',contactInfo.objContact);
                console.log('hhhhhhhh111',contactInfo.lstOtherProducts);
                var ffComp = component.find("FFComponet");
                ffComp.ffMethod(contactInfo.objContact, contactInfo.lstOtherProducts ); 
                //var caseComp = component.find("CaseComponet");
                //caseComp.caseMethod(contactInfo); 
                if(! component.get('v.useFlow') ){
                    var casecreateComp = component.find("CaseCreateComponet");
                    casecreateComp.contactInfo(contactInfo.objContact);
                }
                // if permission is set then this will enable the case creation flow which relaies on contact details being present
                // hence this invocation is placed after the  contact data has been retrieved.
                this.checkPermission(component, event);        
                component.set("v.isContactPresent", true);
            } else {
                component.set("v.isContactPresent", false);
            }
        }else if (state === "ERROR") {
            var errorMsg = response.getError();;
            console.log(errorMsg);
            var error = "Error";
        } else if (state === "INCOMPLETE") {
            var errorMsg = "No resonse from server";
            console.log(errorMsg);
            var error = "Error";
        }
    },
    
    doCaseLayout: function(response, component) {
        var state = response.getState();
        if(state === "SUCCESS"){
            var contactInfo = response.getReturnValue();
            if(contactInfo != null){
                //QDCUSCON-4985 - Start
                //only Name from Case if the component is on Case.
                if(component.get('v.onCase') && contactInfo.objContact != null 
                    && contactInfo.objContact.Frequent_Flyer_Tier__c == 'Non-tiered'){
                    contactInfo.caseCount = 'N/A';
                    contactInfo.disruptionsCount = 'N/A';
                }
                //QDCUSCON-4985 - End
                var caseComp = component.find("CaseComponet");
                caseComp.caseMethod(contactInfo); 
            }
        }else if (state === "ERROR") {
            var errorMsg = response.getError();;
            var error = "Error";
        } else if (state === "INCOMPLETE") {
            var errorMsg = "No resonse from server";
            var error = "Error";
        }
    },
    
    getCaseStatus: function(component) {
        var action = component.get("c.isCaseClosed");
        var recID = component.get("v.recordId");
        if(recID.startsWith("500"))
        {
            action.setParams({
                "recId": recID
            });
            console.log("check case status");
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("State of isCaseClosed call ",state);

                // 11-Nov-2019	GRAPHITE-1151 | "Start Work" & "Resolve Case" Case Actions
                if(state === "SUCCESS"){
                    var caseStatus = response.getReturnValue();
                    console.log("###caseStatus",caseStatus);
                    component.set("v.caseStatus", caseStatus);
                    if (caseStatus == 'Closed'){
                        component.set("v.isCaseClosed", true);
                    }
                    else {
                        component.set("v.isCaseClosed", false);
                    }
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
        }
    },
    
    getCaseRecordType: function(component) {
        var action = component.get("c.caseRecordType");
        var recID = component.get("v.recordId");
        if(recID.startsWith("500"))
        {
            action.setParams({
                "recId": recID
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("State of caseRecordType call ",state);
                if(state === "SUCCESS"){
                    var caseRecordType = response.getReturnValue();
                    component.set("v.isInsuranceLetterCase", caseRecordType == "CCC Insurance Letter Case");
                    component.set("v.isBaggageCase", caseRecordType === "CCC Baggage");
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
        }
    },
    
    getCaseOwner: function(component) {
        var action = component.get("c.isCaseInQueue");
        var recID = component.get("v.recordId");
        if(recID.startsWith("500"))
        {
            action.setParams({
                "recId": recID
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("State of isCaseInQueue call ",state);
                if(state === "SUCCESS"){
                    var isCaseInQueue = response.getReturnValue();
                    console.log("State of isCaseInQueue getReturnValue " + response.getReturnValue());
                    component.set("v.isCaseInQueue", isCaseInQueue);                
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
        }
    },
    /*checkProfile: function(event){
                            var userId = $A.get("$SObjectType.CurrentUser.Id");
                            component.set("v.userId", userId );
                        }*/
    
    checkProfiles: function(component, event, helper){      
        var action = component.get("c.getProfileToHideForContact");        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS") {               
                var pflResult = response.getReturnValue();                
                if(pflResult == true){                   
                    component.set("v.showToProfiles", false);                     
                }
               
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);        
    },

    checkPermission: function(component, event){   
        
        var action = component.get("c.userHasCustomPermission");
        action.setParams({
            "customPermission": component.get("v.flowCustomPermission")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("State of userHasCustomPermission call ",state);
            if(state === "SUCCESS"){
                var hasCustomPermission = response.getReturnValue();
                console.log("### QCC_CustomerInformation - hasCustomPermission : " + JSON.stringify(component.get("v.objCon")));

                component.set("v.useFlow", hasCustomPermission);
                console.log("### QCC_CustomerInformation - hasCustomPermission : " + hasCustomPermission);
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
    //13-Feb-2020  GRAPHITE-1748 | Added switch for "Start Work" & "Resolve Case" Case Actions
    checkButtonSwitch: function(component, event, helper){
        var recID = component.get("v.recordId");
        var action = component.get("c.getSwitchforStartWorkandResolveCase");
        action.setParams({"recId": recID});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log("###switch response: " + response);
                if(response == true){
                    component.set("v.displayStartandResolve", true);
                }
                else if(response == false){
                    component.set("v.displayStartandResolve", false);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
            console.log("###v.displayStartandResolve: " + component.get("v.displayStartandResolve"));
        });
        $A.enqueueAction(action);
    },
})