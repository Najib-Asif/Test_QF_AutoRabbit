({	 
    changeSegment: function (component, event, helper) {
        component.set("v.showSpinner", true);
        console.log('PassengerPushDebug***'+JSON.stringify(component.get("v.passenger")));
        console.log('PassengerPushDebugseg***'+JSON.stringify(component.get("v.segment")));
        console.log('PassengerPushDebugCD***'+JSON.stringify(component.get("v.creationDate")));
        var formatDate =  $A.localizationService.formatDate('2018-11-23 12:51:00', "DD/MM/YYYY");
        let commPerFlightArr = [];
        let commData = [];
        if(component.get("v.disptCommData").length > 0){
            commData = component.get("v.disptCommData");
            for(let i=0;i<commData.length;i++){
                if(component.get("v.segment").operatingFlightNumber == commData[i].flightNumber)
                    commPerFlightArr.push(commData[i]);
            }
            component.set("v.disptCommPerFlight",commPerFlightArr);
            //$A.util.toggleClass(spinner, "slds-hide");
            component.set("v.showSpinner", false);
        }else{
            var action = component.get("c.getCommunicationTblHeaders");
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log('PushTable'+JSON.stringify(response.getReturnValue()));
                    component.set('v.disptCommColumns',response.getReturnValue());
                    helper.getFlightCommDet(component);
                    
                }
            });
            $A.enqueueAction(action);
            
        }
    }
})