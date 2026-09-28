({
    getOrgWideAndCaseType: function(component) {
		var recId = component.get("v.recordId");
        console.log('record id = '+recId);
        var action = component.get("c.getOrgWideAndCaseTypeServer");
        console.log('In getOrgWideAndCaseType');
        action.setParams({
            "recId": recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retval = response.getReturnValue();
                if(!retval) return;
                var arr = retval.split(",");
                console.log('Type == '+arr[0]+' OrgWideId = '+arr[1]);
                if(arr[0] == 'Insurance Letter') {
                    component.set("v.RecType", true);
                }
                if(arr[1] != null) {
                    component.set("v.OrgWideAddress", arr[1]);
                }
                if(arr[2] != null) {
                    console.log("ZZZ tempidofCS: "+arr[2]);
                    component.set("v.templateIdCS", arr[2]);
                }
            }else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
	},
    ValidateCase: function (component) {        
        var caseId1               = component.get("v.recordId"); 
        var ContactId1            = component.get("v.contactId");
        var sfEmailTemplateId1 = '';//component.get("v.caseF.Conga_Email_Template_ID__c");
        var CongaTemplateId1      = '';//component.get("v.caseF.Conga_Template_ID__c");
        var sessionId1            = component.get("v.sessionId");
        var serverUrl1            = component.get("v.serverUrl");
        var caseContactEmail1     = component.get("v.caseF.Contact_Email__c");
        var caseType1             = component.get("v.caseF.Type");
        var caseGroup1            = component.get("v.caseF.Group__c");
        var caseRecordType1       = component.get("v.caseF.Record_Type__c");
        var OrgWideId1 			  = component.get("v.OrgWideAddress");
        var affectedPassCongaQueryId = component.get("v.affectedPassCongaQueryId");
        var emailTemplateName   = component.get("v.emailTemplateName");
        console.log("ZZZ in Helper case type: "+caseType1);
        
        var autoCloseOnEmailSent  = 'true';
        var recoveryInprogress  = 'false';
        
        var caseId15Digit = caseId1;
        if(caseId15Digit.length == 18) {
            caseId15Digit = caseId15Digit.substring(0,15);     
        }
        
        //ticket QDCUSCON-2086
        if(component.get("v.sfEmailTemplateId") !== ""){
            sfEmailTemplateId1 = component.get("v.sfEmailTemplateId");
            CongaTemplateId1      = component.get("v.congaTemplateId");
            //ticket QDCUSCON-3340
            autoCloseOnEmailSent  = component.get("v.autoCloseOnEmailSent");
            recoveryInprogress = component.get("v.recoveryInprogress");
            //end ticket QDCUSCON-3340
        }
        //end ticket QDCUSCON-2086
        
        if(emailTemplateName == 'Blank Template') {
            var url = '/apex/APXTConga4__Conga_Composer?'+
                '&serverUrl1='+serverUrl1+     
                '&id='+caseId1+
                '&EmailAdditionalTo='+caseContactEmail1+
                '&EmailRelatedToId='+caseId15Digit+
                '&CongaEmailTemplateGroup=QCC_Insurance_Letters'+
                '&EmailTemplateId='+sfEmailTemplateId1+
                '&TemplateGroup=QCC_Insurance_Letters'+
                '&EmailFromId='+OrgWideId1+
                '&UF0=1'+
                '&MFTS0=Auto_Close_on_Email_Sent__c'+
                '&MFTSValue0='+autoCloseOnEmailSent+
                '&MFTS1=Recovery_Inprogress__c'+
                '&MFTSValue1='+recoveryInprogress+
                '&DefaultPDF=1'+
                '&DS7=2';
            window.open(url,"", "width=800,height=600");
        }
        else {
            var action1 = component.get("c.getCaseValues");
        
            action1.setParams({
                "recId"     :caseId1,
                "insType"   :caseType1,
                "fromIntegration": false,
                "cs": null
            }); 
            action1.setCallback(this, function(a) {
                var msg = a.getReturnValue();
                console.log('ZZZ Return Value from Apex: '+msg);
                //var arr = msg.split(",");
                //console.log('Array of return getCaseValues'+arr[0]+' to '+ arr[1]);
                if(msg == 'No'){
                    this.displayToastMessage("error", "Validation Error!", "Some error has occured please check case chatter feed for more information.", 10);
                    $A.get('e.force:refreshView').fire();  
                }else if(msg != 'No' && msg != 'Yes') {
                    var arr = msg.split(",");
                    var url = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl1='+serverUrl1+     
                        '&id='+caseId1+
                        //'&EmailToId= '+//ContactId1+
                        '&EmailAdditionalTo='+caseContactEmail1+
                        '&EmailRelatedToId='+caseId15Digit+
                        '&EmailTemplateId='+arr[1]+
                        '&TemplateGroup=QCC_Ineligible_Insurance_Letters'+
                        '&EmailFromId='+OrgWideId1+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        '&MFTSValue0=true'+
                        //'&DS7Preview=1'+
                        '&DS7=2';
                    window.open(url,"", "width=800,height=600");
                }else if(typeof CongaTemplateId1  === 'undefined' || CongaTemplateId1 === null){
                    var url = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl1='+serverUrl1+     
                        '&id='+caseId1+
                        //'&EmailToId= '+//ContactId1+
                        '&EmailAdditionalTo='+caseContactEmail1+
                        '&EmailRelatedToId='+caseId15Digit+
                        '&CongaEmailTemplateGroup=QCC_Insurance_Letters'+
                        //'&CongaEmailTemplateId='+CongaEmailTemplateId1+
                        '&EmailTemplateId='+sfEmailTemplateId1+
                        //'&TemplateId='+CongaTemplateId1+
                        '&TemplateGroup=QCC_Insurance_Letters'+
                        '&EmailFromId='+OrgWideId1+
                        //'&EmailTemplateAttachments=1'+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        //'&MFTSValue0=true'+
                        '&MFTSValue0='+autoCloseOnEmailSent+
                        '&MFTS1=Recovery_Inprogress__c'+
                        '&MFTSValue1='+recoveryInprogress+
                        '&DefaultPDF=1'+
                        //'&DS7Preview=1'+
                        '&DS7=2';
                    window.open(url,"", "width=800,height=600");
                }else{
                    var url = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl1='+serverUrl1+     
                        '&id='+caseId1+
                        //'&EmailToId= '+//ContactId1+
                        '&EmailAdditionalTo='+caseContactEmail1+
                        '&EmailRelatedToId='+caseId15Digit+
                        '&CongaEmailTemplateGroup=QCC_Insurance_Letters'+
                        //'&CongaEmailTemplateId='+CongaEmailTemplateId1+
                        '&EmailTemplateId='+sfEmailTemplateId1+
                        '&TemplateId='+CongaTemplateId1+
                        '&TemplateGroup=QCC_Insurance_Letters'+
                        '&EmailFromId='+OrgWideId1+
                        '&EmailTemplateAttachments=1'+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        //'&MFTSValue0=true'+
                        '&MFTSValue0='+autoCloseOnEmailSent+
                        '&MFTS1=Recovery_Inprogress__c'+
                        '&MFTSValue1='+recoveryInprogress+
                        '&DefaultPDF=1'+
                        '&QueryId=[AffectedPassengers]'+affectedPassCongaQueryId+'?pv0='+caseId1+
                        //'&DS7Preview=1'+
                        '&DS7=2';
                    window.open(url,"", "width=800,height=600");
                }
                console.log('In Validate method = '+ a.getReturnValue());
            });
            
            $A.enqueueAction(action1);
        }
        
          //$A.enqueueAction(update);
    },
    handleEmail: function (component, event, helper) {
        
        var caseId               = component.get("v.recordId"); 
        var ContactId            = component.get("v.contactId");
        var sfEmailTemplateId    = '';//component.get("v.caseF.Conga_Email_Template_ID__c");
        var CongaTemplateId      = '';//component.get("v.caseF.Conga_Template_ID__c");
        var sessionId            = component.get("v.sessionId");
        var serverUrl            = component.get("v.serverUrl");
        var caseContactEmail     = component.get("v.caseF.Contact_Email__c");
        var caseType             = component.get("v.caseF.Type");
        var caseGroup            = component.get("v.caseF.Group__c");
        var caseRecordType       = component.get("v.caseF.Record_Type__c");
        var OrgWideId            = component.get("v.OrgWideAddress");
        var emailTemplateCaseF   = '';//component.get("v.caseF.Email_Template__c");
        var refundType           = component.get("v.caseF.Refund_Type__c");
        var autoCloseOnEmailSent = 'true';
        var recoveryInprogress   = 'false';

        var caseId15Digit = caseId;
        if(caseId15Digit.length == 18) {
        	caseId15Digit = caseId15Digit.substring(0,15);     
        }
        
        //ticket QDCUSCON-2086
        if(component.get("v.sfEmailTemplateId") !== ""){
            sfEmailTemplateId = component.get("v.sfEmailTemplateId");
            CongaTemplateId      = component.get("v.congaTemplateId");
            emailTemplateCaseF   = component.get("v.emailTemplateName");
            //ticket QDCUSCON-3340
            autoCloseOnEmailSent  = component.get("v.autoCloseOnEmailSent");
            recoveryInprogress = component.get("v.recoveryInprogress");
            //end ticket QDCUSCON-3340
        }
        //end ticket QDCUSCON-2086
        
        console.log("caseId: "+caseId);
        console.log("ContactId: "+ContactId);
        console.log("sfEmailTemplateId: "+sfEmailTemplateId);
        console.log("CongaTemplateId: "+CongaTemplateId);
        console.log("sessionId: "+sessionId);
        console.log("serverUrl: "+serverUrl);
        console.log("caseContactEmail: "+caseContactEmail);
        console.log("CaseType: "+caseType);
        console.log("caseGroup: "+caseGroup);
        console.log("Case Record Type: "+caseRecordType);
        console.log("Case EmailTemplateType: "+emailTemplateCaseF);
        console.log("template id from CS: "+component.get("v.templateIdCS"));

        if(emailTemplateCaseF == null && caseType != 'Compliment' && caseType != 'Insurance Letter') {
            this.displayToastMessage("error", "Error!", "Please select the type of Email Template.", 10);
        }
        else if(caseType == 'Insurance Letter' && caseGroup == 'Booking Cancelled by Customer' && refundType == null) {
            this.displayToastMessage("error", "Error!", "Please select a refund type for this insurance letter.", 10);
        }
        else {
            if(caseType == 'Baggage' && CongaTemplateId == null){
                if(emailTemplateCaseF != null && (emailTemplateCaseF == 'EFT Authorisation' || emailTemplateCaseF == 'EFT Authorisation - No Receipt')){
                         var url2 = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl='+serverUrl+     
                        '&id='+caseId+
                        //'&EmailToId='+ContactId+
                        '&EmailAdditionalTo='+caseContactEmail+
                        '&EmailRelatedToId='+caseId15Digit+
                        '&CongaEmailTemplateGroup=Request_Information'+
                        //'&CongaEmailTemplateId='+CongaEmailTemplateId+
                        '&EmailTemplateId='+sfEmailTemplateId+
                        '&EmailFromId='+OrgWideId+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        //'&MFTSValue0=true'+
                        '&MFTSValue0='+autoCloseOnEmailSent+
                        '&MFTS1=Recovery_Inprogress__c'+
                        '&MFTSValue1='+recoveryInprogress+
                        '&DefaultPDF=1'+
                        //'&DS7Preview=1'+
                        '&TemplateGroup=QCC_Email_Templates,Request_Information,QCC_Damaged_Baggage'+
                        '&TemplateId='+component.get("v.templateIdCS")+
                        '&EmailTemplateAttachments=1'+
                        '&DS7=2';
                        
                    console.log('ZZZZ Baggage, tempid == null 1st part URL: '+url2);
                    window.open(url2,"", "width=800,height=600");
                }
                else{
                    var url1 = '/apex/APXTConga4__Conga_Composer?'+
                    '&serverUrl='+serverUrl+     
                    '&id='+caseId+
                    //'&EmailToId='+ContactId+
                    '&EmailAdditionalTo='+caseContactEmail+
                    '&EmailRelatedToId='+caseId15Digit+
                    '&EmailTemplateGroup=QCC_Damaged_Baggage'+
                    //'&CongaEmailTemplateId='+CongaEmailTemplateId+
                    '&EmailTemplateId='+sfEmailTemplateId+
                    '&CongaEmailTemplateGroup=Request_Information,QCC_Damaged_Baggage'+
                    '&EmailFromId='+OrgWideId+
                    '&UF0=1'+
                    '&MFTS0=Auto_Close_on_Email_Sent__c'+
                    //'&MFTSValue0=true'+
                    '&MFTSValue0='+autoCloseOnEmailSent+
                    '&MFTS1=Recovery_Inprogress__c'+
                    '&MFTSValue1='+recoveryInprogress+
                    '&DefaultPDF=1'+
                    '&DS7=2';
                    console.log('ZZZZ Baggage, tempid == null else part URL: '+url1);
                    window.open(url1,"", "width=800,height=600");
                }
            }
            else if(caseType == 'Baggage' && CongaTemplateId != null){
                    if(emailTemplateCaseF != null && (emailTemplateCaseF == 'EFT Authorisation' || emailTemplateCaseF == 'EFT Authorisation - No Receipt')){
                         var url2 = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl='+serverUrl+     
                        '&id='+caseId+
                        //'&EmailToId='+ContactId+
                        '&EmailAdditionalTo='+caseContactEmail+
                        '&EmailRelatedToId='+caseId15Digit+
                        '&CongaEmailTemplateGroup=Request_Information'+
                        //'&CongaEmailTemplateId='+CongaEmailTemplateId+
                        '&EmailTemplateId='+sfEmailTemplateId+
                        '&EmailFromId='+OrgWideId+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        //'&MFTSValue0=true'+
                        '&MFTSValue0='+autoCloseOnEmailSent+
                        '&MFTS1=Recovery_Inprogress__c'+
                        '&MFTSValue1='+recoveryInprogress+
                        '&DefaultPDF=1'+
                        //'&DS7Preview=1'+
                        '&TemplateGroup=QCC_Email_Templates,Request_Information,QCC_Damaged_Baggage'+
                        '&TemplateId='+component.get("v.templateIdCS")+
                        '&EmailTemplateAttachments=1'+
                        '&DS7=2';
                        
                    console.log('ZZZZ Baggage, tempid != null 1st part URL: '+url2);
                    window.open(url2,"", "width=800,height=600");
                        
                        
                        /* url1 += '&TemplateGroup=QCC_Email_Templates,Request_Information,QCC_Damaged_Baggage'+
                                '&TemplateId='+component.get("v.templateIdCS")+
                                '&EmailTemplateAttachments=1';*/
                }
                else{
                    var url2 = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl='+serverUrl+     
                        '&id='+caseId+
                        //'&EmailToId='+ContactId+
                        '&EmailAdditionalTo='+caseContactEmail+
                        '&EmailRelatedToId='+caseId15Digit+
                        '&CongaEmailTemplateGroup=QCC_Damaged_Baggage'+
                        //'&CongaEmailTemplateId='+CongaEmailTemplateId+
                        '&EmailTemplateId='+sfEmailTemplateId+
                        '&TemplateId='+CongaTemplateId+
                        //'&Qvar0ID=a0WN0000004BgxoMAC'+
                        //'&TemplateID={QVAR0}'+
                        //'&Qvar0ID=a0WN0000004Bgxo'+
                        '&EmailFromId='+OrgWideId+
                        '&EmailTemplateAttachments=1'+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        //'&MFTSValue0=true'+
                        '&MFTSValue0='+autoCloseOnEmailSent+
                        '&MFTS1=Recovery_Inprogress__c'+
                        '&MFTSValue1='+recoveryInprogress+
                        '&DefaultPDF=1';
                        if(emailTemplateCaseF == 'Loss or Damage Letter of Offer CAA Limit' || emailTemplateCaseF == 'Loss or Damage Letter of Offer Montreal Limit'){
                            url2 = url2+'&TemplateGroup=QCC_Delayed_Baggage'+
                                   '&LiveEditEnable=1'+
                                   '&DS7=';
                        }
                        // Added by Puru on 17/04/2018 -- QDCUSCON-3815 - Start
                        else if(emailTemplateCaseF == 'Reimbursement - Request for Release Form' || emailTemplateCaseF == 'Replacement - Request for Release Form'){
                            url2 = url2+'&TemplateGroup=QCC_Damaged_Baggage'+
                                   '&LiveEditEnable=1'+
                                   '&DS7=';
                        }
                        // Added by Puru on 17/04/2018 -- QDCUSCON-3815 - End
                        else{
                            url2 = url2+'&TemplateGroup=QCC_Damaged_Baggage'+
                                   '&DS7=2';
                        }
                        
                    console.log('ZZZZYYYY Baggage, tempid != null else part URL: '+url2);
                    window.open(url2,"", "width=800,height=600");
                    }
            }
			else if(caseType == 'Insurance Letter'){
                this.ValidateCase(component);
            }
                else {
                var url = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl='+serverUrl+     
                        '&id='+caseId+
                        //'&EmailToId='+ContactId+
                        '&EmailAdditionalTo='+caseContactEmail+
                        '&EmailRelatedToId='+caseId15Digit+
                        '&EmailTemplateGroup=QCC_Email_Templates'+
                        //'&CongaEmailTemplateId='+CongaEmailTemplateId+
                        '&EmailTemplateId='+sfEmailTemplateId+
                        '&CongaEmailTemplateGroup=Request_Information'+
                        '&EmailFromId='+OrgWideId+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        //'&MFTSValue0=true'+
                        '&MFTSValue0='+autoCloseOnEmailSent+
                        '&MFTS1=Recovery_Inprogress__c'+
                        '&MFTSValue1='+recoveryInprogress+
                        '&DefaultPDF=1'+
                        '&DS7=2';
                        if(emailTemplateCaseF != null && (emailTemplateCaseF == 'EFT Authorisation' || emailTemplateCaseF == 'EFT Authorisation - No Receipt')){
                            url += '&TemplateGroup=QCC_Email_Templates,Request_Information'+
                                '&TemplateId='+component.get("v.templateIdCS")+
                                '&EmailTemplateAttachments=1';
                        }  
                        console.log('ZZZZ else URL: '+url); 
                    
                    window.open(url,"", "width=800,height=600");
                }
        }
        //window.open(url,"", "width=800,height=600");
    },
    getEmailTemplates : function(component) {
        var caseRecordType       = component.get("v.caseF.RecordType.Name");
		var recId = component.get("v.recordId");
        var action = component.get("c.fetchEmailTemplateValues");       
        action.setParams({ "caseRecordType" : caseRecordType, "caseId": recId });      
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data.length === 0){
                this.displayToastMessage("warning", "Warning!", "Category and Sub Category required. If error continues update Classification field.", 10);
            }else if(data.length === 1){
                component.set("v.emailTemplateName", data[0].emailTemplate);
                component.set("v.sfEmailTemplateName", data[0].congaEmailTemplate);
                this.getSfEmailTemplateId(component);
            }else if(data.length > 1){
                component.set('v.lstOfEmailTemplate', data);
                this.initEmailTemplatePopup(component);
            }
        }); 
        $A.enqueueAction(action);
    },
    getSfEmailTemplateId : function(component, isManualInsuranceLetter) {
        var caseObj             = component.get("v.caseF");
        //var emailTemplateName   = component.get("v.emailTemplateName");
        var sfEmailTemplateName   = component.get("v.sfEmailTemplateName");
        var caseGroup            = component.get("v.caseF.Group__c");
        var caseType             = component.get("v.caseF.Type");
        var refundType			 = component.get("v.caseF.Refund_Type__c");
        console.log('sfEmailTemplateName' + sfEmailTemplateName);
        //var action = component.get("c.fetchCongaEmailTemplateId"); 
        var action = component.get("c.fetchSalesforceEmailTemplateId");     
        //action.setParams({ "caseObj" : caseObj, "emailTemplateName" : emailTemplateName, "congaEmailTemplateName" : congaEmailTemplateName });
        action.setParams({ "caseObj" : caseObj, "emailTemplateName" : sfEmailTemplateName });         
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data !== null){
                component.set("v.sfEmailTemplateId", data[0]);
                if(data[1] == ''){
                    component.set("v.congaTemplateId", null);
                }else{
                    component.set("v.congaTemplateId", data[1]); 
                }
                component.set("v.autoCloseOnEmailSent", data[2]);
                component.set("v.recoveryInprogress", data[3]);

                if(isManualInsuranceLetter){
                    this.requestManualInsuranceLetter(component);
                }else{
                    this.handleEmail(component);
                }
            }else{
                if(caseType == 'Insurance Letter' && caseGroup == 'Booking Cancelled by Customer' && refundType == null) {
                    this.displayToastMessage("error", "Error!", "Please select a refund type for this insurance letter.", 10);
                } else if(caseType == 'Insurance Letter' && caseGroup != 'Booking Cancelled by Customer' && refundType != null) {
                    this.displayToastMessage("error", "Error!", "Please choose valid combination for this insurance letter.", 10);
                } else {
                    this.displayToastMessage("warning", "Warning!", "Category and Sub Category required. If error continues update Classification field.", 10);
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    initEmailTemplatePopup : function(component) {
        var listEmailTemp = component.get('v.lstOfEmailTemplate');
        var caseId       = component.get("v.caseF.Id");
        var modalBody;
        var modalFooter;
        var message = "";
        var isShowMessage = false;

        //QDCUSCON-3340
        var action = component.get("c.isAutoCloseCase");       
        action.setParams({"caseId": caseId });      
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data == false){
                message = "This case will not auto-close since there is a recovery in progress";
                isShowMessage = true;           
            }
            $A.createComponents([
            ["c:QCC_EmailTemplate",{"lstOfEmailTemplate":listEmailTemp, "caseId": caseId, "message": message, "isShowMessage": isShowMessage}],
            ],
            function(components, status){
                if (status === "SUCCESS") {
                    modalBody = components[0]; 
                    component.find('overlayLib1').showCustomModal({
                        header: "Email Template Selection",
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "my-modal,my-custom-class,my-other-class"
                    }).then(function (overlay) {
                        modalBody.set('v.overlayPanel', overlay);
                    });
                }
            });
        }); 
        $A.enqueueAction(action);
        //end QDCUSCON-3340      
    },
    requestManualInsuranceLetter: function (component, event, helper) {
        
        var caseId               = component.get("v.recordId"); 
        var ContactId            = component.get("v.contactId");
        var sfEmailTemplateId    = '';//component.get("v.caseF.Conga_Email_Template_ID__c");
        var CongaTemplateId      = '';//component.get("v.caseF.Conga_Template_ID__c");
        var sessionId            = component.get("v.sessionId");
        var serverUrl            = component.get("v.serverUrl");
        var caseType             = component.get("v.caseF.Type");
        var caseGroup            = component.get("v.caseF.Group__c");
        var caseContactEmail     = component.get("v.caseF.Contact_Email__c");
        var OrgWideId            = component.get("v.OrgWideAddress");
        var refundType           = component.get("v.caseF.Refund_Type__c");
        var affectedPassCongaQueryId = component.get("v.affectedPassCongaQueryId");
                
        var caseId15Digit = caseId;
        if(caseId15Digit.length == 18) {
        	caseId15Digit = caseId15Digit.substring(0,15);     
        }

        if(component.get("v.sfEmailTemplateId") !== ""){
            sfEmailTemplateId = component.get("v.sfEmailTemplateId");
            CongaTemplateId      = component.get("v.congaTemplateId");
            //autoCloseOnEmailSent  = component.get("v.autoCloseOnEmailSent");
            //recoveryInprogress = component.get("v.recoveryInprogress");
        }
        
        console.log("caseId: "+caseId);
        console.log("ContactId: "+ContactId);
        console.log("CongaEmailTemplateId: "+sfEmailTemplateId);
        console.log("sessionId: "+sessionId);
        console.log("serverUrl: "+serverUrl);
        console.log("caseContactEmail: "+caseContactEmail);
        
        if(caseType == 'Insurance Letter' && caseGroup == 'Booking Cancelled by Customer' && refundType == null) {
			this.displayToastMessage("error", "Error!", "Please select a refund type for this insurance letter.", 10);
        }
        else {
            var action = component.get("c.getCaseValues");
            
            action.setParams({
                "recId"     :caseId,
                "insType"   :caseType,
                "fromIntegration": false,
                "cs": null
                
            }); 
            
            action.setCallback(this, function(a) {
                
                var msg = a.getReturnValue();
                console.log('Return Value from Apex'+msg)
                //var arr = msg.split(",");
                //console.log('Array of return getCaseValues'+arr[0]+' to '+ arr[1]);
                if(msg == 'No'){
                	this.displayToastMessage("error", "Validation Error!", "Some error has occured please check case chatter feed for more information.", 10);
                    $A.get('e.force:refreshView').fire();  
                }else if(msg != 'No' && msg != 'Yes') {
                    var arr = msg.split(",");
                    var url = '/apex/APXTConga4__Conga_Composer?'+
                    '&serverUrl1='+serverUrl+     
                    '&id='+caseId+
                    //'&EmailToId= '+//ContactId1+
                    '&EmailAdditionalTo='+caseContactEmail+
                    '&EmailRelatedToId='+caseId15Digit+
                    '&EmailTemplateId='+arr[1]+
                    '&TemplateGroup=QCC_Ineligible_Insurance_Letters'+
                    '&EmailFromId='+OrgWideId+
                    '&UF0=1'+
                    '&MFTS0=Auto_Close_on_Email_Sent__c'+
                    '&MFTSValue0=true'+
                    //'&DS7Preview=1'+
                    '&DS7=2';
                     window.open(url,"", "width=800,height=600");
                }else{
                    var url = '/apex/APXTConga4__Conga_Composer?'+
                        '&serverUrl='+serverUrl+     
                        '&id='+caseId+
                        //'&EmailToId='+ContactId+
                        '&EmailAdditionalTo='+caseContactEmail+
                        '&EmailRelatedToId='+caseId15Digit+
                        //'&CongaEmailTemplateId='+CongaEmailTemplateId+
                        '&EmailTemplateId='+sfEmailTemplateId+
                        '&TemplateId='+CongaTemplateId+  
                        '&EmailTemplateAttachments=1'+
                        //'&CongaEmailTemplateGroup=QCC_Insurance_Letters,Request_Information'+
                        '&TemplateGroup=QCC_Insurance_Letters'+
                        '&EmailFromId='+OrgWideId+
                        '&UF0=1'+
                        '&MFTS0=Auto_Close_on_Email_Sent__c'+
                        '&MFTSValue0=true'+
                        '&LiveEditEnable=1'+
                        '&DefaultPDF=1'+
                        '&QueryId=[AffectedPassengers]'+affectedPassCongaQueryId+'?pv0='+caseId+
                        '&DS7=2';
                    
                    console.log("URL: "+url);        
                    window.open(url,"", "width=800,height=600");   
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    displayToastMessage : function(iType, iTitle, iMessage, iDuration) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type"		: iType,
            "title"		: iTitle,
            "message"	: iMessage,
            "duration"	: iDuration
        });
        
        resultsToast.fire();
    }
})