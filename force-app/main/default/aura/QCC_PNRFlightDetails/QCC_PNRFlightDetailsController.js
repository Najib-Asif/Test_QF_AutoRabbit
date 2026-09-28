({
    getFlightDetails : function(component, event, helper) {
        var params = event.getParam("arguments");
        console.log('Param Value###',params.flightDetail);
        component.set("v.flightInfo", params.flightDetail);
        component.set("v.mycolumns", [
            {label: 'Airline', fieldName: 'operatingCarrierAlphaCode', type: 'text'},
            {label: 'Flight Number', fieldName: 'operatingFlightNumber', type: 'text'},
            {label: 'Departure Date', fieldName: 'departureLocalDate', type: 'text'},
            {label: 'Departure Port', fieldName: 'departureAirportCode', type: 'text'},
            {label: 'Arrival Port', fieldName: 'arrivalAirportCode', type: 'text'}
        ]);
        console.log('Rows####',component.get("v.flightInfo"));
        console.log('mycolumns####',component.get("v.mycolumns"));
    },
    getSelectedName: function (component, event) {
        /*var target = event.currentTarget;
        var rowIndex = target.getAttribute("id");
        console.log("Row No : " + rowIndex);
        var d = document.getElementById(rowIndex);
        
        var arr = component.get("v.flightInfo");
        for(var i in arr) {
            if(rowIndex === arr[i].segmentId) {
                d.className += " onSelection";
            } else {
                var element = document.getElementById(arr[i].segmentId);
   				element.classList.remove("onSelection");
            }
        }*/
        console.log('11111',event.currentTarget.getAttribute('data-record'));
        var segmentID = event.currentTarget.getAttribute('data-record');
        $A.util.toggleClass(segmentID, "slds-is-selected");
        var myEvent = component.getEvent("flightEvent");
        myEvent.setParams({"segmentId": segmentID, "history": false});
        myEvent.fire();
    },
    highlightFlight: function (component, event) {
        var params = event.getParam("arguments");
        var rowIndex = params.segmentId;
        //var rowIndex = target.getAttribute("id");
        console.log("Row No : " + rowIndex);
        var d = document.getElementById(rowIndex);
        
        var arr = component.get("v.flightInfo");
        for(var i in arr) {
            if(rowIndex === arr[i].segmentId) {
                d.className += " onSelection";
            } else {
                var element = document.getElementById(arr[i].segmentId);
   				element.classList.remove("onSelection");
            }
        }
    }
})