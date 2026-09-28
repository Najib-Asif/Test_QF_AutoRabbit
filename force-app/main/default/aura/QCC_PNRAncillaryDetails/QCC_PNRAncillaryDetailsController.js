({
	getAncillaryDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value###',params.ancillaryDetail);
        component.set("v.ancillaryInfo", params.ancillaryDetail);
        /*component.set("v.mycolumns", [
                {label: 'Type', fieldName: 'type', type: 'text'},
                {label: 'Description', fieldName: 'description', type: 'text'},
                {label: 'Status', fieldName: 'status', type: 'text'},
                {label: 'Chargeable', fieldName: 'chargeable', type: 'text'},
                {label: 'Amount', fieldName: 'amount', type: 'text'},
                {label: 'Ref', fieldName: 'ref', type: 'text'}
            ]);*/
        component.set("v.mycolumns", [
                {label: 'Type', fieldName: 'type', type: 'text'},
                {label: 'Amount', fieldName: 'amount', type: 'text'},
                {label: 'Ref', fieldName: 'ref', type: 'text'}
            ]);
        console.log('Rows disrupt####',component.get("v.ancillaryInfo"));
        console.log('mycolumns disrupt####',component.get("v.mycolumns"));
    }
})