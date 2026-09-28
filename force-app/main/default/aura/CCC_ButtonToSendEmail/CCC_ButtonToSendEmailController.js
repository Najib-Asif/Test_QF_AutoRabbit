({
    navToEmail: function (component, event, helper) {
        var actionAPI = component.find("quickActionAPI");
        var args = { actionName: "Case.QCC_Send_Email" };
        
        actionAPI.refresh().then(function (){
            component.find('notifLib').showToast({
                "variant": "info",
                "title": "Note:",
                "mode" : "dismissable",
                "message" : "Template is being loaded, please hang tight you will be redirected automatically to the Email Customer Tab"
            });
            actionAPI.selectAction(args).then(function (result) {
                console.log("In Success");
            }).catch(function (e) {
                if (e.errors) {
                    console.log(e.errors);
                }
            });
        });        
    }
})