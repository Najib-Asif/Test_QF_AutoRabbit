/********
    * Created By : Flo De Los Reyes | ACN | Developer 
    * Purpose : Controller class
    * Purpose : Apex controler Class for ObjectAlert Aura Component
    * REST API : No Rest API Needed
    
    Modified Date   : 27/01/23 (DD/MM/YYYY)
    Modified By     : Flo De Los Reyes
    JIRA            : ADT-21
    Version         : 1.1 -Initial Development | Flo
*/
public with sharing class IndicatorController {
  private static SObject sobj;

  /***************************
    *   Purpose				: Method to retrieve dynamically the label of the Object
    * 	Parameters		: String
    * 	Returns				: String
    * 
    * 	Throws
    * 	Expectations	:
	****************************/

  @AuraEnabled
  public static String getSObjectLabel(String sObjName){
    //String label = Schema.getGlobalDescribe().get(sObjName).getDescribe().getLabel();
    List<Schema.DescribeSObjectResult> describes = Schema.describeSObjects(new String[] { sObjName}, SObjectDescribeOptions.DEFERRED);
    return describes[0].getLabel();
  }
  /***************************
    *   Purpose				: Method to retrieve records in the meta data which is used for displaying 
    * 	Parameters		: String
    * 	Returns				: String
    * 
    * 	Throws
    * 	Expectations	: 
	****************************/
  @AuraEnabled
  public static List<IndicatorService.Indicator> getIndicators(String recId, String objectName){
    getSObject(recId, objectName);
    if(sobj != NULL){
      List<IndicatorService.Indicator> indicators = IndicatorService.getIndicatorBadgesForObject(sobj,recId,objectName);
      return indicators;
    } else {
      return null;
    }
  }

  /***************************
    *   Purpose				: Method to retrieve records 
    * 	Parameters		: String, String
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations	:
	****************************/
  public static void getSObject(String recId, String objectName){
    List<String> fNames = IndicatorService.getFieldsToQueryForObject(objectName);
    if(fNames.size() > 0){
      String query = 'SELECT Id,'+ String.join(fNames,',')+' FROM '+ objectName +' WHERE Id =\''+ recId +'\' WITH SECURITY_ENFORCED LIMIT 1';
      List<SObject> results = Database.query(query);
      if(results.size() == 1){
        sobj = results[0];
      }
    }
  }

  /***************************
    *   Purpose				: Method to retrieve related contact record from case 
    * 	Parameters		: String
    * 	Returns				: Id
    * 
    * 	Throws
    * 	Expectations	: should return the related contact id of the case record
	****************************/
  @AuraEnabled
    public static Id getContactId(String recId){ 
        if(!string.isEmpty(recId)){
            
            List<Case> lstCase = [SELECT id,contactId FROM Case WHERE id =: recId];
            
            if(!lstCase.isEmpty()){
                return lstCase[0].contactId;
            }
            return null;
        }
        
        return null;
    }
}