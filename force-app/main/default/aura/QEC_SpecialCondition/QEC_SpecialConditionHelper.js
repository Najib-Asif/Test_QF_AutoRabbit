({
    getFieldMap : function(component) {
        var action = component.get("c.getFieldMap");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.fieldMap", response.getReturnValue());
            }
        })
        $A.enqueueAction(action);
    },
    getPicklistMap : function(component) {
        var action = component.get("c.getPicklistMap");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.conditionTypes", response.getReturnValue()["QEC_Type__c"]);
                component.set("v.cabinOptions", response.getReturnValue()["QEC_Cabin__c"]);
                //component.set("v.fareOptions", response.getReturnValue()["QEC_Booking_Class__c"]);
                //console.log("picklist options " + JSON.stringify(response.getReturnValue()));
                component.set("v.pickListMap",response.getReturnValue());
                var bookingClassOptions = [];
                var bookingClasses = response.getReturnValue()["QEC_Booking_Class__c"];
                for(var i=0; i< bookingClasses.length; i++){
                    bookingClassOptions.push({ label: bookingClasses[i], value: bookingClasses[i]});   
                }
                component.set("v.fareOptions", bookingClassOptions);
                component.set("v.selectedFare", '');
                
                var cabinClassOptions = [];
                var cabinClasses = response.getReturnValue()["QEC_Cabin__c"];
                for(var i=0;i<cabinClasses.length; i++){
                    cabinClassOptions.push({ label: cabinClasses[i], value: cabinClasses[i]});
                }
                component.set("v.cabinOptions",cabinClassOptions);
                component.set("v.selectedCabin",'');
            }
        })
        $A.enqueueAction(action);
    },
    /*getFares : function(component) {
        var action = component.get("c.getFares");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var options = [];
                var result = response.getReturnValue();
                var str = ' ~ ';
                for(var i=0; i< result.length; i++){
                    options.push({ label: result[i].Name+str+result[i].Market__c+str+result[i].ProductCode__c, id: result[i].Id});   
                }
                component.set("v.fareOptions", options);
                component.set("v.selectedFare", '');
            }
        });
        $A.enqueueAction(action);
    }, */ 
    getSpecialConditions : function(component) {
        var action = component.get("c.getSpecialConditions");
        action.setParams({
            recordId:component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.specialConditionMap", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);    
    },
    getObjectType : function(component) {
        var action = component.get("c.getObjectType");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==="SUCCESS") {
                component.set("v.objectType", response.getReturnValue());
                console.log("the object is" + response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})
 //<!-- Helper  --><!-- Helper  -->