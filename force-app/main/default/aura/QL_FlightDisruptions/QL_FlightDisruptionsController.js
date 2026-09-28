({
    fetchFlightDisruptionDetails : function(component) {
        var action = component.get("c.getFlightDisruptionDetails");
        action.setParams({
            "ffNum" : component.get("v.Frequentflyernumber")
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null){
                    if(result.disruptCount){
                        var disruptCount = (result.disruptCount.delay + result.disruptCount.cancel).toString();
                        component.set("v.disruptCount",disruptCount);
                    }
                    if(result.disruptFlight){
                        var disruptRec = [];
                        for(var i=0; i<result.disruptFlight.length; i++){
                            var deptDate = result.disruptFlight[i].bookedFlight.scheduledDepartureLocalDate;
                            result.disruptFlight[i].bookedFlight.scheduledDepartureLocalDate = $A.localizationService.formatDate(deptDate, "DD/MM/YYYY");
                            if(result.disruptFlight[i].disruptionEventType == 'CANCEL'){
                                if(result.disruptFlight[i].bookedFlight.departureDelayInMinute == null)
                                    result.disruptFlight[i].bookedFlight.departureDelayInMinute = 'NA';
                                if(result.disruptFlight[i].bookedFlight.arrivalDelayInMinute == null)
                                    result.disruptFlight[i].bookedFlight.arrivalDelayInMinute = 'NA';
                            }
                            
                            disruptRec.push(result.disruptFlight[i]);
                        }
                        component.set("v.disruptRec",disruptRec);
                    }
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    navigateToDisruptComp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:QCC_CustomerDisruptionSummary",
            componentAttributes: {
                disruptionList : component.get("v.disruptRec"),
                conDetails : component.get("v.contactDetails"),
                recordId : component.get("v.RecId")
            }
            
        });
        evt.fire();
    }
})