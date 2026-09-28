({
    itemSelected : function(component, event, helper) {
        var target = event.target;   
        var SelIndex = helper.getIndexFrmParent(target,helper,"data-selectedIndex");  
        if(SelIndex){
            var serverResult = component.get("v.search_result");
            var selectedItem = serverResult[SelIndex];
            console.log('selectedItem'+selectedItem);
            console.log('serverResult'+serverResult);
            if(selectedItem.val){
                component.set("v.selectedItem",selectedItem);
                component.set("v.last_ServerResult",serverResult);
            } 
            component.set("v.search_result",null); 
        } 
    }, 
    searchCall : function(component, event, helper) {  
        var target = event.target;  
        var searchText = target.value; 
        var last_SearchText = component.get("v.last_SearchText");
        //Escape button pressed 
        if (event.keyCode == 27 || !searchText.trim()) { 
            helper.clearSelection(component, event, helper);
        }else if(searchText.trim() != last_SearchText  && searchText.length >1  ){ 
            //Save server call, if last text not changed
            //Search only when space character entered
            
            var objectName = component.get("v.objectName");
            var field_API_text = component.get("v.field_API_text");
            var field_API_val = component.get("v.field_API_val");
            var field_API_val1 = component.get("v.field_API_val1");
            var field_API_val2 = component.get("v.field_API_val2");
            var field_API_val3 = component.get("v.field_API_val3");
            var field_API_val4 = component.get("v.field_API_val4");
            var field_API_val5 = component.get("v.field_API_val5");
            var field_API_val6 = component.get("v.field_API_val6");
            var field_API_val7 = component.get("v.field_API_val7");
            var field_API_val8 = component.get("v.field_API_val8");
            var field_API_val9 = component.get("v.field_API_val9");
            var field_API_val10 = component.get("v.field_API_val10");
            var field_API_val11 = component.get("v.field_API_val11");
            var field_API_val12 = component.get("v.field_API_val12");
            var field_API_val13 = component.get("v.field_API_val13");
            var field_API_val14 = component.get("v.field_API_val14");
            var field_API_val15 = component.get("v.field_API_val15");
            var field_API_val16 = component.get("v.field_API_val16");
            
            
            
            var field_API_search = component.get("v.field_API_search");
            var limit = component.get("v.limit");
            
            var action = component.get('c.searchDB');
            action.setStorable();
            
            action.setParams({
                objectName : objectName,
                fld_API_Text : field_API_text,
                fld_API_Val : field_API_val,
                fld_API_Val1 : field_API_val1,
                fld_API_Val2 : field_API_val2,
                fld_API_Val3 : field_API_val3,
                fld_API_Val4 : field_API_val4,
                fld_API_Val5 : field_API_val5,
                fld_API_Val6 : field_API_val6,
                fld_API_Val7 : field_API_val7,
                fld_API_Val8 : field_API_val8,
                fld_API_Val9 : field_API_val9,
                fld_API_Val10: field_API_val10,
				fld_API_Val11 : field_API_val11,
				fld_API_Val12 : field_API_val12,
				fld_API_Val13 : field_API_val13,
				fld_API_Val14 : field_API_val14,
				fld_API_Val15 : field_API_val15,
				fld_API_Val16 : field_API_val16,
				
                lim : limit, 
                fld_API_Search : field_API_search,
                searchText : searchText
            });
            
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);
            });
            
            component.set("v.last_SearchText",searchText.trim());
            console.log('Server call made');
            $A.enqueueAction(action); 
        }else if(searchText && last_SearchText && searchText.trim() == last_SearchText.trim()){ 
            component.set("v.search_result",component.get("v.last_ServerResult"));
            console.log('Server call saved');
        }         
    },
    handleResponse : function (res,component,helper){
        if (res.getState() === 'SUCCESS') {
            var retObj = JSON.parse(res.getReturnValue());
            if(retObj.length <= 0){
                var noResult = JSON.parse('[{"text":"No Results Found"}]');
                component.set("v.search_result",noResult); 
                component.set("v.last_ServerResult",noResult);
            }else{
                console.log('Raaaaa');
                console.log(res.getReturnValue());
                component.set("v.search_result",retObj); 
                component.set("v.last_ServerResult",retObj);
            }  
        }else if (res.getState() === 'ERROR'){
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    alert(errors[0].message);
                }
            } 
        }
    },
    getIndexFrmParent : function(target,helper,attributeToFind){
        //User can click on any child element, so traverse till intended parent found
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode ;
            SelIndex = helper.getIndexFrmParent(target,helper,attributeToFind);           
        }
        return SelIndex;
    },
    clearSelection: function(component, event, helper){
        component.set("v.selectedItem",null);
        component.set("v.search_result",null);
    } 
})