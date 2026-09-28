({

    checkIfValid : function(component, event, helper) {

        console.log('Level 1 Type');
        console.log('required : ' + component.get("v.requiredL1Field") );
        console.log('Values No: ' + component.get("v.L1FieldOutput").length);
        console.log('Result : ' + component.get("v.requiredL1Field") && component.get("v.L1FieldOutput").length > 0);


        if( component.get("v.requiredL1Field") && component.get("v.L1FieldValue").length == 0 ){
                component.set("v.isValid", false );
                component.set("v.disabledFlag2", true );
                console.log('### Inputs are NOT Valid');
            }
            else{
                component.set("v.isValid", true );
                component.set("v.disabledFlag2", false );
                console.log('### Inputs are Valid');
            }
            
    }
})