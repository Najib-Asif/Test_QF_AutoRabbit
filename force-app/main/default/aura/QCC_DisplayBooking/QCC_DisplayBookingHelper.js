({
    getLocalList: function(component, pageNumber) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
        var recID = component.get("v.recordId");
        //alert(recID);
        
        var action = component.get("c.getListMyBookings");
        action.setParams({
            "recordId": recID,
        });
        
        action.setCallback(this, function(response) {
            this.doLayout(response, component, pageNumber);
        });
        
        $A.enqueueAction(action);
    },
    doLayout: function(response, component, pageNumber) {
        var data = response.getReturnValue(); 
        var state = response.getState();
        
        if(state === 'SUCCESS'){
            component.set("v.lstBooking", data[pageNumber]);
            component.set("v.mapBooking", data);
            component.set("v.hidePrev", true);
        }
        else{
            component.set("v.hidePrev", true);
            component.set("v.hideNext", true);
        }
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
        console.log("The Data: ", data);
    },
    showCurrentPageDate: function(component, pageNumber) { 
        console.log("Show current PageNumber", pageNumber);
        var data = component.get("v.mapBooking");        
        console.log("Show current Page", data);
        component.set("v.lstBooking", data[pageNumber]);
        component.set("v.pageNumber", pageNumber);
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
        if(!data.hasOwnProperty(pageNumber+1)){
            component.set("v.hideNext", true);
            component.set("v.hidePrev", false);
        }else if(pageNumber == 1){
            component.set("v.hideNext", false);
            component.set("v.hidePrev", true);
        }else{
            component.set("v.hideNext", false);
            component.set("v.hidePrev", false);
        }
    }
})