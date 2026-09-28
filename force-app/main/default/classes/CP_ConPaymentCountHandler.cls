/**********************************************************************************************************************************

Created Date: 26/02/18

Description: Roll up of Contract Payments of Proposal.

Modified :
Ajay    JIRA AE-82      to add Record Type on Contract Payments & Payments object

Versión:
V1.0 - 26/02/18 - Initial version [FO]
**********************************************************************************************************************************/
Public class CP_ConPaymentCountHandler 
{
    // Ajay : added for JIRA : AE - 82
    public static Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
    // Ajay : ended

    
    public static void CountNumofConPayments(List <Contract_Payments__c> newList)
    {
        Set<Id> setProposalIds = new Set<Id>();
        
        for(Contract_Payments__c con : newList)
        {
            setProposalIds.add(con.Proposal__c);
            system.debug('setProposalIds$$$$'+setProposalIds);
        }
        
        List<Proposal__c> listProptoUpdate = [Select id,name,No_of_Cps__c ,(Select id from Contract_Payments__r where RecordTypeId =: cpRTId) from Proposal__c where Id in : setProposalIds];               
        system.debug('query$$$$'+listProptoUpdate );
        
        for(Proposal__c Prop: listProptoUpdate)
        {
            List<Contract_Payments__c> conPmt = new list<Contract_Payments__c>();
            conPmt = Prop.Contract_Payments__r;
            if (Prop.No_of_Cps__c != conPmt.size())
                Prop.No_of_Cps__c = conPmt.size();
        }
        update listProptoUpdate;
    }
}