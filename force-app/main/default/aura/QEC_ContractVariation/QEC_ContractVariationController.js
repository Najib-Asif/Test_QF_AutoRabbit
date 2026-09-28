({
    closeAction:function(component,event,helper){
        var dismissPop = $A.get("e.force:closeQuickAction");
        dismissPop.fire();     
    }

})