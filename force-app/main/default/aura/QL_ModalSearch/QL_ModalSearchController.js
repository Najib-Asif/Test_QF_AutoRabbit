({
    gotoURL:function(component,event,helper){
        console.log('Enter Here');
        console.log('####CaseIdParentComponent'+component.get("v.recordId"));
        var evt = $A.get("e.force:navigateToComponent");
        console.log('evt'+evt);
        console.log('RecordType'+component.get("v.simpleRecord").RecordType.Name);
        evt.setParams({
            componentDef: "c:FFSearchComponent",
            componentAttributes: {
                "CaseId" : component.get("v.recordId"),
                "AccountId" : component.get("v.simpleRecord").AccountId,
                "RecordType" : component.get("v.simpleRecord").RecordType.Name,
                "isOpen" : true
            }	
        });
        
        
        evt.fire();
    }
})