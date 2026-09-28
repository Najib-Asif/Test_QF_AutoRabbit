({
    getFFDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param ValueFFFF###'+params.contactDetail);
         console.log('Param otherProducts###'+params.otherProducts);
        component.set("v.objCon", params.contactDetail);
        component.set("v.lstOtherProducts", params.otherProducts);
        //var ffdate = $A.localizationService.formatDate(params.contactDetail.QCC_Frequent_Flyer_Anniversary_Date__c, "DD/MM/YYYY");
        //QDCUSCON-4985 - Start
        var ffdate =params.contactDetail.Frequent_Flyer_Tier__c == 'Non-tiered' ? '': $A.localizationService.formatDate(params.contactDetail.QCC_Frequent_Flyer_Anniversary_Date__c, "DD/MM/YYYY");
        //QDCUSCON-4985 - End
        console.log('ffdate#######'+ffdate);
        var obj = component.get("v.objCon");
        console.log('ffdate#######'+obj);
        component.set("v.ffDate", ffdate);  
    }
})