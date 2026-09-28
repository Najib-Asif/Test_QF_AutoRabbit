({
	loadColumns : function(component) {
		var action = component.get("c.getColumns");
        action.setParams({
            "componentName": "QCC_PossibleRelatedCases"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var cols = JSON.parse(response.getReturnValue());
                console.log(JSON.stringify(cols));
                component.set("v.mycolumns", cols);
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
	},
    
    loadSimilarCases : function(component) {
        var firstName = component.get("v.case.First_Name__c");
        var lastName = component.get("v.case.Last_Name__c");
        var phone = component.get("v.case.Contact_Phone__c");
        var email = component.get("v.case.Contact_Email__c");
        
        var action = component.get("c.search");
        action.setParams({
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone": phone,
            "caseId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var results = response.getReturnValue();
                if(results.length != 0) {
                    component.set("v.similarCases", results);
                    component.set("v.casesExist", true);
                    component.set("v.maxPage", Math.floor((results.length+4)/5));
                    this.renderPage(component);
                }
                console.log(JSON.stringify(component.get("v.similarCases")));
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
            component.set("v.actionCompleted", true);
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.similarCases");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.similarCases", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) { return primer(x[field]) }
            : function(x) { return x[field] };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
    
    renderPage: function(component) {
        var records = component.get("v.similarCases");
        if(records != null) {
            var pageNumber = component.get("v.pageNumber");
            var pageRecords = records.slice((pageNumber-1)*5, pageNumber*5);
            component.set("v.currentList", pageRecords);
        }
    },
})