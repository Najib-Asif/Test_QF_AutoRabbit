({
    doInit : function (component, event, helper) {  
        var action = component.get('c.getBasicInfo');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = JSON.parse(response.getReturnValue());
                component.set('v.baseUrl', result.baseURL);
                component.set('v.user', result.currentUser);
                
                //GRAPHITE-1152: Case Status -Enhancement                
                helper.checkForInProgressCases(component, event, helper); 
            }
        })
        $A.enqueueAction(action);
    },
    
    logOut : function(component, event, helper) {
        var currentUser = component.get('v.user');
        console.log(currentUser);
        var Name;
        if(currentUser.Profile){
            Name = currentUser.Profile.Name;
        }
        console.log(currentUser.Location__c);
        if( currentUser.Location__c != 'Sydney' && 
           (Name != null && (Name =='Qantas CC Consultant')) ){
            helper.closeAllTab(component, event, helper); 
        }
        helper.reassignCases(component, event, helper);
    }
})