/*----------------------------------------------------------------------------------------------------------------------
Author:      gnanavelu
Jira:      CRM-3586
Description:  Loyalty Account Manager should ensure to downloading the Contract Execution Certificate from Salesforce when closing an opportunity.
Test Class:     QL_CheckRecordhasFilesTest
************************************************************************************************************************
History
************************************************************************************************************************
08-April-2019      gnanavelu               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
public class QL_CheckRecordhasFiles 
{
    public static void CheckAttachment(List<sObject> Obj)
    {
        Map<Id, ContentDocumentLink> contentdocMap = new Map<Id, ContentDocumentLink>();
        Id LoyaltyCommercial = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Loyalty_Commercial').getRecordTypeId();
        Set<Id> OppRecordIds = new Set<Id>();
        List<sObject> Opplist = new List<sObject>();
        
        //Check Loyalty Opportunity has attachment while moving to Closed won
        for(sObject opp : Obj)
        {
            if(opp.get('RecordTypeId') == LoyaltyCommercial && opp.get('StageName') == 'Closed Won')
            {
                OppRecordIds.add(opp.Id);
                Opplist.add(opp);
            }
        }
        
        if(!OppRecordIds.isEmpty())
        {            
            for(ContentDocumentLink ContDoc : [SELECT LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN : OppRecordIds])
            {
                contentdocMap.put(ContDoc.LinkedEntityId, ContDoc);
            }
            system.debug('content docMap'+contentdocMap);
            
            // Throw error if Opportunity has no attachement
            for(sObject Oppty : Opplist)
            {
                if(contentdocMap.get(Oppty.Id) == null)
                    Oppty.addError('To be able to close this opportunity, please download the Contract Execution Certificate document and attach the signed copy');
            }  
        }
    }
}