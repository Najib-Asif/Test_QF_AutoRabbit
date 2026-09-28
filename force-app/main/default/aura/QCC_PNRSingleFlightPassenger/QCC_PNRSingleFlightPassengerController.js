({
    getFlgPassengerDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('getFlgPassengerDetails Param Value###',params.flgPassengerDetail);
        component.set("v.flgPassengerInfo", params.flgPassengerDetail);
        component.set("v.mycolumns", [
            {label: 'First Name', fieldName: 'firstName', type: 'text'},
            {label: 'Last name', fieldName: 'lastName', type: 'text'},
            {label: 'Depature Port', fieldName: 'depaturePort', type: 'text'},
            {label: 'Arrival Port', fieldName: 'arrivalPort', type: 'text'},
            {label: 'Cabin Class', fieldName: 'cabinClass', type: 'text'},
            {label: 'Boarding Status', fieldName: 'boardingStatus', type: 'text'},
            {label: 'Seat #', fieldName: 'seatNumber', type: 'text'},
            {label: 'Checked-In baggage pieces', fieldName: 'checkinBaggage', type: 'integer'}
        ]);
        console.log('Rows disrupt####',component.get("v.flgPassengerInfo"));
        console.log('mycolumns disrupt####',component.get("v.mycolumns"));
    },
    getSelectedName: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            console.log("You selected: " + selectedRows[i].depaturePort);
        }
        var myEvent = component.getEvent("onLegSelection");
        var showButton = false;
        if(selectedRows.length == 1){
            showButton = true;
        }
        myEvent.setParams({
            "selectedLeg": selectedRows[0],
            "showCaseButton": showButton
        });
        
        myEvent.fire();
    }
})