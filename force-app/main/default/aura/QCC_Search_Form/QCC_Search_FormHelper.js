/**
**********************************************************************************************
Author:        Capgemini
Company:       Capgemini
Description:   QCC Customer search form client controller Helper
     
************************************************************************************************
History
************************************************************************************************
Oct-2017      Cyrille Jeufo               Initial Design
**********************************************************************************************/
({

    createContact: function(component, contact) {
        var action = component.get("c.saveContact");
        var caseId = component.get("v.recordId");
        action.setParams({
            "contact": contact,
            "caseId": caseId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = component.get("v.contact");
                var workspace = component.find("workspace");
                var record = response.getReturnValue();
                if(record.length > 1){
                    delete record[record.length - 1];
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Duplicate detected!",
                        "type" : "error",
                        "duration" : "5000",
                        "message": "Duplicate detected"
                    });
                    toastEvent.fire();
                    component.set("v.duplicateContacts", record );
                    component.set("v.duplicateDetected", 'Duplicates detected. Please consider using one of the contacts below' );
                    component.set('v.message' , '');
                    return;
                }
                if(record[0].Id){
                    component.set("v.isOpen", false);
                    workspace.openTab({
                        recordId: record[0].Id,
                        focus: true
                    })
                }else{
                    component.set('v.message' , 'An error occured');
                } 
            }
        });
        $A.enqueueAction(action);
    },

    saveContactClient:function(component , contact){
        if(contact.Id){
            var workspace = component.find("workspace");
            var lightningAppExternalEvent = $A.get("e.c:QCC_Search_Form_LE_Integration");
            lightningAppExternalEvent.setParams({'data':contact});
            lightningAppExternalEvent.fire();
            workspace.openTab({
                recordId: contact.Id,
                focus: true
            });
            return null;
        }
        var action = component.get("c.saveIt");
        action.setParams({
            "contact": contact
        });
        action.setCallback(this, function(response){
            if(!response) {
                this.displayError(component ,  'Unexpected error' , 'Error' , '7000' , 'An unexpected error occurred. Please manually create the customer\'s profile');
            }
            if(response.getState() === "SUCCESS"){
                component.set("v.isOpen", false);
                var workspace = component.find("workspace");
                var record = response.getReturnValue();
                console.log('record returned ' + record);
                if(record){
                    if(record.Id){
                        var lightningAppExternalEvent = $A.get("e.c:QCC_Search_Form_LE_Integration");
                        lightningAppExternalEvent.setParams({'data':record});
                        lightningAppExternalEvent.fire();
                        workspace.openTab({
                            recordId: record.Id,
                            focus: true

                        })
                    }else{
                        this.displayError(component ,  'Unexpected error' , 'Error' , '7000' , 'An unexpected error occurred. Please manually create the customer\'s profile');
                    }
                    
                }else{
                    this.displayError(component ,  'Unexpected error' , 'Error' , '7000' , 'An unexpected error occurred. Please manually create the customer\'s profile');
                }

            }else{
                this.displayError(component ,  'Unexpected error' , 'Error' , '7000' , 'An unexpected error occurred. Please manually create the customer\'s profile');
            }
        });
        $A.enqueueAction(action); 
    },    //navigate to contact

    attachCaseToContact:function(component , contact , caseId){
        var action = component.get("c.AssignToContact");
        action.setParams({
            "contact": contact,
            "caseId" : caseId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                if(record.Id){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "Success",
                        "duration" : "5000",
                        "message": "Case Successfully Assigned"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                component.set("v.message" , '');
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "duration" : "5000",
                    "message": "Case Assignment Failed"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    searchContact: function(component, contact , pnr , caseId) {
        var action = component.get("c.executeSearch");

        if(component.get("v.isSearchLocal")){
            action.setParams({
                "contact": contact,
                "pnr": pnr,
                "crmSearch":true
            });
        }else{
            action.setParams({
                "contact": contact,
                "pnr" : pnr,
                "crmSearch": false
            });
        }

        
        action.setCallback(this, function(response){
            console.log('response ' + response);
            var state = response.getState();
            if (state === "SUCCESS") { 
                var records = response.getReturnValue();
                if(records == null) {
                    this.displayNotFound(component);
                    return;
                }else{
                    if(records.contacts.length == 0) {
                        this.displayNotFound(component);
                        return;
                    }else{
                        component.set("v.message", '');
                    }
                    
                    if(caseId){
                        component.set("v.displayAssignToCaseBtn", true);
                    }
                    
                    if(records.contacts.length > 100){
                        this.displayError(component , 'Too many records! Please refine your search ');
                    }
                    component.set("v.contacts", records.contacts );
                    component.set("v.contactPnr", records.pnr );
                    component.set("v.pageNumber",1);
                    component.set("v.maxPage", Math.floor((records.contacts.length+9)/10));
                    this.renderPage(component);

                }
                
            }else{
               this.displayNotFound(component);
            }
            this.enableLocalSearch(component);
            
        });
        $A.enqueueAction(action);
    },

    enableLocalSearch: function(component){
        
        //CAP search
        if(!component.get("v.tryLocal") && !component.get("v.isSearchLocal")){
            component.set("v.tryLocal", true );
            return;
        }

        if(component.get("v.isSearchLocal")){
            component.set("v.displayNewContactBtn", true );
            component.set("v.tryLocal", false );
        }
    },
    displayNotFound: function(component){
        if(!component.get("v.isSearchLocal")){
            this.displayError(component ,  'Not found' , 'Error' , '5000' , 'No search results returned from CAP. Click on ‘Try Local’ to search within Salesforce');
        }else{
            this.displayError(component ,  'Not found' , 'Error' , '5000' , 'No search results returned from Salesforce. Click on ‘New Contact’ to create the customer in Salesforce');
        }
    },
    
    displayError:function(component , title , type , duration , message){

        component.set("v.displaySearchResults", false);
        
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                "title": title,
                "type" : type,
                "duration" : duration,
                "message": message
            });
            toastEvent.fire();
        }else{
            component.set("v.message", message);
        }

        component.set("v.contacts", null );
        component.set("v.currentList", null);
        component.set("v.pageNumber",1);
        component.set("v.maxPage", 1);
        this.enableLocalSearch(component);
        return;
    },
    
    // [US# 185 Purushotham – Start [2/2]: Setting the currentList attribute based on Page Number value.]
    renderPage: function(component) {
        var records = component.get("v.contacts");
        if(records != null) {
            var pageNumber = component.get("v.pageNumber");
            var pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
            component.set("v.currentList", pageRecords);
            component.set("v.displaySearchResults", true);
        }
    },
    // [US# 185 Purushotham – Ends [2/2]]
    setFocusedTabLabel: function(component, event, helper) {
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function(response) {
        var focusedTabId = response.tabId;
        workspaceAPI.setTabLabel({
            tabId: focusedTabId,
            label: "Customer Search"
        });

        workspaceAPI.setTabIcon({
            tabId: focusedTabId,
            icon: "custom96",
            iconAlt: "Search"
        });
    })
}


})