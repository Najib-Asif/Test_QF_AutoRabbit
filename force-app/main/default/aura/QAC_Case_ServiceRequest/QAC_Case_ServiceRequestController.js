({    
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", false);
        
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleApplicationEvent : function(component, event, helper) 
    {
        console.log("QAC_Case_ServiceRequest.handleApplicationEvent: entry");
        var params = event.getParams();
        
        if(params.recordTypeId != null){
            component.set("v.recordTypeId", params.recordTypeId);            
        }
        if(params.pnrInformation != null){
            component.set("v.pnrInformation", params.pnrInformation);
        }
        console.log("Rec Type ??" +params.recordTypeId);        
        console.log("QAC_Case_ServiceRequest.handleApplicationEvent: exit");
    },
    
    handleBack : function(component, event, helper) {
        component.set("v.resetForm", false);
        
        var cmpEvent = component.getEvent("bubblingEvent");
        console.log('cmpEvent: ' + cmpEvent);
        cmpEvent.setParams({"ComponentAction" : 'showPassengers' });
        cmpEvent.fire(); 
    },
    	
    handleInsert : function(component, event, helper) 
	{
        component.set("v.showSpinner", true);
        //helper.fetchFieldNames(component,event);
		var invalidFields = helper.isFormValid(component);
        var myMap = component.get("v.requiredFieldsMap");
		var myFieldSet = component.find('requiredFields');
        console.log("invalid fields"+JSON.stringify(invalidFields));
        var errorfound = false;
        var errorNote;
        
        // remove errors before starting valid check
        for (var i = 0; i < myFieldSet.length; i++)
        {
            $A.util.removeClass(myFieldSet[i],'slds-has-error');
            errorNote = component.find(myFieldSet[i].get('v.fieldName'));
            $A.util.removeClass(errorNote,'errorNoteClass');
            $A.util.addClass(errorNote,'none');
        }
        
        // add (or) remove error on Account 
		var accId = component.find("srAccountId");
        var accerrorNoteText = component.find("Accounterr");
        if(accId.get("v.value") == null || accId.get("v.value") == ''){
            console.log('inside account check');
            errorfound = true;
            $A.util.addClass(accId,'slds-has-error');
            $A.util.addClass(accerrorNoteText,'errorNoteClass');
            $A.util.removeClass(accerrorNoteText,'none');
            setTimeout($A.getCallback(function(){
                document.getElementById("Accounterr").focus();
                component.set("v.showSpinner", false);
            }),1000);
        }
        else{
            $A.util.removeClass(accId,'slds-has-error');
            $A.util.removeClass(accerrorNoteText,'errorNoteClass');
            $A.util.addClass(accerrorNoteText,'none');
        }        

        // add (or) remove error on Other fields
        if(invalidFields && invalidFields.length > 0){
            console.log('inside other fields check');
            errorfound = true;
            for (var i = 0; i < myFieldSet.length; i++)
            {
                if(invalidFields.includes(myFieldSet[i].get('v.fieldName')))
                {
                    $A.util.addClass(myFieldSet[i],'slds-has-error');
                    errorNote = component.find(myFieldSet[i].get('v.fieldName'));
                    $A.util.addClass(errorNote,'errorNoteClass');
                    $A.util.removeClass(errorNote,'none');  
            	}
            }
            setTimeout($A.getCallback(function(){
                document.getElementById(invalidFields[0]).focus();
                //document.getElementById(invalidFields[0]).parentNode.scrollTop;
                component.set("v.showSpinner", false);
            }),1000);
        }
        
        var fieldNames = invalidFields.map(j => myMap[j]);
        if(errorfound)
        {
            helper.displayToast('error','Please fill all these fields','REQUIRED: '+ (fieldNames && fieldNames.length > 0 ? fieldNames.join(', ') : 'Account'), 2000);
            event.preventDefault();
            window.scrollTo(0,0);
            return;
        }
		else{
            console.log('Insert Case');
            component.find("editFormSR").submit();			
		}
    },
    handleErrors : function(component, event, helper) {
        component.set("v.showSpinner", false);
        window.scrollTo(0,0);
    },
    
    handleSuccess : function(component, event, helper) {
        
        // component.set("v.showSpinner", true);
        var caseId;
        var flights = component.get("v.pnrInformation.flightDetailsWrapper");
        var passengers = component.get("v.pnrInformation.passengerDetailsWrapper");
        var caseFields = component.get("v.pnrInformation.caseFields");
        console.log('Passengers List ' + passengers);
        
        //Calling the Apex Function
        var action = component.get("c.createCase");
        var payload = event.getParams().response;
        console.log(payload.id);
        component.set('v.recordId', payload.id);
        //Json Encode to send the data to Apex Class
        var Strflights = JSON.stringify(flights);
        var StrPassengers = JSON.stringify(passengers);
        var StrCaseFields = JSON.stringify(caseFields);
        //Setting the Apex Parameter
        
        action.setParams({
            "flights" : Strflights,
            "passengers": StrPassengers,
            "caseFields" : StrCaseFields, 
            "caseId" : component.get('v.recordId')
        });
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                console.log( 'check case id ' + a.getReturnValue());
                console.log( 'check case id ' + payload.Id	);
                caseId = a.getReturnValue();
                
                var cmpEvent = component.getEvent("bubblingEvent");
                console.log('cmpEvent: ' + cmpEvent);
                cmpEvent.setParams({"ComponentAction" : 'showSearch' });
                cmpEvent.fire();
                
                helper.refreshBookingOnSuccess(component,event);
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": caseId
                });
                navEvt.fire();
                component.set("v.showSpinner", false);
            } 
            else if(state == "ERROR"){
                component.set("v.showSpinner", false);
                console.log('Exception ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    onChangeType: function(component, event, helper) {
        component.set("v.refreshFlag", true);
    },
    
    resetCaseFields : function(component,event,helper){
        console.log("Reset Flag:"+component.get("v.resetForm"));
        console.log("inside Reset");
        window.scrollTo(0,0);
        component.set("v.resetForm", true);
        
        var pnrInfo = component.get("v.pnrInformation");
        console.log('Check accountId ' + pnrInfo.caseFields.iataAccount.Id);
        component.find("srAccountId").set("v.value", pnrInfo.caseFields.iataAccount.Id);
        
        helper.fetchFieldNames(component,event);
    }
})