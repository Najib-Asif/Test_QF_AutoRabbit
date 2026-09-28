({
    getLocalList: function(component, pageNumber) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
        var recID = component.get("v.recordId");
        
        var action = component.get("c.getListCustomerBookings");
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
        component.set("v.hidePrev", true);
        component.set("v.hideNext", true);
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var rowCount = component.get("v.rowsPerPage");
        console.log("rowCount####",rowCount);
        var lstCurrentVal = [];
        console.log("state###",state);
        if(state === "SUCCESS"){
            component.set("v.mycolumn",data.lstColumn); 
            component.set("v.lstBooking",data.lstBookingWrapper); 
            var loopCount = 0;
            if(data.lstBookingWrapper != null){
                loopCount = data.lstBookingWrapper.length>rowCount?rowCount:data.lstBookingWrapper.length;
                component.set("v.hideNext", false);
            }
            component.set("v.maxRecord",loopCount);
            for (var i = 0; i < loopCount; i++){
                lstCurrentVal.push(data.lstBookingWrapper[i])
            }
            console.log("current vale",lstCurrentVal);
            component.set("v.lstCurrentBook",lstCurrentVal);
        }else if (state === "ERROR") {
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
        } else if (state === "INCOMPLETE") {
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
        }
       
    },
    currentpageRecord: function(component, pageNumber, maxRecord){
        var data = component.get("v.lstBooking");
        var interval = component.get("v.rowsPerPage");
        var maxLoop =  maxRecord + interval;
        var maxRec = maxRecord;
        component.set("v.hidePrev", true);
        component.set("v.hideNext", true);
        if(data != null){ 
            var loopCount =  data.length>maxLoop?maxLoop:data.length;
            var lstCurrentVal = [];
            var i = maxRec;
            for (; i < loopCount; i++){
                lstCurrentVal.push(data[i])
            }
            component.set("v.lstCurrentBook",lstCurrentVal); 
            if(data.length>loopCount){
                component.set("v.hideNext", false);
            }
            if(maxRecord>0){
                component.set("v.hidePrev", false);
            }
            component.set("v.maxRecord",loopCount);
            component.set("v.pageNumber",pageNumber);
        }
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.lstBooking");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.lstBooking", data);
        this.currentpageRecord(component, 1, 0);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})