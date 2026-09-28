({
    sortHelper: function(component, event, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
        if (currentDir == 'arrowdown') {
            component.set("v.arrowDirection", 'arrowup');
            this.sortData(component, sortFieldName, 'asc');
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            this.sortData(component, sortFieldName, 'desc');
        }
        component.set("v.startPage", 0);                
        component.set("v.endPage", component.get("v.pageSize") - 1);
        var PagList = [];
        for ( var i=0; i< component.get("v.pageSize"); i++ ) {
            if ( component.get("v.filterList").length> i )
                PagList.push(component.get("v.filterList")[i]);    
        }
        component.set('v.PaginationList', PagList);
        
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.filterList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.filterList", data);
    },
    sortBy: function (field, reverse, primer) {
        
        var key = function(x) {
            if(field == 'scheduledDepartureLocalDate'){
                var deptDate =  x['bookedFlight'][field];
                var dateParts = deptDate.split("/");
                var dateObject = new Date(dateParts[2], dateParts[1] - 1, dateParts[0]); // month is 0-based
                return dateObject.getTime();
            }else if(field == 'departureAirportCode' || field =='arrivalAirportCode'){
                return x['bookedFlight'][field];
            }else if(field == 'reloc'){
                return x[field];
            }	
            else{
                if(x['bookedFlight'][field] == 'NA' || x['bookedFlight'][field] == null)
                { 
                    return -1000;
                }
                else{
                    return parseInt(x['bookedFlight'][field]);
                }
            }     
        }
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})