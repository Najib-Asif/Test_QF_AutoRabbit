({
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,helper){
        var pillTarget = component.find("selectedPill");
        var selArr = component.get("v.selectedRecords");
        
        let selectedPills = component.get("v.selectedRecords");
        let toDelIndex = event.getSource().get("v.name");
        
        selectedPills.splice(toDelIndex,1);
        
        component.set("v.selectedRecords",selectedPills);
        
        var name = component.get("v.Name");        
        
        //Added for JIRA CRM-4196.Allow multiple Origin and restrict only 1 destination
        switch(name)
        {
            case "Origin":
                component.set("v.originCountC",selArr.length); 
                var originCount = selArr.length;
                var destinationCount = component.get("v.destinationCountC");
                
                //Disable Origin input field when multiple destination is selected
                if(destinationCount > 1 && (originCount === 1 || originCount != 0))
                {
                    component.find("inputField").set("v.disabled", true);
                }
                //Enable Origin input field when destination =1
                else if(originCount === 0 || (originCount === 1 && destinationCount === 1))
                {
                    component.find("inputField").set("v.disabled", false);
                    
                    //Initialize event
                    var enableDestination = component.getEvent("enabledisable");
                    enableDestination.setParams({
                        "enabledisable":"false",
                        "origindestination":"Destination"
                    });
                    enableDestination.fire();
                }
                break;
            case "Destination":
                var originCount = component.get("v.originCountC");
                component.set("v.destinationCountC",selArr.length); 
                var destinationCount = selArr.length;
                
                //Disable destination  input field when multiple Origin is selected
                if(originCount > 1 && (destinationCount === 1 || destinationCount != 0))
                {
                    component.find("inputField").set("v.disabled", true);
                }
                //Enable destination  input field when Origin =1
                else if(destinationCount === 0 || (originCount === 1 && destinationCount === 1))
                {
                    component.find("inputField").set("v.disabled", false);
                    
                    //Initialize event
                    var enableOrigin = component.getEvent("enabledisable");
                    enableOrigin.setParams({
                        "enabledisable":"false",
                        "origindestination":"Origin"
                    });
                    enableOrigin.fire();
                }
                break;
        }
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        
        var mode = component.get("v.Mode");
        var selArr = component.get("v.selectedRecords");
        
        selArr.push(selectedAccountGetFromEvent);
        component.set("v.selectedRecords" , selArr);
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var name = component.get("v.Name");
        
        //Added for JIRA CRM-4196.Allow multiple Origin and restrict only 1 destination
        switch (name) 
        {
            case "Origin": 
                component.set("v.originCountC",selArr.length);
                var originCount = selArr.length;
                var destinationCount = component.get("v.destinationCountC") === undefined ? 0:component.get("v.destinationCountC") ;
                                
                //Disable Origin input field when multiple destination is selected
                if(originCount === 1 && destinationCount > 1)
                {
                    component.find("inputField").set("v.disabled", true);
                }
                //Enable Origin input field when destination =1
                else if(destinationCount === 1)
                {
                    component.find("inputField").set("v.disabled", false);
                    
                    //Initialize event
                    var disableDestination = component.getEvent("enabledisable");
                    disableDestination.setParams({
                        "enabledisable":"true",
                        "origindestination":"Destination"
                    });
                    disableDestination.fire();
                }
                break;
            case "Destination":   
                component.set("v.destinationCountC",selArr.length);
                var originCount = component.get("v.originCountC");
                var destinationCount = selArr.length;
                
                //Disable destination  input field when destination =1
                if(originCount > 1 && destinationCount === 1)
                {
                    component.find("inputField").set("v.disabled", true);
                }
                //Enable destination  input field when Origin =1
                else if(originCount === 1 && destinationCount > 1)
                {
                    component.find("inputField").set("v.disabled", false);
                    
                    //Initialize event
                    var disableOrigin = component.getEvent("enabledisable");
                    disableOrigin.setParams({
                        "enabledisable":"true",
                        "origindestination":"Origin"
                    });
                    disableOrigin.fire();
                }
                break;
        }
        component.find("inputField").set("v.value",'');
        
    },
    
    handleChange : function(component,event,helper)
    {
        var name = component.get("v.Name");
        var originEnDi = component.get("v.originEnDiC");
        var destinationEnDi = component.get("v.destinationEnDiC");
        var setBoolO = component.get("v.setBoolO");
        var setBoolD = component.get("v.setBoolD");
        if(name === originEnDi && setBoolO != 1)
        {
            component.find("inputField").set("v.disabled", setBoolO);
            //set value = 1 so that handlechange works only for True/False. 
            //Or else when Previous & Current value are True/False Change Handler doesn't trigger
            component.set("v.setBoolO",1);
        }
        else if(name === destinationEnDi && setBoolD != 1)
        {
            component.find("inputField").set("v.disabled", setBoolD);
            //set value = 1 so that handlechange works only for True/False. 
            //Or else when Previous & Current value are True/False Change Handler doesn't trigger
            component.set("v.setBoolD",1);
        }
    },
})
//<!-- Controller--><!-- Controller-->