({   

    doInit: function(component , event , helper){
        //Get reports settings
        var reports = component.get("v.reports");
        if(!reports){
             $A.enqueueAction(component.get('c.getSettings'));
        }

        // get default recovery
        var selected = component.find("recType").get("v.value");
        
        if(selected){
            helper.getRecoveryList(component , selected);
        }
        helper.setFocusedTabLabel(component , event , helper);    
    },
    
    handleChange: function(component , event , helper){ 
        var selected = event.getParam("value");
        if(selected) helper.getRecoveryList(component , selected);
    },

    //Retrieves reports and base URL
    getSettings: function(component, event, helper){
        var action = component.get("c.getOrgSettings");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.settings",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    approveSelectedRecoveries : function(component, event, helper) {

        var recoveries = component.get("v.recoveries");
        var listToApprove = [];
        var recoveriesMap = new Map();
        console.log('recoveries ' + recoveries);
        var i;
        
        for(i = 0; i < recoveries.length; i++){
            var element = document.getElementById(recoveries[i].Id);
            if(element){
                if(element.checked === true){
                    listToApprove.push(recoveries[i]);
                }
            }

        }
        var action = component.get("c.updateRecoveryServer");
        action.setParams({
            "recoveries": listToApprove,
            "status": 'Approved'
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Approved!"
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    
    declineSelectedRecoveries : function(component, event, helper) {

        var recoveries = component.get("v.recoveries");
        var listToApprove = [];
        var recoveriesMap = new Map();
        console.log('recoveries ' + recoveries);
        var i;
        
        for(i = 0; i < recoveries.length; i++){
            var element = document.getElementById(recoveries[i].Id);
            if(element){
                if(element.checked === true){
                    listToApprove.push(recoveries[i]);
                }
            }
        }
        var action = component.get("c.updateRecoveryServer");
        action.setParams({
            "recoveries": listToApprove,
            "status": 'Declined'
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "Warning",
                    "message": "Declined!"
                });
                toastEvent.fire();
            }
            
        });
        
        $A.enqueueAction(action);
    },
    navigateToRecord: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId":event.target.id
        });
        navEvt.fire();
    },
    selectAll: function (component, event, helper) { 
        helper.selectAll(component , event , helper);

    },

    searchOnEnter: function(component , event , helper){
        if(event.keyCode == 13){
            $A.enqueueAction(component.get('c.searchRecovery'));
        }
        return;
    },

    searchRecovery: function(component , event , helper){
        var action = component.get("c.getRecovery");
        var recName = component.get("v.searchInput");
        

        if(!recName){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": "No search parameter entered"
            });
            toastEvent.fire();
            return;
        }

        action.setParams({
            "recName": recName.trim(),
        });
        action.setCallback(this, function(response){

            var state = response.getState();
            if (state === "SUCCESS") {
                var recoveries = response.getReturnValue();
                if(recoveries){
                    if(recoveries.length == 0){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Warning",
                            "type" : "warning",
                            "message": "Recovery Not Found"
                        });
                        toastEvent.fire();
                        return;
                    }
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning",
                        "type" : "warning",
                        "message": "Recovery Not Found"
                    });
                    toastEvent.fire();
                    return;
                }
                // alert('updating UI ' + recoveries);
                // component.set('v.recoveries', null);
                component.set('v.recoveries', recoveries);
                component.set('v.currentList', recoveries);
                
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "type" : "error",
                    "message": "Recovery Search Failed"
                });
                toastEvent.fire();
                return;
            }
        });

        $A.enqueueAction(action);
    },

    goToReport : function (component, event, helper) {
        var settings = JSON.parse(component.get("v.settings"));
        var Id = event.getSource().getLocalId();
        var baseUrl     = settings['url'];
        var eftSetting  = settings['eftReport'];
        var ccSetting   = settings['ccReport'];
        var eftReport   = baseUrl + '/' + eftSetting;
        var ccReport    = baseUrl + '/' + ccSetting;
        var error       = false;
        var report;
        if(Id){
            if(Id == 'eftReport'){
                if(!eftSetting) error = true;
                report = eftReport;
            }else{
                if(!ccSetting)  error = true;
                report = ccReport;
            }
        }

        if(error){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Restricted Access!",
                "type" : "Error",
                "message": "You do not have read access on this report. Please contact your System administrator!"
            });
            toastEvent.fire();
            return;
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": report
        });
        urlEvent.fire();
    },

    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    }
    
})