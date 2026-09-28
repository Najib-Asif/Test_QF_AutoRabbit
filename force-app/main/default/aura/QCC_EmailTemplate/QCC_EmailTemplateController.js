({
	onSelectedEmailTemplate: function(component, event) {
		var selectedSfEmTempName = event.getSource().get("v.text");
		var selectedEmTempName = event.getSource().get("v.name");
		var caseId = component.get('v.caseId');

        var emailTemplateEvent = $A.get("e.c:QCC_EmailTemplateEvent");
        emailTemplateEvent.setParams({"emailTemplateName" : selectedEmTempName, "caseId" :  caseId, "sfEmailTemplateName" : selectedSfEmTempName});
        emailTemplateEvent.fire();

        var overlayPanel = component.get('v.overlayPanel');
    	overlayPanel[0].close();
	}
})