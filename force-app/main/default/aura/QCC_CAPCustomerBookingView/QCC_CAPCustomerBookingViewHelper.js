({
    getLocalList: function(component, pageNumber) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
        var recID = component.get("v.recordId");
        //Jira: CRM-6052
        var action = component.get("c.fetchCAPBookingViaFFNumber");
        action.setParams({
            "recordId": recID,
            "pageNumber": pageNumber
        });
        
        action.setCallback(this, function(response) {
            this.doLayout(response, component, pageNumber);
        });
        
        $A.enqueueAction(action);
    },
    doLayout: function(response, component, pageNumber) {
        var data = response.getReturnValue(); 
        console.log("data#####",data);
        var state = response.getState();
        component.set("v.hideNext", true);
        /*var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");*/
        var lstCurrentVal = [];
        console.log("state###",state);
        if(state === "SUCCESS" && data != null){
            //Jira: CRM-6052
            if(data.flights){
                component.set("v.lstCurrentBook",data.flights);
                console.log("ZZZdata.bookings#####",data.flights);
                console.log("ZZZ resp date: "+data.flights[0].departureUTCTimestamp);
            }
            console.log("data.nextPageNumber#####",data.nextPage);
            if(data.nextPage != undefined ){
                component.set("v.nextPageNumber", data.nextPage);
                component.set("v.hideNext", false); 
                component.set("v.pageNumber", data.nextPage-1);
            }
            if (data.nextPage == undefined) {
                var pageNum = component.get("v.nextPageNumber");
                component.set("v.pageNumber",pageNum);
            }
        }else if (state === "ERROR") {
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
        } else if (state === "INCOMPLETE") {
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
        }
        component.set("v.serverCalled", true);
    },
    currentpageRecord: function(component, pageNumber){
        
        component.set("v.hidePrev", true);
        component.set("v.hideNext", true);
        
    }
})