({
	getFlightCommDet : function(component) {
		var action = component.get("c.getFlightCommDetails");
        action.setParams({"pnr":component.get("v.pnr"),
                          "firstName":component.get("v.passenger").firstName,
                          "lastName":component.get("v.passenger").lastName,
                          "creationDate":component.get("v.creationDate")});
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                let commPerFlightArr = [];
                let commResponse = [];
                console.log('responseRet**'+response.getReturnValue());
                if(response.getReturnValue() != null)
                	commResponse = response.getReturnValue().booking.communicationDetails;
                //commResponse=[{"sourceSystem":"15BELOW","communicationType":"DISRUPT","direction":"OUT","disruptionCategory":"BLUE","contactType":"SMS","communicationSentLocalTimestamp":"","communicationSentUTCTimestamp":"2018-11-23 01:51:00","segmentTattoo":"1","carrierCode":"QF","flightNumber":"1015","departurePort":"SYD","departureLocalDateTime":"2018-11-22 14:00:00","arrivalPort":"MEL"},{"sourceSystem":"15BELOW","communicationType":"DISRUPT","direction":"OUT","disruptionCategory":"RED","contactType":"EMAIL","communicationSentLocalTimestamp":"2018-11-23 12:51:00","communicationSentUTCTimestamp":"2018-11-23 01:51:00","segmentTattoo":"1","carrierCode":"QF","flightNumber":"0433","departurePort":"MEL","departureLocalDateTime":"2018-11-22 14:00:00","arrivalPort":"HBA"},{"sourceSystem":"15BELOW","communicationType":"DISRUPT","direction":"OUT","disruptionCategory":"GREEN","contactType":"CALL","communicationSentLocalTimestamp":"2018-11-23 12:51:00","communicationSentUTCTimestamp":"2018-11-23 01:51:00","segmentTattoo":"1","carrierCode":"QF","flightNumber":"0433","departurePort":"SYD","departureLocalDateTime":"2018-11-22 14:00:00","arrivalPort":"MEL"}];
                if(commResponse.length >0){
                    console.log('CommResponse***'+JSON.stringify(commResponse));
                    
                    for(let i=0;i<commResponse.length;i++){
                        console.log('sentTime***'+commResponse[i].communicationSentLocalTimestamp);
                        if(commResponse[i].communicationSentLocalTimestamp != "")
                        	commResponse[i].communicationSentLocalTimestamp = $A.localizationService.formatDate(commResponse[i].communicationSentLocalTimestamp.split(' ')[0], "DD/MM/YYYY")+' '+commResponse[i].communicationSentLocalTimestamp.split(' ')[1];
                        if(component.get("v.segment").operatingFlightNumber == commResponse[i].flightNumber)
                            commPerFlightArr.push(commResponse[i]);
                    }
                    component.set("v.disptCommData",commResponse);
                    component.set("v.disptCommPerFlight",commPerFlightArr);
                }
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
	}
})