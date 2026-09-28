({
    doInit : function(component, event, helper) {
        var key = component.get("v.key");
        var map = component.get("v.map");
        
        // set the values of map to the value attribute	
        // to get map values in lightning component use "map[key]" syntax. 
        console.log('MAP :'+JSON.stringify(map));
        var subcategory = map[key];
        var category=[],content=[];
        for(var j in subcategory){
            category.push(j);
        }
        component.set("v.listKey" , category);
        for(var k in subcategory){
            content.push({key:k,value:subcategory[k]});
        }
        component.set("v.finalval", content);
    }
})