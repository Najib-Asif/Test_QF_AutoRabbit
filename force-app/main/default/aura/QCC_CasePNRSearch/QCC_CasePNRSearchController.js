({
    doInit : function(component, event, helper) {
		var recID = component.get("v.recordId");
        var action = component.get("c.getInitInfo");

        action.setParams({ caseId : recID });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()$$$',response.getReturnValue());
            	if(response.getReturnValue() != null && response.getReturnValue() != '' ){
            		component.set('v.pnr', response.getReturnValue());
            		helper.getBookingList(component, response.getReturnValue());
            	}
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
	},
	searchButtonClick : function(component, event, helper) {
        helper.getBookingList(component, component.get("v.pnr"));
	},
	navigateToMyComponent : function(component, event, helper){
		var count = event.currentTarget.getAttribute('data-record');
        console.log('count######',count);
        var recID = component.get("v.recordId");
        var bookings = component.get("v.lstCurrentBook");
        var booking = bookings[count];
        console.log('booking11111',booking);
        console.log('booking.reloc@@@@',booking.reloc);
        console.log('booking.creationDate',booking.creationDate);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:QCC_PNRBookingFlightDetails",
            componentAttributes: {
                pnr : booking.reloc,
                creationDate : booking.creationDate,
                recordId : recID,
                archivalData: booking.archivalData
            }
        });
        evt.fire();
	},
    turnOffMsg: function(component, event, helper){
        component.set("v.showMsg", false);
    }
})