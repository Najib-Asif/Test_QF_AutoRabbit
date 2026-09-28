({
    initData: function(component){
        var action = component.get('c.getFieldSets');
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set('v.listFieldInFieldSet', actionResult.getReturnValue().listFieldSets);
                var columns = JSON.parse(actionResult.getReturnValue().columnSets);
                for(var i = 0; i < columns.length; i++){
                    if(columns[i].type == 'date'){
                        columns[i].typeAttributes = {day:'2-digit',month:'2-digit',year:'numeric'}
                    }
                    //GRAPHITE-938 Align center if field is for VIPs and SSUs
                    if(columns[i].fieldName == 'QCC_Number_of_VIPs__c' || columns[i].fieldName == 'QCC_Number_of_SSUs__c') {
                        columns[i].cellAttributes = { alignment: 'center' }
                    }
                }
                console.log(columns);
                component.set("v.columns", columns);
            }
        });
        $A.enqueueAction(action);
    },
    getDataEvents: function(component, helper){
        var action = component.get('c.getDataEvents');
        var lstFieldSetMember = component.get("v.listFieldInFieldSet");
        var lstColumns = component.get("v.columns");
        action.setParams({
            lstFieldSetMemberStr : JSON.stringify(lstFieldSetMember),
            lstColumnsStr : JSON.stringify(lstColumns)
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set('v.data', actionResult.getReturnValue());
                component.set('v.selectedRows',[]);
                component.set('v.displayData', []);
                component.set('v.listEventSelected',[]);
                component.set('v.selectedIds',[]);
                var total = actionResult.getReturnValue().length;
                var offSet = component.get('v.offSet');
                var totalPage = Math.floor(total/offSet)+1;
                component.set('v.totalPage', totalPage);
                
                console.log(actionResult.getReturnValue());
                console.log(actionResult.getReturnValue().length);

                //sort if column is defined
                var fieldName = component.get("v.sortedBy");
                var sortDirection = component.set("v.sortedDirection");
                if(fieldName != null && sortDirection != null){
                    this.sortData(component, fieldName, sortDirection);
                }
                
				var isAddedRecord = component.get("v.isAddedRecord");
                if(actionResult.getReturnValue().length == 0 ){
                    if(isAddedRecord){
                        component.set("v.isAddedRecord", false);
                    }else {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "success",
                            "title": "Search Results",
                            "message": "No record found.",
                            duration : 5
                        });
                        resultsToast.fire();
                    }
                    
                }else{
                    this.updateDisplayData(component, 0);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    doAddEvents: function(component){
        
        var selectedIds = component.get("v.selectedIds");
        var selectedTrackers = component.get("v.selectedTrackers");
        var failureInfo = component.get('v.failureInfo');
        var recordId = component.get('v.recordId');

        var action = component.get('c.addEventsToGlobalEvent');
        action.setParams({ 
            lstEventId : selectedIds,
            lstTracker : selectedTrackers,
            globalEventId :  recordId,
            flightFailureJson : failureInfo
        });
        
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Add Events",
                    "message": "Add events to global event success.",
                    duration : 5
                });
                resultsToast.fire();
				component.set("v.isAddedRecord", true);
                this.getDataEvents(component);
                component.set("v.selectedRows", []);
                var refreshEvent = $A.get("e.force:refreshView");
                if(refreshEvent != null)
                    refreshEvent.fire();
            }else if (state === "ERROR") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Add Events",
                    "message": "Some errors happen.",
                    duration : 5
                });
                resultsToast.fire();

                var refreshEvent = $A.get("e.force:refreshView");
                if(refreshEvent != null)
                    refreshEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        if(data != null && data != undefined){
            data.sort(this.sortBy(fieldName, reverse));
            component.set("v.data", data);
            var currentPage = component.get('v.currentPage');
            this.updateDisplayData(component, currentPage);
        }
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
            function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {            
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
	updateDisplayData : function(component, currentPage){
		var data = component.get('v.data');
        var offSet = component.get('v.offSet');
        
        var displayData = [];
        for(var i =0; i < offSet && data.length > i + offSet*currentPage; i++){
            displayData.push(data[i+offSet*currentPage]);
        }
        component.set('v.currentPage', currentPage);
        
        
        this.getEventRootCause(component, displayData);
        /*
        component.set('v.displayData', displayData);
        component.set('v.listEventSelected',[]);
        component.set('v.selectedIds',[]);
        */
        
    },
    getEventRootCause: function(component, displayData) {
        var action = component.get('c.updatePrimaryRootCauseEvent');
        action.setParams({
            events : displayData
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set('v.selectedRows',[]);
                component.set('v.displayData', actionResult.getReturnValue());
                component.set('v.listEventSelected',[]);
                component.set('v.selectedIds',[]);
            }
        });
        $A.enqueueAction(action);
	},
    showFlightFailureInput: function(component, helper) {
        var modalBody;
        $A.createComponents([
            ["c:IOC_CreateFlightFailure",{
                "iocData" : component.getReference("c.handleIOCFlightFailureDataEvent")
            }],
        ],
            function(components, status){
                if (status === "SUCCESS") {
                    modalBody = components[0]; 
                    component.find('overlayLib').showCustomModal({
                        header: "Flight Failure Input",
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "my-modal,my-custom-class,my-other-class"
                    }).then(function (overlay) {
                        modalBody.set('v.overlayPane', overlay);
                    });
                }
            });
	}
})