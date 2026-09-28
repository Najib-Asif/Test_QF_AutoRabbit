({
    InitYearlyView : function(component, event, helper) {
		console.log("valuescamp"+component.get("v.campaignFrYearlyview"));
        var CurrentDate = new Date(component.get("v.CurrentMonth"));        
        console.log("curdate"+CurrentDate);
        var Months = [];
        var monthNumber = [];
        for(var i=6; i<12; i++)
        {
            let date = new Date(CurrentDate.getFullYear(), i);
            Months.push(date);
            let month = {Month:date.getMonth(), Year : date.getFullYear()};
            monthNumber.push(month);
        }
        for(var i=0; i<6; i++)
        {
            let date = new Date(CurrentDate.getFullYear() + 1, i);
            Months.push(date);
            let month = {Month:date.getMonth(), Year : date.getFullYear()};
            monthNumber.push(month);
        }
        component.set("v.Months",Months);
        component.set("v.monthInNumber",monthNumber);

    },
    
    NextPreviousYears : function(component, event, helper)
    {       
		        var CurrentDate = new Date(component.get("v.CurrentMonth"));        
        console.log("curdate"+CurrentDate);
        var Months = [];
        var monthNumber = [];
        for(var i=6; i<12; i++)
        {
            let date = new Date(CurrentDate.getFullYear(), i);
            Months.push(date);
            let month = {Month:date.getMonth(), Year : date.getFullYear()};
            monthNumber.push(month);
        }
        for(var i=0; i<6; i++)
        {
            let date = new Date(CurrentDate.getFullYear() +1, i);
            Months.push(date);
            let month = {Month:date.getMonth(), Year : date.getFullYear()};
            monthNumber.push(month);
        }
        component.set("v.Months",Months);
        component.set("v.monthInNumber",monthNumber);
    },
    
     navigatetoNext : function(component,event,helper)
    {
        var page = component.get("v.page") || 1;
        var recordToDisply = component.find("recordSize").get("v.value");
        page = page + 1;
        
        var YearEvent = component.getEvent("SendYear");
        YearEvent.setParams({"page" : page,
                              "recordToDisply" : recordToDisply});
        YearEvent.fire();
        
    },
    
    navigatePrevious : function(component,event,helper)
    {
        var page = component.get("v.page") || 1;
        var recordToDisply = component.find("recordSize").get("v.value");
        page = page - 1;
        
        var YearEvent = component.getEvent("SendYear");
        YearEvent.setParams({"page" : page,
                              "recordToDisply" : recordToDisply});
        YearEvent.fire();
        
    },
    
    ChangeInRecordNumber : function(component,event,helper)
    {
        var page = 1;
        var recordToDisply = component.find("recordSize").get("v.value");
        
        var YearEvent = component.getEvent("SendYear");
        YearEvent.setParams({"page" : page,
                              "recordToDisply" : recordToDisply});
        YearEvent.fire();
    },
    
    goToRecord : function(component,event,helper)
    {
        var Selecteditem = event.currentTarget; 
        var index = Selecteditem.dataset.record;
        if(index != undefined)
        {
            var SelectedCampaign = component.get("v.campaignFrYearlyview")[index];
            var navigateToRecord = $A.get("e.force:navigateToSObject");
            navigateToRecord .setParams({
                "recordId": SelectedCampaign.Id,
                "slideDevName": "detail"
            });
            navigateToRecord.fire(); 
        }
    }
})