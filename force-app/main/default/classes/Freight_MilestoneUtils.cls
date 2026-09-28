/*==================================================================================================================================
Author:         Abhieet P
Company:        TCS
Purpose:        Freight - Class will be used auto Closure of Milestone, Below class has been copied From Salesforce Documentation
Date:           03/08/2017         
TestClass:      FreightAllTileControllerTest

==================================================================================================================================

==================================================================================================================================*/
public class Freight_MilestoneUtils {
    
    public static void completeMilestone(set<Id> caseIds, 
                                         String milestoneName, DateTime complDate) {  
                                             List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                                                                from CaseMilestone cm
                                                                                where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
                                                                                limit 1];
                                             if (cmsToUpdate.isEmpty() == false){
                                                 for (CaseMilestone cm : cmsToUpdate){
                                                     cm.completionDate = complDate;
                                                 }
                                                 update cmsToUpdate;
                                             }
                                         }
    
    public static void completeMilestoneAutoClosed(set<Id> caseIds,  DateTime complDate)
    {  
    System.debug('caseidsfrom trigger'+caseIds);
        List<CaseMilestone> listToUpdateBoth = new List<CaseMilestone>();       
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate, caseId from CaseMilestone cm where caseId in :caseIds ];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
                listToUpdateBoth.add(cm);
            }
            
        }
        System.debug('insideutility'+listToUpdateBoth.size());
        if (listToUpdateBoth.size() >0)
        {
            update listToUpdateBoth;
        }       
    }
    
    @Future
    public static void completeMilestoneForReopenCase(set<Id> caseIds, 
                                                      String reopenMilestoneName, DateTime emptyComplDate) 
    {  
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                           from CaseMilestone cm
                                           where caseId in :caseIds and cm.MilestoneType.Name=:reopenMilestoneName 
                                           limit 1];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = emptyComplDate;
            }
            update cmsToUpdate;
        }
    }
}