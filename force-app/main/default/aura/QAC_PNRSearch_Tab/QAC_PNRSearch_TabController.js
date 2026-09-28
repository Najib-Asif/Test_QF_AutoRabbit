({
    doInit : function(component, event, helper) {
        
        console.log("SearchBooking.doInit - Entry");
        
        // Hide both template , preview and confirm child Components on init:
        var toggleText = component.find("passengerDiv");
        $A.util.addClass(toggleText,'toggle');
        
        var toggleText = component.find("caseSRDiv");
        
        $A.util.addClass(toggleText,'toggle');
        //PNR Booking Auto Search Code Starts here
        console.log("Init function is called"+component.get("v.recordId"));
        console.log("Init function is called and case rec"+component.get("v.caseRec"));
        console.log("SearchBooking.doInit - Exit");
    },
    // CRM-8136 Live PNR Details
    onRecordLoad : function(component, event, helper)
    {
        console.log("Init function is called"+component.get("v.recordId"));
        console.log("Init function is called and case rec"+component.get("v.caseRec"));
        var changeType = event.getParams().changeType;
         if(changeType==='LOADED')
         {
            var caseRec=component.get("v.caseRec");
            console.log(JSON.stringify(caseRec));
            component.find('search').setSearchParams(caseRec.PNR_number__c,caseRec.Passenger_Last_Name__c)
           
         }
    },  
    handleBubbling : function(component, event, helper) {
        
        console.log("SearchBooking.handleBubbling - Entry");
        window.scrollTo(0,0);
        
        var params = event.getParams();
        var navigateAction = params.ComponentAction;
        
        console.log("navigateAction: " + navigateAction);
        
        // Based on the name of the component to hide received in the Bubble event use CSS to hide the current child LC and unhide the next child LC:
        var searchDiv = component.find("searchDiv");
        var passengerDiv = component.find("passengerDiv");
        var caseSRDiv = component.find("caseSRDiv");
        
        switch (navigateAction) 
        {
            case "showPassengers":
                $A.util.removeClass(passengerDiv,'toggle');
                var activeSections = ['A','B','C','D'];
                component.set('v.activeSections', activeSections);
                $A.util.addClass(caseSRDiv,'toggle');
                $A.util.addClass(searchDiv,'toggle');
                break;
                
            case "showCaseSR":
                $A.util.addClass(passengerDiv,'toggle');
                $A.util.removeClass(caseSRDiv,'toggle');
				var runChildCaseSR = component.find("caseSR");
                runChildCaseSR.resetFields();
                var activeSections = ['SR_A','SR_B','SR_C','SR_D','SR_E','SR_F'];
                component.set('v.srActiveSections', activeSections);
                break;
            
            case "showSearch":
                $A.util.addClass(passengerDiv,'toggle');
                $A.util.addClass(caseSRDiv,'toggle');
                $A.util.removeClass(searchDiv,'toggle');
                break;      
        }
        
        console.log("SearchBooking.handleBubbling - Exit");
    }    
})