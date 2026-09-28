({
    doInit : function(component, event) {
        var action = component.get("c.findAll");
        action.setCallback(this, function(a) {
            component.set("v.accounts", a.getReturnValue());            
            window.setTimeout($A.getCallback(function() {
                var event = $A.get("e.c:AccountsLoaded");
                event.setParams({"accounts": a.getReturnValue()});
                event.fire();
            }), 500);           
        });
        
        $A.enqueueAction(action);
       /* var action1 = component.get("c.recordTypesInfoAccount");
        action1.setCallback(this, function(a) {            
            component.set("v.RecordTypes", a.getReturnValue()); 
        });
      $A.enqueueAction(action1);*/
    },
    search : function(component, event, helper){
       //alert('**********');
        var city = component.find("citySearch").get("v.value");  
        var country = component.find("countrySearch").get("v.value");  
        var state = component.find("stateSearch").get("v.value");  
        var zipcode = component.find("zipcodeSearch").get("v.value");  
        var listView = component.find("ListViewAcc").get("v.value");  
        helper.searchFilters(component, event, helper, city, country, state, zipcode, listView);
        
    },
    
    onSelectChange : function(component, event){
    	var selectedPickVal = component.find("ListViewAcc").get("v.value");        
        component.set("v.selectedRecordType", selectedPickVal);
        console.log('selectedPickVal',selectedPickVal);
        var action = component.get("c.findAllOrMy");
        action.setParams({allOrMy : selectedPickVal});       
        
        action.setCallback(this, function(a) {
            component.set("v.accounts", a.getReturnValue());            
           // window.setTimeout($A.getCallback(function() {
                var event = $A.get("e.c:AccountsLoaded");
                event.setParams({"accounts": a.getReturnValue()});
                event.fire();
          //  }), 500);           
        });
        
        $A.enqueueAction(action);
        
	}
})