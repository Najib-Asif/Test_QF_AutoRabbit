/*----------------------------------------------------------------------------------------------------------------------
Author:        Ram Kolli
Company:       TCS
Description:   To deploy the metadata type record from Banner component.
Inputs:
Test Class:   KM_Banner_Controller_Test.apxc 
************************************************************************************************
History
************************************************************************************************
06-Nov-2020    Ram Kolli   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class KM_Banner_Controller {
	@AuraEnabled(cacheable=true)
    public static List < KM_Banner_Config__mdt > fetchBannerText() {
        return [ SELECT Label,DeveloperName,Banner_Text__c FROM KM_Banner_Config__mdt WHERE DeveloperName='Internal_Community_Banner' LIMIT 1];
    }
    
    @AuraEnabled
    public static void updateBannerText(String metdataName, String recordDevName,String label,String fieldToUpdate,String valToUpdate) {
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
		metadataFieldValueMap.put(fieldToUpdate, valToUpdate);
        CustomMetadataUtils.updateCustomMetadata(metdataName,recordDevName,label,metadataFieldValueMap);
    }
}