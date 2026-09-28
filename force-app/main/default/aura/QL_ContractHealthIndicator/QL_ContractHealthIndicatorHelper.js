({
	
    //client-side helper function to call the 'contractComputePercentage' method of QL_ContractHealthIndicatorController
    callApexMethod : function(component, event, helper)  {
        
        var action = component.get('c.contractComputePercentage');
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
				//component.set("v.active" , response.getReturnValue().split('*')[1] );
                component.set("v.dealCase" , response.getReturnValue().split('*')[1] );
                component.set("v.conType" , response.getReturnValue().split('*')[2] );
                component.set("v.assetExist" , response.getReturnValue().split('*')[3] );
                component.set("v.attachment" , response.getReturnValue().split('*')[4] );
                
                component.set("v.cirDeg" , progressVal );
                component.set("v.perText" , parseInt(percVal)  +'%' );
                component.set("v.proposalType" , response.getReturnValue().split('*')[5]);
                console.log(response.getReturnValue().split('*')[1] );
            }  
        });
        $A.enqueueAction(action);  
    }
})