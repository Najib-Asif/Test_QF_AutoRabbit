/***********************************************************************************************************************************

Description: Lightning component handler for the cloning the Proposal functionality

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam                 CRM-2969   LEx-Custom Clone Proposal                                   T01                                 
Ajay                    AE - 82     to add Record Type on Contract Payments & Payments object
Created Date    : 02/02/18 (DD/MM/YYYY)

**********************************************************************************************************************************/
public with sharing class QL_CloneProposalController {
    
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    @AuraEnabled public String recID {get;set;}
    
    @AuraEnabled
    public static QL_CloneProposalController getClonedProposal(Id propId)
    {
        
        QL_CloneProposalController obj = new QL_CloneProposalController();
        
        try{
            String rtype = '';
            Id RId;
            list<Proposal__c> existingpropList = [SELECT Id,Opportunity__r.StageName FROM Proposal__c where Id =: propId];
            system.debug('clonepropId***********'+propId);
            // validate the opportunity stage
            if(!existingpropList .isEmpty()){
                for(Proposal__c eachProp: existingpropList ){
                    if(eachProp.Opportunity__r.StageName == 'Closed - Not Accepted' || eachProp.Opportunity__r.StageName == 'Closed - Accepted'){
                        obj.isSuccess = false;
                        obj.msg = 'Please note that you cannot create a proposal for a closed opportunity.';
                        return obj;
                    }
                }    
            }
            
            Proposal__c currentProposal;
            if(!existingpropList .isEmpty()){
                //added special conditions to the query as part of QEC
                //added QF/EK field in query for CRM-5329
                for (Proposal__c thisProposal : [SELECT Id,Name,Active__c,QIS_Rejected__c,TeamLead_Approved__c,SBD_Approved__c,QIS_Approved__c,Approval_Required_Others__c,DO_Approved__c,Pricing_Approved1__c,Reason_for_Discount__c,Charter_Price__c,NAM_Approved1__c,Forecast_MCA_Revenue__c,Qantas_Club_Join_Discount_Offer__c,Account__c,Commercial_TC__c,Domestic_Annual_Share__c,International_Annual_Share__c,Legal_TC__c,Opportunity__c,Contact__c,
                                                 Qantas_Annual_Expenditure__c,Status__c,Valid_From_Date__c,Valid_To_Date__c,Standard__c,Additional_Change_Details__c,Deal_Type__c,MCA_Routes_Annual_Share__c,
                                                 Agent_Name__c,Agent_Fax__c,Agent_Email__c,Agent_Address__c,Frequent_Flyer_Status_Upgrade__c,Frequent_Flyer_Status_Upgrade_Offer__c,Qantas_Club_Discount__c,Forecast_Group_Booking_Expenditure__c,Group_Travel_Discount__c,Group_Travel_Offer__c,
                                                 Qantas_Club_Discount_Offer__c,TMC_Code__c,Travel_Fund__c,Travel_Fund_Amount__c,Type__c,Proposal_Start_Date__c,Proposal_End_Date__c, Opportunity__r.Type,Opportunity__r.Sub_Type_Level_1__c,Opportunity__r.Sub_Type_Level_2__c,Leadership_Rejected__c,Expected_Approval_Date__c,EK_Stock__c,Group_Booking__c,QL_Discount_Model__c,
                                                 (SELECT Id, FareStructure__c, Approval_Comment_NAM__c,Approval_Comment_Pricing__c, Comment__c, Discount__c,QL_Tier_1_Offering__c, Discount_Threshold_AM__c, Discount_Threshold_NAM__c,Route_Destination__c,Route_Origin__c,Discount_Threshold_TL__c,Discount_Threshold_DO__c,Network__c,Segment__c,Category__c,Proposal_Type__c,Approval__c,Cabin__c,Market__c,QL_QF_EK__c,IsApproved__c,Approved_by_NAM__c,Fare_Combination__c,NAM_Rejected__c,Qantas_Annual_Expenditures__c FROM Fare_Structure_Lists__r  where FareStructure__r.Active__c = true),
                                                 (SELECT Id, Contract_Agreement__c FROM Charter_Flight_Information__r),
                                                 (SELECT Id, Amount__c,Paid_As__c,Payment_Criteria__c,Payment_Frequency__c,Type__c,Proposal__c FROM Contract_Payments__r),
                                                 (SELECT Id, Proposal__c, Cost_of_sale_Incremental_opportunity__c, Current_performance_in_the_route_s__c, What_else_have_you_considered__c, How_did_you_arrive_with_this_proposal__c, Is_there_competitive_MI__c, Market__c, Requested_routes__c, Supplementary_Materials_Sharepoint_Link__c, What_is_the_current_booking_mix__c,Aligned_with_EK_sales__c FROM Justifications__r),
                                                 (SELECT Id, Name,Proposal__c,QEC_Baggagecode__c,QEC_BlockRevenueTarget__c,QEC_Blocksize__c,QEC_Cancellation__c,QEC_Class__c,QEC_Conditions__c,QEC_DayofWeek__c,QEC_Destination__c,QEC_Discount__c,QEC_FarebasisFarerulenumber__c,QEC_FareBasis__c,QEC_Fare__c,QEC_Flightnumber__c,
                                                  QEC_FromDate__c,QEC_HourDay__c,QEC_Network__c,QEC_NoShow__c,QEC_Numberofpieces__c,QEC_Origin__c,QEC_Route__c,QEC_TimefromDeparture__c,QEC_ToDate__c,QEC_Type__c,QEC_KgPc__c,QEC_Cabin__c,QEC_Booking_Class__c FROM Special_Conditions__r),
                                                 (SELECT Id, Proposal__c, CurrencyIsoCode,PCC_Start_Date__c,PCC_End_Date__c, TMC_Info__c, History__c FROM Contract_TMC_Info__r),AA_Joint_Customer__c,QEC_AA_Customer__c,Forecast_Flight_Share_US__c,Forecast_Flight_Share_Domestic_US__c,Forecast_Flight_Share_International_US__c,Exceeds_Threshold__c,QL_Actual_Estimated_Dom_QF_Market_Share__c 
                                                 FROM Proposal__c where  Id =: propId])
                {
                    system.debug('this proposal^^^^^^^^^^^^'+thisProposal.Id);
                    currentProposal = (thisProposal != null) ? thisProposal : null;
                }
            }
            // Handle the clone  
            if(currentProposal.Active__c !=true)
                
            {
                obj.isSuccess = false;
                obj.msg = 'You cannot clone inactive Proposal';
                return obj;
            }
            system.debug('currentProposal^^^^^^^^^^^^'+currentProposal.Id);
            // Create a cloned Proposal  
            if(currentProposal != null && currentProposal.Active__c == true)
            {
                Proposal__c  cloneProposal = new Proposal__c ();
                
                cloneProposal.Name = currentProposal.Name;
                cloneProposal.Account__c = currentProposal.Account__c;
                cloneProposal.Active__c = true;
                cloneProposal.Charter_Price__c = currentProposal.Charter_Price__c;
                cloneProposal.Commercial_TC__c = currentProposal.Commercial_TC__c;
                cloneProposal.Contact__c = currentProposal.Contact__c;
                cloneProposal.Domestic_Annual_Share__c = currentProposal.Domestic_Annual_Share__c;
                cloneProposal.International_Annual_Share__c = currentProposal.International_Annual_Share__c;
                cloneProposal.Legal_TC__c = currentProposal.Legal_TC__c;
                cloneProposal.Opportunity__c = currentProposal.Opportunity__c;
                cloneProposal.Qantas_Annual_Expenditure__c = currentProposal.Qantas_Annual_Expenditure__c;
                cloneProposal.Valid_From_Date__c = currentProposal.Valid_From_Date__c;
                cloneProposal.Type__c = currentProposal.Type__c;
                cloneProposal.Travel_Fund__c = currentProposal.Travel_Fund__c;
                cloneProposal.Travel_Fund_Amount__c = currentProposal.Travel_Fund_Amount__c;
                cloneProposal.Standard__c = currentProposal.Standard__c;
                cloneProposal.Additional_Change_Details__c = currentProposal.Additional_Change_Details__c;
                cloneProposal.Deal_Type__c = currentProposal.Deal_Type__c;
                cloneProposal.MCA_Routes_Annual_Share__c = currentProposal.MCA_Routes_Annual_Share__c;
                cloneProposal.Agent_Name__c = currentProposal.Agent_Name__c;
                cloneProposal.Agent_Fax__c = currentProposal.Agent_Fax__c;
                cloneProposal.Agent_Email__c = currentProposal.Agent_Email__c;
                cloneProposal.Agent_Address__c = currentProposal.Agent_Address__c;
                cloneProposal.Frequent_Flyer_Status_Upgrade__c = currentProposal.Frequent_Flyer_Status_Upgrade__c;
                cloneProposal.Frequent_Flyer_Status_Upgrade_Offer__c = currentProposal.Frequent_Flyer_Status_Upgrade_Offer__c;
                cloneProposal.Qantas_Club_Discount__c = currentProposal.Qantas_Club_Discount__c;
                cloneProposal.Qantas_Club_Discount_Offer__c = currentProposal.Qantas_Club_Discount_Offer__c;
                cloneProposal.TMC_Code__c = currentProposal.TMC_Code__c;
                cloneProposal.Qantas_Club_Join_Discount_Offer__c = currentProposal.Qantas_Club_Join_Discount_Offer__c;
                cloneProposal.Forecast_MCA_Revenue__c = currentProposal.Forecast_MCA_Revenue__c;
                cloneProposal.Reason_for_Discount__c = currentProposal.Reason_for_Discount__c;
                cloneProposal.Proposal_Start_Date__c=currentProposal.Proposal_Start_Date__c;
                cloneProposal.Proposal_End_Date__c =currentProposal.Proposal_End_Date__c;
                cloneProposal.Group_Travel_Offer__c =currentProposal.Group_Travel_Offer__c;
                cloneProposal.Forecast_Group_Booking_Expenditure__c =currentProposal.Forecast_Group_Booking_Expenditure__c;
                cloneProposal.EK_Stock__c=currentProposal.EK_Stock__c;
                cloneProposal.Group_Booking__c=currentProposal.Group_Booking__c;
                cloneProposal.AA_Joint_Customer__c= currentProposal.AA_Joint_Customer__c;
                cloneProposal.Exceeds_Threshold__c = cloneProposal.Exceeds_Threshold__c;
                cloneProposal.QL_Discount_Model__c = currentProposal.QL_Discount_Model__c;//proposal 2 tier changes
                cloneProposal.QL_Actual_Estimated_Dom_QF_Market_Share__c = currentProposal.QL_Actual_Estimated_Dom_QF_Market_Share__c;//proposal 2 tier changes-CRM 5224 
                //cloneProposal.Forecast_Flight_Share__c= currentProposal.Forecast_Flight_Share__c;
                //cloneProposal.Forecast_Flight_Share_Domestic__c= currentProposal.Forecast_Flight_Share_Domestic__c;
                //cloneProposal.Forecast_Flight_Share_International__c= currentProposal.Forecast_Flight_Share_International__c;
                
               // cloneProposal.NAM_Approved1__c = currentProposal.NAM_Approved1__c;
               // cloneProposal.Pricing_Approved1__c = currentProposal.Pricing_Approved1__c;
               // cloneProposal.DO_Approved__c = currentProposal.DO_Approved__c;
               
                // Added for CRM-3513 to bypass the Expected Approval Date validation.
                cloneProposal.Expected_Approval_Date__c = Date.Today().adddays(30);
                // Added for CRM-3513 to bypass the Expected Approval Date validation.
                
                if(currentProposal.Status__c == 'Rejected - Internal' && currentProposal.Leadership_Rejected__c == true){
                    cloneProposal.Approval_Required_Others__c = true;
                }else{
                    cloneProposal.Approval_Required_Others__c = currentProposal.Approval_Required_Others__c;
                }
                /* Commented as part of iDeal 
                if(currentProposal.QIS_Rejected__c != true){
                    cloneProposal.TeamLead_Approved__c = currentProposal.TeamLead_Approved__c;
                    
                    cloneProposal.SBD_Approved__c = currentProposal.SBD_Approved__c;
                    cloneProposal.QIS_Approved__c = currentProposal.QIS_Approved__c;
                }              
                */
                if(currentProposal.Type__c == 'Qantas Business Savings'){
                    rtype = 'QBS - Draft';
                }else if(currentProposal.Type__c == 'Corporate Airfares'){
                    rtype = 'CA - Draft';
                }else if(currentProposal.Type__c == 'Adhoc'){
                    rtype = 'Adhoc Charter - Approval Required - Customer';
                }else if(currentProposal.Type__c == 'Scheduled'){
                    rtype = 'Adhoc Charter - Approval Required - Customer';
                }
                
                if(String.isNotBlank(rtype))
                    RId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get(rtype).getRecordTypeId();
                
                cloneProposal.RecordTypeId = RId;
                
                insert cloneProposal;
                if(cloneProposal.id!=null ||cloneProposal.id<>'')
                    obj.recID=cloneProposal.id;
                
                // Proposal Fare Discount creation done here
                list<Discount_List__c> createPFDiscountList = new list<Discount_List__c>();
                if(currentProposal.Fare_Structure_Lists__r.size() > 0){
                    list<Discount_List__c> existingPFDiscountList = currentProposal.Fare_Structure_Lists__r;
                    for(Discount_List__c eachPFD : existingPFDiscountList){
                        Discount_List__c propFareDisc = new Discount_List__c();
                        propFareDisc.Approval_Comment_NAM__c = eachPFD.Approval_Comment_NAM__c;
                        propFareDisc.Approval_Comment_Pricing__c = eachPFD.Approval_Comment_Pricing__c;
                        propFareDisc.FareStructure__c = eachPFD.FareStructure__c;
                        propFareDisc.Comment__c = eachPFD.Comment__c;
                        propFareDisc.Proposal__c = cloneProposal.id;
                        propFareDisc.Discount__c = eachPFD.Discount__c;
                        propFareDisc.Discount_Threshold_AM__c = eachPFD.Discount_Threshold_AM__c;
                        propFareDisc.Discount_Threshold_NAM__c = eachPFD.Discount_Threshold_NAM__c; 
                        propFareDisc.QL_Tier_1_Offering__c = eachPFD.QL_Tier_1_Offering__c; //Proposal 2 tier changes
                        // Added for CRM- 3334
                        propFareDisc.Route_Origin__c = eachPFD.Route_Origin__c;
                        propFareDisc.Route_Destination__c = eachPFD.Route_Destination__c;
                        propFareDisc.Discount_Threshold_TL__c = eachPFD.Discount_Threshold_TL__c;
                        propFareDisc.Discount_Threshold_DO__c = eachPFD.Discount_Threshold_DO__c;
                        // Added for CRM- 3334
                        // Added for CRM- 3409
                        propFareDisc.Network__c = eachPFD.Network__c;
                        propFareDisc.Segment__c = eachPFD.Segment__c;
                        propFareDisc.Category__c = eachPFD.Category__c;
                        propFareDisc.Proposal_Type__c = eachPFD.Proposal_Type__c;               
                        propFareDisc.Fare_Combination__c = eachPFD.Fare_Combination__c;      
                        propFareDisc.Qantas_Annual_Expenditures__c  =   eachPFD.Qantas_Annual_Expenditures__c;          
                        // Added for CRM- 3409
                        createPFDiscountList.add(propFareDisc);
                    }
                }
                if(!createPFDiscountList.isEmpty())        
                    insert createPFDiscountList;                            
                // Contract Payments Insert done here
                //list<Contract_Payments__c> existingCPList = new list<Contract_Payments__c>();
                if(currentProposal.Contract_Payments__r.size() > 0){
                    list<Contract_Payments__c> newCPList = new list<Contract_Payments__c>();
                    list<Contract_Payments__c> existingCPList = currentProposal.Contract_Payments__r ;
                    for(Contract_Payments__c eachCP : existingCPList){
                        Contract_Payments__c newCP = new Contract_Payments__c();
                        newCP.Amount__c = eachCP.Amount__c;
                        newCP.Paid_As__c =eachCP.Paid_As__c;
                        newCP.Payment_Criteria__c=eachCP.Payment_Criteria__c;
                        newCP.Payment_Frequency__c =eachCP.Payment_Frequency__c;   
                        newCP.Type__c=eachCP.Type__c;
                        newCP.Proposal__c = cloneProposal.Id;
                        newCPList.add(newCP);
                    }
                    if(!newCPList.isEmpty())
                        insert newCPList;                    
                }
                
                List<Business_Case__c> createBs = new List<Business_Case__c>();
                system.debug('Justifications__r'+currentProposal.Justifications__r.size());
                if(currentProposal.Justifications__r.size() > 0){
                    system.debug('Justifications__r'+currentProposal.Justifications__r);
                    //Business Case Creation
                    List<Business_Case__c> existingBs = currentProposal.Justifications__r;
                    for(Business_Case__c eachBS:existingBs ){
                        Business_Case__c businessValue = new Business_Case__c();
                        
                        businessValue.Proposal__c = cloneProposal.id;
                        businessValue.Aligned_with_EK_sales__c = eachBS.Aligned_with_EK_sales__c;
                        businessValue.Cost_of_sale_Incremental_opportunity__c = eachBS.Cost_of_sale_Incremental_opportunity__c;
                        businessValue.Current_performance_in_the_route_s__c = eachBS.Current_performance_in_the_route_s__c;
                        businessValue.What_else_have_you_considered__c = eachBS.What_else_have_you_considered__c;
                        businessValue.How_did_you_arrive_with_this_proposal__c = eachBS.How_did_you_arrive_with_this_proposal__c;
                        businessValue.Is_there_competitive_MI__c = eachBS.Is_there_competitive_MI__c;
                        businessValue.Market__c = eachBS.Market__c;
                        businessValue.Requested_routes__c = eachBS.Requested_routes__c;
                        businessValue.Supplementary_Materials_Sharepoint_Link__c =eachBS.Supplementary_Materials_Sharepoint_Link__c;
                        businessValue.What_is_the_current_booking_mix__c = eachBS.What_is_the_current_booking_mix__c;
                        
                        
                        createBs . add(businessValue);
                        
                    }
                    system.debug('Business case'+createBs);
                    if(!createBs.isEmpty())
                        insert createBs;
                }
                //Special conditions update done here
                if(currentProposal.Special_Conditions__r.size() > 0){
                    List<QEC_Special_Condition__c> splconditionList = new List<QEC_Special_Condition__c>();
                    for(QEC_Special_Condition__c eachcondition : currentProposal.Special_Conditions__r){
                        QEC_Special_Condition__c condition = new QEC_Special_Condition__c();
                        condition = eachcondition.clone(false,false,false,false);
                        condition.Proposal__c = cloneProposal.Id;
                        splconditionList.add(condition);
                    }
                    insert splconditionList;                    
                }
                
                //Contract TMC clone changes done here
                if(currentProposal.Contract_TMC_Info__r.size() > 0){
                    List<QEC_ContractTMCInfo__c> contractTMCList = new List<QEC_ContractTMCInfo__c>();
                    for(QEC_ContractTMCInfo__c eachcontractTMC : currentProposal.Contract_TMC_Info__r){
                        QEC_ContractTMCInfo__c contractTMC = new QEC_ContractTMCInfo__c();
                        contractTMC = eachcontractTMC.clone(false,false,false,false);
                        contractTMC.Proposal__c = cloneProposal.Id;
                        contractTMCList.add(contractTMC);
                    }
                    insert contractTMCList;                    
                }                
                
                
                // Charter Flight Information Update done here
                list<Charter_Flight_Information__c> newCFIList = new list<Charter_Flight_Information__c>();
                if(currentProposal.Charter_Flight_Information__r.size() > 0){
                    list<Charter_Flight_Information__c> existingCFIList = currentProposal.Charter_Flight_Information__r;
                    for(Charter_Flight_Information__c eachCFI : existingCFIList){
                        Charter_Flight_Information__c charterValue =new Charter_Flight_Information__c();
                        charterValue.Proposal__c =  cloneProposal.id;
                        charterValue.Aircraft_Type__c = eachCFI.Aircraft_Type__c;
                        charterValue.ETD__c = eachCFI.ETD__c;
                        charterValue.Flight_Date__c = eachCFI.Flight_Date__c;
                        charterValue.Flight_Number__c =eachCFI.Flight_Number__c;
                        charterValue.Seating_Space__c = eachCFI.Seating_Space__c;
                        charterValue.Sector__c = eachCFI.Sector__c;
                        newCFIList.add(charterValue);  
                    }
                    if(!newCFIList.isEmpty())
                        insert newCFIList; 
                }
                
                
                obj.isSuccess = true;
                obj.msg = 'The current Proposal has been cloned successfully';
            }
            else{
                obj.isSuccess = false;
                obj.msg = 'Error Occured';
            }
            
            return obj;
        }
        
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());    
        }
    }
    
}