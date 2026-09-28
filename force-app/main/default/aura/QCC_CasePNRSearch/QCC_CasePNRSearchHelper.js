({
	getBookingList: function(component, pnr) {
        var recID = component.get("v.recordId");
		var archivalData = component.get("v.history");
        var action = component.get("c.fetchCAPBooking");
        action.setParams({
            "caseId": recID,
            "pnr": pnr,
            "archivalData": archivalData
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('invoke PNR call');
            if (state === "SUCCESS") {

                console.log(response.getReturnValue());
                this.doLayout(response, component, 1);
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
            //this.doLayout(response, component, pageNumber);
        });
        
        $A.enqueueAction(action);
    },
    doLayout: function(response, component, pageNumber) {
        var data = response.getReturnValue(); 
        console.log("data#####",data);
        var state = response.getState();
        // component.set("v.hideNext", true);
        /*var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");*/
        var lstCurrentVal = [];
        console.log("state###",state);
        if(state === "SUCCESS" && data != null){
            if(data.bookings){
                component.set("v.lstCurrentBook",data.bookings); 
                console.log("ZZZdata.bookings#####",data.bookings);
                console.log("ZZZ resp date: "+data.bookings[0].departureTimeStamp);
                
            }
            // console.log("data.nextPageNumber#####",data.nextPageNumber);
            // if(data.nextPageNumber != undefined ){
            //     component.set("v.nextPageNumber", data.nextPageNumber);
            //     component.set("v.hideNext", false); 
            //     component.set("v.pageNumber", data.nextPageNumber-1);
            // }
            // if (data.nextPageNumber == undefined) {
            //     var pageNum = component.get("v.nextPageNumber");
            //     component.set("v.pageNumber",pageNum);
            // }
        }else if (state === "ERROR") {
             component.set("v.showMsg", true);
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
        } else if (state === "INCOMPLETE") {
             component.set("v.showMsg", true);
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
        }else{
             component.set("v.lstCurrentBook",lstCurrentVal);
             component.set("v.showMsg", true);
        }
        
    },
    // currentpageRecord: function(component, pageNumber){
        
    //     component.set("v.hidePrev", true);
    //     component.set("v.hideNext", true);
        
    // }
})