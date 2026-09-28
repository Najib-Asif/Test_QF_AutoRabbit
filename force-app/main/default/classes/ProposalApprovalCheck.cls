public class ProposalApprovalCheck {
    
	public static string check;
    @InvocableMethod (label = 'Discount list' description = 'Receiving proposal id for discount list')    
    public static void getProposalId(List<Id> ids){
        
        ProposalApprovalCheck.updateProposal(ids);
        ProposalApprovalCheck.updateSC_ODPair_onProposal(ids);
        ProposalApprovalCheck.CP_RollupTravelFundSumHandler(ids);
        ProposalApprovalCheck.CountNumofConPayments(ids);
      //  ProposalApprovalCheck.submitForApproval(ids);
        
    }
    
    public static void updateProposal(List<Id> proposalId){
        String errorMessage = 'No applicable process found';
        Set<Id> proposalIds = new Set<Id>();
        Set<Id> proposalIdsNAM = new Set<Id>();
        Set<Id> proposalIdsTL = new Set<Id>(); // CRM 2003 - Set for TL
        Set<Id> proposalIdsTeamLead = new Set<Id>(); //CRM 1992 - Team Lead for QBS
        Set<Id> proposalIdsDO = new Set<Id>();   // CRM 2003 - Set for DO
        Set<Id> proposalIdsPricing = new Set<Id>(); 
        Set<Id> proposalIdsManagerSBD = new Set<Id>();  //CRM 1989 SBD QBS
        Set<Id> proposalIdsSBD = new Set<Id>(); //CRM 1989 SBD CA
        String rType = Schema.SObjectType.Discount_List__c.getRecordTypeInfosByName().get('Approved - Customer').getRecordTypeId();
       	
    List<Discount_List__c> discountRecords = [Select id,RecordTypeId,Proposal__c,ApprovalRequired_Team_Lead__c,ApprovalRequired_SBD_CA__c,
     									ApprovalRequired_SBD_QBS__c,Approval_Required_NAM__c,Approval_Required_DO__c,Approval_Required_Pricing__c,
                                        ApprovalRequired_Team_Lead_CA__c from Discount_List__c where id IN: proposalId];
    
    for(Discount_List__c dL : discountRecords){ 

          // CRM 2003 Check whether the Approval Required TeamLead for CA  is true, if it is true add it to the set proposalIdsTL
           if(dL.RecordTypeId != rType){            
                if(dL.ApprovalRequired_Team_Lead_CA__c == true && !proposalIdsTL.contains(dL.Proposal__c)){
                    
                    proposalIdsTL.add(dL.Proposal__c);
                } 
                // CRM 1992 
                if(dL.ApprovalRequired_Team_Lead__c == true && !proposalIdsTeamLead.contains(dL.Proposal__c)){
                    
                    proposalIdsTeamLead.add(dL.Proposal__c);
                }
                
                // CRM 1989 - SBD - CA
                
                if(dL.ApprovalRequired_SBD_CA__c == true && !proposalIdsSBD.contains(dL.Proposal__c)){
                    
                    proposalIdsSBD.add(dL.Proposal__c);
                } 
                
                // CRM 1989 - SBD - QBS
                if(dL.ApprovalRequired_SBD_QBS__c == true && !proposalIdsManagerSBD.contains(dL.Proposal__c)){
                    
                    proposalIdsManagerSBD.add(dL.Proposal__c);
                }
            
                      
                if(dL.Approval_Required_NAM__c == true && !proposalIdsNAM.contains(dL.Proposal__c)){
                    
                    proposalIdsNAM.add(dL.Proposal__c);
                } 
                // CRM 2003 Check whether the Approval_Required_DO__c is true, if it is true add it to the set proposalIdsDO
                if(dL.Approval_Required_DO__c == true && !proposalIdsDO.contains(dL.Proposal__c)){
                    
                    proposalIdsDO.add(dL.Proposal__c);
                }
                /* Commented for the CRM 2003 As this condition is no longer valid
                if(dL.Approval_Required_NAM__c == true && !proposalIdsPricing.contains(dL.Proposal__c)){
                    
                    proposalIdsPricing.add(dL.Proposal__c);
                } */
                // CRM 2003 Check whether the Approval_Required_Pricing__c is true, if it is true add it to the set proposalIdsPricing
                if(dL.Approval_Required_Pricing__c == true && !proposalIdsPricing.contains(dL.Proposal__c)){
                    
                    proposalIdsPricing.add(dL.Proposal__c);
                }
                /* Commented for the CRM 2003 As this condition is no longer valid
                if((dL.Approval_Required_NAM__c == true || dL.Approval_Required_Pricing__c == true) && !proposalIds.contains(dL.Proposal__c)){
                    
                    proposalIds.add(dL.Proposal__c);
                }  */
                // CRM -2003 
                if((dL.ApprovalRequired_Team_Lead_CA__c == true || DL.ApprovalRequired_Team_Lead__c  == true || dL.ApprovalRequired_SBD_CA__c == true || dL.ApprovalRequired_SBD_QBS__c == true ||  dL.Approval_Required_NAM__c == true || dL.Approval_Required_DO__c == true || dL.Approval_Required_Pricing__c == true) && !proposalIds.contains(dL.Proposal__c)){
                    
                    proposalIds.add(dL.Proposal__c);
                }            
            }
        }
        
        Set<Id> allproposalIds = new Set<Id>();
        for(Id id1 : proposalIds ){
            allproposalIds.add(id1);
        }
        
        for(Id id2 : proposalIdsNAM ){
            allproposalIds.add(id2);
        }
        
        for(Id id3 : proposalIdsPricing ){
            allproposalIds.add(id3);
        }
        
        for(Id id4 : proposalIdsDO ){
            allproposalIds.add(id4);
        }
        
        for(Id id5 : proposalIdsTL ){
            allproposalIds.add(id5);
        }
 
        for(Id id6 : proposalIdsTeamLead ){
            allproposalIds.add(id6);
        }
        
        // CRM 1989 - SBD CA
        
        for(Id id7 : proposalIdsSBD ){
            allproposalIds.add(id7);
        }
        
        // CRM 1989 - SBD QBS
        
        for(Id id8 : proposalIdsManagerSBD ){
            allproposalIds.add(id8);
        }

        List<Proposal__c> updateProposals = [SELECT Id,NAM_Approved__c,DO_Approved__c, Pricing_Approved__c,TeamLead_Approved__c,TL_Approved__c,Approved_by_SBD__c, SBD_Approved__c,Status__c FROM Proposal__c where Id IN :allproposalIds];
        for(Proposal__c p : updateProposals){
            //if(proposalIds.contains(p.Id)) p.Status__c = 'Approval Required - Internal';
            if(proposalIdsTL.contains(p.Id)) p.TL_Approved__c = false;//test // CRM - 2003 Set TL Approved to False - CA
            if(proposalIdsTeamLead.contains(p.Id)) P.TeamLead_Approved__c = false;  // CRM 1992 Added Team lead for QBS
            if(proposalIdsNAM.contains(p.Id)) p.NAM_Approved__c = false;
            if(proposalIdsDO.contains(p.Id)) p.DO_Approved__c = false;   // CRM - 2003 Set DO Approved to False
            if(proposalIdsPricing.contains(p.Id)) p.Pricing_Approved__c = false; // CRM - 2003 Set Pricing Approved to False
            if(proposalIdsSBD.contains(p.Id)) p.Approved_by_SBD__c = false;   // CRM 1989  SBD - CA
            if(proposalIdsManagerSBD.contains(p.Id)) p.SBD_Approved__c = false;   // CRM 1989  SBD - QBS
           // if(proposalIdsPricing.contains(p.Id)){ p.Pricing_Approved__c = false; p.DO_Approved__c = false;} 
        }        
                
        try{
            System.debug('***'+updateProposals);
            Database.update(updateProposals);            
        }catch(Exception e){
            System.debug('&&&&& Error Message: '+e.getMessage());
        }
   
    }
    
    
     //public static void updateSC_ODPair_onProposal(List<QEC_Special_Condition__c> newList)
     public static void updateSC_ODPair_onProposal(List<Id> newList){
        Set<Id> propIds = new Set<Id>(newList);
        Set<Id> contractIds = new Set<Id>();
        Set<Id> spCondIds = new Set<Id>();
        List<Proposal__c> propList = new List<Proposal__c>();
        List<QEC_Special_Condition__c> spcList = new List<QEC_Special_Condition__c>();
        List<Contract__c> contractList = new List<Contract__c>();
        Map<Id,Airport_Code__c> airportCodeMap = new Map<Id,Airport_Code__c>([Select Id,Name from Airport_Code__c]);
      	
        
       /* for(QEC_Special_Condition__c spc: newList) {
            if(spc.Contract__c != null){
                contractIds.add(spc.Contract__c);
            }    
            else{
                propIds.add(spc.Proposal__c);
            }  
            System.debug(spc.QEC_History__c) ;
            if(!Trigger.isInsert && spc.QEC_History__c){
                spcList.add(new QEC_Special_Condition__c(Id=spc.id,QEC_History__c=false));
            }         
        }*/
        if(spcList.size() > 0){
            update spcList;
        }
        List<Proposal__c> proposalList = [Select Id,QL_IsSpecialConditionAddedDOAppiled__c,QL_IsSpecialConditionAddedPricingAppiled__c,(select id,QEC_Type__c,CreatedDate from special_conditions__r order by CreatedDate DESC limit 1) spc from Proposal__c WHERE Id IN :propIds]; //CRM-8376
        if(propIds.size() > 0){
            for(Proposal__c prop : [Select Id,QEC_Approval_Condition__c,QEC_JQ_Inclusion_City_Pairs__c,QL_IsSpecialConditionAddedDOAppiled__c,QL_IsSpecialConditionAddedPricingAppiled__c,LastModifiedDate,(select id,QEC_Type__c,QEC_Origin__c,QEC_Destination__c,QEC_History__c from special_conditions__r) spc from Proposal__c WHERE Id IN :propIds]){//CRM-7338
                String specialConditions = '';
                String JQ_OnD = '';
                Boolean QL_IsSpecialConditionAddedDOApproval = False;//CRM-7338
                Boolean QL_IsSpecialConditionAddedPricingApproval = False;//CRM-7338
                
                for(QEC_Special_Condition__c sp : prop.special_conditions__r){
                    if(!sp.QEC_History__c){
                        if(specialConditions == ''){
                            specialConditions = String.valueOf(sp.QEC_Type__c)+';';
                        }
                        else{
                            if(!specialConditions.contains(String.valueOf(sp.QEC_Type__c))){
                                specialConditions = specialConditions+String.valueOf(sp.QEC_Type__c)+';';
                                System.debug('inside else'+specialConditions);
                            }
                            else{//Enabling  Boolean Value when duplicate special conditions are added CRM-7338
                                if(specialConditions.contains(String.valueOf(sp.QEC_Type__c))){
                                    System.debug('Inside when special condition added');
                                    for(Proposal__c newProp : proposalList){ // Added list to avoid too many soql error CRM-8376
                                        for(QEC_Special_Condition__c splCondition : newProp.special_conditions__r){
                                            if(splCondition.QEC_Type__c=='Route Deal'|| splCondition.QEC_Type__c=='Incentive Fare') {
                                                System.debug('QEC Type'+splCondition.QEC_Type__c);
                                                prop.QL_IsSpecialConditionAddedDOAppiled__c=True;
                                                QL_IsSpecialConditionAddedDOApproval = prop.QL_IsSpecialConditionAddedDOAppiled__c;
                                                System.debug('QL_IsSpecialConditionAddedDOApproval####'+prop.QL_IsSpecialConditionAddedDOAppiled__c);
                                            }
                                            else{
                                                prop.QL_IsSpecialConditionAddedPricingAppiled__c=True;
                                                QL_IsSpecialConditionAddedPricingApproval = prop.QL_IsSpecialConditionAddedPricingAppiled__c;
                                                System.debug('QL_IsSpecialConditionAddedPricingAppiled__c####'+prop.QL_IsSpecialConditionAddedPricingAppiled__c);
                                            }
                                        }
                                    }
                                }
                                
                            } //CRM-7338
                        }
                    }
                    
                    if(sp.QEC_Type__c == 'JQ Inclusion'){
                        if(airportCodeMap.containsKey(sp.QEC_Origin__c) && airportCodeMap.containsKey(sp.QEC_Destination__c)){
                            if(!JQ_OnD.contains(airportCodeMap.get(sp.QEC_Origin__c).Name+'-'+airportCodeMap.get(sp.QEC_Destination__c).Name))
                                JQ_OnD += airportCodeMap.get(sp.QEC_Origin__c).Name+'-'+airportCodeMap.get(sp.QEC_Destination__c).Name+';';
                        }
                        
                        
                    }
                }
                Proposal__c propInst = new Proposal__c(Id=prop.Id);
                propInst.QEC_Approval_Condition__c = specialConditions;
                propInst.QL_IsSpecialConditionAddedDOAppiled__c = QL_IsSpecialConditionAddedDOApproval;//CRM-7338
                propInst.QL_IsSpecialConditionAddedPricingAppiled__c = QL_IsSpecialConditionAddedPricingApproval;//CRM-7338
                System.debug('QL_IsSpecialConditionAddedDOApproval***'+propInst.QL_IsSpecialConditionAddedDOAppiled__c+'QL_IsSpecialConditionAddedPricingApproval***'+propInst.QL_IsSpecialConditionAddedPricingAppiled__c);//CRM-7338
                if(JQ_OnD != ''){
                    propInst.QEC_JQ_Inclusion_City_Pairs__c = JQ_OnD.removeEnd(';');
                }
                
                propList.add(propInst);
                System.debug('PropAppCondition'+specialConditions);
            }
             if(propList.size() > 0)
            update propList;
            
        }
    }
    
    //Contract payments
    //    public static void SumofCPs(List < Contract_Payments__c > cpList) 
 public static void CP_RollupTravelFundSumHandler(List <Id > cpList) 
    {
        Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
        Set < Id > proposalIds = new Set < Id > (cpList);
        Decimal total_used;
        
        try {
            //Get the ProposalIds
            /*for (Contract_Payments__c cp: cpList) {
                proposalIds.add(cp.Proposal__c);
            }*/
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
    
    
    public static void CountNumofConPayments(List <Id> newList)
    {
		Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
        Set<Id> setProposalIds = new Set<Id>(newList);
        
        /*for(Contract_Payments__c con : newList)
        {
            setProposalIds.add(con.Proposal__c);
            system.debug('setProposalIds$$$$'+setProposalIds);
        }*/
        
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

   /* public static void submitForApproval (List <Id> ids){
        
        for (Id proposalId : ids){
            try{
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    		req.setComments('Submitting the record for approval.');
   	 		req.setObjectId(proposalId);
    		Approval.ProcessResult result = Approval.process(req);
            }
            
            catch(exception e){
           //     Flow.Interview.Proposal_Approval_Check.addErrorMessage('No applicable process found');
                throw new FlowException ('No applicable process found');
            }
        	if(result.isSuccess()){
                
            	check = 'true';
                system.debug('approval submission failed for record id '+result.getInstanceId());
            }
        }
         
        	
    } 
    */
}