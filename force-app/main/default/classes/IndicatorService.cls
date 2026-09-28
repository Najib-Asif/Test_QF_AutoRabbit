/********
    * Created By : Flo De Los Reyes | ACN | Developer 
    * Purpose : Controller class
    * Purpose : Apex Service Class called on IndicatorController
    * REST API : No Rest API Needed
    
    Modified Date   : 27/01/23 (DD/MM/YYYY)
    Modified By     : Flo De Los Reyes
    JIRA            : ADT-21
    Version         : 1.1 -Initial Development | Flo
*/
public inherited sharing class IndicatorService {
    
  /***************************
    *   Purpose             : Method to retrieve the fields
    *   Parameters      : String
    *   Returns             : List<String>
    * 
    *   Throws
    *   Expectations    :
    ****************************/
  public static List<String> getFieldsToQueryForObject(String objName){
    Set<String> targetFields = new Set<String>();
    for(Indicator_Badge__mdt i: [SELECT Related_Field__r.QualifiedApiName FROM Indicator_Badge__mdt WHERE Object__r.QualifiedApiName = :objName WITH SECURITY_ENFORCED]){
        system.debug('QualifiedApiName === ' + i.Related_Field__r.QualifiedApiName);
        targetFields.add(i.Related_Field__r.QualifiedApiName);
    }
    return new List<String>(targetFields);
  }

  /***************************
    *   Purpose             : Method to retrieve the fields
    *   Parameters      : Sobject,String
    *   Returns             : List<Indicator>
    * 
    *   Throws
    *   Expectations    :
    ****************************/
  public static List<Indicator> getIndicatorBadgesForObject(SObject sobj, String recId, String objectName){
    List<Indicator> recordIndicators = new List<Indicator>();
    List<Case> listCase = new List<Case>();
    system.debug('recId === '+ recId);
    if(objectName == 'Case'){
       listCase = [SELECT id,ContactId FROM Case WHERE Id =:recid WITH SECURITY_ENFORCED];
       recId =  listCase[0].ContactId;
    }
    if(String.isNotBlank(recid)){
        listCase = [SELECT id  FROM Case WHERE ContactId =:recid AND Status != 'Completed' AND Status != 'Closed' WITH SECURITY_ENFORCED];
        List<Task> listTask = [SELECT id FROM Task WHERE WhoId =:recid AND CreatedDate = LAST_N_DAYS:14 WITH SECURITY_ENFORCED];
        List<Contact> listContact = [SELECT Id,Birthdate FROM Contact WHERE Id =:recid  WITH SECURITY_ENFORCED];
        system.debug('listTask === '+ listTask);
        system.debug('listCase === '+ listCase);
        
        for(Indicator_Badge__mdt indicator: [SELECT MasterLabel, Badge_Color__c, Comparison_Value__c, Comparison_Type__c, Badge_Icon_Name__c, Related_Field__r.QualifiedApiName FROM Indicator_Badge__mdt WHERE Object__r.QualifiedApiName = :sobj.getSObjectType().getDescribe().getName() WITH SECURITY_ENFORCED]){
        Boolean hasRecords = false;
        if(indicator.Comparison_Type__c == 'Has Open Case'){
            hasRecords = listCase.size() > 0;
        }else if(indicator.Comparison_Type__c == 'Has Repeat Interaction'){
            hasRecords = listTask.size() > 1;
        }else if(indicator.Comparison_Type__c == 'Birthday Tomorrow'){
            if(listContact.size() > 0)
            {
                if(listContact[0].Birthdate != null)
                {
                    Date birthday = listContact[0].Birthdate ;
                    Date dtomorrow = Date.today().addDays(1);
                    if(birthday.month() == dtomorrow.month() && dtomorrow.day() ==birthday.day() )
                    {
                        hasRecords = true;
                    } 
                }
            }  
        }else if(indicator.Comparison_Type__c == 'Birthday Yesterday'){
            if(listContact.size() > 0)
            {
                if(listContact[0].Birthdate != null)
                {
                    Date birthday = listContact[0].Birthdate ;
                    Date dYesterday = Date.today().addDays(-1);
                    if(birthday.month() == dYesterday.month() && dYesterday.day() ==birthday.day() )
                    {
                        hasRecords = true;
                    } 
                }
            }  
        //}else if(indicator.Comparison_Type__c == 'Birthday Today'){
        } else if (indicator.Comparison_Type__c != null && indicator.Comparison_Type__c.equals('Birthday Today')) {
           if(listContact.size() > 0)
            {
                if(listContact[0].Birthdate != null)
                {
                    Date birthday = listContact[0].Birthdate ;
                    Date dToday = Date.today();
                    if(birthday.month() == dToday.month() && dToday.day() ==birthday.day() )
                    {
                        hasRecords = true;
                    } 
                }
            } 
        }
        recordIndicators.add(evaluateIndicator(indicator, sobj, recId, hasRecords));
        }
    }  
    
    
    return recordIndicators;
  }

  /***************************
    *   Purpose             : Method which contains logic if a particular icon/alert should be display 
    *   Parameters      : Sobject,String
    *   Returns             : List<Indicator>
    * 
    *   Throws
    *   Expectations    :
    ****************************/
  private static Indicator evaluateIndicator(Indicator_Badge__mdt i, SObject sobj, String recId,Boolean hasRecords){
    Object field = sobj.get(i.Related_Field__r.QualifiedApiName);
    if(hasRecords){
      return new Indicator(i.Badge_Icon_Name__c, i.Badge_Color__c, i.MasterLabel);
    } else {
      return null;
    }
  }
  //inner class, creating our 'Indicator' object and attributes
  public class Indicator{
    //first, the attributes:
    @AuraEnabled
    public String icon {get; set;}
    @AuraEnabled
    public String color {get; set;}
    @AuraEnabled
    public String label {get; set;}
    //then, our object:
    public Indicator(String icon, String color, String label){
      this.icon = icon;
      this.color = color;
      this.label = label;
    }
  }
}