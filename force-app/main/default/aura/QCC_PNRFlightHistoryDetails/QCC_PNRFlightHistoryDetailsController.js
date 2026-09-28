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
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
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
            if(rowIndex === arr[i].segmentTattoo) {
                d.className += " onSelection";
            } else {
                var element = document.getElementById(arr[i].segmentTattoo);
   				element.classList.remove("onSelection");
            }
        }*/
        console.log('11111',event.currentTarget.getAttribute('data-record'));
        var segmentID = event.currentTarget.getAttribute('data-record');
        var myEvent = component.getEvent("flightEvent");
        myEvent.setParams({"segmentId": segmentID, "history": true});
        myEvent.fire();
    },
    showInfo: function(component, event) {
        component.set("v.disable", true);
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
        var myEvent = component.getEvent("flightHistoryEvent");
        myEvent.fire();
    },
    highlightFlight: function (component, event) {
        var params = event.getParam("arguments");
        var rowIndex = params.segmentTattoo;
        //var rowIndex = target.getAttribute("id");
        console.log("Row No 1: " + rowIndex);
        var d = document.getElementById(rowIndex+'abc');
        //var d = document.getElementById(rowIndex);
        //var d = document.getElementById("ABCIssue");
        //Added by bharath for testing the PNR functionality
        var arr = component.get("v.flightInfo");
        for(var i in arr) {
            if(rowIndex === arr[i].segmentTattoo+'abc') {
                d.className += " onSelection";
            } else {
                var element = document.getElementById(arr[i].segmentTattoo+'abc');
   				element.classList.remove("onSelection");
            }
        }
    }
})