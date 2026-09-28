({
    init: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'PNR', fieldName: 'PNR__c', type: 'text'},
            {label: 'Code', fieldName: 'Code__c', type: 'text'},
            {label: 'Category', fieldName: 'Category__c', type: 'text'},
            {label: 'Subcategory', fieldName: 'Subcategory__c', type: 'text'},
            {label: 'Value', fieldName: 'Value__c', type: 'text'},
            {label: 'Currency Code', fieldName: 'CurrencyIsoCode', type: 'text'},
            {label: 'Waiver Date', fieldName: 'Waiver_Date__c', type: 'date'}
        ]);
        
        helper.loadDataHelper(component, event, helper);
    }
});