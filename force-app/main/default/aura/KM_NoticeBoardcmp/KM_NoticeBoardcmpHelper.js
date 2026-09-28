({
    getCategories : function(component, event, helper) {
        var action = component.get("c.switchMethod");
        action.setParams({"currURL" : window.location.href});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === 'SUCCESS' && null != result) {
               console.log('--------------- '+JSON.stringify(result));
             
                var newItems=[];
                debugger;
            //   console.log("initial v.lstvalue" +component.get("v.lstvalue"));
                for (var i=0; i< result.length; i++)
                {
                    var record = result[i];
                    console.log('record-> ' + JSON.stringify(record));

                    var Item = {Title: record.Title, Announcement: record.Announcement__c,ArticleOverview: record.Article_Overview__c,
                              Startdate: record.Start_Date__c,Enddate: record.End_Date__c};
                    console.log('Item-> ' + JSON.stringify(Item));

                    newItems.push(Item);
                   // component.set("v.lstvalue",true);
                    console.log('newItems-> ' + JSON.stringify(newItems));
                }
                          }
            
             console.log("before setting v.lstKey" +component.get("v.lstKey.length"))
             component.set("v.lstKey",  newItems);
             // console.log("final v.lstvalue" +component.get("v.lstvalue"));
               console.log('Resposeval ' +newItems.length);

        })
        $A.enqueueAction(action);
    }
})