/*----------------------------------------------------------------------------------------------------------------------
Author:        Flo
Company:       ACN
Description:   For opening a new tab with the ARD web address when the Open ARD Web is click
Inputs:
Test Class:
************************************************************************************************
History
************************************************************************************************
10-March-2023      Flo               Initial Design - getURLAddress &  getARDWeb method

-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_PNRHighlightPanelController {
	/*----------------------------------------------------------------------------------------------
    Method Name:        getURLAddress
    Description:        Get the base URL of org to get the ARD Web address via custom meta data
    Parameter:          String
	Return: 			List<QCC_ARD_Url_Address__mdt>
	----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<Environment_Setting__mdt> getURLAddress(){
        String orgId = UserInfo.getOrganizationId();
        system.debug('orgId ==' + orgId);
        Environment_Setting__mdt[] lstARDMetaData = getARDWeb(orgId);
        if(!lstARDMetaData.isEmpty()){
            return lstARDMetaData;
        }
        
        return null;
    }
    /*----------------------------------------------------------------------------------------------
    Method Name:        getARDWeb
    Description:        Query in the custom meta data 
    Parameter:          String
	Return: 			List<QCC_ARD_Url_Address__mdt>
	----------------------------------------------------------------------------------------------*/
    public static List<Environment_Setting__mdt> getARDWeb(String orgId){
        List <Environment_Setting__mdt> lstARDMetaData = new List <Environment_Setting__mdt>([SELECT id, ARD_Enabled__c,ARD_Url__c FROM Environment_Setting__mdt WHERE  Org_Id__c = : orgId LIMIT 1]);
        system.debug('lstARDMetaData ==' + lstARDMetaData);
        return !lstARDMetaData.isEmpty()? lstARDMetaData : null ;
        
    }
   
}