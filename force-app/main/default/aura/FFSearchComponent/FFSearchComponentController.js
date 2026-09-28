({
    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    Search: function(component, event, helper) {
        helper.SearchHelper(component, event);
    },
    //Process the selected Frequent Flyers
    handleSelectedFFs: function(component, event, helper) {
        
        //helper.onSelectChange(component, event);
        var isError = false;
        var allFFs = component.get("v.freqFlyerList");
        console.log('ALLFFs'+JSON.stringify(allFFs));
        console.log('Showerrormessage'+JSON.stringify(allFFs));
        var selectedFFs = [];
        var checkvalue = component.find("checkFreqFlyer");
        var RectypeValue = component.get("v.RecordType");
        console.log('InsidehandleSelectedFFs'+checkvalue); 
        console.log('recordtypeval'+component.get("v.RecordType"));
        console.log('Rectypevalue123'+RectypeValue);
        if(!Array.isArray(checkvalue)){
            console.log('IFCONDITION'); 
            if (checkvalue.get("v.value") == true) {
                var index = checkvalue.get("v.text");
                console.log('index'+index);
                var myKey = allFFs[index];
                selectedFFs.push(myKey);
                //selectedFFs.push(checkvalue.get("v.text"));
                console.log('selectedFFs-' + JSON.stringify(selectedFFs));
                if(RectypeValue == 'Frequent Flyer Request' && (selectedFFs[0].key6 == null || selectedFFs[0].key7 == null || selectedFFs[0].key6 == 'Please select')){
                    console.log('ffvalues'+selectedFFs[0].key6);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: 'Please enter the value for Request Type,Upgrade Tier',
                        key: 'info_alt',
                        type: 'info'
                    });
                    toastEvent.fire();
                } else{
                    isError =true;
                    console.log('error'+isError);
                } 
            } 
            
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                console.log('For loop checkvalue'+checkvalue.length); 
                console.log('checkvaluearrayvalue:'+checkvalue[i].get("v.value"));
                if (checkvalue[i].get("v.value") == true) {                    
                    var index = checkvalue[i].get("v.text");
                    console.log('Index'+index);
                    var myKey = allFFs[index];
                    selectedFFs.push(myKey);
                    //selectedFFs.push(checkvalue.get("v.text"));
                    console.log('selectedFFs-' + JSON.stringify(selectedFFs));
                    console.log('type-' + typeof selectedFFs);
                    if(RectypeValue == 'Frequent Flyer Request' && (selectedFFs[i].key6 == null || selectedFFs[i].key7 == null)) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info Message',
                            message: 'Please enter the value for Request Type,Upgrade Tier',
                            key: 'info_alt',
                            type: 'info'
                        });
                        toastEvent.fire();
                    }  
                    //This can be reused once the Salesforce enable this validsofar functionality for lightning select feature
                    /* var allValidReqType = component.find('ReqType').reduce(function (validSoFar, inputCmp) {
                        inputCmp.showHelpMessageIfInvalid();
                        return validSoFar && !inputCmp.get('v.validity').valueMissing;
                    }, true); 
                    
                    var allValidUpgTier = component.find('UpgradeTierPicklist').reduce(function (validSoFar1, inputCmp1) {
                        inputCmp1.showHelpMessageIfInvalid();
                        return validSoFar1 && !inputCmp1.get('v.validity').valueMissing;
                    }, true);
                    
                    if (!allValidReqType || !allValidUpgTier) {
                        isError =true;
                        //allValidReqType.set("v.errors", [{message:"Please enter the value: " + value}]);
                        //allValidUpgTier.set("v.errors", [{message:"Please enter the value: " + value}]);
                    } */
                    else{
                        isError =true;
                        console.log('error'+isError);
                    }  
                } console.log('Length of checkval'+checkvalue.length);
            } 
            /* if(!isError){
                component.set("v.selectedFlyers",selectedFFs);
                helper.CreateHelper(component, event);*/
            // }
        }
        if(isError){
            component.set("v.selectedFlyers",selectedFFs);
            helper.CreateHelper(component, event);}
    },  
    //Select all Frequent Flyers
    handleSelectAllFF: function(component, event, helper) {
        
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkFreqFlyer = component.find("checkFreqFlyer"); 
        if(checkvalue == true){
            for(var i=0; i<checkFreqFlyer.length; i++){
                checkFreqFlyer[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkFreqFlyer.length; i++){
                checkFreqFlyer[i].set("v.value",false);
            }
        }
    }
})