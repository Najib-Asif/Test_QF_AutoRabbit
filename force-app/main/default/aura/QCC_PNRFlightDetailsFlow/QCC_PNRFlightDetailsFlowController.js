({

    doInit : function(component, event, helper) {
        
        helper.getCompleteDetail(component);        
    },
    
    returnSelectedFlight: function (component, event, helper) {
        console.log('#### QCC_PNRFlightDetailsFlow Controller - returnSelectedFlight : Event : ' + event.currentTarget.getAttribute('data-record'));
        console.log('#### QCC_PNRFlightDetailsFlow Controller - returnSelectedFlight : completebooking : ' + JSON.stringify(component.get("v.completebooking")));
        var segmentID = event.currentTarget.getAttribute('data-record');
        var history = false;
        var invokedFlight = true;

        component.set("v.isHistory", history);
        component.set("v.segmentID", segmentID);
        $A.util.toggleClass(segmentID, "slds-is-selected");

        //Highlight the selected row
        helper.highlightFlight(component, event, segmentID);

        var myEvent = component.getEvent("flightEvent");
        myEvent.setParams({ "segmentId": segmentID, 
                            "history": false, 
                            "bookingInfo":component.get("v.completebooking")});
        myEvent.fire();

    },

 
})