({
    CreatRecord : function(component, event, helper) {     
        var action = component.get("c.Newproposal");	        
        action.setParams({
            "Oppid" : component.get("v.recordId")
        });
        console.log('inside create record function1');
        action.setCallback(this, function(response) {   
            var state = response.getState();
            console.log('State of the response '+state);
            if (state === "SUCCESS") {
                var output =  JSON.parse(response.getReturnValue());
                var resultsToast = $A.get("e.force:showToast");
                console.log('Return Value',response.getReturnValue());
                if(output.isSuccess)
                {                
                    resultsToast.setParams({
                        "title": "Error Occured:",
                        "type": "error",
                        "mode": "sticky",
                        "message": output.Message
                    });
                    resultsToast.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                else
                {                              
                    var createRecordEvent = $A.get("e.force:createRecord");
                    console.log('recordtypeid',output.MyPropObj.RecordTypeId)
                    createRecordEvent.setParams({
                        "entityApiName": 'Proposal__c',
                        "recordTypeId": output.MyPropObj.RecordTypeId,
                        'defaultFieldValues': {
                            'Opportunity__c': output.MyPropObj.Opportunity__c,
                            'Qantas_Annual_Expenditure__c': output.MyPropObj.Qantas_Annual_Expenditure__c,
                            'Domestic_Annual_Share__c': output.MyPropObj.Domestic_Annual_Share__c,
                            'International_Annual_Share__c': output.MyPropObj.International_Annual_Share__c,
                            'Forecast_Charter_Spend__c': output.MyPropObj.Forecast_Charter_Spend__c,
                            'Forecast_MCA_Revenue__c': output.MyPropObj.Forecast_MCA_Revenue__c,
                            'Deal_Type__c': output.MyPropObj.Deal_Type__c,
                            'MCA_Routes_Annual_Share__c': output.MyPropObj.MCA_Routes_Annual_Share__c,                        
                            'Type__c': output.MyPropObj.Type__c,
                            'Contact__c': output.MyPropObj.Contact__c,
                            'Account__c': output.MyPropObj.Account__c,
                            'QL_Actual_Estimated_Dom_QF_Market_Share__c':output.MyPropObj.QL_Actual_Estimated_Dom_QF_Market_Share__c //Proposal 2 Tier Changes-CRM-5224
                        }
                    });
                    createRecordEvent.fire();     
                }    
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var errorToast = $A.get("e.force:showToast");
                            errorToast.setParams({
                                "title": "Error Occured:",
                                "type": "error",
                                "mode": "sticky",
                                "message": errors[0].message
                            });
                            errorToast.fire();
                            $A.get("e.force:closeQuickAction").fire();
                            
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }    
    
})