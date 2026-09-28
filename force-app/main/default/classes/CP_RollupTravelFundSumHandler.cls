/**********************************************************************************************************************************

Created Date: 29/09/17

Description: Roll up of CP Amount on Proposal.

Versión:
V1.0 - 29/09/17 - Initial version [FO]
======================================================================================================================
Name                          Jira           Description                                             Tag
======================================================================================================================
Karpagam Swaminathan         CRM-2771        CP amount rollup on Proposal
Ajay						 JIRA AE-82		 to add Record Type on Contract Payments & Payments object
**********************************************************************************************************************************/
public class CP_RollupTravelFundSumHandler 
{
    // Ajay : added for JIRA : AE - 82
    public static Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
    // Ajay : ended
    
    public static void SumofCPs(List < Contract_Payments__c > cpList) 
    {
        Set < Id > proposalIds = new Set < Id > ();
        Decimal total_used;
        
        try {
            //Get the ProposalIds
            for (Contract_Payments__c cp: cpList) {
                proposalIds.add(cp.Proposal__c);
            }
            proposalIds.remove(null);
            Map < Id, AggregateResult > resultsMAP = new Map < id, AggregateResult > ();
            if (!proposalIds.isEmpty()) {
                List < Proposal__c > propToUpdate = new List < Proposal__c > ();
                AggregateResult[] results = [SELECT Proposal__c PropId, sum(Amount__c) Amtsum from Contract_Payments__c where Proposal__c in : proposalIds and RecordTypeId =: cpRTId and Type__c = 'Performance Bonus' group by Proposal__c];
                //Iterate through the Aggregate result and update on Proposal
                for (AggregateResult ar: results) {
                    //resultsMAP.put(ar.get('PropId'),ar.get('Amtsum'));
                    decimal temp = (decimal) ar.get('Amtsum');
                    total_used = Decimal.valueOf(ar.get('Amtsum') + '');
                    propToUpdate.add(new Proposal__c(Id = String.Valueof(ar.get('PropId')), Travel_Fund_Amount__c = total_used));     
                }
                if (!propToUpdate.isEmpty()) {
                    update propToUpdate;
                }
            }
            
        } catch (Exception e) {
            System.debug('Error Occured From RollupTravelFundSumHandler: ' + e.getMessage());
        }
    }
}