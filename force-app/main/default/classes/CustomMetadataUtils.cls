/*----------------------------------------------------------------------------------------------------------------------
Author:        Ram Kolli
Company:       TCS
Description:   To deploy the metadata type record from Banner component.
Inputs:
Test Class:   KM_Banner_Controller_Test 
************************************************************************************************
History
************************************************************************************************
06-Nov-2020    Ram Kolli   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class CustomMetadataUtils implements Metadata.DeployCallback {
     
    //Interface method 
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            //Success
            System.debug('Success Result-' + result);
        } else {
            //Failed
            System.debug('Failed Result-' + result);
        }
    }
     
    //Update Custom Metadata record
    public static void updateCustomMetadata(String metdataName, String recordDevName, String label, Map<String, Object> metadataFieldValueMap){
        Metadata.CustomMetadata cMetadata = new Metadata.CustomMetadata();
        cMetadata.fullName = metdataName + '.' + recordDevName;
        cMetadata.label = label;
         
        for(String key : metadataFieldValueMap.keySet()){
            Metadata.CustomMetadataValue cMetadataValue = new Metadata.CustomMetadataValue();
            cMetadataValue.Field = key;
            cMetadataValue.Value = metadataFieldValueMap.get(key); 
            cMetadata.values.add(cMetadataValue);
        }
         
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(cMetadata);
        CustomMetadataUtils callback = new CustomMetadataUtils();
        if(!Test.isRunningTest()){
    	    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
}