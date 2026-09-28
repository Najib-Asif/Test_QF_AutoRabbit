({
	
    //client-side helper function to call the 'proposalComputePercentage' method of QL_ProposalHealthIndicatorcontroller
    callApexMethod : function(component, event, helper)  {
        
        var action = component.get('c.proposalComputePercentage');
        var txt_recordId = component.get("v.recordId");
        var txt_sObjectName = component.get("v.sObjectName");
        
        action.setParams({
            recordId : txt_recordId,
            sObjectName : txt_sObjectName   
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var percVal = parseInt(response.getReturnValue().split('*')[0]); 
                var progressVal = parseInt(  (percVal/100) * 360  ) ;
				//set component attributes from server response
				component.set("v.active" , response.getReturnValue().split('*')[1] );
                component.set("v.discList" , response.getReturnValue().split('*')[2] );
                component.set("v.freqFlyStatUpOff" , response.getReturnValue().split('*')[3] );
                component.set("v.strfreqFlyStatUpOff" , response.getReturnValue().split('*')[4] );
                component.set("v.grpTravelOffer" , response.getReturnValue().split('*')[5] );
                component.set("v.strgrpTravelOffer" , response.getReturnValue().split('*')[6] );
                component.set("v.contractPayment" , response.getReturnValue().split('*')[7] );
                component.set("v.strContractPay" , response.getReturnValue().split('*')[8] );
                component.set("v.contractExist" , response.getReturnValue().split('*')[9] );
                component.set("v.businessCase" , response.getReturnValue().split('*')[10] );
                component.set("v.cirDeg" , progressVal );
                component.set("v.perText" , parseInt(percVal)  +'%' );
                component.set("v.qClubDisc" , response.getReturnValue().split('*')[11] );
                component.set("v.strqClubDisc" , response.getReturnValue().split('*')[12] );
                component.set("v.proposalType" , response.getReturnValue().split('*')[13] );
                console.log(response.getReturnValue().split('*')[1] );

            }  
        });
        $A.enqueueAction(action);  
    }
})