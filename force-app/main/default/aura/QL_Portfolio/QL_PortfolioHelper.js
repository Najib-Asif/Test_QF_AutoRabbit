({
    getRoleAndSubordinates : function(component, event, userId, toggleVal){
        component.set("v.Spinner",true);
        
        if(component.get("v.value")=='myTeamPf')
            component.find("selectOwner").set("v.value","showAllMem");
        
        var action = component.get("c.fetchRoleUsers");
        action.setStorable();
        action.setParams({"userId":userId});
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === "SUCCESS"){
                var allOwnerList = component.get("v.allOwnerList");
                var allOwnerIds = component.get("v.allOwnerIds");
                var arrObj = response.getReturnValue();
                console.log('%%%%'+JSON.stringify(response.getReturnValue()));
                if(allOwnerList.length == 0){
                    for(var i=0;i<arrObj.length;i++){
                        var selectObj = new Object();
                        selectObj.label = arrObj[i].Name;
                        selectObj.value = arrObj[i].Name;
                        selectObj.photoURL = arrObj[i].SmallPhotoUrl;
                        selectObj.id = arrObj[i].Id;
                        allOwnerList.push(selectObj);
                        allOwnerIds.push(arrObj[i].Id);
                        
                    }
                    
                    component.set("v.allOwnerList",allOwnerList.sort(function(a, b){
                        var x = a.label.toLowerCase();
                        var y = b.label.toLowerCase();
                        if (x < y) {return -1;}
                        if (x > y) {return 1;}
                        return 0;
                    })); 
                    //component.set("v.allOwnerList",allOwnerList);
                    component.set("v.allOwnerIds",allOwnerIds); 
                }
                //console.log('%%%%'+allOwnerIds);
                
            }
        });
        $A.enqueueAction(action);
    },
    expandSections : function(component,event,helper){
        var proactiveSec = component.find("articleOne");
        for(var cmp in proactiveSec){
            //$A.util.removeClass(proactiveSec[cmp], "slds-hide"); 
            $A.util.addClass(proactiveSec[cmp], "slds-show");
        }
        var reactiveSec = component.find("articleTwo");
        for(var cmp in reactiveSec){
            //$A.util.removeClass(reactiveSec[cmp], "slds-hide");  
            $A.util.addClass(reactiveSec[cmp], "slds-show");
        }
        var recommendSec = component.find("articleThree");
        for(var cmp in recommendSec){
            //$A.util.removeClass(recommendSec[cmp], "slds-hide"); 
            $A.util.addClass(recommendSec[cmp], "slds-show");
        }
    },
    fetchOpp : function(component,event,userId,toggleVal) {
        component.set("v.Spinner",true);
        $A.util.addClass(component.find("dymDivPiOpp"),"slds-hide");
        $A.util.addClass(component.find("dymDivPiOppFilter"),"slds-hide");
        $A.util.removeClass(component.find("dymDivPiOppMaster"),"slds-hide");
        if(toggleVal == "myPf"){
            $A.util.addClass(component.find("selectPiOpp"),"slds-hide");
        }else{
            $A.util.removeClass(component.find("selectPiOpp"),"slds-hide");
        }
        //component.find("v.selectPiOpp").set("v.value",{ text: "Red", label: "Red" });
        var action = component.get("c.fetchOpps");
        action.setStorable();
        var roleIds = component.get("v.allOwnerIds");
        action.setParams({"userId":userId,"TeamOrMine":toggleVal,"roleIds":roleIds});
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === "SUCCESS"){
                var arrObj = response.getReturnValue();
                component.set("v.oppList",arrObj);  
                var oppOwnerList = component.get("v.oppOwnerList");
                
                console.log('yaaaay');
                var containsStr="";
                if(arrObj.length > 0){
                    if(oppOwnerList.length == 0){
                        for(var i=0;i<arrObj.length;i++){
                            if(!containsStr.includes(arrObj[i].OwnerId)){
                                var selectObj = new Object();
                                selectObj.label = arrObj[i].Owner.Name;
                                selectObj.value = arrObj[i].Owner.Name;
                                selectObj.id = arrObj[i].OwnerId;
                                oppOwnerList.push(selectObj);
                                containsStr = containsStr.concat(arrObj[i].OwnerId);
                                
                            }
                            
                        }
                        component.set("v.oppOwnerList",oppOwnerList); 
                        
                    }
                }
                if(toggleVal == 'myTeamPf' && component.get("v.oppOwnerList").length > 0 ){
                    $A.util.removeClass(component.find("selectPiOpp"),"slds-hide"); 
                }else {
                    $A.util.addClass(component.find("selectPiOpp"),"slds-hide");
                }
                
                
                component.set("v.Spinner",false);
            }else{
                component.set("v.Spinner",false);
                console.log('Failure');
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchAccountWOKeyContact : function(component,event,userId,toggleVal) {
        component.set("v.Spinner",true);
        $A.util.addClass(component.find("dymDiv"),"slds-hide");
        $A.util.addClass(component.find("dymDivAccountWOKeyContactTsk"),"slds-hide");
        $A.util.addClass(component.find("dymDivFilter"),"slds-hide");
        $A.util.addClass(component.find("dymDivAccountWOKeyContactTskFilter"),"slds-hide");
        $A.util.removeClass(component.find("dymDivAccountWOKeyContactTskMaster"),"slds-hide");
        $A.util.removeClass(component.find("dymDivMaster"),"slds-hide");
        if(toggleVal == 'myPf'){
            $A.util.addClass(component.find("selectAccNoKeyCont"),"slds-hide");
            $A.util.addClass(component.find("selectAccNoKeyContTask"),"slds-hide");    
        }else {
            $A.util.removeClass(component.find("selectAccNoKeyCont"),"slds-hide");
            $A.util.removeClass(component.find("selectAccNoKeyContTask"),"slds-hide");
        }
        var action = component.get("c.fetchAccountWOKeyContacts");
        action.setStorable();
        var roleIds = component.get("v.allOwnerIds");
        action.setParams({"userId":userId,"TeamOrMine":toggleVal,"roleIds":roleIds});
        
        action.setCallback(this,function(response){
            //console.log('Two Lists1 : '+response);
            //console.log('Two Lists : '+JSON.parse(JSON.stringify(response.getReturnValue()[1])));
            var state=response.getState();
            if(state === "SUCCESS"){
                //console.log('accList'+ JSON.parse(response.getReturnValue().split('*')[0]));
                //console.log('acckycWOActivities'+ JSON.parse(response.getReturnValue().split('*')[1]));
                
                //console.log('Map Owner AccIds'+(JSON.parse(response.getReturnValue().split('*')[3]))[userIdStr]);
                //var arrObj = response.getReturnValue().split('*');
                var accList = JSON.parse(response.getReturnValue().split('*')[0]);
                var acckycWOActivities = JSON.parse(response.getReturnValue().split('*')[1]);
                var custAccIds = JSON.parse(response.getReturnValue().split('*')[2]);
                var allAccList = JSON.parse(response.getReturnValue().split('*')[3]);
                component.set("v.accList",(accList != null)?accList:null);
                component.set("v.acckycWOActivities",(acckycWOActivities != null)?acckycWOActivities:null);
                component.set("v.pfAccIds",(custAccIds != null)?custAccIds:null);
                component.set("v.allAccList",(allAccList != null)?allAccList:null);
                //console.log('allAccList'+response.getReturnValue().split('*')[3]);
                /*for(var i=0;i<accList.length;i++){
                    if(accList[i].OwnerId == selOwnerId)
                        newArrAccList.push(accList[i]);
                    
            	}*/
                console.log('custAccs'+response.getReturnValue().split('*')[3]);
                console.log('Sel Owner $'+component.get("v.selectedOwner"));
                console.log('ahiids'+component.get("v.pfAccIds"));
                if(toggleVal == 'myPf' ){
                    
                    if(component.isValid()){
                        $A.createComponent(
                            "c:QL_AccountHealthIndicator",
                            {
                                "pfAccId": component.get("v.pfAccIds")
                            },
                            function(newCmp, status, errorMessage){
                                if (status === "SUCCESS") {
                                    var body = [];
                                    body.push(newCmp);
                                    component.set("v.body", body);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                    // Show offline error
                                }
                                    else if (status === "ERROR") {
                                        console.log("Error: " + errorMessage);
                                        // Show error message
                                    }
                            }
                        );
                    }
                }else if(toggleVal == 'myTeamPf'){
                    var allAccList = component.get("v.allAccList");
                    var allOwnerList = component.get("v.allOwnerList");
                    
                    console.log('allOwnerList'+allOwnerList);
                    console.log('allAccList'+allAccList);
                    component.set("v.body",[]);
                    for(var j=0;j<allOwnerList.length;j++){
                        var accIds = [];
                        console.log('OwnerID#'+allOwnerList[j].id);
                        for(var i=0;i<allAccList.length;i++){
                            if(allAccList[i].Owner.Id == allOwnerList[j].id){
                                
                                accIds.push(allAccList[i].Id);
                            }
                        }
                        component.set("v.pfAccIds",accIds);
                        $A.createComponent(
                            "c:QL_AccountHealthIndicator",
                            {
                                "pfAccId": component.get("v.pfAccIds"),
                                "ownerObj": allOwnerList[j]
                            },
                            function(newCmp, status, errorMessage){
                                if (status === "SUCCESS") {
                                    console.log("comp create change");
                                    var body = component.get("v.body");
                                    body.push(newCmp);
                                    component.set("v.body", body);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                    // Show offline error
                                }
                                    else if (status === "ERROR") {
                                        console.log("Error: " + errorMessage);
                                        // Show error message
                                    }
                            }
                        );
                    }
                    component.set("v.Spinner",false);
                }
                
                //}
                var accOwnerList = component.get("v.accOwnerList");
                var accTaskOwnerList = component.get("v.accTaskOwnerList");
                var containsStr="";
                
                if(accList.length > 0){
                    if(accOwnerList.length == 0){
                        for(var i=0;i<accList.length;i++){
                            if(!containsStr.includes(accList[i].OwnerId)){
                                var selectObj = new Object();
                                selectObj.label = accList[i].Owner.Name;
                                selectObj.value = accList[i].Owner.Name;
                                selectObj.id = accList[i].OwnerId;
                                accOwnerList.push(selectObj);
                                containsStr = containsStr.concat(accList[i].OwnerId);
                                console.log('concatStr'+containsStr);
                                //console.log("OwnerId"+arrObj[0].OwnerId);
                                //console.log("OwnerName"+arrObj[0].Owner.Name);                            
                            }
                            
                        }
                        component.set("v.accOwnerList",accOwnerList);
                        
                    }
                }
                
                if(toggleVal == 'myTeamPf' && component.get("v.accOwnerList").length > 0){
                    $A.util.removeClass(component.find("selectAccNoKeyCont"),"slds-hide");
                }else {
                    $A.util.addClass(component.find("selectAccNoKeyCont"),"slds-hide");
                }
                if(acckycWOActivities.length > 0){
                    if(accTaskOwnerList.length == 0){
                        for(var i=0;i<acckycWOActivities.length;i++){
                            if(!containsStr.includes(acckycWOActivities[i].Owner.Id)){
                                var selectObj = new Object();
                                selectObj.label = acckycWOActivities[i].Owner.Name;
                                selectObj.value = acckycWOActivities[i].Owner.Name;
                                selectObj.id = acckycWOActivities[i].Owner.Id;
                                accTaskOwnerList.push(selectObj);
                                containsStr = containsStr.concat(acckycWOActivities[i].Owner.Id);
                                console.log('concatStr'+containsStr);
                                //console.log("OwnerId"+arrObj[0].OwnerId);
                                //console.log("OwnerName"+arrObj[0].Owner.Name);                            
                            }
                            
                        }
                        component.set("v.accTaskOwnerList",accTaskOwnerList);
                        
                    }
                }
                
                if(toggleVal == 'myTeamPf' && component.get("v.accTaskOwnerList").length > 0){
                    $A.util.removeClass(component.find("selectAccNoKeyContTask"),"slds-hide");
                }else {
                    $A.util.addClass(component.find("selectAccNoKeyContTask"),"slds-hide");
                }    
                
                component.set("v.Spinner",false);
            }else{
                component.set("v.Spinner",false);
                console.log('Failure');
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchOverdueOpp : function(component,event,userId,toggleVal) {
        component.set("v.Spinner",true);
        $A.util.addClass(component.find("dymDivOverdueOpp"),"slds-hide");
        $A.util.addClass(component.find("dymDivOverdueOppFilter"),"slds-hide");
        $A.util.removeClass(component.find("dymDivOverdueOppMaster"),"slds-hide");
        if(toggleVal == 'myPf'){
            $A.util.addClass(component.find("selectOverdueOpp"),"slds-hide");  
        }else {
            $A.util.removeClass(component.find("selectOverdueOpp"),"slds-hide");
        }
        var action = component.get("c.fetchOverdueOpps");
        action.setStorable();
        var roleIds = component.get("v.allOwnerIds");
        action.setParams({"userId":userId,"TeamOrMine":toggleVal,"roleIds":roleIds});
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === "SUCCESS"){
                var arrObj = response.getReturnValue();
                component.set("v.overdueOppList",arrObj);
                var overdueOppOwnerList = component.get("v.overdueOppOwnerList");
                var containsStr="";
                if(arrObj.length > 0){
                    if(overdueOppOwnerList.length == 0){
                        for(var i=0;i<arrObj.length;i++){
                            if(!containsStr.includes(arrObj[i].OwnerId)){
                                var selectObj = new Object();
                                selectObj.label = arrObj[i].Owner.Name;
                                selectObj.value = arrObj[i].Owner.Name;
                                selectObj.id = arrObj[i].OwnerId;
                                overdueOppOwnerList.push(selectObj);
                                containsStr = containsStr.concat(arrObj[i].OwnerId);
                                console.log('concatStr'+containsStr);
                                console.log("OwnerId"+arrObj[0].OwnerId);
                                console.log("OwnerName"+arrObj[0].Owner.Name);                            
                            }
                            
                        }
                        component.set("v.overdueOppOwnerList",overdueOppOwnerList);
                        
                    }
                }
                if(toggleVal == 'myTeamPf' && component.get("v.overdueOppOwnerList").length > 0){
                    $A.util.removeClass(component.find("selectOverdueOpp"),"slds-hide");
                }else {
                    $A.util.addClass(component.find("selectOverdueOpp"),"slds-hide");
                }
                component.set("v.Spinner",false);
            }else{
                component.set("v.Spinner",false);
                console.log('Failure');
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchDecAcc : function(component,event,userId,toggleVal) {
        component.set("v.Spinner",true);
        $A.util.addClass(component.find("dymDivDecAcc"),"slds-hide");
        $A.util.addClass(component.find("dymDivDecAccFilter"),"slds-hide");
        $A.util.addClass(component.find("dymDivDecAccRisk"),"slds-hide");
        $A.util.addClass(component.find("dymDivDecAccRiskFilter"),"slds-hide");
        $A.util.removeClass(component.find("dymDivDecAccRiskMaster"),"slds-hide");
        $A.util.removeClass(component.find("dymDivDecAccMaster"),"slds-hide");
        if(toggleVal == 'myPf'){
            $A.util.addClass(component.find("selectDecAcc"),"slds-hide");
            $A.util.addClass(component.find("selectDecAccRisk"),"slds-hide");
        }else {
            $A.util.removeClass(component.find("selectDecAcc"),"slds-hide");
            $A.util.removeClass(component.find("selectDecAccRisk"),"slds-hide");
        }
        var action = component.get("c.fetchShareDecliningAccounts");
        console.log('outside fetchDecAcc***');
        action.setStorable();
        var roleIds = component.get("v.allOwnerIds");
        action.setParams({"userId":userId,"TeamOrMine":toggleVal,"roleIds":roleIds});
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === "SUCCESS"){
                console.log('inside fetchDecAcc');
                
                var arrObj = response.getReturnValue();
                console.log(JSON.stringify(arrObj[0]));
                console.log(JSON.stringify(arrObj[1]));
                var decAccList = arrObj[0];
                var decAccRiskList = arrObj[1];
                
                
                component.set("v.decAccList",(decAccList != null)?decAccList:null);
                component.set("v.decAccRiskList",(decAccRiskList != null)?decAccRiskList:null);
                var decAccOwnerList = component.get("v.decAccOwnerList");
                var decAccRiskOwnerList = component.get("v.decAccRiskOwnerList");
                var containsStr="";
                if(decAccList.length > 0){
                    console.log(decAccList.length);
                    if(decAccOwnerList.length == 0){
                        for(var i=0;i<decAccList.length;i++){
                            if(!containsStr.includes(decAccList[i].OwnerId)){
                                var selectObj = new Object();
                                selectObj.label = decAccList[i].Account_Alias__c;
                                selectObj.value = decAccList[i].Account_Alias__c;
                                selectObj.id = decAccList[i].OwnerId;
                                decAccOwnerList.push(selectObj);
                                containsStr = containsStr.concat(decAccList[i].OwnerId);
                                console.log('concatStr'+containsStr);
                                //console.log("OwnerId"+arrObj[0].OwnerId);
                                //console.log("OwnerName"+arrObj[0].Owner.Name);                            
                            }
                            
                        }
                        component.set("v.decAccOwnerList",decAccOwnerList);
                        console.log('****'+component.get("v.decAccOwnerList").length);
                        
                    }
                }
                if( toggleVal == 'myTeamPf' && component.get("v.decAccOwnerList").length > 0){
                    $A.util.removeClass(component.find("selectDecAcc"),"slds-hide");
                }else {
                    $A.util.addClass(component.find("selectDecAcc"),"slds-hide");
                }
                if(decAccRiskList.length > 0){
                    console.log(decAccRiskList.length);
                    if(decAccRiskOwnerList.length == 0){
                        for(var i=0;i<decAccRiskList.length;i++){
                            if(!containsStr.includes(decAccRiskList[i].OwnerId)){
                                var selectObj = new Object();
                                selectObj.label = decAccRiskList[i].Account_Alias__c;
                                selectObj.value = decAccRiskList[i].Account_Alias__c;
                                selectObj.id = decAccRiskList[i].OwnerId;
                                decAccRiskOwnerList.push(selectObj);
                                containsStr = containsStr.concat(decAccRiskList[i].OwnerId);
                                console.log('concatStr'+containsStr);
                                //console.log("OwnerId"+arrObj[0].OwnerId);
                                //console.log("OwnerName"+arrObj[0].Owner.Name);                            
                            }
                            
                        }
                        component.set("v.decAccRiskOwnerList",decAccRiskOwnerList);
                        console.log('****'+component.get("v.decAccRiskOwnerList").length);
                        
                    }
                    
                }
                if(toggleVal == 'myTeamPf' && component.get("v.decAccRiskOwnerList").length > 0){
                    $A.util.removeClass(component.find("selectDecAccRisk"),"slds-hide");
                }else {
                    $A.util.addClass(component.find("selectDecAccRisk"),"slds-hide");
                }
                component.set("v.Spinner",false);
            }else{
                component.set("v.Spinner",false);
                console.log('Failure');
            }
        });
        
        $A.enqueueAction(action);
    },
    helperFun : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    }
})