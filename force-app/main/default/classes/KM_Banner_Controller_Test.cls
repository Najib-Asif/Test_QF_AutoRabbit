/*----------------------------------------------------------------------------------------------------------------------
Author:        Ram Kolli
Company:       TCS
Description:   Test class for KM_Banner_Controller class.
************************************************************************************************
History
************************************************************************************************
06-Nov-2020    Ram Kolli   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class KM_Banner_Controller_Test {
@IsTest
    static void testMyCallback() {
        
        // Instantiate the callback.
		KM_Banner_Controller.fetchBannerText();
        KM_Banner_Controller.updateBannerText('KM Banner Config', 'Internal_Community_Banner', 'Banner Text', 'Banner_Text__c', 'test');
        
        Metadata.DeployCallback callback = new CustomMetadataUtils();
       
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        
        // Invoke the callback's handleResult method.
        callback.handleResult(result, context);
    }
}