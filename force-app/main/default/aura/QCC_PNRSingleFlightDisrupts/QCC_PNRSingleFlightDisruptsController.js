({
	getDisruptDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value###',params.disruptDetail);
        component.set("v.disruptsInfo", params.disruptDetail);
        component.set("v.mycolumns", [
                {label: 'Date', fieldName: 'departureLocalDate', type: 'text'},
                {label: 'Departure Port', fieldName: 'depaturePort', type: 'text'},
                {label: 'Arrival Port', fieldName: 'arrivalPort', type: 'text'},
                {label: 'Type', fieldName: 'type', type: 'text'},
                {label: 'reason', fieldName: 'reason', type: 'text'},
                {label: 'length of Delay', fieldName: 'duration', type: 'text'}
            ]);
        console.log('Rows disrupt####',component.get("v.disruptsInfo"));
        console.log('mycolumns disrupt####',component.get("v.mycolumns"));
    }
})