({
    handleApplicationEvent : function(component, event, helper) {
        
        var params = event.getParams();
        console.log("QAC_PassengerData_V1.handleApplicationEvent: entry");
        
        /*
        var sectionHidden = (params.pnrInformation == null || params.pnrInformation.pointSales == null) ? true : false; 
        console.log("section disabled**"+sectionHidden);
        component.set("v.isSectionHidden",sectionHidden);
        */
        
        var capDiv = component.find("capSecDiv");
        console.log('params.pnrInformation'+params.pnrInformation);
        if(params.pnrInformation == null || params.pnrInformation.pointSales == null ){
            console.log("section disabled**");
            component.set("v.isSectionHidden",true);
            $A.util.addClass(capDiv,'toggle');
        }
        else{
            console.log("section enabled**");
            component.set("v.isSectionHidden",false);
            $A.util.removeClass(capDiv,'toggle');            
        }

        var localDiv = component.find("localCasesSecDiv");
        if(params.localCases != null || params.localCases != undefined){
            $A.util.removeClass(localDiv,'toggle');
        }
        else{
            $A.util.addClass(localDiv,'toggle');            
        }
        component.set("v.localCases",params.localCases);

        component.find("allCheckPAX").set("v.value",false);
        component.find("allCheckFL").set("v.value",false);

        if(params.pnrInformation != null){
            component.set("v.pnrInformation", params.pnrInformation);
            component.set("v.isDisabled", (params.pnrInformation.caseFields.iataAccount.Name == undefined) ? true : false);
        } 
        
        console.log("QAC_PassengerData_V1.handleApplicationEvent: exit");
    },
    
    showCaseSR : function(component, event, helper) {
        var flightChecked = false;
        var passengerChecked = false;
        var flightInfo = [];
        flightInfo = component.get("v.pnrInformation.flightDetailsWrapper");
        var passengerInfo = [];
        passengerInfo = component.get("v.pnrInformation.passengerDetailsWrapper");
        
        for(var i = 0, size = flightInfo.length; i < size ; i++){
            if(flightInfo[i].selectedFlight){
                flightChecked = true;
                break; 
            } 
        }
        
        for(var i = 0, size = passengerInfo.length; i < size ; i++){
            if(passengerInfo[i].selectedFlight){
                passengerChecked = true;
                break; 
            } 
        }
        
        if(flightChecked && passengerChecked){
            helper.selectPassengersAndNavigate(component);
            var cmpEvent = component.getEvent("bubblingEvent");
            console.log('cmpEvent: ' + cmpEvent);
            cmpEvent.setParams({"ComponentAction" : 'showCaseSR' });
            cmpEvent.fire();     	    
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Information Not Selected',
                message: 'Atleast one passenger and flight needs to be selected',
                messageTemplate: 'Record {0} created! See it {1}!',
                duration:' 8000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },
    
    handleBack : function(component, event, helper) {
        var cmpEvent = component.getEvent("bubblingEvent");
        console.log('cmpEvent: ' + cmpEvent);
        cmpEvent.setParams({"ComponentAction" : 'showSearch' });
        cmpEvent.fire();
    },
    
    selectAllFL : function(component, event, helper) {
        helper.onChangeAllSelect(component, event, "flight");
    },
    
    selectAllPAX : function(component, event, helper) {
        helper.onChangeAllSelect(component, event, "pax");
    },
    
    openTab : function(component, event, helper) 
    {
        var aHrefLinkTag = event.currentTarget;
        var caseId = aHrefLinkTag.dataset.custom;
        console.log("Local Case Id**"+caseId);
        
        /*
        event.preventDefault();
        var sobjectEvent=$A.get("e.force:navigateToSObject");
        sobjectEvent.setParams({
            "recordId": caseId
        });
        sobjectEvent.fire();
        */
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: caseId,
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
                console.log("The url for this tab is: " + tabInfo.url);
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})