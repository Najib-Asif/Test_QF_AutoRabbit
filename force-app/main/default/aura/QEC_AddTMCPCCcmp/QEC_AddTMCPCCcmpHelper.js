({
    saveToController : function(component, event, helper){
        var action = component.get("c.performSave");
        var tmcArrayVar = component.get("v.TMCArray");
        var historyArray = component.get("v.HistoryTable");
        var addedArray = component.get("v.addedArray");
        console.log('added array '+ JSON.stringify(addedArray));
                console.log('added array j '+ addedArray);

        var removedArray = component.get("v.removedArray");
        var linkedRecords = component.get("v.linkedArray");
        console.log('linkedRecords  '+ JSON.stringify(linkedRecords));
        console.log('linkedRecords j '+ linkedRecords);
        var emailDistribution = component.get("v.emailDistribution");
        var invokeFlag = false;
        var upsertArray =[]; 
        var spinner = component.find("mySpinner");
		
        var activeTab = component.get("v.activeTab");
        
        var tmcArray = (activeTab == 'historyTab')  ? historyArray : tmcArrayVar;
        
        $A.util.removeClass(spinner, "slds-hide");
        var todays = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        //CRM-7181
        for (var x in linkedRecords) {
            for (var y in addedArray) {
                if ((addedArray[y].pcc  === linkedRecords[x].PCC) &&
                 (addedArray[y].gds  === linkedRecords[x].GDS) &&
                  (addedArray[y].iata  === linkedRecords[x].IATA) && (addedArray[y].sdate  === linkedRecords[x].startDate || addedArray[y].sdate  !== linkedRecords[x].startDate ) && (addedArray[y].edate  === linkedRecords[x].endDate )) {
                    invokeFlag = true;
                    alert('Duplicate is already present in the existing list for '+linkedRecords[x].PCC);
                    
                    $A.get("e.force:closeQuickAction").fire();
                    var spinner = component.find("mySpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
                    break; 
                }
            }
        }
        //CRM-7181(Invoke flag added to the below loop)
        if(!invokeFlag) {
            for(var x in tmcArray){
                var startDate  = new Date(tmcArray[x].sdate);
                var endDate  = new Date(tmcArray[x].edate);
                var History = new Boolean(tmcArray[x].history);
                var contractId = tmcArray[x].contractTMCId;
                if(null != tmcArray[x].edate  && startDate > endDate ){
                    invokeFlag = true;
                    alert('End date can not be less than start date at '+tmcArray[x].pcc);
                    alert('Please ensure that you have selected all relevant PCCs prior to saving '+tmcArray[x].pcc);
                    $A.get("e.force:closeQuickAction").fire();
                    var spinner = component.find("mySpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
                    
                }
                if(contractId != ''){
                    for(var y in linkedRecords){
                        if(contractId == linkedRecords[y].recId && (tmcArray[x].edate != linkedRecords[y].endDate || tmcArray[x].history != linkedRecords[y].history)){
                        upsertArray.push(tmcArray[x]); 
                    }
                }
            }
            }
        }
       /* if(emailDistribution == null || emailDistribution == undefined || emailDistribution == "" ) {
            console.log('Email Distribution',emailDistribution);
            invokeFlag = true;
            alert('Please enter the value for Distribution email');
            return;
        } else {
            invokeFlag = false;
        } */
        if(removedArray == null ){
            removedArray = [];
        }
        if(upsertArray == null){
            upsertArray=[];
        }
        if(addedArray == null){
            addedArray=[];
        }
        
        
        if(!invokeFlag){
            
            action.setParams({
                data : JSON.stringify(addedArray),
                recordId : component.get("v.recordId"),
                removalArray : JSON.stringify(removedArray),
                linkedArray : JSON.stringify(upsertArray),
                emailField : emailDistribution
            });
           // Callback function to get the response
            action.setCallback(this, function(response) {
                $A.util.addClass(spinner, "slds-hide");
                var state = response.getState();
                var result = response.getReturnValue();
                if(state === 'SUCCESS' && null != response.getReturnValue()) {
                    var evt = $A.get("e.force:showToast");
                    if(null != result && result.isProposalRecord)
                    {
                        evt.setParams({
                            mode: 'sticky',
                            message: $A.get('{!$Label.c.QEC_Toast_Message}'),
                            type : 'success',
                            duration:'50',
                            mode: 'dismissible'
                        });
                    }else{
                        var toastMsg ;
                        if(result.isCaseCreated)
                        {
                            toastMsg=$A.get('{!$Label.c.QEC_Case_Toast_Message}');
                        }else{
                            toastMsg=$A.get('{!$Label.c.QEC_Toast_Message}');
                        }
                        evt.setParams({
                            mode: 'sticky',
                            message: toastMsg,
                            type : 'success',
                            duration:'50',
                            mode: 'dismissible'
                        });
                    }
                    evt.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var spinner = component.find("mySpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
                }else if(response.getReturnValue() == null){
                    var evt = $A.get("e.force:showToast");
                    evt.setParams({
                        mode: 'sticky',
                        message: 'No Changes made',
                        type : 'info',
                        duration:'50',
                        mode: 'dismissible'
                    });
                    evt.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    fetchTMCPCC : function(component, event, helper) {
        console.log('inside helper');
        var action = component.get("c.getTMCPCC");
        var record_id = component.get("v.recordId");
        
        var action2 = component.get("c.getUserRoleName");
        
        action.setParams({
            recordid: record_id
        });
        // Callback function to get the response
        action.setCallback(this, function(response) {
            var state = response.getState();
            var fareDiscountsList = [];
            if(state === 'SUCCESS' && null != response.getReturnValue()) {
                var resultsObj = response.getReturnValue();
                var results = resultsObj.wrapperList;
                console.log('results________ '+JSON.stringify(results));
                if(results.length > 0 && typeof results != 'undefined'){
                    var historyData = [];
                    var tmcArray =[];
                    var linkedRecords = [];
                    //CRM-8007: If end date is in the past it should move to History tab
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    for(var i=0;i<results.length;i++){  
                        if(results[i].history === true || results[i].edate<today){
                            historyData.push(results[i]);
                        }else{
                            tmcArray.push(results[i]);
                            
                        }
                        var array = {
                                recId			 : results[i].contractTMCId,
                                endDate			 : results[i].edate,
                                startDate	     : results[i].sdate, //CRM-7181(Added extra fields to the array)
                                PCC			     : results[i].pcc,
                                GDS			     : results[i].gds,
                                IATA		     : results[i].iata,
                                history          : results[i].history
                            };
                            linkedRecords.push(array);
                    }
                    if(!resultsObj.isProposalRecord){
                        component.set("v.isContract", true);
                        component.set("v.emailDistribution", resultsObj.emailDistribution);
                    }
                    component.set("v.HistoryTable", historyData);
                    component.set("v.basetable",true);
                    component.set("v.TMCArray", tmcArray);
                    component.set("v.linkedArray", linkedRecords);
                    var spinner = component.find("mySpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
                }else{
                    var errorEvt = $A.get("e.force:showToast");
                    errorEvt.setParams({
                        mode: 'sticky',
                        message: 'Proposal does not have account Relationship',
                        type : 'error',
                        duration:'50',
                        mode: 'dismissible'
                    });
                    errorEvt.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            else {
                console.log('Error in getting data or records not found');
                var tmcArray =[];
                //tmcArray.push('');
                component.set("v.TMCArray", tmcArray);
                                    var spinner = component.find("mySpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
            }
        });
        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS' && null != response.getReturnValue()) {
                var roleName = response.getReturnValue();
                if((roleName.toUpperCase().includes('QF-DOM-SALES') || roleName.toUpperCase().includes('QF-INT-SALES'))&&
                   (!roleName.toUpperCase().includes('QF-DOM-SALES PERFORMANCE') && !roleName.toUpperCase().includes('QF-DOM-SALES-AP'))
                  ){
                    component.set("v.isHistoryEditable",false);
                }else{
                    component.set("v.isHistoryEditable",true);
				}
            }
                
        });
        
        $A.enqueueAction(action);
        $A.enqueueAction(action2);
    },
    //Search pcc 
    searchPCC : function(component, event, helper){
        var targt = component.get("v.searchData");
        var action = component.get("c.fetchPCCData");
        action.setParams({
            searchString : targt,
            recordId : component.get("v.recordId")
        });
        // Callback function to get the response
        action.setCallback(this, function(response) {
            var state = response.getState();
            var fareDiscountsList = [];
            if(state === 'SUCCESS' && null != response.getReturnValue()) {
                var results = response.getReturnValue();
                if(results.length > 0 && typeof results != 'undefined'){
                    component.set("v.searchResultsFlag", false);
                    component.set("v.searchResultArray", results);
                    component.set("v.initialTable", true);
                }else{
                    component.set("v.searchResultsFlag", true);
                    component.set("v.initialTable", false);
                }
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                
            }
            else {
                console.log('Error in getting data or records not found');
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                
            }
        });
        $A.enqueueAction(action);
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
    }
})