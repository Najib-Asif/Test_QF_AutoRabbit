({
	combinePhoneNumber: function(component, event, helper) {
        if(event != null){
            var el = component.find(event.getSource().getLocalId());
            if(!el.reportValidity()){
                $A.util.removeClass(el, "hide-error-message"); // show error message
                $A.util.addClass(el, "slds-has-error");
            }
        }

        //phone logic - start
        console.log('phone change');
        var phone = '';
        var phone_Country_Code__c  = component.get('v.phone_Country_Code__c');
        var phone_Area_Code__c  = component.get('v.phone_Area_Code__c');
        var phone_Line_Number__c  = component.get('v.phone_Line_Number__c');
        if(phone_Country_Code__c == '' || phone_Country_Code__c == null){
            phone_Country_Code__c = '61';
        }
        if(phone_Country_Code__c != null && phone_Country_Code__c != ''){
            phone=phone_Country_Code__c.trim();
        }
        if(phone_Area_Code__c != null && phone_Area_Code__c != ''){
            phone+=phone_Area_Code__c.trim();
        }
        if(phone_Line_Number__c != null && phone_Line_Number__c != ''){
            phone+=phone_Line_Number__c.trim();
        }
        if(phone == '61'){
            phone = '';
        }
        var isnum = /^\d+$/.test(phone) || (phone == '');

        if(isnum){
            component.set('v.phone', phone);
        }
        console.log(phone);
    }
})