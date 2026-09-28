({
    renderPassenger : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value###',params.passengerId);
        var passengerDetail = component.get("v.passengerInfo");

        /*  Assume the default passenger is the 1st pasenger on the the list.
            Set the default passenger only if passenger ID has not been set.
            This will remove the need to the agent to click if there is only one passenger.
        */
        if (! params.passengerId){
            // Highlight the 1st (or only) passenger row
            var defaultPassenger = passengerDetail[0]
            var element = document.getElementById(defaultPassenger.passengerId);
            element.classList.remove("onSelection");
            //Fire event to pass ocnrol to parent object and update the case with required details.
            var myEvent = component.getEvent("passengerEvent");
            myEvent.setParams({"passengerId": defaultPassenger.passengerId});
            myEvent.fire();    
        }

    },

    getSelectedName: function (component, event) {
        var target = event.currentTarget;
        var rowIndex = target.getAttribute("id");
        console.log("Row No : " + rowIndex);
        var d = document.getElementById(rowIndex);
        
        var arr = component.get("v.passengerInfo");
        for(var i in arr) {
            if(rowIndex === arr[i].passengerId) {
                d.className += " onSelection";
            } else {
                var element = document.getElementById(arr[i].passengerId);
   				element.classList.remove("onSelection");
            }
        }
        console.log('11111',event.currentTarget.getAttribute('data-record'));
        var passengerId = event.currentTarget.getAttribute('data-record');
        var myEvent = component.getEvent("passengerEvent");
        myEvent.setParams({"passengerId": passengerId});
        myEvent.fire();
    }
})