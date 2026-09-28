({
    SaveRecord: function(component, event, helper) {
        var Editmode = component.get("v.Editmode");
        console.log('Editmode', Editmode);
        if(Editmode)
        {
            component.set("v.spinner",true);
            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                
                component.set("v.spinner",false);
                component.set("v.showSaveResetBtn",false);
                component.set("v.Buttonlable",'Reset Estimations');
                
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log("Save completed successfully.");
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                    component.set("v.Buttonlable",'Reset Estimations');
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + 
                                JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
            
        }
        else{
            alert("You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary."); 
            component.set("v.showSaveResetBtn",false);
            component.set("v.Buttonlable",'Reset Estimations');
        }
        
    },
    
    ResetEstimations : function(component, event, helper){
        
        var Editmode = component.get("v.Editmode");
        if(Editmode)
        {
            var Estimatedfield = component.get("v.AccountObj");
            Estimatedfield.Estimated_Total_Air_Travel_Spend__c = null;
            Estimatedfield.Estimated_Total_Annual_Revenue__c = null;
            Estimatedfield.Estimated_Total_QF_Dom_Annual_Revenue__c = null;
            Estimatedfield.Estimated_Total_QF_Int_Annual_Revenue__c = null;
            Estimatedfield.Estimated_QF_Dom_Market_Share__c = null;
            Estimatedfield.Estimated_Int_Market_Share__c = null;
            
            component.set("v.AccountObj",Estimatedfield);
            component.set("v.spinner",true);
            
            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                
                component.set("v.spinner",false);
                component.set("v.showSaveResetBtn",false);
                component.set("v.Buttonlable",'Reset Estimations');
                
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log("Save completed successfully.");
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + 
                                JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
        }
        else{
            alert("You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.");
            component.set("v.showSaveResetBtn",false);
            component.set("v.Buttonlable",'Reset Estimations');
        }
    },
    inlineEditTATS : function(component,event,helper){   
        component.set("v.EditModeTATS", true); 
        component.set("v.showSaveResetBtn",true);
        component.set("v.Buttonlable",'Reset');
        setTimeout(function(){ 
            component.find("EditModeTATSId").focus();
        },100);
        
        
    },
    
    inlineEditTQR : function(component,event,helper){   
        component.set("v.EditModeTQR", true); 
        component.set("v.showSaveResetBtn",true);
        component.set("v.Buttonlable",'Reset');
        setTimeout(function(){ 
            component.find("EditModeTQRId").focus();
        },100);
        
        
    },
    inlineEditDQR : function(component,event,helper){   
        component.set("v.EditModeDQR", true); 
        component.set("v.showSaveResetBtn",true);
        component.set("v.Buttonlable",'Reset');
        setTimeout(function(){ 
            component.find("EditModeDQRId").focus();
        },100);
        
        
    },
    inlineEditIQR : function(component,event,helper){   
        component.set("v.EditModeIQR", true); 
        component.set("v.showSaveResetBtn",true);
        component.set("v.Buttonlable",'Reset');
        setTimeout(function(){ 
            component.find("EditModeIQRId").focus();
        },100);
        
        
    },
    inlineEditDQMS : function(component,event,helper){   
        component.set("v.EditModeDQMS", true); 
        component.set("v.showSaveResetBtn",true);
        component.set("v.Buttonlable",'Reset');
        setTimeout(function(){ 
            component.find("EditModeDQMSId").focus();
        },100);
        
        
    },
    inlineEditIQMS : function(component,event,helper){   
        component.set("v.EditModeIQMS", true); 
        component.set("v.showSaveResetBtn",true);
        component.set("v.Buttonlable",'Reset');
        setTimeout(function(){ 
            component.find("EditModeIQMSId").focus();
        },100);
        
        
    },
    
    closeBox : function (component, event, helper) {
        component.set("v.EditModeTATS", false); 
        component.set("v.EditModeTQR", false); 
        component.set("v.EditModeDQR", false); 
        component.set("v.EditModeIQR", false); 
        component.set("v.EditModeDQMS", false); 
        component.set("v.EditModeIQMS", false); 
    },
    onChange : function(component,event,helper){ 
        component.set("v.showSaveResetBtn",true);
    },
    OnCancel : function(component,event,helper){ 
        location.reload();        
    },
    recordUpdated : function(component,event,helper){ 
        var Error = component.get("v.error");
        //component.set("v.Cancel",false);
        console.log('1error ' + Error);
        if(Error != undefined){
            console.log('error not null' + Error);
            var Elementindex = Error.indexOf('access');
            var Elementindex1 = Error.indexOf('not');
            if(Elementindex > 0 && Elementindex1 > 0)
                component.set("v.Editmode",false);}
    }
})