({
    doInit : function(component, event, helper) {
        //helper.getMonthHeaders(component,event,helper);
        var Recordperpage = [50, 100, 200];
        var items = [];
        for(var i=0; i<Recordperpage.length; i++)
        {
            var item = {
                "label" : Recordperpage[i],
                "value" : Recordperpage[i]
            };
            items.push(item);
        }
        //component.set("v.RecordsPerPage",items);
        
        
    },
    
    navigatetoNext : function(component,event,helper)
    {
        var page = component.get("v.page") || 1;
        var recordToDisply = component.find("recordSize").get("v.value");
        page = page + 1;
        
        var MonthEvent = component.getEvent("SendMonth");
        MonthEvent.setParams({"page" : page,
                              "recordToDisply" : recordToDisply});
        MonthEvent.fire();
        
    },
    
    navigatePrevious : function(component,event,helper)
    {
        var page = component.get("v.page") || 1;
        var recordToDisply = component.find("recordSize").get("v.value");
        page = page - 1;
        
        var MonthEvent = component.getEvent("SendMonth");
        MonthEvent.setParams({"page" : page,
                              "recordToDisply" : recordToDisply});
        MonthEvent.fire();
        
    },
    
    ChangeInRecordNumber : function(component,event,helper)
    {
        var page = 1;
        var recordToDisply = component.find("recordSize").get("v.value");
        
        var MonthEvent = component.getEvent("SendMonth");
        MonthEvent.setParams({"page" : page,
                              "recordToDisply" : recordToDisply});
        MonthEvent.fire();
    },
    
    handleShowPopover : function(component, event, helper) {
    component.find('overlayLib').showCustomPopover({
    body: "Popovers are positioned relative to a reference element",
    referenceSelector: ".mypopover",
    cssClass: "slds-nubbin_left,slds-popover_walkthrough,no-pointer,cQL_Campaign_Calendar_Month"
}).then(function (overlay) {
    setTimeout(function(){
        //close the popover after 3 seconds
        overlay.close();
    }, 3000);
});
},
    goToRecord : function(component,event,helper)
{
    var Selecteditem = event.currentTarget; 
    var index = Selecteditem.dataset.record;
    if(index != undefined)
    {
        var SelectedCampaign = component.get("v.Campaigns")[index];
        var navigateToRecord = $A.get("e.force:navigateToSObject");
        navigateToRecord .setParams({
            "recordId": SelectedCampaign.Id,
            "slideDevName": "detail"
        });
        navigateToRecord.fire(); 
    }
},
    openPop : function(component, event, helper) {
        var src = event.getSource();
        alert('helo '+src.get("v.value"));		
    },
        closepop : function(component, event, helper) {
            component.set("v.popover",false);		
        }

})