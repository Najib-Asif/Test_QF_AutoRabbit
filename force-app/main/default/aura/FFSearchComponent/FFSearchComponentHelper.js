({
    SearchHelper: function(component, event) {
        component.set("v.showSpinner",true);
        var action = component.get("c.invokeWebServiceCAP");        
        action.setParams({
            "ffnumber": component.get("v.ffnumber")
        });
        console.log('ffnumber : '+component.get("v.ffnumber"));
        var listFF = [];
        
        action.setCallback(this, function(response) {
            component.set("v.showSpinner",false);
            var state = response.getState();
            console.log('***State***'+state);
            if (state === "SUCCESS") {     
                
                var output = response.getReturnValue();
                //component.set(ListtoString,output);
                //console.log('***output**'+output);
                console.log('***output**'+JSON.stringify(output));
                component.set("v.freqFlyerList",output);
                
                
                for(var i in output){ 
                    console.log('***Valueofifromctrlr**'+i);
                    //console.log('***Valueofifromctrlr**'+output[i]);
                    var FreqFlyer = JSON.parse(output[i]);
                    console.log('FreqFlyer********',FreqFlyer);
                    var fname = null;
                    if (FreqFlyer.qantasFrequentFlyerProfile != null)
                    {
                   		fname = FreqFlyer.qantasFrequentFlyerProfile.firstName+' '+FreqFlyer.qantasFrequentFlyerProfile.lastName;
                    }
                    
                    var email = FreqFlyer.qantasFrequentFlyerContact != null ? FreqFlyer.qantasFrequentFlyerContact.emails[0].emailAddress : null;
                    var mid =   FreqFlyer.qantasFrequentFlyerProfile != null ? FreqFlyer.qantasFrequentFlyerProfile.memberId : null;
                    
                    console.log('***programDetails**'+FreqFlyer.programs);
                    /*for(var j in FreqFlyer.programDetails) {	
                        console.log('***tierName**'+FreqFlyer.programDetails[j].tierName);	
                        if(FreqFlyer.programDetails[j].ffExpireDate != null) {	
                            var pgmTier = FreqFlyer.programDetails[j].tierName;                		
                        }	
                        if(FreqFlyer.programDetails[j].ffExpireDate != null) {	
                            var pgmExp = FreqFlyer.programDetails[j].ffExpireDate;	
                        } 
                      }*/ /*CRM -5003*/
                    var pgmExp = null;
                    for(var j in FreqFlyer.programs) {
                        if(FreqFlyer.programs[j].ffExpireDate != null) {
                            pgmExp = FreqFlyer.programs[j].ffExpireDate;
                        }                
                    }
                    var pgmTier = null;
                    for(var j in FreqFlyer.qantasFrequentFlyerTiers) {
                        console.log('*qantasFrequentFlyerTier*'+FreqFlyer.qantasFrequentFlyerTiers[j].qantasFrequentFlyerTier);
                        if(FreqFlyer.qantasFrequentFlyerTiers[j].qantasFrequentFlyerTier != null) { 
                        console.log('*qantasFrequentFlyerTier.tiercode*'+FreqFlyer.qantasFrequentFlyerTiers[j].qantasFrequentFlyerTier.tierCode);
                        if(FreqFlyer.qantasFrequentFlyerTiers[j].qantasFrequentFlyerTier.tierCode != null) {
                            pgmTier = FreqFlyer.qantasFrequentFlyerTiers[j].qantasFrequentFlyerTier.tierCode;                	
                        }
                      }
                    }
                    var reqType = null;
                    var upgrdtier = null;
                    listFF.push(
                        {
                            key1:fname,
                            key2:mid,
                            key3:email,
                            key4:pgmTier,
                            key5:pgmExp,
                            key6:reqType,
                            key7:upgrdtier                                       
                        }
                    );
                }
                console.log('list FF**'+JSON.stringify(listFF));
                component.set("v.freqFlyerList",listFF);
                
                // if output size is 0 ,display no record found message on screen.
                if (output.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set numberOfRecord attribute value with length of return value from server
                component.set("v.TotalNumberOfRecord", output.length);
                
                // set searchResult list with return value from server.
                component.set("v.searchResult", output); 
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
            
        }); 
        $A.enqueueAction(action);
    },     
    
    CreateHelper: function(component, event) {
        component.set("v.showSpinner",true);
        //call apex class method
        var action = component.get('c.addParentCase');
        //var objList = component.get("v.selectedFlyers");
        var myMap = component.get("v.selectedFlyers");
        console.log('type 2-' + typeof myMap);
        console.log('ValuesOfmyMap' +JSON.stringify(myMap));
        action.setParams({
            "caseId": component.get("v.CaseId"),
            "accountId" : component.get("v.AccountId"),
            "results" : JSON.stringify(myMap),
            "RecordType" : component.get("v.RecordType")
        });
        
        action.setCallback(this, function(response) {
            component.set("v.showSpinner",false);
            console.log('state'+JSON.stringify(response));
            var state = response.getState();
            var output = response.getReturnValue();				
            if (state === "SUCCESS") {            
                // display SUCCESS message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": output
                });
                toastEvent.fire();
                // refresh/reload the page view
                $A.get('e.force:refreshView').fire();
                
            }                
        });
        $A.enqueueAction(action);   
    },
})