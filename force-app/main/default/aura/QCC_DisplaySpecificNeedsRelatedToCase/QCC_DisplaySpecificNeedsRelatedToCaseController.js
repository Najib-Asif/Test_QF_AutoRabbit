({
    doInit: function (component, event, helper) {
        helper.getCheckboxValues(component, event, helper);
        helper.getFields(component, event, helper);
    },
    
    setActiveSections: function (component, event, helper) {
        component.set("v.activeSectionsName", ['sectionWC', 'sectionMCNE', 'sectionSD', 'sectionMCPAP', 'sectionMCS', 'sectionMCOD', 'sectionMCOIQ', 'sectionMCOITO', 'sectionBCB', 'sectionBMBW']);
    },
    
    handleChange: function (component, event){
        var eventSource = event.getSource();
        var auraId = eventSource.getLocalId();
        var attributeName = auraId.replace("checkboxGroup", "");
        
        if (component.get("v.mode" + attributeName) == 'edit') {
            component.set("v.mode" + attributeName, 'view');
        }
        component.set("v.mode" + attributeName, 'edit');
    },
    
    handleSuccess: function(component, event, helper){
        helper.saveCheckboxValues(component, event, helper);
    }
});