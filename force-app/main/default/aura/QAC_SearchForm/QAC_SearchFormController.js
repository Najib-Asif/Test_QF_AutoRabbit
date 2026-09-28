({
    changeCaseLastName : function(component, event, helper) {
        var lastname = component.get("v.lastName");
        component.set("v.lastName", lastname.toUpperCase());
    },
    
    changeCasePNR : function(component, event, helper) {
        var pnrNumber = component.get("v.pnrNumber");
        
        component.set("v.pnrNumber", pnrNumber.toUpperCase());
    },
    
    searchData : function(component, event, helper) {
        console.log('Inside the searchData');
        component.set("v.showSpinner", true);
        
        var pnr = component.get("v.pnrNumber");
        var lastname = component.get("v.lastName");
        // for CAP Search
        if((pnr == undefined || pnr == '') || (lastname == undefined || lastname == '')){ 
            component.set("v.showSpinner", false);
            helper.displayToast('Information Not Provided','Please provide PNR and Last Name');
        }
        else{
            var includeLocalSearch = component.find("chkbox");
            component.set("v.localCases",null);
            
            // for Local Search
            if(includeLocalSearch.get("v.value")){
                helper.localSearchAction(component,event);
            }
            else{
                component.set("v.localAvailable",false);
            }			
            helper.searchCapAction(component,event);
        }
    },
    
    resetData : function(component, event, helper) {
        component.set("v.lastName", '');
        component.set("v.pnrNumber", '');
    },
    //CRM-8136 Live PNR Details
    setSearchParams: function(component, event, helper)
    {
        var params = event.getParam('arguments');
        component.set("v.pnrNumber", params.pnrNumber);
        component.set("v.lastName", params.lastName);
        component.set("v.localAvailable",false);
        component.set("v.localCases",null);
        
        if(params.pnrNumber && params.lastName)
        {
            helper.searchCapAction(component,event);
        }
            
    }
})