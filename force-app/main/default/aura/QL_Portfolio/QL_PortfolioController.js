({
    /*doInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('User Id'+userId);
        console.log('Name : '+ component.get("v.value"));
        helper.expandSections(component,event,helper);
        helper.fetchOpp(component, event, helper, userId);
    },*/
    initHandleChange : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var toggleVal = component.get("v.value");
        var headerNames = $A.get("$Label.c.Portfolio_Headers");
        component.set("v.headers",headerNames.split(','));
        var proAction = $A.get("$Label.c.Portfolio_Proactive_Actions");
        component.set("v.proactiveActions",proAction.split(','));
        var reAction = $A.get("$Label.c.Portfolio_Reactive_Actions");
        component.set("v.reactiveActions",reAction.split(','));
        
        helper.getRoleAndSubordinates(component, event, userId, toggleVal);
        helper.expandSections(component,event,helper);
        helper.fetchOpp(component, event, userId, toggleVal);
        helper.fetchAccountWOKeyContact(component, event, userId, toggleVal);
        helper.fetchOverdueOpp(component, event, userId, toggleVal);
        helper.fetchDecAcc(component, event, userId, toggleVal);
 
    },
    onSelectValOwnerChange : function(component, event, helper) {
        component.set("v.newArrOppList",[]);
        component.set("v.newArrAccList",[]);
        component.set("v.newArrAcckycWOActivities",[]);
        component.set("v.newArrOverdueOppList",[]);
        component.set("v.newArrDecAccList",[]);
        component.set("v.newArrDecAccRiskList",[]);
        component.set("v.pfAccIds",[]);
        var selOwnerId = component.get("v.selectedOwner");
        var oppList = component.get("v.oppList");
        var newArrOppList = component.get("v.newArrOppList");
        var accList = component.get("v.accList");
        var newArrAccList = component.get("v.newArrAccList");
        var accActList = component.get("v.acckycWOActivities");
        var newArrAcckycWOActivities = component.get("v.newArrAcckycWOActivities");
        var overdueOppList = component.get("v.overdueOppList");
        var newArrOverdueOppList = component.get("v.newArrOverdueOppList");
        var decAccList = component.get("v.decAccList");
        var newArrDecAccList = component.get("v.newArrDecAccList");
        var decAccRiskList = component.get("v.decAccRiskList");
        var newArrDecAccRiskList = component.get("v.newArrDecAccRiskList");
        var allAccList = component.get("v.allAccList");
        var allOwnerList = component.get("v.allOwnerList");
        var selAccObj = null;
        
        if(selOwnerId != 'showAll' && selOwnerId != 'showAllMem'){
            for(var i=0;i<oppList.length;i++){
                if(oppList[i].OwnerId == selOwnerId)
                    newArrOppList.push(oppList[i]);
            }
            component.set("v.newArrOppList",newArrOppList);
            $A.util.removeClass(component.find("dymDivPiOppFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivPiOppMaster"),"slds-hide");
            for(var i=0;i<accList.length;i++){
                if(accList[i].OwnerId == selOwnerId)
                    newArrAccList.push(accList[i]);
            }
            component.set("v.newArrAccList",newArrAccList);
            $A.util.removeClass(component.find("dymDivFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivMaster"),"slds-hide");
            for(var i=0;i<accActList.length;i++){
                if(accActList[i].Owner.Id == selOwnerId)
                    newArrAcckycWOActivities.push(accActList[i]);
            }
            component.set("v.newArrAcckycWOActivities",newArrAcckycWOActivities);
            $A.util.removeClass(component.find("dymDivAccountWOKeyContactTskFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivAccountWOKeyContactTskMaster"),"slds-hide");
            for(var i=0;i<overdueOppList.length;i++){
                if(overdueOppList[i].OwnerId == selOwnerId)
                    newArrOverdueOppList.push(overdueOppList[i]);
            }
            component.set("v.newArrOverdueOppList",newArrOverdueOppList);
            $A.util.removeClass(component.find("dymDivOverdueOppFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivOverdueOppMaster"),"slds-hide");
            for(var i=0;i<decAccList.length;i++){
                if(decAccList[i].OwnerId == selOwnerId)
                    newArrDecAccList.push(decAccList[i]);
            }
            component.set("v.newArrDecAccList",newArrDecAccList);
            $A.util.removeClass(component.find("dymDivDecAccFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivDecAccMaster"),"slds-hide");
            for(var i=0;i<decAccRiskList.length;i++){
                if(decAccRiskList[i].OwnerId == selOwnerId)
                    newArrDecAccRiskList.push(decAccRiskList[i]);
            }
            component.set("v.newArrDecAccRiskList",newArrDecAccRiskList);
            $A.util.removeClass(component.find("dymDivDecAccRiskFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivDecAccRiskMaster"),"slds-hide");
            
            var accIds = [];
            for(var i=0;i<allAccList.length;i++){
                if(allAccList[i].Owner.Id == selOwnerId){
                    
                    accIds.push(allAccList[i].Id);
                }
            }
            for(var i=0;i<allOwnerList.length;i++){
                if(allOwnerList[i].id == selOwnerId){           
                    selAccObj = allOwnerList[i];
                }
            }
            component.set("v.pfAccIds",accIds);
            
        }else if(selOwnerId == 'showAll'){
            $A.util.removeClass(component.find("dymDivPiOppMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivPiOppFilter"),"slds-hide");
            $A.util.removeClass(component.find("dymDivMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivFilter"),"slds-hide");
            $A.util.removeClass(component.find("dymDivAccountWOKeyContactTskMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivAccountWOKeyContactTskFilter"),"slds-hide");
            $A.util.removeClass(component.find("dymDivOverdueOppMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivOverdueOppFilter"),"slds-hide");
            $A.util.removeClass(component.find("dymDivDecAccMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivDecAccFilter"),"slds-hide");
            $A.util.removeClass(component.find("dymDivDecAccRiskMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivDecAccRiskFilter"),"slds-hide");
            
            
            var accIds = [];
            for(var i=0;i<allAccList.length;i++){                    
                accIds.push(allAccList[i].Id);  
            }
            component.set("v.pfAccIds",accIds);
        }
        
        $A.createComponent(
            "c:QL_AccountHealthIndicator",
            {
                "pfAccId": component.get("v.pfAccIds"),
                "ownerObj": selAccObj
            },
            function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    console.log("comp create change");
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
        if(selOwnerId == 'showAllMem'){
            $A.enqueueAction(component.get("c.initHandleChange"));
        }
    },
    onShowMoreAccWOKeyCont : function(component, event, helper){
        $A.util.toggleClass(component.find("dymDiv"),"slds-hide");
        if(component.get("v.showMoreAccWOKeyCont") == "show more >>"){
            component.set("v.showMoreAccWOKeyCont","show less <<");
        }else{
            component.set("v.showMoreAccWOKeyCont","show more >>");
        }
    },
    onShowMoreAccWOKeyContTsk : function(component, event, helper){
        $A.util.toggleClass(component.find("dymDivAccountWOKeyContactTsk"),"slds-hide");
        if(component.get("v.showMoreAccWOKeyContTsk") == "show more >>"){
            component.set("v.showMoreAccWOKeyContTsk","show less <<");
        }else{
            component.set("v.showMoreAccWOKeyContTsk","show more >>");
        }
    },
    onShowMorePiOpp : function(component, event, helper){
        $A.util.toggleClass(component.find("dymDivPiOpp"),"slds-hide");
        if(component.get("v.showMorePiOpp") == "show more >>"){
            component.set("v.showMorePiOpp","show less <<");
        }else{
            component.set("v.showMorePiOpp","show more >>");
        }
    },
    onShowMoreOverdueOpp : function(component, event, helper){
        $A.util.toggleClass(component.find("dymDivOverdueOpp"),"slds-hide");
        if(component.get("v.showMoreOverdueOpp") == "show more >>"){
            component.set("v.showMoreOverdueOpp","show less <<");
        }else{
            component.set("v.showMoreOverdueOpp","show more >>");
        }
    },
    onShowMoreDecAcc : function(component, event, helper){
        $A.util.toggleClass(component.find("dymDivDecAcc"),"slds-hide");
        if(component.get("v.showMoreDecAcc") == "show more >>"){
            component.set("v.showMoreDecAcc","show less <<");
        }else{
            component.set("v.showMoreDecAcc","show more >>");
        }
    },
    onShowMoreDecRiskAcc : function(component, event, helper){
        $A.util.toggleClass(component.find("dymDivDecAccRisk"),"slds-hide");
        if(component.get("v.showMoreDecRiskAcc") == "show more >>"){
            component.set("v.showMoreDecRiskAcc","show less <<");
        }else{
            component.set("v.showMoreDecRiskAcc","show more >>");
        }
    },
    onSelectValOpp : function(component,event,helper){
        
        //console.log(component.find("select").get("v.value"));
        console.log('***'+component.get("v.value"));
        console.log(component.get("v.selectedValue"));
        var selOwnerId = component.get("v.selectedValue");
        var oppList = component.get("v.oppList");
        var newArr = [];
        if(selOwnerId != ''){
            $A.util.removeClass(component.find("dymDivPiOppFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivPiOppMaster"),"slds-hide");
            for(var i=0;i<oppList.length;i++){
                if(oppList[i].OwnerId == selOwnerId)
                    newArr.push(oppList[i]);
            }
            component.set("v.newArrOppList",newArr);
        }else{
            $A.util.removeClass(component.find("dymDivPiOppMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivPiOppFilter"),"slds-hide");
        }
        
        
        
    },
    onSelectValAccNoKeyCont : function(component,event,helper){
        
        var selOwnerId = component.get("v.selectedValueAccNoKeyCont");
        var accList = component.get("v.accList");
        var newArr = [];
        if(selOwnerId != ''){
            $A.util.removeClass(component.find("dymDivFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivMaster"),"slds-hide");
            for(var i=0;i<accList.length;i++){
                if(accList[i].OwnerId == selOwnerId)
                    newArr.push(accList[i]);
            }
            component.set("v.newArrAccList",newArr);
        }else{
            $A.util.removeClass(component.find("dymDivMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivFilter"),"slds-hide");
        }
        
    },
    onSelectValAccNoKeyContTask : function(component,event,helper){
        
        var selOwnerId = component.get("v.selectedValueAccNoKeyContTask");
        var accList = component.get("v.acckycWOActivities");
        var newArr = [];
        if(selOwnerId != ''){
            $A.util.removeClass(component.find("dymDivAccountWOKeyContactTskFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivAccountWOKeyContactTskMaster"),"slds-hide");
            for(var i=0;i<accList.length;i++){
                if(accList[i].Owner.Id == selOwnerId)
                    newArr.push(accList[i]);
            }
            component.set("v.newArrAcckycWOActivities",newArr);
        }else{
            $A.util.removeClass(component.find("dymDivAccountWOKeyContactTskMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivAccountWOKeyContactTskFilter"),"slds-hide");
        }
        
    },
    onSelectValOverdueOpp : function(component,event,helper){
        
        var selOwnerId = component.get("v.selectedValueOverdueOpp");
        var overdueOppList = component.get("v.overdueOppList");
        var newArr = [];
        if(selOwnerId != ''){
            $A.util.removeClass(component.find("dymDivOverdueOppFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivOverdueOppMaster"),"slds-hide");
            for(var i=0;i<overdueOppList.length;i++){
                if(overdueOppList[i].OwnerId == selOwnerId)
                    newArr.push(overdueOppList[i]);
            }
            component.set("v.newArrOverdueOppList",newArr);
        }else{
            $A.util.removeClass(component.find("dymDivOverdueOppMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivOverdueOppFilter"),"slds-hide");
        }
        
    },
    onSelectValDecAcc : function(component,event,helper){
        
        var selOwnerId = component.get("v.selectedValueDecAcc");
        var decAccList = component.get("v.decAccList");
        var newArr = [];
        if(selOwnerId != ''){
            $A.util.removeClass(component.find("dymDivDecAccFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivDecAccMaster"),"slds-hide");
            for(var i=0;i<decAccList.length;i++){
                if(decAccList[i].OwnerId == selOwnerId)
                    newArr.push(decAccList[i]);
            }
            component.set("v.newArrDecAccList",newArr);
        }else{
            $A.util.removeClass(component.find("dymDivDecAccMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivDecAccFilter"),"slds-hide");
        }
        
    },
    onSelectValDecAccRisk : function(component,event,helper){
        
        var selOwnerId = component.get("v.selectedValueDecAccRisk");
        var decAccRiskList = component.get("v.decAccRiskList");
        var newArr = [];
        if(selOwnerId != ''){
            $A.util.removeClass(component.find("dymDivDecAccRiskFilter"),"slds-hide");
            $A.util.addClass(component.find("dymDivDecAccRiskMaster"),"slds-hide");
            for(var i=0;i<decAccRiskList.length;i++){
                if(decAccRiskList[i].OwnerId == selOwnerId)
                    newArr.push(decAccRiskList[i]);
            }
            component.set("v.newArrDecAccRiskList",newArr);
        }else{
            $A.util.removeClass(component.find("dymDivDecAccRiskMaster"),"slds-hide");
            $A.util.addClass(component.find("dymDivDecAccRiskFilter"),"slds-hide");
        }
        
    },
    sectionAHI : function(component, event, helper) {
        helper.helperFun(component,event,'articleAHI');
    },
    sectionOne : function(component, event, helper) {
        helper.helperFun(component,event,'articleOne');
    },
    
    sectionTwo : function(component, event, helper) {
        helper.helperFun(component,event,'articleTwo');
    },
    sectionThree : function(component, event, helper) {
        helper.helperFun(component,event,'articleThree');
    }
})