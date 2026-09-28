({
    searchFilters : function(component, event, helper, city, country, state, zipcode, listView){
        var action = component.get("c.searchFilters");
        action.setParams(
            
            {
                citySearch 	  : city,
             	countrySearch : country,
             	stateSearch   : state,
             	zipcodeSearch : zipcode,
                allOrMy		  : listView,
            }
        
        ); 
        
        action.setCallback(this, function(a) {
            console.log('############After search',a.getReturnValue());
            component.set("v.accounts", a.getReturnValue());            
           // window.setTimeout($A.getCallback(function() {
                var event = $A.get("e.c:AccountsLoaded");
                event.setParams({"accounts": a.getReturnValue()});
                event.fire();
           // }), 500);           
        });
        
        $A.enqueueAction(action);
    
	}
})