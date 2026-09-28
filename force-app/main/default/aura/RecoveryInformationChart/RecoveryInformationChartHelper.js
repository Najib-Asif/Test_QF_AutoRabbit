({
	getMemberList : function(component,helper,event) {
        var action = component.get("c.getMembers");             
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',response);
            if(state=="SUCCESS"){ 
                 console.log('response member',JSON.stringify(response.getReturnValue()));                                                    
                component.set("v.MemberList",response.getReturnValue());
             }
        });

        $A.enqueueAction(action);
       
    },        
	getReccoveryTypeList : function(component,helper,event) {
        var action = component.get("c.getMembersRecoveryTypeList");             
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',response);
            if(state=="SUCCESS"){ 
                 console.log('response member',JSON.stringify(response.getReturnValue()));                                                    
                component.set("v.typeList",response.getReturnValue());
             }
        });

        $A.enqueueAction(action);
       
    },    
    getChart : function(component, helper, event){
        
        var action = component.get("c.getMembersRecoveryData");
        
        var Approved=0;
        var Rejected=0;
        var SubmitforFinalisation=0;
        var FinalisationDeclined=0;
        var Finalised=0;
        var AwaitingApproval=0;
        var AwaitingCustomerResponse=0;
        var Submitted=0;
        var SubmitforApproval=0;
        console.log('response####%%%',component.find("teamMemberSelectId").get("v.value"));
        console.log('response####%%%',component.find("RecoveryTypeId").get("v.value"));
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
            rcvryType: component.find("RecoveryTypeId").get("v.value")
            
   		 });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('response####',response);
            console.log('response####',JSON.stringify(response.getReturnValue())); 
            if(state=="SUCCESS"){ 
                 console.log('response',JSON.stringify(response.getReturnValue())); 
        
             var recvry =  response.getReturnValue();
                
                //for(var recvry in response.getReturnValue()){
                for(var i = 0, size = recvry.length; i < size ; i++){
                    console.log('sdfds');
                    if(recvry[i].Status__c == 'Submit for Approval'){
                        SubmitforApproval++;
                    }else if(recvry[i].Status__c =='Approved'){
                        Approved++;
                    }else if(recvry[i].Status__c =='Rejected'){                      
                        Rejected++;
                    }else if(recvry[i].Status__c =='Finalised'){
                        Finalised++;                                                  
                    }else if(recvry[i].Status__c =='Awaiting Approval'){
                        AwaitingApproval++;
                    }else if(recvry[i].Status__c =='Awaiting Customer Response'){                        
                        AwaitingCustomerResponse++;                       
                    }else if(recvry[i].Status__c =='Submitted'){
                        Submitted++;
                    }else if(recvry[i].Status__c =='Finalisation Declined'){
                        FinalisationDeclined++;
                    }else if(recvry[i].Status__c =='Submit for Finalisation'){
                        SubmitforFinalisation++;
                    }                                                                                                                                                       
                         
                    }
               
                component.set("v.Approved",Approved);
                component.set("v.Rejected",Rejected);
                component.set("v.SubmitforFinalisation",SubmitforFinalisation);
                component.set("v.FinalisationDeclined",FinalisationDeclined);
                component.set("v.Finalised",Finalised);
                component.set("v.AwaitingApproval",AwaitingApproval);
                component.set("v.AwaitingCustomerResponse",AwaitingCustomerResponse);
                component.set("v.Submitted",Submitted);
                component.set("v.SubmitforApproval",SubmitforApproval);
                                                    
             }
       
        
        
        var el = component.find("chart").getElement();
        var ctx = el.getContext("2d");
        
       
                console.log('Approved',Approved);
                console.log('Rejected',Rejected);
                console.log('SubmitforFinalisation',SubmitforFinalisation);
                console.log('FinalisationDeclined',FinalisationDeclined);
                console.log('Finalised',Finalised);
                console.log('AwaitingApproval',AwaitingApproval);
                console.log('AwaitingCustomerResponse',AwaitingCustomerResponse);
                console.log('Submitted',Submitted);
                console.log('SubmitforApproval',SubmitforApproval);
        
        var myNewChart = new Chart(ctx, {
            type: 'horizontalBar',
            data: {
                labels: ["Submit for Approval", "Approved", "Rejected", "Submit for Finalisation", "Finalisation Declined", "Finalised","Awaiting Approval","Awaiting Customer Response","Submitted"],
                datasets: [{
                    label: 'Recovery Chart',
                    //data: [ 11, 12, 44, 45, 24, 56 ,65,87,65],
                    data: [ SubmitforApproval, Approved, Rejected, SubmitforFinalisation, FinalisationDeclined, Finalised,AwaitingApproval,AwaitingCustomerResponse,Submitted],
                    backgroundColor: [
                           '#3F51B5',
                           '#9370DB',
                           '#32CD32',
                           '#8FBC8B',
                           '#B8860B',
                           '#F4A460',
                           '#A52A2A',
                           '#DC143C',
                           '#00BCD4'
                        ],
                    yAxisID: "bar-y-axis1",
                   // backgroundColor:'#191970',
                    borderWidth: 3
                },
               ]
            },
            options: {
                responsive: true,
                legend: {
                    position: 'bottom',
                           labels: {
                                fontColor: "Green",
                                fontSize: 18
            				}
                },
                scales: {
                    yAxes: [{
                        stacked: true,
                        id: "bar-y-axis1",
                        
                    }],
                    xAxes: [{
                        //stacked:true,
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
        });
           // myNewChart.canvas.parentNode.style.height = '400px';
            myNewChart.canvas.parentNode.style.width = '400px';
             });

        $A.enqueueAction(action);
        
    },        
    getPieChart : function(component, helper, event){
        
        var action = component.get("c.getMembersRecoveryTypeData");
                
        var QantasPoints=0;
        var DomesticClubLoungePassesPoints=0;
        var InternationalBusinessLoungePasses=0;
        var ValetParkingCarwash=0;
        var Travelvouchers=0;
        var CreditCardRefund=0;
        var EFTRefund=0;
        var BagRepair=0;
        var BagReplacement=0;
        var NoGoodwill=0;
        var Dinnervouchers=0;
        var Flowers=0;
        var Wine=0;
        var Spaceavailableupgrade=0;
        var Firmspaceupgrade=0;

        console.log('response####%%%',component.find("teamMemberSelectId").get("v.value"));
       // console.log('response RecoveryTypeId####%%%',component.find("RecoveryTypeId").get("v.value"));
        
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value")            
   		 });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('response####',response);
            console.log('response####',JSON.stringify(response.getReturnValue())); 
            if(state=="SUCCESS"){ 
                 console.log('response',JSON.stringify(response.getReturnValue())); 
        
             var recvry =  response.getReturnValue();
                
                //for(var recvry in response.getReturnValue()){
                for(var i = 0, size = recvry.length; i < size ; i++){
                    console.log('sdfds');
                    if(recvry[i].Type__c == 'Qantas Points'){
                        QantasPoints++;
                    }else if(recvry[i].Type__c =='Domestic Qantas Club Lounge Passes'){
                        DomesticClubLoungePassesPoints++;
                    }else if(recvry[i].Type__c =='International Business Lounge Passes'){                      
                        InternationalBusinessLoungePasses++;
                    }else if(recvry[i].Type__c =='Valet Parking or Carwash'){
                        ValetParkingCarwash++;                                                  
                    }else if(recvry[i].Type__c =='Travel vouchers'){
                        Travelvouchers++;
                    }else if(recvry[i].Type__c =='Credit Card Refund'){                        
                        CreditCardRefund++;                       
                    }else if(recvry[i].Type__c =='EFT Refund'){
                        EFTRefund++;
                    }else if(recvry[i].Type__c =='Bag Repair'){
                        BagRepair++;
                    }else if(recvry[i].Type__c =='Bag Replacement'){
                        BagReplacement++;                               
					}else if(recvry[i].Type__c =='No Goodwill'){
                        NoGoodwill++;                    
					}else if(recvry[i].Type__c =='Dinner vouchers'){
                        Dinnervouchers++;                     
					}else if(recvry[i].Type__c =='Flowers'){
                        Flowers++;                     
					}else if(recvry[i].Type__c =='Wine'){
                        Wine++;
                    }else if(recvry[i].Type__c =='Space available upgrade'){
                        Spaceavailableupgrade++;                    
					}else if(recvry[i].Type__c =='Firm space upgrade'){
                        Firmspaceupgrade++;
                    }                                                                                                                                         
                         
                    }
               
               component.set("v.QantasPoints",QantasPoints);
                component.set("v.DomesticClubLoungePassesPoints",DomesticClubLoungePassesPoints);
                component.set("v.InternationalBusinessLoungePasses",InternationalBusinessLoungePasses);
                component.set("v.ValetParkingCarwash",ValetParkingCarwash);
                component.set("v.Travelvouchers",Travelvouchers);
                component.set("v.CreditCardRefund",CreditCardRefund);
                component.set("v.EFTRefund",EFTRefund);
                component.set("v.BagRepair",BagRepair);
                component.set("v.BagReplacement",BagReplacement);
				component.set("v.NoGoodwill",NoGoodwill);
				component.set("v.Dinnervouchers",Dinnervouchers);
				component.set("v.Flowers",Flowers);
				component.set("v.Wine",Wine);
				component.set("v.Spaceavailableupgrade",Spaceavailableupgrade);
				component.set("v.Firmspaceupgrade",Firmspaceupgrade);
                                                    
             }
       
        
        
        var el = component.find("pieChart").getElement();
        var ctx = el.getContext("2d");
        
                       
         var myNewChart = new Chart(ctx, {
            type: 'horizontalBar',
            data: {
                labels: ["Qantas Points", "Domestic Qantas Club Lounge Passes", "International Business Lounge Passes", "Valet Parking or Carwash", "Travel vouchers", "Credit Card Refund","EFT Refund","Bag Repair","Bag Replacement","No Goodwill","Dinner vouchers","Flowers","Wine","Space available upgrade","Firm space upgrade"],
                datasets: [{
                    label: 'Recovery Chart',
                    //data: [ 11, 12, 44, 45, 24, 56 ,65,87,65],
                    data: [ QantasPoints, DomesticClubLoungePassesPoints, InternationalBusinessLoungePasses, ValetParkingCarwash, Travelvouchers, CreditCardRefund,EFTRefund,BagRepair,BagReplacement,NoGoodwill,Dinnervouchers,Flowers,Wine,Spaceavailableupgrade,Firmspaceupgrade],
                    backgroundColor: [
                           '#3F51B5',
                           '#9370DB',
                           '#32CD32',
                           '#8FBC8B',
                           '#B8860B',
                           '#F4A460',
                           '#A52A2A',
                           '#DC143C',
                           '#00BCD4',
                           '#7df442',
                           '#6ec193',
                           '#1e663e',
                           '#3f7c96',
                           '#a039bf',
                           '#b22066'
                        ],
                    yAxisID: "bar-y-axis2",
                   // backgroundColor:'#191970',
                    borderWidth: 3
                },
       
               ]
            },
            options: {
                responsive: true,
                legend: {
                    position: 'bottom',
                           labels: {
                                fontColor: "Green",
                                fontSize: 18
            				}
                },
                scales: {
                    yAxes: [{
                        stacked: true,
                        id: "bar-y-axis2",
                        
                    }],
                    xAxes: [{
                        //stacked:true,
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
        });
           // myNewChart.canvas.parentNode.style.height = '400px';
            myNewChart.canvas.parentNode.style.width = '400px';
             });

        $A.enqueueAction(action);
        
    },
    getMemberData : function(component,event,helper){
        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getMembersRecoveryData");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value")
   		 });
        console.log('dfsd');
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',response);
            if(state=="SUCCESS"){ 
                console.log('response',JSON.stringify(response.getReturnValue()));  
                var result = response.getReturnValue();
                console.log('result.length',result.length);                              
                component.set("v.recoveries",response.getReturnValue());                
                component.set("v.TotalRecovery",result.length);
                
            }
        });

        $A.enqueueAction(action);
    },    
    getMemberDataFilterByStatus : function(component,event,helper){
        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");  
        var filter = component.find("statusFilter").get("v.value");  
           console.log('filter : ',filter);
        var action = component.get("c.getMembersRecoveryDataFiltered");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
            status : filter
   		 });
        console.log('entring');
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response filter',response);
            if(state=="SUCCESS"){ 
                console.log('response filter',JSON.stringify(response.getReturnValue()));  
                   console.log('response filter',response.getReturnValue());  
                var result = response.getReturnValue();
                console.log('result.length filter',result.length);                
                component.set("v.recoveries",response.getReturnValue());                  
                
            }
        });

        $A.enqueueAction(action);
    },
    getAveragevalue : function(component,event,helper){        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getAverageRecoveryValue");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
            rcvryType: component.find("RecoveryTypeId").get("v.value")
   		 });     
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('responseiiiiiii',response.getState());
            
            if(state=="SUCCESS"){
                console.log('ssssss');
                console.log('ssssss',response.getReturnValue());
                console.log('v.AverageValue',response.getReturnValue());  
                var result = response.getReturnValue();                
                component.set("v.AverageValue",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },    
    getAverageGoodwillMonetaryValue : function(component,event,helper){        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getAverageRecoveryGoodwillMonetaryValue");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value")
   		 });     
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('responseiiiiiii',response.getState());
            
            if(state=="SUCCESS"){
                console.log('ssssss');
                console.log('ssssss',response.getReturnValue());
                console.log('v.AverageGoodwillMonetaryValue',response.getReturnValue());  
                var result = response.getReturnValue();                
                component.set("v.AverageGoodwillMonetaryValue",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },    
    getAverageMonetaryValue : function(component,event,helper){        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getAverageRecoveryMonetaryValue");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
            rcvryType: component.find("RecoveryTypeId").get("v.value")
   		 });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',response);
            if(state=="SUCCESS"){ 
                console.log('v.MonetaryValue',JSON.stringify(response.getReturnValue()));  
                var result = response.getReturnValue();                
                component.set("v.MonetaryValue",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },
    getAverageQuantity : function(component,event,helper){        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getAverageRecoveryAmount");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
            rcvryType: component.find("RecoveryTypeId").get("v.value")
   		 });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',response);
            if(state=="SUCCESS"){ 
                console.log('v.AverageQuantity',JSON.stringify(response.getReturnValue()));  
                var result = response.getReturnValue();                
                component.set("v.AverageQuantity",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },    
    getAveragevalueByDate : function(component,event,helper,FromDate,ToDate){        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getAverageRecoveryValueDate");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
             fDate : FromDate,
            tDate : ToDate
   		 });     
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('responseiiiiiii',response.getState());
            
            if(state=="SUCCESS"){
                console.log('ssssss');
                console.log('ssssss',response.getReturnValue());
                console.log('v.AverageValue',response.getReturnValue());  
                var result = response.getReturnValue();                
                component.set("v.AverageValue",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },    
    getAverageMonetaryValueByDate : function(component,event,helper,FromDate,ToDate){        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getAverageRecoveryMonetaryValueDate");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
             fDate : FromDate,
            tDate : ToDate
   		 });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',response);
            if(state=="SUCCESS"){ 
                console.log('v.MonetaryValue',JSON.stringify(response.getReturnValue()));  
                var result = response.getReturnValue();                
                component.set("v.MonetaryValue",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },
    getAverageQuantityByDate : function(component,event,helper,FromDate,ToDate){        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getAverageRecoveryAmountDate");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
            fDate : FromDate,
            tDate : ToDate
   		 });   
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',response);
            if(state=="SUCCESS"){ 
                console.log('v.AverageQuantity',JSON.stringify(response.getReturnValue()));  
                var result = response.getReturnValue();                
                component.set("v.AverageQuantity",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },    
    getAverageGoodwillMonetaryValueDate : function(component,event,helper,FromDate,ToDate){        
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value");                
        var action = component.get("c.getAverageRecoveryGoodwillMonetaryValueDate");
        action.setParams({
        	usrId : component.find("teamMemberSelectId").get("v.value"),
             fDate : FromDate,
            tDate : ToDate
   		 });     
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('responseiiiiiii',response.getState());
            
            if(state=="SUCCESS"){
                console.log('ssssss');
                console.log('ssssss',response.getReturnValue());
                console.log('v.AverageGoodwillMonetaryValue',response.getReturnValue());  
                var result = response.getReturnValue();                
                component.set("v.AverageGoodwillMonetaryValue",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },        
    SearchDatarange : function(component,event,helper,FromDate,ToDate){  
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value"); 
        var action = component.get("c.searchMembersRecoveryData");
        
        console.log('FromDate helper',FromDate);
        console.log('ToDate helper',FromDate);
        
        action.setParams({
            usrId : selectedMemberId,
        	fDate : FromDate,
            tDate : ToDate
   		 });    
        
        var Approved=0;
        var Rejected=0;
        var SubmitforFinalisation=0;
        var FinalisationDeclined=0;
        var Finalised=0;
        var AwaitingApproval=0;
        var AwaitingCustomerResponse=0;
        var Submitted=0;
        var SubmitforApproval=0;
        console.log('response####%%%',component.find("teamMemberSelectId").get("v.value"));        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('response####',response);
            console.log('response####',JSON.stringify(response.getReturnValue())); 
            if(state=="SUCCESS"){ 
                 console.log('response',JSON.stringify(response.getReturnValue())); 
        
             var recvry =  response.getReturnValue();
                
                //for(var recvry in response.getReturnValue()){
                for(var i = 0, size = recvry.length; i < size ; i++){
                    console.log('sdfds');
                    if(recvry[i].Status__c == 'Submit for Approval'){
                        SubmitforApproval++;
                    }else if(recvry[i].Status__c =='Approved'){
                        Approved++;
                    }else if(recvry[i].Status__c =='Rejected'){                      
                        Rejected++;
                    }else if(recvry[i].Status__c =='Finalised'){
                        Finalised++;                                                  
                    }else if(recvry[i].Status__c =='Awaiting Approval'){
                        AwaitingApproval++;
                    }else if(recvry[i].Status__c =='Awaiting Customer Response'){                        
                        AwaitingCustomerResponse++;                       
                    }else if(recvry[i].Status__c =='Submitted'){
                        Submitted++;
                    }else if(recvry[i].Status__c =='Finalisation Declined'){
                        FinalisationDeclined++;
                    }else if(recvry[i].Status__c =='Submit for Finalisation'){
                        SubmitforFinalisation++;
                    }                                                                                                                                                       
                         
                    }
               
                component.set("v.Approved",Approved);
                component.set("v.Rejected",Rejected);
                component.set("v.SubmitforFinalisation",SubmitforFinalisation);
                component.set("v.FinalisationDeclined",FinalisationDeclined);
                component.set("v.Finalised",Finalised);
                component.set("v.AwaitingApproval",AwaitingApproval);
                component.set("v.AwaitingCustomerResponse",AwaitingCustomerResponse);
                component.set("v.Submitted",Submitted);
                component.set("v.SubmitforApproval",SubmitforApproval);
                                                    
             }
       
        
        
        var el = component.find("chart").getElement();
        var ctx = el.getContext("2d");
        
       
                console.log('Approved',Approved);
                console.log('Rejected',Rejected);
                console.log('SubmitforFinalisation',SubmitforFinalisation);
                console.log('FinalisationDeclined',FinalisationDeclined);
                console.log('Finalised',Finalised);
                console.log('AwaitingApproval',AwaitingApproval);
                console.log('AwaitingCustomerResponse',AwaitingCustomerResponse);
                console.log('Submitted',Submitted);
                console.log('SubmitforApproval',SubmitforApproval);
        
        var myNewChart = new Chart(ctx, {
            type: 'horizontalBar',
            data: {
                labels: ["Submit for Approval", "Approved", "Rejected", "Submit for Finalisation", "Finalisation Declined", "Finalised","Awaiting Approval","Awaiting Customer Response","Submitted"],
                datasets: [{
                    label: 'Recovery Chart',
                    //data: [ 11, 12, 44, 45, 24, 56 ,65,87,65],
                    data: [ SubmitforApproval, Approved, Rejected, SubmitforFinalisation, FinalisationDeclined, Finalised,AwaitingApproval,AwaitingCustomerResponse,Submitted],
                    backgroundColor: [
                           '#C0C0C0',
                           '#008000',
                           '#FF0000',
                           '#FFFF00',
                           '#800000',
                           '#36a2eb',
                           '#cc65fe',
                           '#ff6384',
                           '#ffce56'
                        ],
                    yAxisID: "bar-y-axis1",
                   // backgroundColor:'#191970',
                    borderWidth: 1
                },
               ]
            },
            options: {
                responsive: true,
                legend: {
                    position: 'bottom'
                },
                scales: {
                    yAxes: [{
                        stacked: true,
                        id: "bar-y-axis1",
                        
                    }],
                    xAxes: [{
                        //stacked:true,
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
        });
             });

        $A.enqueueAction(action);
        
    },    
    SearchTypeDatarange : function(component,event,helper,FromDate,ToDate){  
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value"); 
        var action = component.get("c.searchMembersRecoveryData");
        
        console.log('FromDate helper',FromDate);
        console.log('ToDate helper',FromDate);
        
        action.setParams({
            usrId : selectedMemberId,
        	fDate : FromDate,
            tDate : ToDate
   		 });    
        
                
        var QantasPoints=0;
        var DomesticClubLoungePassesPoints=0;
        var InternationalBusinessLoungePasses=0;
        var ValetParkingCarwash=0;
        var Travelvouchers=0;
        var CreditCardRefund=0;
        var EFTRefund=0;
        var BagRepair=0;
        var BagReplacement=0;
        var NoGoodwill=0;
        var Dinnervouchers=0;
        var Flowers=0;
        var Wine=0;
        var Spaceavailableupgrade=0;
        var Firmspaceupgrade=0;

        console.log('response####%%%',component.find("teamMemberSelectId").get("v.value"));        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('response####',response);
            console.log('response####',JSON.stringify(response.getReturnValue())); 
            if(state=="SUCCESS"){ 
                 console.log('response',JSON.stringify(response.getReturnValue())); 
        
             var recvry =  response.getReturnValue();
                
                 //for(var recvry in response.getReturnValue()){
                for(var i = 0, size = recvry.length; i < size ; i++){
                    console.log('sdfds');
                    if(recvry[i].Type__c == 'Qantas Points'){
                        QantasPoints++;
                    }else if(recvry[i].Type__c =='Domestic Qantas Club Lounge Passes'){
                        DomesticClubLoungePassesPoints++;
                    }else if(recvry[i].Type__c =='International Business Lounge Passes'){                      
                        InternationalBusinessLoungePasses++;
                    }else if(recvry[i].Type__c =='Valet Parking or Carwash'){
                        ValetParkingCarwash++;                                                  
                    }else if(recvry[i].Type__c =='Travel vouchers'){
                        Travelvouchers++;
                    }else if(recvry[i].Type__c =='Credit Card Refund'){                        
                        CreditCardRefund++;                       
                    }else if(recvry[i].Type__c =='EFT Refund'){
                        EFTRefund++;
                    }else if(recvry[i].Type__c =='Bag Repair'){
                        BagRepair++;
                    }else if(recvry[i].Type__c =='Bag Replacement'){
                        BagReplacement++;                               
					}else if(recvry[i].Type__c =='No Goodwill'){
                        NoGoodwill++;                    
					}else if(recvry[i].Type__c =='Dinner vouchers'){
                        Dinnervouchers++;                     
					}else if(recvry[i].Type__c =='Flowers'){
                        Flowers++;                     
					}else if(recvry[i].Type__c =='Wine'){
                        Wine++;
                    }else if(recvry[i].Type__c =='Space available upgrade'){
                        Spaceavailableupgrade++;                    
					}else if(recvry[i].Type__c =='Firm space upgrade'){
                        Firmspaceupgrade++;
                    }                                                                                                                                         
                         
                    }
               
               component.set("v.QantasPoints",QantasPoints);
                component.set("v.DomesticClubLoungePassesPoints",DomesticClubLoungePassesPoints);
                component.set("v.InternationalBusinessLoungePasses",InternationalBusinessLoungePasses);
                component.set("v.ValetParkingCarwash",ValetParkingCarwash);
                component.set("v.Travelvouchers",Travelvouchers);
                component.set("v.CreditCardRefund",CreditCardRefund);
                component.set("v.EFTRefund",EFTRefund);
                component.set("v.BagRepair",BagRepair);
                component.set("v.BagReplacement",BagReplacement);
				component.set("v.NoGoodwill",NoGoodwill);
				component.set("v.Dinnervouchers",Dinnervouchers);
				component.set("v.Flowers",Flowers);
				component.set("v.Wine",Wine);
				component.set("v.Spaceavailableupgrade",Spaceavailableupgrade);
				component.set("v.Firmspaceupgrade",Firmspaceupgrade);
                                                    
             }
       
        
        
        var el = component.find("pieChart").getElement();
        var ctx = el.getContext("2d");
        
                       
         var myNewChart = new Chart(ctx, {
            type: 'horizontalBar',
            data: {
                labels: ["Qantas Points", "Domestic Qantas Club Lounge Passes", "International Business Lounge Passes", "Valet Parking or Carwash", "Travel vouchers", "Credit Card Refund","EFT Refund","Bag Repair","Bag Replacement","No Goodwill","Dinner vouchers","Flowers","Wine","Space available upgrade","Firm space upgrade"],
                datasets: [{
                    label: 'Recovery Chart',
                    //data: [ 11, 12, 44, 45, 24, 56 ,65,87,65],
                    data: [ QantasPoints, DomesticClubLoungePassesPoints, InternationalBusinessLoungePasses, ValetParkingCarwash, Travelvouchers, CreditCardRefund,EFTRefund,BagRepair,BagReplacement,NoGoodwill,Dinnervouchers,Flowers,Wine,Spaceavailableupgrade,Firmspaceupgrade],
                    backgroundColor: [
                           '#3F51B5',
                           '#9370DB',
                           '#32CD32',
                           '#8FBC8B',
                           '#B8860B',
                           '#F4A460',
                           '#A52A2A',
                           '#DC143C',
                           '#00BCD4',
                           '#7df442',
                           '#6ec193',
                           '#1e663e',
                           '#3f7c96',
                           '#a039bf',
                           '#b22066'
                        ],
                    yAxisID: "bar-y-axis2",
                   // backgroundColor:'#191970',
                    borderWidth: 3
                },
       
               ]
            },
            options: {
                responsive: true,
                legend: {
                    position: 'bottom',
                           labels: {
                                fontColor: "Green",
                                fontSize: 18
            				}
                },
                scales: {
                    yAxes: [{
                        stacked: true,
                        id: "bar-y-axis2",
                        
                    }],
                    xAxes: [{
                        //stacked:true,
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
        });
            //myNewChart.canvas.parentNode.style.height = 'auto';
          //  myNewChart.canvas.parentNode.style.width = '500px';
             });

        $A.enqueueAction(action);
        
    },
    
    
      
   convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['Name','Status__c'];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
    
   /* 
    numberOfDays :  function(component,helper,event){  
        var selectedMemberId = component.find("teamMemberSelectId").get("v.value"); 
        var action = component.get("c.numberofDayForClose");
        action.setParams({
            usrId : selectedMemberId,        	
   		 });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',response);
            if(state=="SUCCESS"){ 
                console.log('v.caseWorkingDays',JSON.stringify(response.getReturnValue()));                                
                component.set("v.caseWorkingDays",response.getReturnValue());                                
            }
        });

        $A.enqueueAction(action);
    },*/
     showHideHelper : function(auraId) {
         if(auraId == 'BodyAverageInfo'){
             	if(component.get("v.averageValueDisplay"))
                {
                    var cmp = component.find(auraId);
                    $A.util.addClass(cmp, "slds-show");
                    $A.util.removeClass(cmp, "slds-hide");
                    component.set("v.averageValueDisplay",true);
                }
                else
                {
                    var cmp = component.find(auraId);
                    $A.util.addClass(cmp, "slds-hide");
                    $A.util.removeClass(cmp, "slds-show");
                    component.set("v.averageValueDisplay",false);
                }
         }else if(auraId == 'BodyGraph'){
             if(component.get("v.graphDisplay"))
                {
                    var cmp = component.find(auraId);
                    $A.util.addClass(cmp, "slds-show");
                    $A.util.removeClass(cmp, "slds-hide");
                    component.set("v.graphDisplay",true);
                }
                else
                {
                    var cmp = component.find(auraId);
                    $A.util.addClass(cmp, "slds-hide");
                    $A.util.removeClass(cmp, "slds-show");
                    component.set("v.graphDisplay",false);
                }
         }else if(auraId == 'BodyData'){
             if(component.get("v.DataDisplay"))
                {
                    var cmp = component.find(auraId);
                    $A.util.addClass(cmp, "slds-show");
                    $A.util.removeClass(cmp, "slds-hide");
                    component.set("v.DataDisplay",true);
                }
                else
                {
                    var cmp = component.find(auraId);
                    $A.util.addClass(cmp, "slds-hide");
                    $A.util.removeClass(cmp, "slds-show");
                    component.set("v.DataDisplay",false);
                }
         }
        
        
    },
    
})