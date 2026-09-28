({	
    //get user Profile to check for system admin
    getUserProfile : function(component){
		var action = component.get("c.getProfileName");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==="SUCCESS"){
                //console.log('Profile Name'+response.getReturnValue());
                if(response.getReturnValue()==='System Administrator'){
                    component.set("v.isSystemAdmin", true);
                }else{
                    component.set("v.isSystemAdmin", false);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    //method to navigate to when sys admin clicks new Frequent flyer Information
    navigateToFFCreatePage : function(component){
        var caseId = component.get("v.recordId");
        var currentUrl = window.location.href;
        var ffUrl = '/a0t/e?saveURL=%2F'+component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({"url":ffUrl});
        urlEvent.fire();
    },
    
    //fetch Frequent Flyer Info from apex
	FFInfo : function(component) {
		var action = component.get("c.getFFInfo");
        action.setParams({caseId:component.get("v.recordId")});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==="SUCCESS"){
                component.set("v.FrequentFlyers",response.getReturnValue());
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + 
                                 errors[0].message);
                component.set("v.error","Failed to retrieve Frequent Flyer Informations.");
            }
            else{
                component.set("v.error","Failed to retrieve Frequent Flyer Informations.");
            }
        });
        $A.enqueueAction(action);
	},
    
    //columns to be displayed in the data table
    setUpColumns : function(component){
        var columns = [
            { label: 'Frequent Flyer Information Name', fieldName: 'Name', type: 'text',wrapText: true,
             cellAttributes: { class: 'bold-cell'}
            },
            {label:'Frequent Flyer Number', fieldName:'Frequent_Flyer_Number__c', type:'text'},
            {label:'Freq Flyer Expiry Date', fieldName:'Freq_Flyer_Expiry_Date__c', type: "date-local",
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        }},
            {label:'Upgrade Tier Requested', fieldName:'Upgrade_Tier_Requested__c', type:'text'},
            {label:'Request Type', fieldName:'Request_Type__c', type:'text',wrapText: true},
            {label: '', type: 'button', initialWidth: 135, 
             typeAttributes: { label: 'View Details', name: 'view_details', title: 'Click to View Details'}}
        ];
        component.set("v.columns",columns);
    },
    
    //method to open the FF in a new subtab
    showRowDetails : function(component,row) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response.tabId,
                url: '/lightning/r/Frequent_Flyer_Information__c/'+row.Id+'/view',
                focus: true
            }).catch(function(error) {
            		console.log(error);
       		 	})
        })
        
    }
})