({
    saveRecords : function(component, event, helper){
       var distEmail = component.find("distributionemail");
        var tmcArray = component.get("v.TMCArray");
   if(component.get("v.isContract"))
        {
          console.log("contract" +tmcArray.id);
       var validity = distEmail.get("v.validity");
        //   helper.saveToController(component, event, helper);
       if(validity.valid)
            helper.saveToController(component, event, helper); 
        else
            distEmail.reportValidity();
   }
    else
       helper.saveToController(component, event, helper);
       /* var errorEvt = $A.get("e.force:showToast");
                    errorEvt.setParams({
                        mode: 'sticky',
                        message: 'Please ensure that you have selected all relevant PCCs prior to saving',
                        type : 'error',
                        duration:'50',
                        
                    });
                    errorEvt.fire();                   
    */

},
    
    handleClick : function(component, event, helper){
        helper.searchPCC(component,event, helper);
    },
    
    tmctab : function(component, event, helper){
        component.set("v.activeTab", 'tmcTab');
    },
    
    histroytab : function(component, event, helper){
        component.set("v.activeTab", 'historyTab');
    },
    
    loadTMCPCC : function(component, event, helper) {
        var label = $A.get("$Label.c.noteMessage");
        component.set("v.noteMsg",label);
        helper.fetchTMCPCC(component, event, helper);
    },
    removeRecords : function(component, event, helper){
        var recId = event.target.getAttribute("data-recId");
        var tmcArray = component.get("v.TMCArray");
        var removeRec = component.get("v.removedArray");
        var addedArray =component.get("v.addedArray");
        if(null == removeRec){
            removeRec = [];
        }
        for(var i = 0; i < tmcArray.length; i++){ 
            if (tmcArray[i].tmcId === recId ) {
                //if(typeof tmcArray[i].contractTMCId != 'undefined'){
                removeRec.push(tmcArray[i]);
                //}   
                tmcArray.splice(i, 1);
            }
        }
        if(null != addedArray && addedArray.length > 0){
            for(var i = 0; i < addedArray.length; i++){ 
                if (addedArray[i].tmcId === recId ) {
                    removeRec.push(addedArray[i]);
                    addedArray.splice(i, 1);
                }
            }
            component.set("v.addedArray", addedArray);
            
        }
        component.set("v.TMCArray", tmcArray);
        component.set("v.removedArray", removeRec);
    },
    
    selectCurrentRow : function(component, event, helper){
        //component.set("v.displayTMCInfo", true);
        var selected = [], checkboxes = component.find("checkbox1");
        var recordIds =[];
        if(!checkboxes) {   
            checkboxes = [];
        } else if(!checkboxes.length) { 
            checkboxes = [checkboxes];
        }
        //finds either checkbox selected or deselected - true/false
        var checkboxSelected = event.getSource().get("v.value");
        if(checkboxSelected){
            checkboxes.filter(checkbox1 => checkbox1.get("v.value"))    // Get only checked boxes
            .forEach(checkbox1 => selected.push(checkbox1.get("v.text")));   // get the record Id
            
            var existingPCCArray = component.get("v.TMCArray");
            var ListTobeAdded = component.get("v.searchResultArray");
            var addedArray =component.get("v.addedArray");
            if(null == addedArray){
                addedArray = [];
            }
            console.log('___________ '+event.currentTarget );
            if(selected.length > 0){
                var allCheckboxes = [];
                var existingIds =[];
                for(var x in selected){
                    allCheckboxes.push(selected[x]);
                }
                for(var x in existingPCCArray){
                    existingIds.push(existingPCCArray[x].tmcId);
                }
                for(var i=0;i<ListTobeAdded.length;i++){
                    for(var y in allCheckboxes){
                        var flag = existingIds.includes(allCheckboxes[y]);
                        if(allCheckboxes[y] == ListTobeAdded[i].tmcId /*&& !flag*/){ /*CRM 5688 -Commented to exclude existing id check and add in listToBeAdded Array */
                            addedArray.push(ListTobeAdded[i]);
                            existingPCCArray.push(ListTobeAdded[i]);
                           // alert('Please ensure that you have selected all relevant PCCs prior to saving ');
                            /*var errorEvt = $A.get("e.force:showToast");
                    errorEvt.setParams({
                        mode: 'sticky',
                        message: 'Please ensure that you have selected all relevant PCCs prior to saving',
                        type : 'error',
                        duration:'50',
                        
                    });
                    errorEvt.fire();*/
                        }
                    }
                }
                
            }
            component.set("v.basetable",true);
            component.set("v.TMCArray",existingPCCArray);
            if(null != addedArray && addedArray.length > 0){
                component.set("v.addedArray", addedArray);
            }
        }
        //component.set("v.searchResultArray",ListTobeAdded);        
    },
    
    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
    
})