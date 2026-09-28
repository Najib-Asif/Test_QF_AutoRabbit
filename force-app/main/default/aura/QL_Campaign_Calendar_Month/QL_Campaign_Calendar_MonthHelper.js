({
    getMonthHeaders : function(component,event,helper) {
        //component.set("v.Spinner",true);
        
        if(component.get("v.ButtonValue") == 'previousmonth')
            var action1 = component.get("c.previousMonth");
        else if(component.get("v.ButtonValue") == 'nextmonth')
            var action1 = component.get("c.nextMonth");
        else if(component.get("v.ButtonValue") == 'RecordtypeChanged')
            var action1 = component.get("c.populateDateAndCampaigns");
            else{
                var action1 = component.get("c.populateDateAndCampaigns");
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                component.set("v.today",today);
                component.set("v.Month",today);
            }
        var date = new Date(component.get("v.today"));
        var MonthEvent = component.getEvent("SendMonth");
        console.log("values12 "+component.get("v.Month")+" "+new Date(date.getFullYear(), date.getMonth(), 1)+" "
                   +component.get("v.page") || 1);
        
        MonthEvent.setParams({"Month" : component.get("v.Month"),
                              "StartDate" : new Date(date.getFullYear(), date.getMonth(), 1),
                              "EndDate" : new Date(date.getFullYear(), date.getMonth() + 1, 0),
                              "page" : component.get("v.page") || 1,
                              "recordToDisply" : component.get("v.recordToDisply") || 50,
                              "view" : 'monthlyview'});
       // MonthEvent.fire();
        
        /*var btn = event.getParam('arguments');
        
        if(component.get("v.ButtonValue") == 'previousmonth' || component.get("v.ButtonValue") == 'nextmonth' || component.get("v.ButtonValue") == 'RecordtypeChanged')
            action1.setParams({  paramDate : component.get("v.today")  });
            else
            action1.setParams({  paramDate : today  });
        
        action1.setCallback(this, function(response) {
            
            component.set("v.Spinner",false);
            
            var state = response.getState();
            var result = response.getReturnValue();
            console.log("result "+result+"state"+state);
            if (state === "SUCCESS") {
                component.set("v.SplitDates",response.getReturnValue());
                
                var Splitdates = response.getReturnValue();
                var Campaign = component.get("v.allCampaigns");
                var CampaignToShow = [];
                for(var k=0; k<Campaign.length;k++)
                {
                    for(var i=0; i<Splitdates.length; i++)
                    {
                        var datevalue = Splitdates[i].dateCams;
                        for(var j=0; j<datevalue.length; j++)
                        {
                            if(datevalue[j].isInCurrentMonth && (datevalue[j].sDate >= Campaign[k].StartDate && datevalue[j].sDate <= Campaign[k].EndDate))
                            {
                                console.log("dates"+datevalue[j].sDate);
                                CampaignToShow.push(Campaign[k]);
                            }
                        }
                    }
                }
                CampaignToShow = CampaignToShow.filter( function( item, index, inputArray ) {
                    return inputArray.indexOf(item) == index;});
                
                console.log('campaignss'+JSON.stringify(CampaignToShow));
                component.set("v.Campaigns",CampaignToShow);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action1);*/
    }
})