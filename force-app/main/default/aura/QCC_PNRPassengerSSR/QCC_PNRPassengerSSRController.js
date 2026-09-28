({
    getSSRPassengerDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value###',params.ssrPassengerDetail);
        component.set("v.ssrPassengerInfo", params.ssrPassengerDetail);
        component.set("v.mycolumns", [
            {label: 'First Name', fieldName: 'firstName', type: 'text'},
            {label: 'Last name', fieldName: 'lastName', type: 'text'},
            {label: 'Type', fieldName: 'type', type: 'text'},
            {label: 'Description', fieldName: 'description', type: 'text'},
            {label: 'Characteristics', fieldName: 'characteristics', type: 'text'},
            {label: 'Status', fieldName: 'status', type: 'text'},
            {label: 'Chargeable', fieldName: 'chargeable', type: 'text'},
            {label: 'Amount', fieldName: 'amount', type: 'integer'}
        ]);
        console.log('Rows disrupt####',component.get("v.ssrPassengerInfo"));
        console.log('mycolumns disrupt####',component.get("v.mycolumns"));
    },
    getSelectedName: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        console.log('length####',selectedRows.length);
       
        var myEvent = component.getEvent("onSSRSelection");
        var showButton = false;
        if(selectedRows.length == 1){
            showButton = true;
        }
        myEvent.setParams({
            "selectedSSR": selectedRows,
            "showCaseButton": showButton
        });
        console.log('length####',selectedRows);
        console.log('showButton####',showButton);
        myEvent.fire();
    }
})