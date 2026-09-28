({
	displayToast : function(component,logCheck,myType,myTitle,myMessage,myDuration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : myTitle,
            message: myMessage,
            duration: myDuration,
            type: myType,
            mode: 'Timed'
        });
        toastEvent.fire();	
        if(logCheck == 'valid'){
            window.setTimeout(
                $A.getCallback(function() {
                    // log out from salesforce
                    window.location.replace(component.get('v.baseUrl')+"/secur/logout.jsp");
                }), 1000
            );            
        }
        else{
            this.toggleCurrentUtility(component);
            setTimeout($A.getCallback(
                // function(){...} is replaced by () in ECMAscript 6
                () => this.openCaseOwnerUtility(component,'Change Case Ownership')
            ), 2000);
        }
    },
    toggleCurrentUtility : function(component){
        
        var utilityAPI = component.find("utilitybar");
        
        utilityAPI.getUtilityInfo().then(function(response) {
            if (response.utilityVisible) {
                utilityAPI.minimizeUtility();
            }
        }).catch(function(error) {
            console.log(error);
        });        
    },
    openCaseOwnerUtility : function(component,utilityLabelToOpen){
        
        var utilityAPI = component.find("utilitybar");
        
        var uId;
        utilityAPI.getAllUtilityInfo().then(function(response) {
            
            for(var i=0;i<response.length; i++){
                var myUtil = response[i];
                if(myUtil.utilityLabel === utilityLabelToOpen)
                    uId = myUtil.id;
            }
            utilityAPI.openUtility({
                utilityId: uId
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})