({
    doInit : function(component, event, helper) {
        console.log('----------'+component.get("v.FFNumber"));
        var action=component.get("c.getContact");
        var ffnum = component.get('v.FFNumber');
        action.setParams({
            ffnumber: ffnum
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var results = response.getReturnValue();
                if(null != results){
                    if(results.length ==1){
                        var rec= results[0].Id;
                        window.location='/'+rec;
                    }else if(results.length >1){
                        alert('Duplicate contact records found for FF number '+ffnum);
                        window.location='/lightning/page/home';
                        
                    }else{
                        alert('Contact record not found for the FF number '+ffnum);
                        window.location='/lightning/page/home';
                        
                    }
                }}
        });
        $A.enqueueAction(action);
        
    }
})