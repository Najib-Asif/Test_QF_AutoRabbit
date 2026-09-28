({
    loadChild : function(component) {
        var recId = component.get("v.recordId");
        console.log('RecordId$$$',recId);
        
        //Pass Case Id to PNR Component
        //var pnrComp = component.find('pnrLookUP');
        //pnrComp.casePNRSearch(recId);
        
        //Pass Case Id to FF Lookup Component
        //var ffComp = component.find('ffLookUP');
        //ffComp.caseFFSearch(recId);
        
        //Pass Case Id to FF Lookup Component
        //var nonffComp = component.find('nonFF');
         //nonffComp.caseNONFFContact(recId);
    }
})