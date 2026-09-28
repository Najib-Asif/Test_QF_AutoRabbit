/**********************************************************************************************************************************
Modified Date   : 29/01/19 (DD/MM/YYYY)
Added By        : Vinothkumar Balasubramanian
JIRA            : CRM - 3494
Version         : V2.0 - Commented this class after discussing with Nijo as this functionality has been deprecated

**********************************************************************************************************************************/

public class MemberTriggerHandler
{
  
  /*public static void processCases(List<Associated_Person__c> newList, Map<Id, Associated_Person__c> oldMap){
      
      Set<String> ffSet = new Set<String>();
      Map<String, List<Case>> casesMap = new Map<String, List<Case>>();
      Set<Case> subtypeCases = new Set<Case>();
      Set<Case> closeCases = new Set<Case>();
      List<Case> updateAllCases = new List<Case>();
      Map<string, QBD_Case_Subtype__c> mapCodes = QBD_Case_Subtype__c.getAll();
      
      for(Associated_Person__c ap : newList){
          if(ap.Active_Profile_Record__c != oldMap.get(ap.Id).Active_Profile_Record__c || ap.Active_QBD_Record__c != oldMap.get(ap.Id).Active_QBD_Record__c || ap.Last_Name_Match__c != oldMap.get(ap.Id).Last_Name_Match__c || ap.Last_Name__c != oldMap.get(ap.Id).Last_Name__c || ap.QBD_Last_Name__c != oldMap.get(ap.Id).QBD_Last_Name__c || ap.Sync_Traveller_Override__c != oldMap.get(ap.Id).Sync_Traveller_Override__c){
              ffSet.add(ap.Frequent_Flyer_Number__c);
          }
      }
      
      if(ffSet.size() > 0) casesMap = allRelatedCases(ffSet);
      
      for(Associated_Person__c ap : newList){
        if(ap.Active_QBD_Record__c && ap.Active_Profile_Record__c){      
             if(ap.Active_Profile_Record__c != oldMap.get(ap.Id).Active_Profile_Record__c || ap.Active_QBD_Record__c != oldMap.get(ap.Id).Active_QBD_Record__c || ap.Last_Name_Match__c != oldMap.get(ap.Id).Last_Name_Match__c || ap.Last_Name__c != oldMap.get(ap.Id).Last_Name__c || ap.QBD_Last_Name__c != oldMap.get(ap.Id).QBD_Last_Name__c || ap.Sync_Traveller_Override__c != oldMap.get(ap.Id).Sync_Traveller_Override__c){
                  if(casesMap.containsKey(ap.Frequent_Flyer_Number__c)){
                      List<Case> casesList = casesMap.get(ap.Frequent_Flyer_Number__c);
                      for(Case myCase : casesList){
                          if(myCase.AccountId == ap.Account__c){
                              if(ap.Last_Name_Match__c == false && ap.Sync_Traveller_Override__c == false){
                                 if(myCase.Sub_Type__c == mapCodes.get('New QBD Traveller added').PickList_value__c || myCase.Sub_Type__c  == mapCodes.get('Member updated with QBD Traveller').PickList_value__c){
                                      subtypeCases.add(myCase);
                                 }
                              }
                              if(ap.Last_Name_Match__c == true || ap.Sync_Traveller_Override__c == true){                      
                                      closeCases.add(myCase);                      
                              }
                           }
                       }                   
                  }
              }
         } 
      }
      
      for(Case cs : subtypeCases){
          cs.Sub_Type__c = mapCodes.get('Last Name Mismatch').PickList_value__c;
          updateAllCases.add(cs);
      }
      
      for(Case cs1 : closeCases){
          cs1.Status = 'Closed';
          updateAllCases.add(cs1);
      }
      
      Database.Update(updateAllCases);      
  }
  
  public static Map<String, List<Case>> allRelatedCases(Set<String> allMembers){
      Map<String, List<Case>> casesMap = new Map<String, List<Case>>();
      Map<string, QBD_Case_Subtype__c> mapCodes = QBD_Case_Subtype__c.getAll();
      List<String> caseSubType = new List<String>();
      caseSubType.add(mapCodes.get('New QBD Traveller added').PickList_value__c);
      caseSubType.add(mapCodes.get('Member updated with QBD Traveller').PickList_value__c);
      caseSubType.add(mapCodes.get('Last Name Mismatch').PickList_value__c);
      List<Case> allCases = [SELECT Id, Status, Frequent_Flyer_Number__c, Sub_Type__c, AccountId FROM Case where Status != 'Closed' AND Frequent_Flyer_Number__c IN :allMembers AND Sub_Type__c IN :caseSubType];
      
      for(Case cs : allCases){
          if(!casesMap.containsKey(cs.Frequent_Flyer_Number__c)) casesMap.put(cs.Frequent_Flyer_Number__c, new List<Case>());
          casesMap.get(cs.Frequent_Flyer_Number__c).add(cs);
      }
      return casesMap;
  }*/

}