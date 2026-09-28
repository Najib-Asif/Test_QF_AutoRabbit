({
	doInit : function(component, event, helper) {
        var navigateToURL = $A.get("e.force:navigateToURL");
        navigateToURL.setParams({
            "url": "testus://"
        });
        //navigateToURL.fire();
        
        /**var navigateToRecord = $A.get("e.force:navigateToSObject");
        navigateToRecord.setParams({
            "recordId": component.get("v.contactId")
        });
        navigateToRecord.fire();*/
        
        var aqireURL = $A.get("$Label.c.QCC_Aqire_Application_URL");
        aqireURL = aqireURL.replace("<FrequentFlyerNumber>", component.get("v.ffNo"));
        alert(aqireURL);
        //window.open("/lightning/r/" + component.get("v.contactId"), "_top");
	}
})