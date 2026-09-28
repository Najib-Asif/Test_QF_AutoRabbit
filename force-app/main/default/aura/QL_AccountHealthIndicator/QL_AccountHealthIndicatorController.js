({
    doInit : function(component, event, helper) {
        component.set('v.accTableColumns', [
            {label: 'Account Name', fieldName: 'AcntName', type: 'text',initialWidth:200,sortable:true},
            {label: 'Dom Revenue', fieldName: 'accDomRev', type: 'currency',sortable:true},
            {label: 'Dom Share(%)', fieldName: 'accDomShare', type: 'number',sortable:true},
            {label: 'Int Revenue', fieldName: 'accIntRev', type: 'currency',sortable:true},
            {label: 'Int Share(%)', fieldName: 'accIntShare', type: 'number',sortable:true},
            {label: 'Active SAP', fieldName: 'activeSAP', type: 'boolean',sortable:true},
            {label: 'Updated SAP (Last 3 months)', fieldName: 'updatedSAP', type: 'boolean',sortable:true},
            {label: 'Account Review (Last 3 months)', fieldName: 'accReviewed', type: 'boolean',sortable:true},
            {label: 'Activity Created (Last 3 months)', fieldName: 'actCreated', type: 'boolean',sortable:true},
            {label: 'No Overdue Opportunity', fieldName: 'noOverdueOpp', type: 'boolean',sortable:true},
            {label: 'No Unsigned Contract', fieldName: 'noUnsignedContracts', type: 'boolean',sortable:true}
        ]);
        
        //calling helper method from client-side controller
        if(!component.get("v.recordId"))
            helper.callApexMethod(component, event, helper);
    },
    openOverallInd : function (component, event, helper) {
        $A.util.toggleClass(component.find("overallHealthDiv"),"slds-hide");
    },
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
        component.set("v.startPage", 0);                
        component.set("v.endPage", component.get("v.pageSize") - 1);
        var PagList = [];
        for ( var i=0; i< component.get("v.pageSize"); i++ ) {
            if ( component.get("v.accountDetailsList").length> i )
                PagList.push(component.get("v.accountDetailsList")[i]);    
        }
        component.set('v.PaginationList', PagList);
    },
    next: function (component, event, helper) {
        var sObjectList = component.get("v.accountDetailsList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i = end + 1; i < end + pageSize + 1; i++ ) {
            if ( sObjectList.length > i ) {
                PagList.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.accountDetailsList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i= start-pageSize; i < start ; i++ ) {
            if ( i > -1 ) {
                PagList.push(sObjectList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED" || eventParams.changeType === "CHANGED") {
            console.log("account loaded:::::" + component.get("v.simpleAccRecord").RecordTypeId);
           if(component.get("v.simpleAccRecord")) {
                helper.getRecordTypeId(component, event, helper);
            }
        } 
    },
    fetchSAPActive : function(component, event, helper) {
        component.set("v.listToDisplay",component.get("v.activeSAPAccs"));
        component.set("v.accCategory","WithActiveSAP");
    },
    fetchSAPUpdated : function(component, event, helper) {
        component.set("v.listToDisplay",component.get("v.updatedSAPAccs"));
        component.set("v.accCategory","WithUpdatedSAP");
    },
    fetchAccReview : function(component, event, helper) {
        component.set("v.listToDisplay",component.get("v.accReviewAccs"));
        component.set("v.accCategory","ReviewedAccounts");
    },
    fetchActReview : function(component, event, helper) {
        component.set("v.listToDisplay",component.get("v.actReviewAccs"));
        component.set("v.accCategory","WithActivities");
    },
    fetchAccOverdueOpp : function(component, event, helper) {
        component.set("v.listToDisplay",component.get("v.noOverdueOppAccs"));
        component.set("v.accCategory","WithOverdueOpps");
    },
    fetchAccContractUnsigned : function(component, event, helper) {
        component.set("v.listToDisplay",component.get("v.contractSignedAccs"));
        component.set("v.accCategory","WithUnsignedContracts");
    },
    exportAll : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var sourceVal = ctarget.dataset.value;
        helper.exportAllData(component, event, helper,sourceVal);
        
    }
    
})