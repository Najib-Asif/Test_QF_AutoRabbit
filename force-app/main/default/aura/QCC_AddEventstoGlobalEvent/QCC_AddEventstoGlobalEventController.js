({
	init : function(component, event, helper) {
		helper.initData(component);
        console.log(component.get('v.recordData'));
	},
    resetData : function(component, event, helper) { 
        console.log('==resetData==');
        var listFieldInFieldSet = component.get('v.listFieldInFieldSet');
        for(var i = 0; i < listFieldInFieldSet.length; i++){
            listFieldInFieldSet[i].fieldValue = '';
        }
        component.set('v.listFieldInFieldSet',listFieldInFieldSet);
        component.set('v.data', []);
        component.set('v.displayData', []);
        component.set('v.currentPage', 0);
        component.set('v.totalPage', 0);
        component.set('v.selectedIds', []);
        component.set('v.selectedTrackers', []);
        component.set('v.failureInfo', "");
    },
    searchData: function(component, event, helper) {
        // check have at least one condition
        var listFieldInFieldSet = component.get('v.listFieldInFieldSet');
        var isNotInputCondition = true;
        for(var i = 0; i < listFieldInFieldSet.length; i++){
            if(listFieldInFieldSet[i].fieldValue){
                isNotInputCondition = false;
                break;
            }
        }
        if(isNotInputCondition){
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": "Search Events",
                "message": "Please input at least one search condition.",
                duration : 5
            });
            resultsToast.fire();
        } else {
            helper.getDataEvents(component);
        }
    },
    doAddEvents: function(component, event, helper) {
        var listEventSelected = component.get("v.listEventSelected");
        var selectedIds =[];
        var selectedTrackers =[];
        for (var i = 0; i < listEventSelected.length; i++){
            if(listEventSelected[i].Id != null){
                selectedIds.push(listEventSelected[i].Id);
            }else {
                selectedTrackers.push(listEventSelected[i].TECH_FlightTrackerId__c);
            }
        }
        component.set('v.selectedIds', selectedIds);
        component.set('v.selectedTrackers', selectedTrackers);
        var recordData = component.get('v.recordData');
        if(recordData.Status__c == 'Closed'){
            alert('can not add to closed Event');
        }else if(selectedIds.length == 0 && selectedTrackers.length == 0){
            alert('Please select at least 1 record.');
        }
        else{
            if(selectedTrackers.length > 0){
                helper.showFlightFailureInput(component, helper);
            }else{
                helper.doAddEvents(component, helper);
            }
        }
        
    },
    getSelectedItems: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.listEventSelected',selectedRows);
        console.log(selectedRows);
    },
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // Assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    next : function(component, event, helper){
        var currentPage = component.get('v.currentPage');
        var totalPage = component.get('v.totalPage');
        if(currentPage < totalPage-1){
            currentPage++;
            helper.updateDisplayData(component, currentPage);
        }
    },
    previous : function(component, event, helper){
		var currentPage = component.get('v.currentPage');
        if(currentPage > 0){
            currentPage--;
            helper.updateDisplayData(component,  currentPage);
        }
    },
    handleIOCFlightFailureDataEvent : function(component, event, helper) {
        //get flight failure Info from the pop up
    	var objFlightFailure = event.getParam("objFlightFailure");
        console.log(objFlightFailure);
        component.set('v.failureInfo', objFlightFailure);
        helper.doAddEvents(component, helper);
    }
})