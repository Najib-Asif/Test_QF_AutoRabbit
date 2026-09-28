({
	getBookingList: function(component, pnr, lastname) {
        console.log("@@@@ getBookingListT HELPER");
        var recID = component.get("v.recordId");
		var archivalData = component.get("v.history");
        var action = component.get("c.fetchCAPBookingWithLastName");
        var spinner = component.find("pnrSpinner");
        $A.util.removeClass(spinner, "slds-hide");
        action.setParams({
            "caseId": recID,
            "pnr": pnr,
            "archivalData": archivalData,
            "lastName": lastname
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('invoke PNR call', state);
            if (state === "SUCCESS") {

                console.log(response.getReturnValue());
                this.doLayout(response, component, 1);
                
            }
            else if (state === "INCOMPLETE") {
                $A.util.toggleClass(spinner, "slds-hide");
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
                $A.util.toggleClass(spinner, "slds-hide");
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getBookingListCreationDate: function(component, pnr, creationDate) {
        console.log('@@@@ getBookingListCreationDate helper')
        var recID = component.get("v.recordId");
		var archivalData = component.get("v.history");
        var action = component.get("c.fetchCAPBookingWithCreationDate");
        var spinner = component.find("pnrSpinner");
        $A.util.removeClass(spinner, "slds-hide");
        action.setParams({
            "caseId": recID,
            "pnr": pnr,
            "isHistory": archivalData,
            "archivalData": archivalData,
            "creationDate": creationDate
        });
        
        action.setCallback(this, function(response) {
            console.log('@@@@ getBookingListCreationDate')
            var state = response.getState();
            console.log('@@@@ getBookingListCreationDateinvoke PNR call', state);
            if (state === "SUCCESS") {

                this.autoDisplayBookings(response, component, 1);
            }
            else if (state === "INCOMPLETE") {
                $A.util.toggleClass(spinner, "slds-hide");
                $A.util.toggleClass(spinner, "slds-hide");
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
                $A.util.toggleClass(spinner, "slds-hide");
                $A.util.toggleClass(spinner, "slds-hide");
            }
        });
        
        $A.enqueueAction(action);
        
    },

    doLayout: function(response, component, pageNumber) {
        var data = response.getReturnValue(); 
        var state = response.getState();
        var pnr = component.get("v.pnr");
        var lastname = component.get("v.lastName");
        var spinner = component.find("pnrSpinner");
        var lstCurrentVal = [];
        console.log("state###",state);
        console.log("lastname",lastname);
        if(state === "SUCCESS" && data != null){
            if(data.bookings){
                component.set("v.lstCurrentBook",data.bookings);
                this.updateCasePnr(component,pnr); 
                console.log("ZZZdata.bookings#####",data.bookings);
                console.log("ZZZ resp date: "+data.bookings[0].departureTimeStamp);
            }	
        }
       else if(state === "SUCCESS" && data === null && (pnr !=null && pnr!="") && (lastname !=null && lastname != "undefined" && lastname!=""))
        {
            component.set("v.noBookings",true);
            component.set("v.showMsg", true);
            $A.util.toggleClass(spinner, "slds-hide"); 
        }
        else if (state === "ERROR") {
             component.set("v.showMsg", true);
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
            $A.util.toggleClass(spinner, "slds-hide");
        } 
        else if (state === "INCOMPLETE") {
             component.set("v.showMsg", true);
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
            $A.util.toggleClass(spinner, "slds-hide");
        }
        else{
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.showMsg", true);
            $A.util.toggleClass(spinner, "slds-hide");
        }

        //$A.util.toggleClass(spinner, "slds-hide");

    },

    autoDisplayBookings: function(response, component, pageNumber) {
        console.log("@@@@ autoDisplayBookings");
        var spinner = component.find("pnrSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var data = response.getReturnValue(); 
        var state = response.getState();
        var pnr = component.get("v.pnr");
        var lstCurrentVal = [];
        console.log("state###",state);
        if(state === "SUCCESS" && data != null){
           
            if(data.bookings){
                component.set("v.lstCurrentBook",data.bookings);
                console.log("ZZZdata.bookings#####",data.bookings);
                console.log("ZZZ resp date: "+data.bookings[0].departureTimeStamp);
                
            }
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
        
        $A.util.toggleClass(spinner, "slds-hide");
    },

    updateCasePnr: function(component, pnr){
        console.log('@@@@ updateCasePnr')
        var spinner = component.find("pnrSpinner");
        var recId = component.get("v.componentId");
        var action = component.get("c.updateCasePNR");
        action.setParams({
            "caseId": recId,
            "pnr": pnr
        });

        var samplePromise = new Promise(function(resolve, reject){
            action.setCallback(this, function(response){
                var state= response.getState();
                console.log("@@@@ Invoke updateCasePnr state", state);
                if(state === "SUCCESS"){
                    console.log("@@@@ case pnr updated successfully");
                    resolve(response.getReturnValue());
                    
                }
                else if(state === "INCOMPLETE"){
                    console.log("@@@@ case pnr updated incomplete");
                    $A.util.toggleClass(spinner, "slds-hide");
                }
                else if(state === "ERROR"){
                    console.log("@@@@ case pnr updated error");
                    $A.util.toggleClass(spinner, "slds-hide");
                }
                else{
                    console.log("@@@@ unknown error");
                    $A.util.toggleClass(spinner, "slds-hide");
                }
            });
            $A.enqueueAction(action);
        });

        console.log("@@@@ case pnr update BEFORE THEN");
        samplePromise.then(function(result){
            console.log("@@@@ case pnr update THEN");
            //publish LMS message to refresh Case History Tab
            const payloadmessage = {
                action: 'refresh',
                pnrValue: pnr
            };

            var payload = {payloadData: payloadmessage};
            component.find('qccCaseChannel').publish(payload);
            console.log("@@@@ case pnr update payload", payload);
            console.log("@@@@ case pnr update payload", JSON.stringify(payload));
            $A.util.toggleClass(spinner, "slds-hide");
        }).catch(function(error){

            console.log("@@@@@ samplePromise error", error);
            $A.util.toggleClass(spinner, "slds-hide");
        })           
    }
})