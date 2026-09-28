({
    selectPassengersAndNavigate : function(component) {
        var capOutput = component.get("v.pnrInformation");
        var localOutput = component.get("v.localCases");
        console.log('Enter Helper Selection method');
        var appEvent = $A.get("e.c:QAC_DataSharingEvent");
        appEvent.setParams({ 
            "pnrInformation" : capOutput,
            "localCases" : localOutput            
        });
        appEvent.fire();
        console.log('Exit Helper Selection method');
    },
    
    onChangeAllSelect : function(component, event, myFlag) 
    {
        var selectedHeaderCheck = event.getSource().get("v.value");
        if(myFlag == "flight"){
            var getAllId = component.find("eachRowCheckFL");
        }
        if(myFlag == "pax"){
            var getAllId = component.find("eachRowCheckPAX");
        }
        
        if(Array.isArray(getAllId))
        {
            for (var i = 0; i < getAllId.length; i++) 
                getAllId[i].set("v.value", (selectedHeaderCheck == true) ? true : false);
        }
        else{
            getAllId.set("v.value", (selectedHeaderCheck == true) ? true : false);
        }
    }
})