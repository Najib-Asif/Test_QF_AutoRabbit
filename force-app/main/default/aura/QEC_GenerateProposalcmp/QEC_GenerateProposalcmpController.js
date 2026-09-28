({
    invokeSelection : function(component, event, helper) {
        var selection = component.find("selectDealSheetType").get("v.value");
        var categoryCheck = component.find("btlcheck").get("v.value");
        //Removed as per JIRA CRM-4173
        //var wordformat = component.find("wordyes").get("v.value");
        var action = component.get("c.getContractInfo");
        action.setParams({
            recordId : component.get("v.recordId"),
            dealsheetType : selection,
            categoryFlag : categoryCheck
            //Removed as per JIRA CRM-4173
            //,wordFormat : wordformat
        });
        // Callback function to get the response
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            //result ='/apex/APXTConga4__Conga_Composer?serverUrl=https://qantas--qecsit.cs112.my.salesforce.com/services/Soap/c/48.0/00D0T0000008als/apex/APXTConga4__Conga_Composer?serverUrl=API.Partner_Server_URL_370&id=a080T00000060QQQAY&TemplateId=a0X0T0000004FmqUAE&DS7=1&DS7Preview=1&DefaultPDF=1&FP0=1;&queryid=[DSDLDOM]a0W0T000000DeTmUAK,[DSRINT]a0W0T000000DeUAUA0,[DSRUNU]a0W0T000000DeUCUA0,[DSDLINT]a0W0T000000DeUBUA0,[DSDENU]a0W0T000000DeTlUAK,[ExBaDOM]a0W0T000000DdLpUAK,[PenDOM]a0W0T000000DdLvUAK,[AdvResDOM]a0W0T000000DeQmUAK,[DSACD]a0W0T000000DeUDUA0,[DSACI]a0W0T000000DeTrUAK,[DSJQ]a0W0T000000DeTnUAK,[DSRDOM]a0W0T000000DeToUAK,[DSTMCI]a0W0T000000DeTpUAK,[InFaDOM]a0W0T000000DeQvUAK,[RoDeDOM]a0W0T000000DeQxUAK,[FiFaDOM]a0W0T000000DdLwUAK,[BlFaDOM]a0W0T000000DeQqUAK,[BlFaFlex]a0W0T000000DdLkUAK,[BlFaSFlex]a0W0T000000DeQhUAK,[SPDOM]a0W0T000000DeU7UAK,[SPINT]a0W0T000000DeU6UAK&QVar0ID=a0W0T000000DeTlUAK?pv0=a080T00000060QQQAY&OFN=QantasDSDomestic-a0W0T000000DeTlUAK-0010T000003HrcSQAS&SC1=SalesforceFile';
            //result ='/apex/APXTConga4__Conga_Composer?serverUrl=https://qantas--qecsit.cs112.my.salesforce.com/services/Soap/c/48.0/00D0T0000008als/apex/APXTConga4__Conga_Composer?serverUrl=API.Partner_Server_URL_370&id=a080T00000060QQQAY&TemplateId=a0X0T0000004FmqUAE&DS7=1&DS7Preview=1&DefaultPDF=1&FP0=1;&queryid=[DSDLDOM]a0W0T000000DeTmUAK,[DSRINT]a0W0T000000DeUAUA0,[DSRUNU]a0W0T000000DeUCUA0,[DSDLINT]a0W0T000000DeUBUA0,[DSDENU]a0W0T000000DeTlUAK,[ExBaDOM]a0W0T000000DdLpUAK,[PenDOM]a0W0T000000DdLvUAK,[AdvResDOM]a0W0T000000DeQmUAK,[DSACD]a0W0T000000DeUDUA0,[DSACI]a0W0T000000DeTrUAK,[DSJQ]a0W0T000000DeTnUAK,[DSRDOM]a0W0T000000DeToUAK,[DSTMCI]a0W0T000000DeTpUAK,[InFaDOM]a0W0T000000DeQvUAK,[RoDeDOM]a0W0T000000DeQxUAK,[FiFaDOM]a0W0T000000DdLwUAK,[BlFaDOM]a0W0T000000DeQqUAK,[BlFaFlex]a0W0T000000DdLkUAK,[BlFaSFlex]a0W0T000000DeQhUAK,[SPDOM]a0W0T000000DeU7UAK,[SPINT]a0W0T000000DeU6UAK&QVar0ID=a0W0T000000DeTlUAK?pv0=a080T00000060QQQAY&OFN=Qantas Domestic Dealsheet&SC1=SalesforceFile';
            if(state === 'SUCCESS' & result != null) {
                console.log('--------------- '+JSON.stringify(result));
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    'url': result
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})