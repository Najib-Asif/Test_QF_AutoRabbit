({
    displayToast : function(myType,myTitle,myMessage,myDuration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : myTitle,
            message: myMessage,
            duration: myDuration,
            type: myType,
            mode: 'dismissible'
        });
        toastEvent.fire();	
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
    },
    refreshCurrentUtility : function(component){
        var utilityBarAPI = component.find("utilitybar");
        var eventHandler = function(response){
            component.reInit();
            console.log(response);
        };
        
        utilityBarAPI.onUtilityClick({ 
            eventHandler: eventHandler 
        }).then(function(result){
            console.log(result);
        }).catch(function(error){
            console.log(error);
        });                
    },
    changeCacheSession : function(component){
        var action = component.get('c.modifyCacheSettings');
        $A.enqueueAction(action);
    }
})