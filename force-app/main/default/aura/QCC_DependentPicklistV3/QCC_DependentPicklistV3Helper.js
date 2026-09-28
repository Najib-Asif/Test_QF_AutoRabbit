({
    handleButtonClick : function(component, event, helper) {
        console.log('entering handleclick');        
        var navigationGoal = component.get("v.h_navigationType");
        
        var navigate = component.get('v.navigateFlow');
                    
        if (navigationGoal.toLowerCase() == 'next') {
            navigate("NEXT");  
        }  
        if (navigationGoal.toLowerCase() == 'back') {
            navigate("BACK");  
        }  
    
    }, 

    checkIfValid : function(component, event, helper) {

        console.log('Level 1 Type');
        console.log('required : ' + component.get("v.requiredL1Field") );
        console.log('Values No: ' + component.get("v.L1FieldOutput").length);
        console.log('Result : ' + component.get("v.requiredL1Field") && component.get("v.L1FieldOutput").length > 0);

        console.log('Level 2 Group');
        console.log('required : ' + component.get("v.requiredL2Field") );
        console.log('Values No: ' + component.get("v.L2FieldOutput").length);
        console.log('Result : ' + component.get("v.requiredL2Field") && component.get("v.displayL2Field") && component.get("v.L2FieldOutput").length > 0);

        console.log('Level 3 Category');
        console.log('required : ' + component.get("v.requiredL3Field") );
        console.log('Values No: ' + component.get("v.L3FieldOutput").length);
        console.log('Result : ' + component.get("v.requiredL3Field") && component.get("v.displayL3Field") && component.get("v.L3FieldOutput").length > 0);

        console.log('Level 4 Sub Category');
        console.log('required : ' + component.get("v.requiredL4Field") );
        console.log('Values No: ' + component.get("v.L4FieldOutput").length);
        console.log('Result : ' + component.get("v.requiredL4Field") && component.get("v.displayL4Field") && component.get("v.L4FieldOutput").length > 0);

        console.log('Level 5 Sub Category');
        console.log('required : ' + component.get("v.requiredL5Field") );
        console.log('Values No: ' + component.get("v.L5FieldOutput").length);
        console.log('Result : ' + component.get("v.requiredL5Field") && component.get("v.displayL5Field") && component.get("v.L5FieldOutput").length > 0);

        if( component.get("v.requiredL1Field") && component.get("v.L1FieldOutput").length == 0 ||
            component.get("v.requiredL2Field") && component.get("v.displayL2Field") && component.get("v.L2FieldOutput").length == 0 ||
            component.get("v.requiredL3Field") && component.get("v.displayL3Field") && component.get("v.L3FieldOutput").length == 0 ||
            component.get("v.requiredL4Field") && component.get("v.displayL4Field") && component.get("v.L4FieldOutput").length == 0 ||
            component.get("v.requiredL5Field") && component.get("v.displayL5Field") && component.get("v.L5FieldOutput").length == 0 ){
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