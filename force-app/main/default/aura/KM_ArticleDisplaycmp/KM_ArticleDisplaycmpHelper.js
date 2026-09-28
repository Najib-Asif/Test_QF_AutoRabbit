({
    getArticle : function(component, event, helper) {
        var action = component.get("c.findArticles");
        action.setParams({
            recordType: "Qantas_S_D",
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === 'SUCCESS' && null != result) {
                var newItems=[];
                debugger;
                for (var i=0; i< result.length; i++)
                {
                    var record = result[i];

                    var Item = {Title: record.Title, Summary: record.Summary,Content: record.Content__c,
                              Startdate: record.Start_Date__c,Enddate: record.End_Date__c};
                    console.log('Item-> ' + JSON.stringify(Item));

                    newItems.push(Item);
                    console.log('newItems-> ' + JSON.stringify(newItems));
                }
                          }
            
             console.log("before setting v.lstKey" +component.get("v.lstKey.length"))
             component.set("v.lstKey",  newItems);
               console.log('Resposeval ' +newItems.length);

        })
        $A.enqueueAction(action);
    }
})