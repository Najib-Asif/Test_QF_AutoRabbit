/*----------------------------------------------------------------------------------------------------------------------
Description:   For Triggering assignment rules when the case/lead is created via flow
Test Class:    QCC_TriggerAssignmentRulesTest
************************************************************************************************
History
************************************************************************************************
15-July-2021     gnanavelu          Initial Design
-----------------------------------------------------------------------------------------------------------------------*/

public class QCC_TriggerAssignmentRules {
    
    @InvocableMethod(label='Trigger Assignment Rules.' description='Will trigger assignment rules for the records created via flow. Please pass list of Ids of the Same Object')
    public static void QCCTriggerAssignmentRules(List<Id> recordIds)
    {
        String objName = recordIds[0].getSObjectType().getDescribe().getName();
        AssignmentRule AR = new AssignmentRule();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        
        if(objName != '' && (objName == 'Case' || objName == 'Lead'))
        {
            AR = [SELECT Id FROM AssignmentRule WHERE SobjectType =: objName AND Active = True LIMIT 1];
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        }
        
        List<sObject> updateRecords = new List<sObject>();
        for(Id recordId : recordIds)
        {
            if(objName == 'Case')
            {
                Case obj = new Case(Id = recordId, Status = 'New');
                obj.setOptions(dmlOpts);
                updateRecords.add(obj);
            }
            // Use the below for Lead
            /*else if(objName == 'Lead')
            {
                Lead obj = new Lead(Id = recordId);
                obj.setOptions(dmlOpts);
                updateRecords.add(obj);
            }*/
        }
        
        List<Database.upsertResult> upsertResults = updateRecords.size() > 0 ? Database.upsert(updateRecords,false):null;
        
        for(Database.upsertResult result:upsertResults) {
            if (result.isSuccess()) 
                system.debug('record updated '+result.getId());
            else{
                for(Database.Error err : result.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
}