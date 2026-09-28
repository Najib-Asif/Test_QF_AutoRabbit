({
    getPassengerDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value###',params.passengerDetail);
        component.set("v.passengerInfo", params.passengerDetail);
        component.set("v.mycolumns", [
                {label: 'First Name', fieldName: 'firstName', type: 'text'},
                {label: 'Last Name', fieldName: 'lastName', type: 'text'},
                {label: 'Frequent Flyer', fieldName: 'qantasFFNo', type: 'text'}
            ]);
        console.log('Rows####',component.get("v.passengerInfo"));
        console.log('mycolumns####',component.get("v.mycolumns"));
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