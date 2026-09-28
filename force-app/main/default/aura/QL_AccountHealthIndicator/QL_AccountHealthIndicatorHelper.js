({
    getRecordTypeId : function(component, event, helper){
        component.set("v.Spinner",true);
        var action = component.get("c.fetchRecordType");
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                console.log('Acc Rec Type Id'+response.getReturnValue());
                if(response.getReturnValue() == component.get("v.simpleAccRecord").RecordTypeId ){
                    component.set("v.accFreightRecType",response.getReturnValue());                    
                    this.computePercentageFreight(component, event, helper);
                    component.set("v.Spinner",false);
                }
                else if(component.get("v.simpleAccRecord.Contracted__c")) {                              
                	console.log('contracted accounts'+component.get("v.simpleAccRecord.Contracted__c"));
                    this.callApexMethod(component, event, helper);
                    component.set("v.Spinner",false);
                } else {
                    console.log('Account is not Contracted');
                    this.callNonContractQBRMethod(component, event, helper);
                    component.set("v.Spinner",false);
                }
                component.set("v.Spinner",false);
            }
        });  
        $A.enqueueAction(action);  
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.accountDetailsList");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.accountDetailsList", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    computePercentageFreight : function(component, event, helper)  {
        var action = component.get("c.computePercentage_Freight");
        var txt_recordId = null;
        if(component.get("v.recordId"))
            txt_recordId = component.get("v.recordId");
        var txt_sObjectName = component.get("v.sObjectName");
        action.setParams({
            recordIds : txt_recordId,
            sObjectName : txt_sObjectName,
            recordDetail : (component.get("v.recordId"))?true:false
        });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var percVal = parseInt(response.getReturnValue().split('*')[0]); 
                var progressVal = parseInt(  (percVal/100) * 360  ) ; 
                console.log('percVal'+percVal);
                component.set("v.activeSAP" , response.getReturnValue().split('*')[1] );
                component.set("v.activeContact" , response.getReturnValue().split('*')[2] );
                component.set("v.noOverdueOpp" , response.getReturnValue().split('*')[3] );
                component.set("v.actReview" , response.getReturnValue().split('*')[4] );
                
                component.set("v.cirDeg" , progressVal );
                component.set("v.perText" , parseInt(percVal)  +'%' );
                
            }
        });
        $A.enqueueAction(action);
    },    
    //client-side helper function to call the 'computePercentage' method of QL_AccountHealthIndicator controller
    callApexMethod : function(component, event, helper)  {
        console.log('contracted');
        var action = component.get("c.computePercentage");
        var txt_recordId = null;
        if(component.get("v.recordId"))
            txt_recordId = component.get("v.recordId");
        else
            txt_recordId=component.get("v.pfAccId");
        
        component.set("v.pfAccId",txt_recordId);
        var txt_sObjectName = component.get("v.sObjectName");
        
        action.setParams({
            recordIds : txt_recordId,
            sObjectName : txt_sObjectName,
            recordDetail : (component.get("v.recordId"))?true:false
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                
                var percVal = parseInt(response.getReturnValue().split('*')[0]); 
                var progressVal = parseInt(  (percVal/100) * 360  ) ; 
                console.log('response****'+response.getReturnValue());
                //set component attributes from server response
                if(component.get("v.recordId")){
                    component.set("v.activeSAP" , response.getReturnValue().split('*')[1] );
                    component.set("v.updatedSAP" , response.getReturnValue().split('*')[2] );
                    component.set("v.accReview" , response.getReturnValue().split('*')[3] );
                    component.set("v.actReview" , response.getReturnValue().split('*')[4] );
                    component.set("v.noOverdueOpp" , response.getReturnValue().split('*')[5] );
                    component.set("v.contractSigned" , response.getReturnValue().split('*')[6] );
                }else{
                    var activeSAPAccs = JSON.parse(response.getReturnValue().split('*')[1]);
                    component.set("v.activeSAP" , activeSAPAccs.length);
                    component.set("v.activeSAPAccs" , activeSAPAccs);
                    var updatedSAPAccs = JSON.parse(response.getReturnValue().split('*')[2]);
                    component.set("v.updatedSAP" , updatedSAPAccs.length);
                    component.set("v.updatedSAPAccs" , updatedSAPAccs);
                    var accReviewAccs = JSON.parse(response.getReturnValue().split('*')[3]);
                    component.set("v.accReview" , accReviewAccs.length);
                    component.set("v.accReviewAccs" , accReviewAccs);
                    var actReviewAccs = JSON.parse(response.getReturnValue().split('*')[4]);
                    component.set("v.actReview" , actReviewAccs.length);
                    component.set("v.actReviewAccs" , actReviewAccs);
                    var noOverdueOppAccs = JSON.parse(response.getReturnValue().split('*')[5]);
                    component.set("v.noOverdueOpp" , noOverdueOppAccs.length);
                    component.set("v.noOverdueOppAccs" , noOverdueOppAccs);
                    var contractSignedAccs = JSON.parse(response.getReturnValue().split('*')[6]);
                    component.set("v.contractSigned" , contractSignedAccs.length);
                    component.set("v.contractSignedAccs" , contractSignedAccs);
                    component.set("v.accountDetailsList",JSON.parse(response.getReturnValue().split('*')[7]));
                    component.set("v.totalRecords", component.get("v.accountDetailsList").length);
                    var pageSize = component.get("v.pageSize");
                    component.set("v.startPage", 0);                
                    component.set("v.endPage", pageSize - 1);
                    var PagList = [];
                    for ( var i=0; i< pageSize; i++ ) {
                        if ( component.get("v.accountDetailsList").length> i )
                            PagList.push(component.get("v.accountDetailsList")[i]);    
                    }
                    component.set('v.PaginationList', PagList);
                    console.log('&&&Wrapper'+response.getReturnValue().split('*')[7]);
                }
                
                component.set("v.cirDeg" , progressVal );
                component.set("v.perText" , parseInt(percVal)  +'%' );              
            }  
        });
        $A.enqueueAction(action);  
    },
        //client-side helper function to call the 'computePercentageNonContractedQBR' method of QL_AccountHealthIndicator controller
    callNonContractQBRMethod : function(component, event, helper)  {
        console.log('NoncontractedQBR');
        var action = component.get("c.computePercentageNonContractedQBR");
        var txt_recordId = null;
        if(component.get("v.recordId"))
            txt_recordId = component.get("v.recordId");
        else
            txt_recordId=component.get("v.pfAccId");
        
        component.set("v.pfAccId",txt_recordId);
        var txt_sObjectName = component.get("v.sObjectName");
        
        action.setParams({
            recordIds : txt_recordId,
            sObjectName : txt_sObjectName,
            recordDetail : (component.get("v.recordId"))?true:false
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                
                var percVal = parseInt(response.getReturnValue().split('*')[0]); 
                var progressVal = parseInt(  (percVal/100) * 360  ) ; 
                //set component attributes from server response
                if(component.get("v.recordId")){
                    component.set("v.activeSAP" , response.getReturnValue().split('*')[1] );
                    component.set("v.updatedSAP" , response.getReturnValue().split('*')[2] );
                    component.set("v.accReview" , response.getReturnValue().split('*')[3] );
                    component.set("v.actReview" , response.getReturnValue().split('*')[4] );
                    component.set("v.industry" , response.getReturnValue().split('*')[5] );
                    component.set("v.activeB2BContact" , response.getReturnValue().split('*')[6] );                    
                }else{
                    var activeSAPAccs = JSON.parse(response.getReturnValue().split('*')[1]);
                    component.set("v.activeSAP" , activeSAPAccs.length);
                    component.set("v.activeSAPAccs" , activeSAPAccs);
                    var updatedSAPAccs = JSON.parse(response.getReturnValue().split('*')[2]);
                    component.set("v.updatedSAP" , updatedSAPAccs.length);
                    component.set("v.updatedSAPAccs" , updatedSAPAccs);
                    var accReviewAccs = JSON.parse(response.getReturnValue().split('*')[3]);
                    component.set("v.accReview" , accReviewAccs.length);
                    component.set("v.accReviewAccs" , accReviewAccs);
                    var actReviewAccs = JSON.parse(response.getReturnValue().split('*')[4]);
                    component.set("v.actReview" , actReviewAccs.length);
                    component.set("v.actReviewAccs" , actReviewAccs);
                    var industryAccs = JSON.parse(response.getReturnValue().split('*')[5]);
                    component.set("v.industry" , industryAccs.length);
                    component.set("v.industryAccs" , industryAccs);
                    var activeB2BContactAccs = JSON.parse(response.getReturnValue().split('*')[6]);
                    component.set("v.activeB2BContact" , activeB2BContactAccs.length);
                    component.set("v.activeB2BContactAccs" , activeB2BContactAccs);
                    component.set("v.accountDetailsList",JSON.parse(response.getReturnValue().split('*')[7]));
                    component.set("v.totalRecords", component.get("v.accountDetailsList").length);
                    var pageSize = component.get("v.pageSize");
                    component.set("v.startPage", 0);                
                    component.set("v.endPage", pageSize - 1);
                    var PagList = [];
                    for ( var i=0; i< pageSize; i++ ) {
                        if ( component.get("v.accountDetailsList").length> i )
                            PagList.push(component.get("v.accountDetailsList")[i]);    
                    }
                    component.set('v.PaginationList', PagList);
                    console.log('&&&Wrapper'+response.getReturnValue().split('*')[7]);
                }
                
                component.set("v.cirDeg" , progressVal );
                component.set("v.perText" , parseInt(percVal)  +'%' );              
            }  
        });
        $A.enqueueAction(action);  
    },
    exportAllData : function(component, event, helper,sourceVal){
        
        var csvContent;
        var ActTitle='';
        if(sourceVal == 'single'){
            if(component.get('v.listToDisplay').length >0)
                csvContent = this.appendList(component.get('v.listToDisplay'),component.get('v.accCategory'),sourceVal);
            ActTitle = 'AccountList_'+component.get('v.accCategory')+'_'+((component.get("v.ownerObj.value") != null)?component.get("v.ownerObj.value"):'');
        }else{
            csvContent = this.appendList(component.get('v.accountDetailsList'),'',sourceVal);
            ActTitle = 'AccountList_'+((component.get("v.ownerObj.value") != null)?component.get("v.ownerObj.value"):'');
        }
        
        //Generate a file name
        var fileName = "Portfolio_";
        //this will remove the blank-spaces from the title and replace it with an underscore
        fileName += ActTitle.replace(/ /g,"_");   
        fileName += ".csv";
        //Initialize file format you want csv or xls
        var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
        
        if (navigator.msSaveBlob) { // IE 10+
            console.log('----------------if-----------');
            var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
            console.log('----------------if-----------'+blob);
            navigator.msSaveBlob(blob, fileName);
        }
        else{
            // Download file
            // you can use either>> window.open(uri);
            // but this will not work in some browsers
            // or you will not get the correct file extension    
            var link = document.createElement("a");
            
            //link.download to give filename with extension
            //link.download = fileName;
            link.setAttribute('download',fileName);
            //To set the content of the file
            link.href = uri;
            
            //set the visibility hidden so it will not effect on your web-layout
            link.style = "visibility:hidden";
            
            //this part will append the anchor tag and remove it after automatic click
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
        }
    },
    appendList : function(contnt,contntType,sourceVal){
        var headerArray = [];
        var csvContentArray = [];
        var CSV = '';//'\r\nSelected Position\r\n';
        if(contntType == 'activeSAP' || contntType == 'WithActiveSAP')
            CSV = '\r\nAccounts with SAP active\r\n\r\n';
        if(contntType == 'updatedSAP' || contntType == 'WithUpdatedSAP')
            CSV = '\r\nAccounts with SAP updated last 3 months\r\n\r\n';
        if(contntType == 'accReview' || contntType == 'ReviewedAccounts')
            CSV = '\r\nAccounts with reviews completed last 90 days\r\n\r\n';
        if(contntType == 'actReview' || contntType == 'WithActivities')
            CSV = '\r\nAccounts with activities created last 90 days\r\n\r\n';
        if(contntType == 'overdueOpp' || contntType == 'WithOverdueOpps')
            CSV = '\r\nAccounts with overdue opportunities\r\n\r\n';
        if(contntType == 'contractUnSigned' || contntType == 'WithUnsignedContracts')
            CSV = '\r\nAccounts with unsigned contracts\r\n\r\n';
        
        var data=[];
        //Fill out the Header of CSV
        if(sourceVal == 'single'){
            headerArray.push('SNo.');
            headerArray.push('ACCOUNT NAME');
            headerArray.push('ACCOUNT LINK');
            data.push(headerArray);
        }else{
            headerArray.push('SNo.');
            headerArray.push('ACCOUNT NAME');
            headerArray.push('DOM REVENUE');
            headerArray.push('DOM SHARE(%)');
            headerArray.push('INT REVENUE');
            headerArray.push('INT SHARE(%)');
            headerArray.push('ACTIVE SAP');
            headerArray.push('UPDATED SAP');
            headerArray.push('ACCOUNT REVIEW COMPLETED LAST 90 DAYS');
            headerArray.push('ACTIVITY CREATED LAST 90 DAYS');
            headerArray.push('NO OVERDUE OPPORTUNITIES');
            headerArray.push('NO UNSIGNED CONTRACTS');
            headerArray.push('ACCOUNT LINK');
            data.push(headerArray);
        }
        
        
        var sno = 0;
        for(var i=0;i<contnt.length;i++){
            
            var tempArray = [];
            //use parseInt to perform math operation
            sno = parseInt(sno) + parseInt(1);
            if(sourceVal == 'single'){
                tempArray.push('"'+sno+'"');
                tempArray.push('"'+contnt[i].Name+'"');
                tempArray.push('=HYPERLINK("https://'+window.location.hostname+'/'+contnt[i].Id+'")');
            }else{
                tempArray.push('"'+sno+'"');
                tempArray.push('"'+contnt[i].AcntName+'"');
                tempArray.push('"'+((contnt[i].accDomRev != null)?contnt[i].accDomRev:'')+'"');
                tempArray.push('"'+((contnt[i].accDomShare != null)?(contnt[i].accDomShare):'')+'"');
                tempArray.push('"'+((contnt[i].accIntRev != null)?contnt[i].accIntRev:'')+'"');
                tempArray.push('"'+((contnt[i].accIntShare != null)?(contnt[i].accIntShare):'')+'"');
                tempArray.push('"'+((contnt[i].activeSAP == 1)?'Yes':'No')+'"');
                tempArray.push('"'+((contnt[i].updatedSAP == 1)?'Yes':'No')+'"');
                tempArray.push('"'+((contnt[i].accReviewed == 1)?'Yes':'No')+'"');
                tempArray.push('"'+((contnt[i].actCreated == 1)?'Yes':'No')+'"');
                tempArray.push('"'+((contnt[i].noOverdueOpp == 1)?'Yes':'No')+'"');
                tempArray.push('"'+((contnt[i].noUnsignedContracts == 1)?'Yes':'No')+'"');
                tempArray.push('=HYPERLINK("https://'+window.location.hostname+'/'+contnt[i].AcntId+'")');
            }
            data.push(tempArray);
            
        }
        
        for(var j=0;j<data.length;j++){
            var dataString = data[j].join(",");
            csvContentArray.push(dataString);
        }
        var csvContent = CSV + csvContentArray.join("\r\n");
        return csvContent;
    }    
})