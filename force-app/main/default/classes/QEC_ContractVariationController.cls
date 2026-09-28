/***********************************************************************************************************************************

Description: Lightning component handler for the contract variation/renewal functionality

History:
======================================================================================================================
Name                    Jira                Description                                     Tag
======================================================================================================================
Pushkar Purushothaman   EXPRCON-38/116      Contract Variation & Renewal                    T01
Created Date    : 02/09/2019 (DD/MM/YYYY)

***********************************************************************************************************************/

public without sharing class QEC_ContractVariationController {
    @AuraEnabled public String recID {get;set;}
    @AuraEnabled public String error {get;set;}
    //method to create variation proposal on discount line changes and renewal proposal
    @AuraEnabled
    public static QEC_ContractVariationController variationProposal(String recordId, Boolean renewal){
        System.Savepoint sp = Database.setSavepoint();
        QEC_ContractVariationController obj = new QEC_ContractVariationController();
        try{
            Opportunity renewalOppty = new Opportunity();
            Contract__c contract = [SELECT id,Parent_Contract__c,PreviousContract__c,Account__c,Active__c,Additional_Change_Details__c,Agent_Address__c,
                                    Agent_Email__c,Agent_Fax__c,Agent_Name__c,Approval_Status__c,
                                    Approval_Submission_Date__c,Approved_Rejected_Date__c,Changes_in_Legal_T_Cs__c,
                                    Charter_Price__c,Comments__c,Commercial_TC__c,Contact_Information__c,Contact__c,
                                    CurrencyIsoCode,Deal_Type__c,Description__c,Domestic_Annual_Share__c,
                                    Forecast_Charter_Spend__c,Forecast_Group_Booking_Expenditure__c,
                                    Frequent_Flyer_Status_Upgrade_Offer__c,Frequent_Flyer_Status_Upgrade__c,
                                    Group_Travel_Offer__c,International_Annual_Share__c,Legal_Approval__c,
                                    Legal_TC__c,Link_to_the_Sharepoint_document__c,MCA_Routes_Annual_Share__c,Name,
                                    Opportunity__c,Opportunity__r.OwnerId,Qantas_Annual_Expenditure__c,QL_Forecast_MCA_Revenue__c,QL_Contract_IsQFEKPresent__c,Qantas_Club_Discount_Offer__c,
                                    Qantas_Club_Discount__c,Qantas_Club_Join_Discount_Offer__c,Standard__c,Status__c,
                                    TMC_Code__c,Travel_Fund_Amount__c,Travel_Fund__c,Type__c,Valid_From_Date__c,
                                    Value_Adds__c,Value_Add_Reasons__c,contract_Start_Date__c,contract_End_Date__c,Eligible_for_EK_ticket_stock__c,Group_Booking__c,
                                    AA_Joint_Customer__c,Forecast_Flight_Share_US__c,Forecast_Flight_Share_Domestic_US__c,Forecast_Flight_Share_International_US__c,QL_Discount_Model__c,QL_Actual_Estimated_Dom_QF_Market_Share__c
                                    FROM Contract__c WHERE Id =: recordId];
            
            if(renewal){
                Opportunity opp = [SELECT AccountId,Accounting_Remarks__c,Accounting__c,Account_Name_Expected_Closure_Date__c,Agency_Proposed_Market_Share__c,
                                   Amount,Assumed_Tag_Rate_at_Maturity__c,At_Risk_Since__c,AutorabitExtId__c,Auto_Create_Oppty_for_Con_renewal__c,Average_Spend_Per_Customer__c,Baseline_Close_Date__c,
                                   Baseline_Market_Share__c,Baseline_QF_Spend__c,Baseline_Start_Date__c,Baseline_Total_Air_Spend__c,Baseline_Total_Revenue__c,Bureaux__c,CampaignId,Campaign_Market_Share__c,
                                   Campaign_QF_Revenue__c,Campaign_Total_Revenue__c,Carbon_Offset_Projects__c,Category__c,CloseDate,Closed_Date_for_Reports__c,Closed_Reasons__c,Competitor_Contract__c,Contact_Information__c,
                                   Contact__c,Contract__c,CreatedById,CreatedDate,CurrencyIsoCode,Current_Contracted_Cost_of_Sale_Percent__c,Current_Contracted_Cost_of_Sale__c,Current_Market_Share_Int__c,Current_Market_Share__c,
                                   Current_Required_Actions__c,Current_Revenue_IPR__c,Current_Revenue_Other_sources__c,Current_Revenue_Total__c,Current_Revenue__c,Current_Status__c,Customer_Base__c,Deal_Type__c,Description,DOM_Market_Share_Trend__c,
                                   EnquiryType__c,Estimated_Current_Market_Share__c,Estimated_Current_Revenue__c,Estimated_Increment_Market_Share__c,Estimated_Increment_Revenue__c,Expected_Amount_Technical__c,Expected_Closure_Month__c,Expected_Closure_Year__c,
                                   Fiscal,FiscalQuarter,FiscalYear,ForecastCategory,ForecastCategoryName,Forecast_Charter_Spend__c,Forecast_MCA_Revenue__c,Freight_Actual_Shipment_Date__c,Freight_Aircraft_Type__c,Freight_AWB_Number__c,
                                   Freight_AWB_Received__c,Freight_Capacity_Forecast__c,Freight_Days_Since_Last_Created_Activity__c,Freight_First_Shipment_Propose_Date__c,Freight_Frequency__c,Freight_Last_Activity_Created_Date_Oppty__c,Freight_Opportunity_Name_Account_Name__c,
                                   Freight_Quote_Count__c,Freight_Shipping__c,Global_Opportunity__c,Gross_Margin__c,HasOpenActivity,HasOpportunityLineItem,HasOverdueTask,Id,Implications__c,Incremental_DOM_Market_Share__c,Incremental_INT_Market_Share__c,Incremental_INT_MCA_Market_Share__c,
                                   Incremental_Market_Share__c,Incremental_Revenue_Amount__c,Incremental_Revenue__c,Increment_Mrkt_Share_Indicator__c,Increment_Revenue_Indicator__c,Industry__c,Insurance_Remarks__c,Insurance__c,INT_Market_Share_Trend__c,INT_MCA_Market_Share_Trend__c,IsClosed,IsDeleted,
                                   IsExcludedFromTerritory2Filter,IsWon,Is_Amount_Calculated__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LeadSource,Legal_Remarks__c,Legal__c,Low_Points_Price_Justification__c,Market_Share_Source__c,Migrated__c,Minimum_Spend_Commitment__c,
                                   Name,NextStep,No_of_Contracts__c,Number_of_Days_Since_Last_Activity__c,Number_of_Opportunities__c,Number_of_Proposals__c,Open_skies_policy__c,Opportunity_Creator__c,Opportunity_Type_Reporting__c,Opportunity_Type_System__c,Opp_update_counter__c,Other_reasons__c,Overdue_Opportunity__c,
                                   OwnerId,Partnership_type__c,PartnerType__c,Partner_Value__c,Part_of_Corporate_Deal__c,Points_Per__c,Precedent__c,Previous_Stage__c,Pricebook2Id,Price_Per_Point__c,Probability,Program_Fee__c,Projected_Billing_This_FY_Text__c,Projected_Billing_This_FY__c,Proposed_Contracted_Cost_of_Sale_Percent__c,
                                   Proposed_Contracted_Cost_of_Sale__c,Proposed_DOM_Revenue_Amount__c,Proposed_International_Market_Share__c,Proposed_INT_Revenue_Amount__c,Proposed_Market_Share_Int__c,Proposed_Market_Share__c,Proposed_MCA_Routes_Market_Share__c,Proposed_Summary__c,Proposed_Term_of_Agreement__c,PushCount__c,QDMEstimated_DOM_QF_Market_Share__c,
                                   QDMEstimated_DOM_QF_Revenue__c,QDMEstimated_INT_MCA_Routes_Market_Shar__c,QDMEstimated_INT_QF_Market_Share__c,QDMEstimated_INT_QF_Revenue__c,QDMEstimated_QF_Revenue__c,Ramp_up_factor__c,Reason_At_Risk__c,RecordTypeId,Related_Registry_ID__c,Revenue_Trend_URL__c,Revenue_Trend__c,
                                   RFP_Process__c,RFP_RFT__c,RFP_Submission_Date__c,Risk_Indicator__c,Risk_Level__c,Senior_Executive_Action__c,StageName,Stakeholders__c,Status__c,Sub_Type_Level_1__c,Sub_Type_Level_2__c,Sub_Type_Level_3__c,Sub_Type_Loyalty__c,Switching_to_a_competitor__c,SyncedQuoteId,SystemModstamp,Tax_Remarks__c,Tax__c,Territory2Id,Total_Points__c,
                                   Total_Program_Amount__c,Total_Revenue_Amount__c,Treasury_Remarks__c,Treasury__c,Turnover__c,Type,Variance_Market_Share__c,Variance_QF_Revenue__c,Volume_Deal__c,
                                   Forecast_Flight_Share__c,Forecast_Flight_Share_Domestic__c,Forecast_Flight_Share_International__c
                                   FROM Opportunity
                                   WHERE Id =:contract.Opportunity__c];
                
                renewalOppty = opp.clone(false,false,false,false);
                renewalOppty.Name = 'Renewal - '+renewalOppty.Name+' - to be Amended*';
                renewalOppty.StageName = 'Propose & Negotiate';
                renewalOppty.Sub_Type_Level_1__c = 'Currently In Contract';
                renewalOppty.Sub_Type_Level_2__c = 'Renewal';
                renewalOppty.Sub_Type_Level_3__c ='Single POS';
                renewalOppty.OwnerId = UserInfo.getUserId();
                renewalOppty.CloseDate = Date.today().addDays(30);
                try{
                    insert renewalOppty;
                }
                catch(DmlException e) {
                    obj.error = e.getMessage();
                    System.debug('The following exception has occurred inserting renewal oppty: ' + e.getMessage());
                }
                
            }

            if(!renewal && contract.Opportunity__r.OwnerId != UserInfo.getUserId()){
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.UserId = UserInfo.getUserId();
                otm.TeamMemberRole = 'Account Manager';
                otm.OpportunityAccessLevel = 'Edit';
                otm.OpportunityId = contract.Opportunity__c;
                insert otm;
            }
            
            //Proposal created from contract details
            
            Proposal__c currentProposal = new Proposal__c();
            currentProposal.Account__c =  contract.Account__c;
            currentProposal.Active__c  =  true;
            currentProposal.Additional_Change_Details__c  =  contract.Additional_Change_Details__c;
            currentProposal.Changes_in_Legal_T_Cs__c  =  contract.Changes_in_Legal_T_Cs__c;
            currentProposal.Charter_Price__c  =  contract.Charter_Price__c;
            currentProposal.Comments__c  =  contract.Comments__c;
            currentProposal.Commercial_TC__c =  contract.Commercial_TC__c;
            currentProposal.Contact_Information__c =  contract.Contact_Information__c;
            currentProposal.Contact__c  =  contract.Contact__c;
            currentProposal.Deal_Type__c =  contract.Deal_Type__c;
            currentProposal.Description__c =  contract.Description__c;
            currentProposal.Domestic_Annual_Share__c =  contract.Domestic_Annual_Share__c;
            currentProposal.Expected_Approval_Date__c = null;
            currentProposal.Forecast_Charter_Spend__c =  contract.Forecast_Charter_Spend__c;
            currentProposal.Forecast_Group_Booking_Expenditure__c =  contract.Forecast_Group_Booking_Expenditure__c;
            currentProposal.Frequent_Flyer_Status_Upgrade_Offer__c =  contract.Frequent_Flyer_Status_Upgrade_Offer__c;
            currentProposal.Frequent_Flyer_Status_Upgrade__c =  contract.Frequent_Flyer_Status_Upgrade__c;
            currentProposal.Group_Travel_Offer__c  =  contract.Group_Travel_Offer__c;
            currentProposal.International_Annual_Share__c =  contract.International_Annual_Share__c;
            currentProposal.Legal_Approval__c =  contract.Legal_Approval__c;
            currentProposal.Legal_TC__c =  contract.Legal_TC__c;
            currentProposal.Link_to_the_Sharepoint_document__c =  contract.Link_to_the_Sharepoint_document__c;
            currentProposal.MCA_Routes_Annual_Share__c =  contract.MCA_Routes_Annual_Share__c;
            currentProposal.Name  =  (renewal)?'Renewal - '+contract.Name:'Variation - '+contract.Name;
            currentProposal.Opportunity__c  =  (renewal)?renewalOppty.Id:contract.Opportunity__c;
            currentProposal.Parent_Contract_ID__c = (contract.Parent_Contract__c == null)?contract.Id:contract.Parent_Contract__c;
            currentProposal.Previous_Contract_ID__c = contract.id;
            currentProposal.Qantas_Annual_Expenditure__c  =  contract.Qantas_Annual_Expenditure__c;
            currentProposal.Qantas_Club_Discount__c =  contract.Qantas_Club_Discount__c;
            currentProposal.Qantas_Club_Join_Discount_Offer__c =  contract.Qantas_Club_Join_Discount_Offer__c=='38%'?'0%':contract.Qantas_Club_Join_Discount_Offer__c;
            currentProposal.QL_Discount_Model__c =contract.QL_Discount_Model__c;//proposal 2 Tier changes
            currentProposal.QL_Actual_Estimated_Dom_QF_Market_Share__c =contract.QL_Actual_Estimated_Dom_QF_Market_Share__c;//proposal 2 Tier changes- CRM 5224
            currentProposal.Forecast_MCA_Revenue__c = contract.QL_Forecast_MCA_Revenue__c;//proposal 2 Tier changes- CRM 5343
            currentProposal.QL_IsQFEKPresent__c= contract.QL_Contract_IsQFEKPresent__c;
            if(contract.Qantas_Club_Discount_Offer__c =='22%')
            {
            currentProposal.Qantas_Club_Discount_Offer__c = '20%';
            }
            else if(contract.Qantas_Club_Discount_Offer__c =='23%')
            {
            currentProposal.Qantas_Club_Discount_Offer__c = '25%';
            }
            else if(contract.Qantas_Club_Discount_Offer__c =='29%')
            {
            currentProposal.Qantas_Club_Discount_Offer__c = '30%';
            }
            else
            {
            currentProposal.Qantas_Club_Discount_Offer__c=contract.Qantas_Club_Discount_Offer__c;
            }
            if(contract.Type__c == 'Corporate Airfares')
                currentProposal.RecordTypeId =  Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Corporate_Airfares').getRecordTypeId();
            else if(contract.Type__c == 'Qantas Business Savings')
                currentProposal.RecordTypeId =  Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Qantas_Business_Savings').getRecordTypeId();
            currentProposal.Standard__c =  contract.Standard__c;
            currentProposal.Status__c  =  'Draft';
            currentProposal.TMC_Code__c  =  null;
            currentProposal.Travel_Fund_Amount__c =  contract.Travel_Fund_Amount__c;
            currentProposal.Travel_Fund__c =  contract.Travel_Fund__c;
            currentProposal.Type__c  =  contract.Type__c;
            currentProposal.Proposal_Start_Date__c  =  contract.contract_Start_Date__c;
            currentProposal.Proposal_End_Date__c  =  contract.contract_End_Date__c;
            currentProposal.Value_Adds__c  =  contract.Value_Adds__c;
            currentProposal.Value_Add_Reasons__c =  contract.Value_Add_Reasons__c;
            currentProposal.EK_Stock__c =  contract.Eligible_for_EK_ticket_stock__c;
            currentProposal.Group_Booking__c =  contract.Group_Booking__c;
            currentProposal.AA_Joint_Customer__c= contract.AA_Joint_Customer__c;
            //currentProposal.Forecast_Flight_Share__c= contract.Forecast_Flight_Share__c;
            //currentProposal.Forecast_Flight_Share_Domestic__c= contract.Forecast_Flight_Share_Domestic__c;
            //currentProposal.Forecast_Flight_Share_International__c= contract.Forecast_Flight_Share_International__c;
                
            try{
                if((renewal && renewalOppty.Id != null) || renewal == false){
                    if(currentProposal.Name.length()>80){
                       obj.error = 'Your current contract name is too long to proceed, please shorten it and try again.';//CRM-8170
                    }else{
                    insert currentProposal;
                        }
                }    
            }
            catch(DmlException e) {
                obj.error = e.getMessage();
                Database.rollback(sp);
                System.debug('The following exception has occurred inserting variation proposal: ' + e.getMessage());
            }
            
            obj.recID = currentProposal.Id;
            
            if(currentProposal.Id != null){
                // Proposal fare discount created from contract fare discounts and associated to cloned proposal
            
                list<Discount_List__c> propDiscountList = new list<Discount_List__c>();
                for(Contract_Discount_List__c eachCFD : [SELECT id,Approval_Comment_NAM__c,Approval_Comment_Pricing__c,FareStructure__c,Comment__c,Discount__c,Discount_Threshold_AM__c,Discount_Threshold_NAM__c,Discount_Threshold_DO__c,Fare_Structure_Segment__c,Fare_Structure_Market__c,Fare_Structure_Market_Category__c,Contract__r.Type__c,Fare_Combination__c,Network__c,QL_Tier_1_Offering__c 
                                                        FROM Contract_Discount_List__c 
                                                        WHERE Contract__c =:recordId and FareStructure__r.Active__c = true]){
                                                            Discount_List__c propFareDisc = new Discount_List__c();
                                                            propFareDisc.Approval_Comment_NAM__c = eachCFD.Approval_Comment_NAM__c;
                                                            propFareDisc.Approval_Comment_Pricing__c = eachCFD.Approval_Comment_Pricing__c;
                                                            propFareDisc.FareStructure__c = eachCFD.FareStructure__c;
                                                            propFareDisc.Comment__c = eachCFD.Comment__c;
                                                            propFareDisc.Proposal__c = currentProposal.id;
                                                            propFareDisc.Discount__c = eachCFD.Discount__c;
                                                            propFareDisc.Discount_Threshold_AM__c = eachCFD.Discount_Threshold_AM__c;
                                                            propFareDisc.Discount_Threshold_NAM__c = eachCFD.Discount_Threshold_NAM__c;
                                                            propFareDisc.Discount_Threshold_DO__c = eachCFD.Discount_Threshold_DO__c;
                                                            propFareDisc.Segment__c = eachCFD.Fare_Structure_Segment__c;
                                                            propFareDisc.Category__c = eachCFD.Fare_Structure_Market_Category__c;
                                                            propFareDisc.Proposal_Type__c = eachCFD.Contract__r.Type__c;
                                                            propFareDisc.Fare_Combination__c = eachCFD.Fare_Combination__c;
                                                            propFareDisc.Network__c = eachCFD.Network__c;
                                                            propFareDisc.QL_Tier_1_Offering__c =eachCFD.QL_Tier_1_Offering__c;//proposal 2 Tier changes
                                                            propDiscountList.add(propFareDisc);
                                                        }
                
                
                if(!propDiscountList.isEmpty()){ 
                    try{
                        insert propDiscountList;
                    }   
                    catch(DmlException e) {
                        obj.error = e.getMessage();
                        System.debug('The following exception has occurred inserting variation proposal discount list: ' + e.getMessage());
                    }       
                    
                }
                
                // Contract payments cloned from contract and associated to cloned proposal
                
                List<Contract_Payments__c> existingCPList = new List<Contract_Payments__c>();
                Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
                for(Contract_Payments__c eachCP : [SELECT Id, Amount__c,Paid_As__c,Payment_Criteria__c,Payment_Frequency__c,Type__c,Contract_Agreement__c 
                                                FROM Contract_Payments__c 
                                                WHERE Contract_Agreement__c =:recordId AND RecordTypeId =:cpRTId]){
                                                    Contract_Payments__c contractPay = new Contract_Payments__c();
                                                    contractPay = eachCP.clone(false,false,false,false);
                                                    contractPay.Proposal__c = currentProposal.Id;
                                                    existingCPList.add(contractPay);
                                                }
                
                if(!existingCPList.isEmpty()){
                    try{
                        insert existingCPList;
                    }
                    catch(DmlException e) {
                        obj.error = e.getMessage();
                        System.debug('The following exception has occurred inserting variation proposal contract payment: ' + e.getMessage());
                    }
                    
                }    
                
                // Special conditions cloned from contract and associated to cloned proposal
                
                List<QEC_Special_Condition__c> splconditionList = new List<QEC_Special_Condition__c>();
                for(QEC_Special_Condition__c eachcondition : [SELECT Id,Active__c,Name,Proposal__c,Contract__c,QEC_Baggagecode__c,QEC_BlockRevenueTarget__c,QEC_Blocksize__c,QEC_Booking_Class__c,QEC_Cabin__c,QEC_Cancellation__c,QEC_Class__c,QEC_Conditions__c,
                                                            QEC_DayofWeek__c,QEC_Destination__c,QEC_Discount__c,QEC_FarebasisFarerulenumber__c,QEC_FareBasis__c,QEC_Fare_Type__c,QEC_Fare__c,QEC_Flightnumber__c,QEC_FromDate__c,QEC_History__c,QEC_HourDay__c,QEC_KgPc__c,QEC_Network__c,QEC_NoShow__c,QEC_Numberofpieces__c,QEC_Origin__c,QEC_Route__c,QEC_TimefromDeparture__c,QEC_ToDate__c,QEC_Type__c 
                                                            FROM QEC_Special_Condition__c 
                                                            WHERE Contract__c =:recordId]){
                                                                QEC_Special_Condition__c condition = new QEC_Special_Condition__c();
                                                                condition = eachcondition.clone(false,false,false,false);
                                                                condition.Proposal__c = currentProposal.Id;
                                                                condition.Contract__c = null;
                                                                condition.QEC_History__c = true;
                                                                splconditionList.add(condition);
                                                            }
                
                if(!splconditionList.isEmpty()){
                    try{
                        insert splconditionList;
                    }
                    catch(DmlException e) {
                        obj.error = e.getMessage();
                        System.debug('The following exception has occurred inserting variation proposal special condition: ' + e.getMessage());
                    }
                    
                } 
                
                // Contract TMC Info cloned from contract and associated to cloned proposal
                
                List<QEC_ContractTMCInfo__c> contractTMCList = new List<QEC_ContractTMCInfo__c>();
                for(QEC_ContractTMCInfo__c eachcontractTMC : [SELECT Id, Contract__c,Proposal__c,TMC_Info__c,History__c,PCC_Start_Date__c,PCC_End_Date__c 
                                                            FROM QEC_ContractTMCInfo__c 
                                                            WHERE Contract__c =:recordId]){
                                                                QEC_ContractTMCInfo__c tmcInfo = new QEC_ContractTMCInfo__c();
                                                                tmcInfo = eachcontractTMC.clone(false,false,false,false);
                                                                tmcInfo.Proposal__c = currentProposal.Id;
                                                                tmcInfo.Contract__c = null; //CRM-7181
                                                                contractTMCList.add(tmcInfo);
                                                            }
                
                if(!contractTMCList.isEmpty()){
                    try{
                        insert contractTMCList;
                    }
                    catch(DmlException e) {
                        obj.error = e.getMessage();
                        System.debug('The following exception has occurred inserting variation proposal tmc info: ' + e.getMessage());
                    }
                    
                }
            }
                               
        }
        catch(Exception e) {
            obj.error = e.getMessage();
            System.debug('An exception occurred in variationProposal method: ' + e.getMessage());
        }
        
        return obj;
    }
    
    //method to create child contract on special condition change
    @AuraEnabled
    public static QEC_ContractVariationController childContractClone(String recordId){
        
        QEC_ContractVariationController obj = new QEC_ContractVariationController();
        try{
            
            Contract__c contract = [SELECT id,Parent_Contract__c,Proposal__c,Account__c,Active__c,Additional_Change_Details__c,Agent_Address__c,
                                    Agent_Email__c,Agent_Fax__c,Agent_Name__c,Approval_Status__c,
                                    Approval_Submission_Date__c,Approved_Rejected_Date__c,Changes_in_Legal_T_Cs__c,
                                    Charter_Price__c,Comments__c,Commercial_TC__c,Contact_Information__c,Contact__c,
                                    CurrencyIsoCode,Deal_Type__c,Description__c,Domestic_Annual_Share__c,
                                    Forecast_Charter_Spend__c,Forecast_Group_Booking_Expenditure__c,
                                    Frequent_Flyer_Status_Upgrade_Offer__c,Frequent_Flyer_Status_Upgrade__c,
                                    Group_Travel_Offer__c,International_Annual_Share__c,Legal_Approval__c,
                                    Legal_TC__c,Link_to_the_Sharepoint_document__c,MCA_Routes_Annual_Share__c,Name,
                                    Opportunity__c,Opportunity__r.OwnerId,PreviousContract__c,Qantas_Annual_Expenditure__c,Qantas_Club_Discount_Offer__c,
                                    Qantas_Club_Discount__c,Qantas_Club_Join_Discount_Offer__c,Standard__c,Status__c,
                                    TMC_Code__c,Travel_Fund_Amount__c,Travel_Fund__c,Type__c,Valid_From_Date__c,Ticketing_Instructions__c,Agent_Override__c,
                                    Value_Adds__c,Value_Add_Reasons__c,contract_Start_Date__c,contract_End_Date__c,Eligible_for_EK_ticket_stock__c,Group_Booking__c,
                                    AA_Joint_Customer__c, Forecast_Flight_Share_US__c,Forecast_Flight_Share_Domestic_US__c,Forecast_Flight_Share_International_US__c,QL_Discount_Model__c,QL_Actual_Estimated_Dom_QF_Market_Share__c
                                    FROM Contract__c 
                                    WHERE Id =: recordId];
            
            
            // Child contract cloned from parent
            
            Contract__c childContract = new Contract__c();
            childContract = contract.clone(false,false,false,false);
            childContract.Status__c = 'Draft';
            childContract.Name = 'Variation - '+contract.Name;
            childContract.Active__c = false;
            childContract.PreviousContract__c = contract.id;
            childContract.Parent_Contract__c = (contract.Parent_Contract__c == null)?contract.Id:contract.Parent_Contract__c;
            childContract.TMC_Code__c = null;
            if(contract.Type__c == 'Corporate Airfares')
                childContract.RecordTypeId =  Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('CA_Contract_Variation').getRecordTypeId();
            else if(contract.Type__c == 'Qantas Business Savings')
                childContract.RecordTypeId =  Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('QBS_Contract_Variation').getRecordTypeId();
            try{
                insert childContract;
            }
            catch(DmlException e) {
                obj.error = e.getMessage();
                System.debug('The following exception has occurred inserting variation contract: ' + e.getMessage());
            }
            
            obj.recID = childContract.Id;

            if(contract.Opportunity__r.OwnerId != UserInfo.getUserId()){
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.UserId = UserInfo.getUserId();
                otm.TeamMemberRole = 'Account Manager';
                otm.OpportunityAccessLevel = 'Edit';
                otm.OpportunityId = contract.Opportunity__c;
                insert otm;
            }
            
            if(childContract.Id != null){
                // Special Conditions cloned from parent contract and associated to child contract
            
                List<QEC_Special_Condition__c> splconditionList = new List<QEC_Special_Condition__c>();
                for(QEC_Special_Condition__c eachcondition : [SELECT Id,Active__c,Name,Proposal__c,Contract__c,QEC_Baggagecode__c,QEC_BlockRevenueTarget__c,QEC_Blocksize__c,QEC_Booking_Class__c,QEC_Cabin__c,QEC_Cancellation__c,QEC_Class__c,QEC_Conditions__c,
                                                            QEC_DayofWeek__c,QEC_Destination__c,QEC_Discount__c,QEC_FarebasisFarerulenumber__c,QEC_FareBasis__c,QEC_Fare_Type__c,QEC_Fare__c,QEC_Flightnumber__c,QEC_FromDate__c,QEC_History__c,QEC_HourDay__c,QEC_KgPc__c,QEC_Network__c,QEC_NoShow__c,QEC_Numberofpieces__c,QEC_Origin__c,QEC_Route__c,QEC_TimefromDeparture__c,QEC_ToDate__c,QEC_Type__c 
                                                            FROM QEC_Special_Condition__c 
                                                            WHERE Contract__c =:recordId]){
                                                                QEC_Special_Condition__c condition = new QEC_Special_Condition__c();
                                                                condition = eachcondition.clone(false,false,false,false);
                                                                condition.Contract__c = childContract.Id;
                                                                condition.QEC_History__c = true;
                                                                splconditionList.add(condition);
                                                            }
                
                if(!splconditionList.isEmpty()){
                    try{
                        insert splconditionList;
                    }
                    catch(DmlException e) {
                        obj.error = e.getMessage();
                        System.debug('The following exception has occurred inserting variation proposal special conditions: ' + e.getMessage());
                    }
                    
                }
                
                // Contract TMC Info cloned from parent contract and associated to child contract
                
                List<QEC_ContractTMCInfo__c> contractTMCInfo = new List<QEC_ContractTMCInfo__c>();
                for(QEC_ContractTMCInfo__c eachTMCInfo : [SELECT Id, Contract__c,Proposal__c,TMC_Info__c,History__c,PCC_Start_Date__c,PCC_End_Date__c 
                                                        FROM QEC_ContractTMCInfo__c 
                                                        WHERE Contract__c = :recordId]){
                                                            QEC_ContractTMCInfo__c tmcInfo = new QEC_ContractTMCInfo__c();
                                                            tmcInfo = eachTMCInfo.clone(false,false,false,false);
                                                            tmcInfo.Contract__c = childContract.Id;
                                                            contractTMCInfo.add(tmcInfo);
                                                        }
                
                if(!contractTMCInfo.isEmpty()){
                    try{
                        insert contractTMCInfo;
                    }
                    catch(DmlException e) {
                        obj.error = e.getMessage();
                        System.debug('The following exception has occurred inserting variation contract tmc info: ' + e.getMessage());
                    }
                    
                }
                
                // Contract Payments cloned from parent contract and associated to child contract
                
                List<Contract_Payments__c> contractPayments = new List<Contract_Payments__c>();
                Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
                for(Contract_Payments__c eachCP : [SELECT Id, Amount__c,Paid_As__c,Payment_Criteria__c,Payment_Frequency__c,Type__c,Contract_Agreement__c 
                                                FROM Contract_Payments__c 
                                                WHERE Contract_Agreement__c = :recordId AND RecordTypeId =:cpRTId]){
                                                    Contract_Payments__c contractPay = new Contract_Payments__c();
                                                    contractPay = eachCP.clone(false,false,false,false);
                                                    contractPay.Contract_Agreement__c = childContract.Id;
                                                    contractPayments.add(contractPay);
                                                }
                
                if(!contractPayments.isEmpty()){
                    try{
                        insert contractPayments;
                    }
                    catch(DmlException e) {
                        obj.error = e.getMessage();
                        System.debug('The following exception has occurred inserting variation contract payments: ' + e.getMessage());
                    }
                    
                }
                
                // Contract Discount List cloned from parent contract and associated to child contract
                
                List<Contract_Discount_List__c> contractDiscLists = new List<Contract_Discount_List__c>();
                for(Contract_Discount_List__c eachCDL : [SELECT id,Approval_Comment_NAM__c,Approval_Comment_Pricing__c,FareStructure__c,Comment__c,Discount__c,Discount_Threshold_AM__c,Discount_Threshold_NAM__c 
                                                        FROM Contract_Discount_List__c 
                                                        WHERE Contract__c = :recordId and FareStructure__r.Active__c = true]){
                                                            Contract_Discount_List__c contractDisc = new Contract_Discount_List__c();
                                                            contractDisc = eachCDL.clone(false,false,false,false);
                                                            contractDisc.Contract__c = childContract.Id;
                                                            contractDiscLists.add(contractDisc);
                                                        }
                
                if(!contractDiscLists.isEmpty()){
                    try{
                        insert contractDiscLists;
                    }
                    catch(DmlException e) {
                        obj.error = e.getMessage();
                        System.debug('The following exception has occurred inserting variation contract discount list: ' + e.getMessage());
                    }
                    
                }
            }
            
            
        }
        catch(Exception e) {
            obj.error = e.getMessage();
            System.debug('An exception occurred childContractClone method: ' + e.getMessage());    
        }
        
        return obj;
        
    }
}