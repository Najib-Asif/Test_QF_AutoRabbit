({
    doInit : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo().then(function(response) {
            var focusedTabId = response.tabId; 
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Flight Disruption"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:topic",
                iconAlt: "FD:"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
        
        console.log('disruptionList'+component.get("v.disruptionList"));
        component.set("v.filterList",component.get("v.disruptionList"));
        component.set("v.totalRecords", component.get("v.disruptionList").length);
        component.set("v.startPage", 0);   
        var pageSize = component.get("v.pageSize");
        component.set("v.endPage", pageSize - 1);
        var PagList = [];
        for ( var i=0; i< pageSize; i++ ) {
            if ( component.get("v.disruptionList").length> i ) {
                //CRM-9311
                let disruption = component.get("v.disruptionList")[i];
                disruption.creationDate = (disruption.creationDate != null && disruption.creationDate != undefined && disruption.creationDate != '') ? disruption.creationDate.split("-").reverse().join("/") : '';
                PagList.push(disruption);    
            }
                
        }
        component.set('v.PaginationList', PagList);
        console.log('PagList'+PagList);
    },
    navigateToMyComponent : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var itemVal = ctarget.dataset.value;
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__QCC_PNRBookingFlightDetails"
            }, 
            "state": {
                'c__pnr':itemVal.split(',')[0],
                'c__creationDate' : itemVal.split(',')[1],
                'c__recordId' : component.get("v.recordId"),
                'c__archivalData': 'false'
            }
        };
        navService.navigate(pageReference);
    },
    next: function (component, event, helper) {
        var sObjectList = component.get("v.filterList");
        console.log('Next:sObjectList'+JSON.stringify(sObjectList));
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
        console.log('Next:PaginationList'+JSON.stringify(PagList));
        component.set('v.PaginationList', PagList);
    },
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.filterList");
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
    onSelectFilter : function (component, event, helper) {
        //var selVal = event.currentTarget.dataset.value;
        var selVal = component.find("filterDispTime").get("v.value");
        var filterArr =[];
        var totList = component.get("v.disruptionList");
        
        if(selVal == 'lt60'){
            for(var i=0; i<totList.length; i++){
                if(parseInt(totList[i].bookedFlight.departureDelayInMinute) < 60){
                    filterArr.push(totList[i]);
                }
            }
            component.set("v.filterList",filterArr);
        }
        if(selVal == 'gteq60'){
            for(var i=0; i<totList.length; i++){
                if(parseInt(totList[i].bookedFlight.departureDelayInMinute) >= 60){
                    filterArr.push(totList[i]);
                }
            }
            component.set("v.filterList",filterArr);
        }	
        if(selVal == 'All'){
            filterArr = totList;
            component.set("v.filterList",filterArr);
        }
        component.set("v.totalRecords", filterArr.length);
        component.set("v.startPage", 0);   
        var pageSize = component.get("v.pageSize");
        component.set("v.endPage", pageSize - 1);
        var PagList = [];
        for ( var i=0; i< pageSize; i++ ) {
            if ( filterArr.length> i )
                PagList.push(filterArr[i]);    
        }
        component.set('v.PaginationList', PagList);
        
        
    },
    sortDeptDlyDurtn : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'departureDelayInMinute');
        helper.sortHelper(component, event, 'departureDelayInMinute');
    },
    sortArrvlDlyDurtn : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'arrivalDelayInMinute');
        helper.sortHelper(component, event, 'arrivalDelayInMinute');
    },
    sortDeptDate : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'scheduledDepartureLocalDate');
        helper.sortHelper(component, event, 'scheduledDepartureLocalDate');
    },
    sortDeptPort : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'departureAirportCode');
        helper.sortHelper(component, event, 'departureAirportCode');
    },
    sortArrPort : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'arrivalAirportCode');
        helper.sortHelper(component, event, 'arrivalAirportCode');
    },
    sortPNR : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'reloc');
        helper.sortHelper(component, event, 'reloc');
    }
    
})