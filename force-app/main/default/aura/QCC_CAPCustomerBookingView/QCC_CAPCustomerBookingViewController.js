({
	doInit : function(component, event, helper) {
        console.log("Log Init");
        debugger;
        var pageNumber = component.get("v.pageNumber");
        helper.getLocalList(component, pageNumber);
        component.set("v.hidePrev", true);
    },
    Next: function(component, event, helper){
        var pageNumber = component.get("v.nextPageNumber");
        console.log("pageNumber#####",pageNumber);
        component.set("v.hidePrev", true);
        if(pageNumber>0){
            component.set("v.hidePrev", false);
        }
        helper.getLocalList(component, pageNumber);
    },
    Previous: function(component, event, helper){
        var pageNumber = component.get("v.pageNumber");
        component.set("v.hidePrev", true);
        if((pageNumber-1)>1){
            component.set("v.hidePrev", false);
        }
        helper.getLocalList(component, pageNumber-1); 
    },
    navigateToMyComponent : function(component, event, helper) {
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
                //JIra: CRM-6052
                archivalData: "false",
                isNeedToFormatDate: "false"
            }
        });
        evt.fire();
    }
})