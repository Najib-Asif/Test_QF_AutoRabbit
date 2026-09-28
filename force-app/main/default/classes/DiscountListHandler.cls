/**********************************************************************************************************************************
 
    Description: Once the Proposal Discount is added to a Proposal, based on the Annual Revenue of Proposal the allowed discount percentages of Account Manager & National Account Manager will 
                 be copied to the particular fields on the individual Proposal Discount List record.
    Method Description: 
    1) populateDiscountThreshold: To populate the discount thresholds of AM & NAM from Fare Discount Guidelines object based on the Annual Revenue of Proposal.
    2) updateProposal: If any of the Discount List is required Approval from AM/ NAM then the Proposal status will be turned to "Approval Required - Internal".
    3) afterApprovalsDiscountChanged: After the approval of Proposal if the standard discount on the Discount List record changed then the flags which represents approval done earlier, will turns to off.
    Versión:
    
**********************************************************************************************************************************/

public class DiscountListHandler {
    /*
    Method Description: To populate the discount thresholds of AM & NAM from Fare Discount Guidelines object based on the Annual Revenue of Proposal.
    */ 
    public static List<Discount_List__c> populateDiscountThreshold(List<Discount_List__c> newList ){
        
        Set<Id> discountListIds = new Set<Id>();
        List<Id> proposalIds = new List<Id>();
        //List<Discount_List__c> dlWithThresholdVal = new List<Discount_List__c>();
        
        for(Discount_List__c dl1: newList){
            discountListIds.add(dl1.FareStructure__c);
            proposalIds.add(dl1.Proposal__c);
        }
        Map<Id, Standard_Discount_Guidelines__c> prodIdDiscMap = new Map<Id, Standard_Discount_Guidelines__c>();
        List<Standard_Discount_Guidelines__c> allDiscountGuidelines = [SELECT Id, Fare_Combination__c,Active__c, Fare_Structure__c, Minimum_Revenue__c, Maximum_Revenue__c, Discount_Threshold_AM__c,Discount_Threshold_TL__c,Discount_Threshold_NAM__c,Segment__c,Network__c,Discount_Threshold_DO__c,Maximum_Forecast_QF_Share_Int_MCA__c,Minimum_Forecast_QF_Share_Int_MCA__c FROM Standard_Discount_Guidelines__c where Fare_Structure__c IN :discountListIds and Active__c=true];    
        
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
        Map<Id, Fare_Structure__c> bookingClassMap = new Map<Id, Fare_Structure__c>();
        
        List<Fare_Structure__c> bookingClasses = [SELECT Id, Segment__c, Category__c FROM Fare_Structure__c where Id IN :discountListIds];
        
        for(Fare_Structure__c fs: bookingClasses){
            bookingClassMap.put(fs.Id, fs);
        }
                
        List<Proposal__c> allProposals = [SELECT Id, Qantas_Annual_Expenditure__c,Forecast_MCA_Revenue__c,International_Annual_Share__c,MCA_Routes_Annual_Share__c FROM Proposal__c where Id IN : proposalIds];
        
        for(Proposal__c pr : allProposals){
            proposalMap.put(pr.Id, pr);
        }
        
        for(Standard_Discount_Guidelines__c dG : allDiscountGuidelines){
            prodIdDiscMap.put(dG.Fare_Structure__c, dG);
        }

        for(Discount_List__c dL : newList){
            
            for(Standard_Discount_Guidelines__c discountGuide : allDiscountGuidelines){    
                //Standard_Discount_Guidelines__c discountGuide = prodIdDiscMap.get(dL.FareStructure__c);
                if(discountGuide.Fare_Structure__c == dL.FareStructure__c && discountGuide.Fare_Combination__c == dL.Fare_Combination__c){
                    /*if((proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= discountGuide.Minimum_Revenue__c && proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c < discountGuide.Maximum_Revenue__c) && No_of_Domestic_Fares__c > 0) {        
        
                        dL.Discount_Threshold_AM__c = discountGuide.Discount_Threshold_AM__c;
                        dL.Discount_Threshold_TL__c = discountGuide.Discount_Threshold_TL__c; // CRM - 2003 To populate the Discount Threshold(TL) from Fare Discount guidelines to Proposal Fare discount.
                        dL.Discount_Threshold_NAM__c = discountGuide.Discount_Threshold_NAM__c;
                        dL.Discount_Threshold_DO__c = discountGuide.Discount_Threshold_DO__c; // CRM - 2003 To populate the Discount Threshold(DO) from Fare Discount guidelines to Proposal Fare discount.
                        System.debug('*** Step1'+dL);
                    }*/
                    // CRM  - 1686 To check the condition for Forecast QF Share (Int) and Forecast Qantas Market Share (MCA)
                    system.debug('frst '+proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c+'>='+discountGuide.Minimum_Revenue__c);
                    system.debug('frstsecnd '+proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c+'<='+discountGuide.Maximum_Revenue__c);
                    system.debug('frstthrd '+proposalMap.get(dL.Proposal__c).International_Annual_Share__c+'>='+discountGuide.Minimum_Forecast_QF_Share_Int_MCA__c);
                    system.debug('frstfrth '+proposalMap.get(dL.Proposal__c).International_Annual_Share__c+'<='+discountGuide.Maximum_Forecast_QF_Share_Int_MCA__c);
                    // Changed Qantas_Annual_Expenditure__c from 300k to 250k for domestic only as part of JIRA CRM-4466 (Stand down Period)
                     if(((proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= discountGuide.Minimum_Revenue__c && 
                    proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c <= discountGuide.Maximum_Revenue__c) &&
                    (proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= 250000)&&
                    (proposalMap.get(dL.Proposal__c).International_Annual_Share__c >= discountGuide.Minimum_Forecast_QF_Share_Int_MCA__c && 
                    proposalMap.get(dL.Proposal__c).International_Annual_Share__c <= discountGuide.Maximum_Forecast_QF_Share_Int_MCA__c) && (discountGuide.Segment__c == 'International') && (discountGuide.Network__c == 'Non-MCA') )||
                    ((proposalMap.get(dL.Proposal__c).Forecast_MCA_Revenue__c  >= discountGuide.Minimum_Revenue__c &&
                    proposalMap.get(dL.Proposal__c).Forecast_MCA_Revenue__c <= discountGuide.Maximum_Revenue__c) &&
                       (proposalMap.get(dL.Proposal__c).MCA_Routes_Annual_Share__c  >= discountGuide.Minimum_Forecast_QF_Share_Int_MCA__c &&
                    proposalMap.get(dL.Proposal__c).MCA_Routes_Annual_Share__c <= discountGuide.Maximum_Forecast_QF_Share_Int_MCA__c) && (discountGuide.Segment__c == 'International') && (discountGuide.Network__c == 'MCA')) ||
                   ((proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= discountGuide.Minimum_Revenue__c && 
                    proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c <= discountGuide.Maximum_Revenue__c) &&
                   (proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= 300000)&&                   
                    (discountGuide.Fare_Combination__c == 'INT Non MCA Route Deal') && (discountGuide.Network__c == 'Non-MCA') && (discountGuide.Segment__c == 'International') ) ||
                    ((proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= discountGuide.Minimum_Revenue__c && 
                    proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c <= discountGuide.Maximum_Revenue__c) &&
                   (proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= 300000)&&                   
                    (discountGuide.Fare_Combination__c == 'INT MCA Route Deal') && (discountGuide.Network__c == 'MCA') && (discountGuide.Segment__c == 'International') ) ||
                    ((proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= discountGuide.Minimum_Revenue__c && proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c <=discountGuide.Maximum_Revenue__c) &&
                    (proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c >= 250000)&&
                    (discountGuide.Segment__c == 'Domestic')))
                    
                                      
                    
                    {        
        
                        dL.Discount_Threshold_AM__c = discountGuide.Discount_Threshold_AM__c;
                        dL.Discount_Threshold_TL__c = discountGuide.Discount_Threshold_TL__c;
                        dL.Discount_Threshold_NAM__c = discountGuide.Discount_Threshold_NAM__c;
                        dL.Discount_Threshold_DO__c = discountGuide.Discount_Threshold_DO__c;
                        dL.Maximum_Forecast_QF_Share_Int_MCA__c = discountGuide.Maximum_Forecast_QF_Share_Int_MCA__c;
                        dL.Minimum_Forecast_QF_Share_Int_MCA__c = discountGuide.Minimum_Forecast_QF_Share_Int_MCA__c;
                        
                        
                         System.debug('*** Step2'+dL);
                    }
                    dL.Qantas_Annual_Expenditures__c = proposalMap.get(dL.Proposal__c).Qantas_Annual_Expenditure__c;
                }
              
             }
        }   
        System.debug('New Discount List With Threshold ***'+newList);
        return newList;
    } 
    /*
    Method Description: If any of the Discount List is required Approval from AM/ NAM then the Proposal status will be turned to "Approval Required - Internal".
    */
   /* public static void updateProposal(List<Discount_List__c> newList){
        
        Set<Id> proposalIds = new Set<Id>();
        Set<Id> proposalIdsNAM = new Set<Id>();
        Set<Id> proposalIdsTL = new Set<Id>(); // CRM 2003 - Set for TL
        Set<Id> proposalIdsTeamLead = new Set<Id>(); //CRM 1992 - Team Lead for QBS
        Set<Id> proposalIdsDO = new Set<Id>();   // CRM 2003 - Set for DO
        Set<Id> proposalIdsPricing = new Set<Id>(); 
        Set<Id> proposalIdsManagerSBD = new Set<Id>();  //CRM 1989 SBD QBS
        Set<Id> proposalIdsSBD = new Set<Id>(); //CRM 1989 SBD CA
        String rType = Schema.SObjectType.Discount_List__c.getRecordTypeInfosByName().get('Approved - Customer').getRecordTypeId();
        for(Discount_List__c dL : newList){ 

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
               /* if(dL.Approval_Required_Pricing__c == true && !proposalIdsPricing.contains(dL.Proposal__c)){
                    
                    proposalIdsPricing.add(dL.Proposal__c);
                }*/
                /* Commented for the CRM 2003 As this condition is no longer valid
                if((dL.Approval_Required_NAM__c == true || dL.Approval_Required_Pricing__c == true) && !proposalIds.contains(dL.Proposal__c)){
                    
                    proposalIds.add(dL.Proposal__c);
                }  */
                // CRM -2003 
               /* if((dL.ApprovalRequired_Team_Lead_CA__c == true || DL.ApprovalRequired_Team_Lead__c  == true || dL.ApprovalRequired_SBD_CA__c == true || dL.ApprovalRequired_SBD_QBS__c == true ||  dL.Approval_Required_NAM__c == true || dL.Approval_Required_DO__c == true || dL.Approval_Required_Pricing__c == true) && !proposalIds.contains(dL.Proposal__c)){
                    
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
    } */ 
    /*
    Method Description: After the approval of Proposal if the standard discount on the Discount List record changed then the flags which represents approval done earlier, will turns to off.
    */
    public static void afterApprovalsDiscountChanged(List<Discount_List__c> newList, Map<Id, Discount_List__c> oldMap){
         
         for(Discount_List__c dL : newList){
             if(dL.Discount__c > oldMap.get(dL.Id).Discount__c){
                 dL.Approved_by_NAM__c = false;
                 dL.Approved_by_Pricing__c = false;
                 dL.DO_Approved__c = false;   //CRM -2003
                 dL.TeamLead_Approved__c = false;
                 dL.Approved_by_TL__c= false;   //CRM -2003
                 dL.Approved_by_SBD__c= false;  // CRM 1989 SBD CA
                 dL.SBD_Approved__c= false;     // CRM 1989 SBD QBS
             }
         }   
    } 
    //updates Include R/KMLVS to false CRM-9486
    public static void handleAfterDelete(List<Discount_List__c> oldDLs){
        Set<Id> ProposalIds = new Set<Id>();
        Set<Id> ProposalStillWithRandKMLVS = new Set<Id>();
        List<Proposal__c> proposalToUpdate = new List<Proposal__c>();
        for(Discount_List__c dl: oldDLs){
            if((dl.Booking_Class_Name__c == 'R' || dl.Booking_Class_Name__c== 'KMLVS')&& dl.Proposal__c != null){
             	ProposalIds.add(dl.Proposal__c);
            }
        }
        List<Discount_List__c> remainingDLs = [select Id, Proposal__c, Booking_Class_Name__c from Discount_List__c where Proposal__c in:ProposalIds];
        for(Discount_List__c dl: remainingDLs){
            if(dl.Booking_Class_Name__c== 'R' || dl.Booking_Class_Name__c== 'KMLVS'){
                ProposalStillWithRandKMLVS.add(dl.Proposal__c);
            }
        }
        for(Id PrId: ProposalIds){
            if(!ProposalStillWithRandKMLVS.contains(PrId)){
                proposalToUpdate.add(new Proposal__c(Id = PrId, Includes_R_KMLVS__c= false));
            }
        }
        
        if(!proposalToUpdate.isEmpty()){
            update proposalToUpdate;
        }
    }
    
}