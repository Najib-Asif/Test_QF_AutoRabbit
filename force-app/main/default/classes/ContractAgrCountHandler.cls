/**********************************************************************************************************************************
 
    Created Date: 29/10/18
 
    Description: Roll up of Contract & Agreement of Proposal.
  
    Versión:
    V1.0 - 29/10/18 - Initial version [FO]
 
**********************************************************************************************************************************/
Public class ContractAgrCountHandler { 
    public static void CountNumofContractAgr(List <Contract__c> newList) {
    Set<Id> setProposalIds = new Set<Id>();
    
     for(Contract__c con : newList)
       {
        setProposalIds.add(con.Proposal__c);
        system.debug('setProposalIds$$$$'+setProposalIds);
       }
  
     List<Proposal__c> listProptoUpdate = [Select id,name,No_of_Contr_Agr__c ,(Select id from Contracts__r) from Proposal__c where Id in : setProposalIds ];               
     system.debug('query$$$$'+listProptoUpdate );
     
     for(Proposal__c Prop: listProptoUpdate)  {
     
     List<Contract__c> conAgr = new list<Contract__c>();
     conAgr = Prop.Contracts__r;
        if (Prop.No_of_Contr_Agr__c != conAgr.size())
            Prop.No_of_Contr_Agr__c = conAgr.size();
    }
      update listProptoUpdate;
  }
}