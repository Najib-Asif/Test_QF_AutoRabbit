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
                //var custComp = component.find("customerComponet");
                //QDCUSCON-4985 - Start
                //only Name from Case if the component is on Case.
                /*if(component.get('v.onCase')){
                    contactInfo.objContact.Name = contactInfo.objContact.FirstName+' '+contactInfo.objContact.LastName;
                }*/
                //QDCUSCON-4985 - End
                //custComp.contactMethod(contactInfo.objContact); 
                console.log('hhhhhhhhhhh',contactInfo.objContact);
                console.log('hhhhhhhh111',contactInfo.lstOtherProducts);
                //var ffComp = component.find("FFComponet");
                //ffComp.ffMethod(contactInfo.objContact, contactInfo.lstOtherProducts ); 
                //var caseComp = component.find("CaseComponet");
                //caseComp.caseMethod(contactInfo); 
                /*if(! component.get('v.useFlow') ){
                    var casecreateComp = component.find("CaseCreateComponet");
                    casecreateComp.contactInfo(contactInfo.objContact);
                }
                // if permission is set then this will enable the case creation flow which relaies on contact details being present
                // hence this invocation is placed after the  contact data has been retrieved.
                this.checkPermission(component, event);*/        
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
    }
})