({
    
    getCampaignMem: function(component, page,recordToDisply,userId,campaignId) {
      
        var action = component.get("c.fetchCampMembers");
        action.setStorable();
        action.setParams({
            "userId": userId,
            "pageNumber": page,
            "recordToDisply": recordToDisply,
            "campaignId": campaignId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                
                //component.set("v.campaignmems",record.campMems);
                console.log(record);
                component.set('v.mycolumns', [
                    {label: 'Name', fieldName: 'CampaignMemURL',type: 'url',initialWidth:'40px',sortable:true,typeAttributes: {
                        label: { fieldName: 'CampaignMemName' }}},
                    {label:'Status',fieldName: 'CampaignStatus',sortable:true,initialWidth:'40px' },
                    {label:'Account Name',fieldName: 'AccountURL',type: 'url',initialWidth:'40px',sortable:true,typeAttributes: {
                        label: { fieldName: 'AccountName' }}},
                    {label:'Account ABN',fieldName: 'AccountABN',type: 'text',sortable:true,initialWidth:'40px' },
                    {label:'Account QCI',fieldName: 'AccountQCI',type: 'text',sortable:true,initialWidth:'40px' },
                    {label:'Account QBR',fieldName: 'AccountQBR',type: 'text',sortable:true,initialWidth:'40px' },
                    {label:'AMEX',fieldName: 'AMEX',type: 'text',sortable:true,initialWidth:'40px' }
                    
                ]);
                component.set("v.page", record.page);
                component.set("v.total", record.total);
                component.set("v.campaignmems", record.totalCampMems);
                component.set("v.pages", Math.ceil(record.total / recordToDisply));
            }
        })
        $A.enqueueAction(action);
        
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.campaignmems");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.campaignmems", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
    
})