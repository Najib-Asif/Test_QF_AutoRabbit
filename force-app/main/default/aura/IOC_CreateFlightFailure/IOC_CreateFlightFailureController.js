({
    handleSubmit : function(component, event, helper) {
        event.preventDefault();    
        var fields = event.getParam('fields');
        var errorMessage = "";
        if(fields.Failure_Code__c == "" || fields.Affected_Region__c == "" 
           || fields.Affect_Sub_Section__c== null || fields.Affect_Sub_Section__c == ""){
            component.find('myRecordForm').submit(fields);
        }
        if(!fields.Pre_Flight__c && !fields.Post_Flight__c){
            errorMessage+= "Pre Flight or Post Flight";
        }
        if(errorMessage != ""){
            component.set("v.message", "Please input "+ errorMessage +".");
            component.set("v.isError", true);
        }else{
            var myJSON = JSON.stringify(fields);
            console.log(myJSON);
            component.set("v.isError", false);
            var myEvent = component.getEvent("iocData");
            myEvent.setParams({"objFlightFailure": myJSON});
            myEvent.fire();
            
            component.find("overlayLib").notifyClose();
        } 
    }
})