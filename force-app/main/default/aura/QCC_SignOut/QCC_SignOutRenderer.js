({
    //GRAPHITE-1152: Case Status -Enhancement
	afterRender: function(component, helper)
	{
        this.superAfterRender();

        var utilityBarAPI = component.find("utilitybar");
        var eventHandler = function(response){
              helper.handleUtilityClick(component, response);
          };

        utilityBarAPI.onUtilityClick({ 
                eventHandler: eventHandler 
        }).then(function(result){
            console.log(result);
        }).catch(function(error){
            console.log(error);
        });

        // now manually invoke action for the first time
        helper.checkForInProgressCases(component);
    }        
})