/****************************************************************************************************************************************************************************
 
    Created Date  : 31/08/16 (DD/MM/YYYY)
    Added By      : Vinothkumar Balasubramanian
    Description   : Trigger Handler Class to update the Custom Settings "Opportunity maintenance" while updating or Inserting the Active QBS or CA Opportunity maintance records
    JIRA          : CRM - 2053, CRM - 2217 and CRM - 2238
    Version       :V1.0 - 31/08/16 - Initial version
 
*****************************************************************************************************************************************************************************/

               /*
                This method is to update the fields "Close Date"
                 and "Create an Opportunity before (in months)" on the Custom settings "Opportunity maintenance"
                */



public class OpptyMaintenanceTriggerHandler {
    
   
        
    public static void updateclosurecreationdate(List<Opportunity_Maintenance__c> newList, Map<Id, Opportunity_Maintenance__c> oldMap)
    
    {
        Opportunity_main__c caOpptymain = Opportunity_main__c.getValues('Corporate Airfares');
        Opportunity_main__c qbsopptymain = Opportunity_main__c.getValues('Qantas Business Savings');
        
        List<Opportunity_main__c> opptymain = new List<Opportunity_main__c>();
        
        List<Opportunity_Maintenance__c> listopptymain = new List<Opportunity_Maintenance__c>();
        
        
        Set<Id> setOpptymaintenanceChangedIds = new Set<Id>();
        
        for(Opportunity_Maintenance__c Oopptymain: newList){
            
            if(Oopptymain.Create_an_Opportunity_before_in_months__c != oldMap.get(Oopptymain.Id).Create_an_Opportunity_before_in_months__c
                                 || Oopptymain.Create_an_Opportunity_before_in_months__c == oldMap.get(Oopptymain.Id).Create_an_Opportunity_before_in_months__c ||
                                 Oopptymain.Close_Date__c != oldMap.get(Oopptymain.Id).Close_Date__c ||
                                 Oopptymain.Close_Date__c == oldMap.get(Oopptymain.Id).Close_Date__c ||
                                 Oopptymain.Active__c != oldMap.get(Oopptymain.Id).Active__c || Oopptymain.Active__c == oldMap.get(Oopptymain.Id).Active__c){
                                     
                setOpptymaintenanceChangedIds.add(Oopptymain.Id);
            }
        }
        
    
        if (setOpptymaintenanceChangedIds.isEmpty() == false){
             listopptymain = [SELECT Id, Account_Record_Type__c, Active__c,Category__c, Create_an_Opportunity_before_in_months__c, Close_Date__c 
                                                              FROM Opportunity_Maintenance__c WHERE Id IN :setOpptymaintenanceChangedIds];
         }
         
         if(!listopptymain.isEmpty()){
             for (Opportunity_Maintenance__c opptymain2 : listopptymain){
                 if (opptymain2.Category__c == 'Corporate Airfares' && opptymain2.Active__c == true){
                     caOpptymain.Create_an_Opportunity_before_in_months__c = opptymain2.Create_an_Opportunity_before_in_months__c;
                     caOpptymain.Close_Date__c = opptymain2.Close_Date__c;
                     caOpptymain.Active__c = true;
                     opptymain.add(caOpptymain);
                }
                else if(opptymain2.Category__c == 'Corporate Airfares' && opptymain2.Active__c == false){
                    caOpptymain.Create_an_Opportunity_before_in_months__c = NULL;
                    caOpptymain.Close_Date__c = NULL;
                    caOpptymain.Active__c = false;
                    opptymain.add(caOpptymain);
                }
                
                else if(opptymain2.Category__c == 'Qantas Business Savings' && opptymain2.Active__c == true){
                    qbsopptymain.Create_an_Opportunity_before_in_months__c = opptymain2.Create_an_Opportunity_before_in_months__c;
                    qbsopptymain.Close_Date__c = opptymain2.Close_Date__c;
                    qbsopptymain.Active__c = true;
                    opptymain.add(qbsopptymain);
                }
                else if(opptymain2.Category__c == 'Qantas Business Savings' && opptymain2.Active__c == false){
                    qbsopptymain.Create_an_Opportunity_before_in_months__c = NULL;
                    qbsopptymain.Close_Date__c = NULL;
                    qbsopptymain.Active__c = false;
                    opptymain.add(qbsopptymain);
                }
             }
         }
         
         if(!opptymain.isEmpty())update opptymain;
    }
   
                /*
                This method is to insert the values on the fields "Expected Closure Date"
                and "Create an Opportunity before (in months)" on the Custom settings "Opportunity maintenance"
                once the Active Opportunity maintenance record is created
                 
                */
    
    public static void insertclosurecreationdate(List<Opportunity_Maintenance__c> newList)
    {
        
        Opportunity_main__c caOpptymaint = Opportunity_main__c.getValues('Corporate Airfares');
        Opportunity_main__c qbsOpptymaint = Opportunity_main__c.getValues('Qantas Business Savings');
        List<Opportunity_main__c> opptymaint = new List<Opportunity_main__c>();
        
        for (Opportunity_Maintenance__c opptymaintenace : newList){
            if(opptymaintenace.Category__c == 'Corporate Airfares' && opptymaintenace.Active__c == TRUE){
                caOpptymaint.Create_an_Opportunity_before_in_months__c = opptymaintenace.Create_an_Opportunity_before_in_months__c;
                caOpptymaint.Close_Date__c = opptymaintenace.Close_Date__c;
                caOpptymaint.Active__c = TRUE;
                opptymaint.add(caOpptymaint);
            }
            
            else if (opptymaintenace.Category__c == 'Qantas Business Savings' && opptymaintenace.Active__c == TRUE){
                qbsOpptymaint.Create_an_Opportunity_before_in_months__c = opptymaintenace.Create_an_Opportunity_before_in_months__c;
                qbsOpptymaint.Close_Date__c = opptymaintenace.Close_Date__c;
                qbsOpptymaint.Active__c = TRUE;
                opptymaint.add(qbsOpptymaint);
            }
        }
        
        if(!opptymaint.isEmpty())insert opptymaint;
    }
}