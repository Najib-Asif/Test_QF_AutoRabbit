({
    doInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var vfUrl = '/apex/APXTConga4__Conga_Composer?serverUrl={!API.Partner_Server_URL_290}&Id='+userId+'&TemplateId=a0X2v00000MATFz,&ReportId=00O90000008kSo2?pv0=,00O90000008k6zv?pv0=,00O90000008kEaj?pv0=,00O90000008k7ig?pv0=&DS7=13';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": vfUrl
        });
        urlEvent.fire();
    }
})