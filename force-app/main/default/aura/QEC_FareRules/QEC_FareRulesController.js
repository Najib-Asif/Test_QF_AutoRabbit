({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRuleGuidelines");
        action.setParams({
            dealType : $A.get('{!$Label.c.QEC_Deal_Type}'),
            marketSegment :$A.get('{!$Label.c.QEC_Market_Segment}'),
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var dealTypeArray = $A.get('{!$Label.c.QEC_Deal_Type}');
                var optionsArray = dealTypeArray.split(',');
                var newOptions =[];
                for(var y in optionsArray){
                    var newValue={
                        label : optionsArray[y],
                        value:optionsArray[y],
                        selected:false
                    };
                    newOptions.push(newValue);
                }
                var results = response.getReturnValue();
                console.log('results----'+JSON.stringify(results));
                if(null != results && results.length > 0){
                    var region = results[0].location;
                    if(region != 'AU'){
                        component.set("v.AUregion",false);
                        component.set("v.nonAUTable", results);
                    }else{
                        var privateFare =[];
                        var netFare = [];
                        for(var x in results){
                            if(results[x].dealType =='DOMESTIC'){
                                privateFare.push(results[x]);
                            }else if(results[x].dealType=='INTERNATIONAL'){
                                netFare.push(results[x]);
                            }
                        }
                        component.set("v.AUregion",true);
                        component.set("v.privateFareTable", privateFare);
                        component.set("v.netFareTable", netFare);
                        
                    }
                }
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
            }
        })
        $A.enqueueAction(action);
    },
    handleSave : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        var pvtFare = component.get("v.privateFareTable");
        var netFare = component.get("v.netFareTable");
        var action = component.get("c.saveFareRules");
        var region = component.get("v.AUregion");
        
        var dataSelected =[];
        if(region){
        for(var x in pvtFare){
            dataSelected.push(pvtFare[x]);
        }
        for(var x in netFare){
            dataSelected.push(netFare[x]);
        }
        }else{
            dataSelected = component.get("v.nonAUTable");
        }
        action.setParams({
            ruleList : dataSelected,
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            $A.util.addClass(spinner, "slds-hide");
            var state = response.getState();
            if(state === 'SUCCESS') {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    mode: 'sticky',
                    message: 'Data Saved successfully.',
                    type : 'success',
                    duration:'50',
                    mode: 'dismissible'
                });
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        })
        $A.enqueueAction(action);
    }
    
})