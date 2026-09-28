({
    doInit : function(component, event, helper) {
        var creationDate = component.get("v.creationDate");
        var pnr = component.get("v.pnr");
        var recID = component.get("v.componentId");
        if(creationDate != null){
            console.log("@@@@ calling bookingListCreationDate")
            helper.getBookingListCreationDate(component,pnr,creationDate);
        }
        
	},
	searchButtonClick : function(component, event, helper) {
        var pnr = component.get("v.pnr");
        var lastName = component.get("v.lastName");

        helper.getBookingList(component, pnr, lastName);
	},

	navigateToMyComponent : function(component, event, helper){
		var count = event.currentTarget.getAttribute('data-record');
        console.log('count######',count);
        var recID = component.get("v.componentId");
        var bookings = component.get("v.lstCurrentBook");
        var booking = bookings[count];
        console.log('booking11111',booking);
        console.log('booking.reloc@@@@',booking.reloc);
        console.log('booking.creationDate',booking.creationDate);
        console.log('case record ID@@@@@',recID);

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

    //CRM-8619
    capitalisePNR: function(component, event, helper) {
        var pnr = component.get("v.pnr");
        component.set("v.pnr", pnr.toUpperCase());
        component.set("v.showMsg", false);
    },

    turnOffMsg: function(component, event, helper){
        component.set("v.showMsg", false);
    }
})