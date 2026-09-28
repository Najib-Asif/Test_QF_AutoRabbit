({
    doInit: function(cmp, event, helper){
        var caseId = cmp.get('v.recordId');
        //var rec=cmp.get('v.record');
        //alert('caseId: ' + caseId);
        //alert('rec: ' + rec);
        helper.getContact(cmp, caseId);
    }
})