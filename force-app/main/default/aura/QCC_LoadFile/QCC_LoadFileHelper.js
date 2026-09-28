({
	getUploadedFiles : function(cmp, event){
        var mode = 'dismissable';
        this.toggleSpinner(cmp,false);
        var methodName = "getAllUploadedFiles";
       	var param = {'caseRecordId':cmp.get("v.caseRecord.Id")};
        if(!$A.util.isEmpty(cmp.get("v.caseRecord.Id"))){
            this.enqueueAction(cmp, methodName, param ,true, function(error, data){
                this.toggleSpinner(cmp,false);
                if(error){
                    cmp.set("v.errorList",[error]); 
                    this.handleShowToast(cmp,event,mode);
                }else {
                   cmp.set("v.uploadedFiles",data);  
                }
            });
        }
    },
    createCaseCommentRecord: function(cmp, event,uploadedFileNames){ 
        var mode = 'dismissable';
        this.toggleSpinner(cmp,false);
        var methodName = "createCaseCommentRecord"; 
        var param = { 'caseRecordId':cmp.get("v.caseRecord.Id"),'fileNames' :uploadedFileNames };
        if(!$A.util.isEmpty(cmp.get("v.caseRecord.Id"))){
            this.enqueueAction(cmp, methodName, param ,true, function(error, data){
                this.toggleSpinner(cmp,false);
                if(error){
                    cmp.set("v.errorList",[error]); 
                    this.handleShowToast(cmp,event,mode);
                }
            });
        }
    },
    enqueueAction: function(cmp, method, params,toggerRequired, callback){
        if(toggerRequired){
            this.toggleSpinner(cmp, true);
        }
		var action = cmp.get("c." + method); 
		if(params) action.setParams(params);
		action.setCallback(this, function(response){
			if(response.getState() === "SUCCESS") {
				if(callback) callback.call(this, null, response.getReturnValue());
	        } else if(response.getState() === "ERROR") {
	        	var message = 'Unknown error'; 
	        	var errors = response.getError();
	            if (!$A.util.isEmpty(errors)) {
	                message = errors[0].message;
	            }
	        	console.error(message);
	        	if(callback) callback.call(this, message);
	        }
	        this.toggleSpinner(cmp, false);
		});
		$A.enqueueAction(action);
	},
	toggleSpinner: function(cmp, show) {
        cmp.set("v.loaded",show);
	},
    handleShowToast : function(cmp, event,mode) {
        cmp.find('notifLib').showToast({
            "variant" : "error",
            "title": "Please review below error messages!",
            "message": "{0} !",
            "messageData":cmp.get("v.errorList"),
            "mode" : mode
        });
    },
})