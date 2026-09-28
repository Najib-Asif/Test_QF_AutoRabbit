({
    refreshDestinationList : function(component) 
    {
        var origin = component.get("v.origin");
        var origins = component.get("v.origins");
        var destinations = component.get("v.destinations");
        var iterator;
        var specialConditions=[];
        
        //<!--Added for JIRA CRM-4196.Allow multiple Origin and restrict only 1 destination-->
        if (origins != null && origins.length === 1 && destinations.length >= 1)
        {
            if(component.get("v.objectType") === "Proposal__c")
            {
                //When origin = 1 && destination > 1
                for ( iterator in destinations) 
                {
                    specialConditions.push({
                        'QEC_Origin__c': origins[0].Name,
                        'QEC_Destination__c': destinations[iterator].Name, 
                        'QEC_Type__c': component.get("v.type"), 
                        'QEC_Booking_Class__c': component.get("v.selectedFare"),
                        'Proposal__c':component.get("v.recordId"),
                        'QEC_Cabin__c':component.get("v.selectedCabin") 
                    })
                }
            }
            else {
                for ( iterator in destinations) 
                {
                    specialConditions.push({
                        'QEC_Origin__c': origins[0].Name,
                        'QEC_Destination__c': destinations[iterator].Name, 
                        'QEC_Type__c': component.get("v.type"), 
                        'QEC_Booking_Class__c': component.get("v.selectedFare"),
                        'Contract__c':component.get("v.recordId"),
                        'QEC_Cabin__c':component.get("v.selectedCabin")
                    })
                } 
            }
            component.set("v.specialConditionList",specialConditions);
        }
        //<!--Added for JIRA CRM-4196.Allow multiple Origin and restrict only 1 destination-->
        else if(origins != null && origins.length >= 1 && destinations.length === 1)
        {
            if(component.get("v.objectType") === "Proposal__c")
            {
                //When origin > 1 && destination = 1
                for ( iterator in origins) 
                {
                    specialConditions.push({
                        'QEC_Origin__c': origins[iterator].Name,
                        'QEC_Destination__c': destinations[0].Name, 
                        'QEC_Type__c': component.get("v.type"), 
                        'QEC_Booking_Class__c': component.get("v.selectedFare"),
                        'Proposal__c':component.get("v.recordId"),
                        'QEC_Cabin__c':component.get("v.selectedCabin") 
                    })
                }
            }
            else {
                for ( iterator in origins) 
                {
                    specialConditions.push({
                        'QEC_Origin__c': origins[iterator].Name,
                        'QEC_Destination__c': destinations[0].Name, 
                        'QEC_Type__c': component.get("v.type"), 
                        'QEC_Booking_Class__c': component.get("v.selectedFare"),
                        'Contract__c':component.get("v.recordId"),
                        'QEC_Cabin__c':component.get("v.selectedCabin")
                    })
                } 
            }
            component.set("v.specialConditionList",specialConditions);
        }
        //<!--Added for JIRA CRM-4196.when origin=0 & destination >0 delete all rows-->
        else
        {
            component.set("v.specialConditionList",specialConditions);
        }    
    },
})
// <!-- Helper--><!-- Helper-->