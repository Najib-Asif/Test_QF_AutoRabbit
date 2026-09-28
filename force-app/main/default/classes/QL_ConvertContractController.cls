/***********************************************************************************************************************************

Description: Lightning component handler for the convert contract functionality

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam                CRM-2797    LEx-Contract Convert                                           T01
Ajay          AE - 82    to add Record Type on Contract Payments & Payments object
Created Date    : 25/09/17 (DD/MM/YYYY)
Modified Date   : 12/03/2020 (DD/MM/YYYY)
Priyadharshini Vellingiri CRM-4302
**********************************************************************************************************************************/
public with sharing class QL_ConvertContractController {
    
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    @AuraEnabled public String recID {get;set;}
    
    @AuraEnabled
    public static QL_ConvertContractController getConvertedContract(Id propId)
    {
        system.debug('proposal id'+propId);
        QL_ConvertContractController obj = new QL_ConvertContractController();
        
        try{
            Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
            String rtype = '';
            Id recId;
            list<Contract__c> existingContractList = [SELECT Id,Status__c FROM Contract__c where Proposal__c =: propId];
            system.debug('Existing Cont***'+existingContractList);
            //Validate the contract exists scenario
            if(!existingContractList.isEmpty()){
                for(Contract__c eachContract : existingContractList){
                    if(eachContract.Status__c != 'Rejected – Legal' && eachContract.Status__c != 'Rejected - Customer'){
                        obj.isSuccess = false;
                        obj.msg = 'Contract exist for this Proposal';
                        return obj;
                    }
                }    
            }
            
            Proposal__c currentProposal;
            //added special conditions to the query as part of QEC
            //CRM-4302 Aggregate Query Fix. Removed subquery/aggregate query and added query for each related object
            for (Proposal__c thisProposal : [SELECT Id,Name,Account__c,Parent_Contract_ID__c,Previous_Contract_ID__c,Commercial_TC__c,Domestic_Annual_Share__c,International_Annual_Share__c,Legal_TC__c,Opportunity__c,Contact__c,Account__r.Qantas_Corporate_Identifier__c,
                                             Qantas_Annual_Expenditure__c,Forecast_MCA_Revenue__c,QL_IsQFEKPresent__c,Status__c,Valid_From_Date__c,Valid_To_Date__c,Standard__c,Additional_Change_Details__c,Deal_Type__c,MCA_Routes_Annual_Share__c,EK_Stock__c,Group_Booking__c,
                                             Agent_Name__c,Agent_Fax__c,Agent_Email__c,Agent_Address__c,Frequent_Flyer_Status_Upgrade__c,Frequent_Flyer_Status_Upgrade_Offer__c,Qantas_Club_Discount__c,Forecast_Group_Booking_Expenditure__c,Group_Travel_Discount__c,Group_Travel_Offer__c,
                                             Qantas_Club_Join_Discount_Offer__c,Qantas_Club_Discount_Offer__c,TMC_Code__c,Travel_Fund__c,Travel_Fund_Amount__c,Type__c,Proposal_Start_Date__c,Proposal_End_Date__c,Opportunity__r.Owner.Country,Opportunity__r.Type,Opportunity__r.Sub_Type_Level_1__c,Opportunity__r.Sub_Type_Level_2__c,Opportunity__r.Category__c,
                                             AA_Joint_Customer__c,QEC_AA_Customer__c,Forecast_Flight_Share_US__c,Forecast_Flight_Share_Domestic_US__c,Forecast_Flight_Share_International_US__c,QEC_Original_Contract_Start_Date__c,QL_Discount_Model__c,QL_Includes_JQ__c,QL_Is_Locked__c,QL_Actual_Estimated_Dom_QF_Market_Share__c,Includes_R_KMLVS__c
                                             FROM Proposal__c where Active__c =true AND Status__c = 'Accepted by Customer' AND Id =: propId])
            {
                system.debug('thisProposal'+thisProposal);
                currentProposal = (thisProposal != null) ? thisProposal : null;
            }
            // Handle the Contract variation scenario   
            if(null != currentProposal && currentProposal.Opportunity__r.Type == 'Business and Government' && currentProposal . Opportunity__r.Sub_Type_Level_1__c == 'Currently In Contract' && currentProposal . Opportunity__r.Sub_Type_Level_2__c == 'Variation' && (currentProposal . Opportunity__r.Category__c == 'Corporate Airfares' || currentProposal . Opportunity__r.Category__c == 'Qantas Business Savings'))
            {
                obj.isSuccess = false;
                obj.msg = 'For Variation Type Proposals, you do not have to convert this Proposal to a Contract. Please raise your Deal Support Case on the Renewal Contract';
                return obj;
            }
            
            // Create a contract if already there is no such contract exist   
            if(currentProposal != null)
            {
                Contract__c createContract = new Contract__c();
                createContract.Name = currentProposal.Name;
                createContract.Account__c = currentProposal.Account__c;
                createContract.Parent_Contract__c = currentProposal.Parent_Contract_ID__c;
                createContract.PreviousContract__c = currentProposal.Previous_Contract_ID__c;
                createContract.Commercial_TC__c = currentProposal.Commercial_TC__c;
                createContract.Contact__c = currentProposal.Contact__c;
                createContract.Domestic_Annual_Share__c = currentProposal.Domestic_Annual_Share__c;
                createContract.International_Annual_Share__c = currentProposal.International_Annual_Share__c;
                createContract.Legal_TC__c = currentProposal.Legal_TC__c;
                createContract.Opportunity__c = currentProposal.Opportunity__c;
                createContract.Qantas_Annual_Expenditure__c = currentProposal.Qantas_Annual_Expenditure__c;
                createContract.Proposal__c = currentProposal.Id;
                createContract.Type__c = currentProposal.Type__c;
                createContract.Eligible_for_EK_ticket_stock__c = currentProposal.EK_Stock__c;
                createContract.Group_Booking__c = currentProposal.Group_Booking__c;
                createContract.Travel_Fund__c = currentProposal.Travel_Fund__c;
                createContract.Travel_Fund_Amount__c = currentProposal.Travel_Fund_Amount__c;
                createContract.Standard__c = currentProposal.Standard__c;
                createContract.Additional_Change_Details__c = currentProposal.Additional_Change_Details__c;
                createContract.Status__c = 'Signature Required by Customer';
                createContract.Deal_Type__c = currentProposal.Deal_Type__c;
                createContract.MCA_Routes_Annual_Share__c = currentProposal.MCA_Routes_Annual_Share__c;
                createContract.Agent_Name__c = currentProposal.Agent_Name__c;
                createContract.Agent_Fax__c = currentProposal.Agent_Fax__c;
                createContract.Agent_Email__c = currentProposal.Agent_Email__c;
                createContract.Agent_Address__c = currentProposal.Agent_Address__c;
                createContract.Qantas_Club_Discount__c = currentProposal.Qantas_Club_Discount__c;
                createContract.Frequent_Flyer_Status_Upgrade__c = currentProposal.Frequent_Flyer_Status_Upgrade__c;
                createContract.Frequent_Flyer_Status_Upgrade_Offer__c = currentProposal.Frequent_Flyer_Status_Upgrade_Offer__c;
                createContract.Qantas_Club_Join_Discount_Offer__c = currentProposal.Qantas_Club_Join_Discount_Offer__c;
                createContract.Qantas_Club_Discount_Offer__c = currentProposal.Qantas_Club_Discount_Offer__c;
                createContract.TMC_Code__c = currentProposal.TMC_Code__c;
                createContract.contract_Start_Date__c = currentProposal.Proposal_Start_Date__c;
                createContract.contract_End_Date__c = currentProposal.Proposal_End_Date__c; 
                createContract.Forecast_Group_Booking_Expenditure__c = currentProposal.Forecast_Group_Booking_Expenditure__c;
                createContract.Group_Travel_Discount__c = currentProposal.Group_Travel_Discount__c;
                createContract.Group_Travel_Offer__c = currentProposal.Group_Travel_Offer__c;
                createContract.AA_Joint_Customer__c= currentProposal.AA_Joint_Customer__c;
                createContract.QEC_AA_Customer__c= currentProposal.QEC_AA_Customer__c;
                createContract.QL_Discount_Model__c = currentProposal.QL_Discount_Model__c;//Proposal 2-Tier changes CRM-5209
                createContract.QL_Includes_JQ__c =currentProposal.QL_Includes_JQ__c;//Proposal 2-Tier changes CRM-5209
                createContract.QL_Actual_Estimated_Dom_QF_Market_Share__c =currentProposal.QL_Actual_Estimated_Dom_QF_Market_Share__c;//Proposal 2-Tier changes CRM-5224
                createContract.QL_Forecast_MCA_Revenue__c = currentProposal.Forecast_MCA_Revenue__c;//Proposal 2-Tier changes CRM-5343
                createContract.QL_Contract_IsQFEKPresent__c = currentProposal.QL_IsQFEKPresent__c;
                //Contract variation start date changes starts- CRM-4131
                createContract.QEC_Variation_Start_Date__c = currentProposal.Proposal_Start_Date__c;
                createContract.Includes_R_KMLVS__c = currentProposal.Includes_R_KMLVS__c;//CRM-9486
                if(currentProposal.QEC_Original_Contract_Start_Date__c <> null){
                    createContract.Contract_Start_Date__c = currentProposal.QEC_Original_Contract_Start_Date__c;
                }else{
                    createContract.Contract_Start_Date__c = currentProposal.Proposal_Start_Date__c;
                }
                //Contract variation start date changes ends- CRM-4131
                String qci = String.isBlank(currentProposal.Account__r.Qantas_Corporate_Identifier__c) ? '' : currentProposal.Account__r.Qantas_Corporate_Identifier__c;
                if(currentProposal.Opportunity__r.Owner.Country == 'AU'){
                    createContract.Ticketing_Instructions__c =Label.Ticketing_Instructions+qci+Label.Ticketing_Instructions_Merge_field;
                }
                else if(currentProposal.Opportunity__r.Owner.Country == 'US'){
                    createContract.Ticketing_Instructions__c = 
                    'QF Deal Code: '+qci+'\n\nThe 3 letter Qantas Corporate Identifier (QCI) code specified for this customer is “'+qci+'”. Per ticketing instructions and covered further in Contractual documents, the QCI must be entered into the tour code of all Private Fares and into the PNR for ALL bookings made for this customer. The below SK / OSI entries may be programmed into your booking systems by your Organization to ensure the QCI code is automatically entered into the PNR whenever a booking is made. The PNR entry must be in the exact format provided below:\n\nAmadeus: SK QCID QF-'+qci+'\nApollo: @:3OSI QF QCID.'+qci+'\nGalileo: SI.QF*QCID.'+qci+'\nSabre: 3OSI QF QCID.'+qci+'\nWorldspan: 3OSI QF QCID.'+qci+'\n\nAny ticket that is missing or has an incorrect tour code will result in the issue of an ADM.';
                }
                
                if(currentProposal.Type__c == 'Qantas Business Savings'){
                    rtype = 'QBS - Legal/Customer Pending';
                }else if(currentProposal.Type__c == 'Corporate Airfares'){
                    rtype = 'CA - Legal/Customer Pending';
                }else if(currentProposal.Type__c == 'Adhoc'){
                    rtype = 'Charters Contract - Legal/Customer Pending';
                }else if(currentProposal.Type__c == 'Scheduled'){
                    rtype = 'Charters Contract - Legal/Customer Pending';
                }
                
                if(String.isNotBlank(rtype)){
                    recId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get(rtype).getRecordTypeId();
                }
                createContract.RecordTypeId = recId;
                try{
                    insert createContract;
                }
                catch(DMLException e){
                    System.debug(e.getMessage());
                    throw new AuraHandledException(e.getMessage());  
                }
                
                currentProposal.QL_Is_Locked__c  = true; // Enabling the field to lock proposal record when converted to contract - CRM 5221
                try{
                update currentProposal;
                }
                catch(DMLException e){
                    System.debug(e.getMessage());
                    throw new AuraHandledException(e.getMessage());  
                }
                if(createContract.id!=null ||createContract.id<>''){
                    obj.recID=createContract.id;
                }
                // Contract Fare Discount creation done here
                list<Contract_Discount_List__c> createCFDiscountList = new list<Contract_Discount_List__c>();
                //CRM-4302 Aggregate Query Fix. Removed subquery/aggregate query and added query for each related object
                    for(Discount_List__c eachPFD : [SELECT Id, Proposal__c,FareStructure__c, Approval_Comment_NAM__c,Approval_Comment_Pricing__c, Comment__c, Discount__c, Discount_Threshold_AM__c, Discount_Threshold_NAM__c,Route_Origin__c,Route_Destination__c,Fare_Combination__c,Discount_Threshold_DO__c,QL_Tier_1_Offering__c FROM Discount_List__c WHERE Proposal__r.Active__c = True AND Proposal__r.Status__c = 'Accepted by Customer' AND Proposal__c= :propId AND FareStructure__r.Active__c= True]){
                        Contract_Discount_List__c contFareDisc = new Contract_Discount_List__c();
                        contFareDisc.Approval_Comment_NAM__c = eachPFD.Approval_Comment_NAM__c;
                        contFareDisc.Approval_Comment_Pricing__c = eachPFD.Approval_Comment_Pricing__c;
                        contFareDisc.FareStructure__c = eachPFD.FareStructure__c;
                        contFareDisc.Comment__c = eachPFD.Comment__c;
                        contFareDisc.Contract__c = createContract.id;
                        contFareDisc.Discount__c = eachPFD.Discount__c;
                        contFareDisc.Discount_Threshold_AM__c = eachPFD.Discount_Threshold_AM__c;
                        contFareDisc.Discount_Threshold_NAM__c = eachPFD.Discount_Threshold_NAM__c;
                        contFareDisc.Discount_Threshold_DO__c = eachPFD.Discount_Threshold_DO__c;
                        contFareDisc.Fare_Combination__c = eachPFD.Fare_Combination__c;
                        // Added for CRM - 3741
                        contFareDisc.Route_Origin__c    = eachPFD.Route_Origin__c;
                        contFareDisc.Route_Destination__c   = eachPFD.Route_Destination__c;
                        // Added for CRM - 3741
                        contFareDisc.QL_Tier_1_Offering__c  = eachPFD.QL_Tier_1_Offering__c;//Proposal 2-Tier changes CRM-5209
                        createCFDiscountList.add(contFareDisc);
                        system.debug('createCFDiscountList'+createCFDiscountList);
                    }    
                if(!createCFDiscountList.isEmpty()){        
                    insert createCFDiscountList;            
                }
                // Contract Payments Update done here
                //list<Contract_Payments__c> existingCPList = new list<Contract_Payments__c>();
                

              //CRM-4302 Aggregate Query Fix. Removed subquery/aggregate query and added query for each related object
                list<Contract_Payments__c> existingCPList = new List<Contract_Payments__c>();  
                for(Contract_Payments__c eachCP : [SELECT Id, Amount__c,Paid_As__c,Payment_Criteria__c,Payment_Frequency__c,Type__c,Proposal__c FROM Contract_Payments__c where RecordTypeId =: cpRTId AND Proposal__r.Active__c = True AND Proposal__r.Status__c = 'Accepted by Customer' AND Proposal__c= :propId]){
                        eachCP.Contract_Agreement__c = createContract.Id;
                        eachCP.Proposal__c = currentProposal.Id;
                    	existingCPList.add(eachCP);
                    }
                    update existingCPList;   

                // Special conditions Update done here
                // //CRM-4302 Aggregate Query Fix. Removed subquery/aggregate query and added query for each related object
                    List<QEC_Special_Condition__c> splconditionList = new List<QEC_Special_Condition__c>();
                    for(QEC_Special_Condition__c eachcondition : [SELECT Id, Name,Proposal__c,QEC_Baggagecode__c,QEC_BlockRevenueTarget__c,QEC_Blocksize__c,QEC_Cancellation__c,QEC_Class__c,QEC_Conditions__c,QEC_DayofWeek__c,QEC_Destination__c,QEC_Discount__c,QEC_FarebasisFarerulenumber__c,QEC_FareBasis__c,QEC_Fare__c,QEC_Flightnumber__c,
																										  QEC_FromDate__c,QEC_HourDay__c,QEC_Network__c,QEC_NoShow__c,QEC_Numberofpieces__c,QEC_Origin__c,QEC_Route__c,QEC_TimefromDeparture__c,QEC_ToDate__c,QEC_Type__c,QEC_KgPc__c FROM QEC_Special_Condition__c WHERE Proposal__r.Active__c = True AND Proposal__r.Status__c = 'Accepted by Customer' AND Proposal__c= :propId]){
                        eachcondition.contract__c = createContract.Id;
                        splconditionList.add(eachcondition);
                        system.debug('splconditionList :'+splconditionList);
                    }
                    update splconditionList;

                //Contract TMC clone changes done here
                ////CRM-4302 Aggregate Query Fix. Removed subquery/aggregate query and added query for each related object
                 List<QEC_ContractTMCInfo__c> contractTMCList = new List<QEC_ContractTMCInfo__c>();
                    for(QEC_ContractTMCInfo__c eachcontractTMC : [SELECT Id, Proposal__c, CurrencyIsoCode, TMC_Info__c FROM QEC_ContractTMCInfo__c WHERE Proposal__r.Active__c = True AND Proposal__r.Status__c = 'Accepted by Customer' AND Proposal__c= :propId]){
                        eachcontractTMC.contract__c = createContract.Id;
                        contractTMCList.add(eachcontractTMC);
                        system.debug('contractTMCList :'+contractTMCList);
                    }
                    update contractTMCList;                    

                
                // Charter Flight Information Update done here
                // //CRM-4302 Aggregate Query Fix. Removed subquery/aggregate query and added query for each related object
                 	list<Charter_Flight_Information__c> existingCFIList = new list<Charter_Flight_Information__c>();
                    for(Charter_Flight_Information__c eachCFI : [SELECT Id, Contract_Agreement__c FROM Charter_Flight_Information__c WHERE Proposal__r.Active__c = True AND Proposal__r.Status__c = 'Accepted by Customer' AND Proposal__c= :propId]){
                        eachCFI.Contract_Agreement__c = createContract.Id;
                        //eachCP.Proposal__c = currentProposal.Id;
                        existingCFIList.add(eachCFI);
                    }
                    update existingCFIList; 
                    system.debug('existingCFIList :'+existingCFIList);

                
                // Contract Attachment insert done here
                Attachment existingPropAtt;
                for(Attachment thisAttachment : [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId =: currentProposal.Id ORDER BY CreatedDate DESC LIMIT 1]){
                    existingPropAtt = (thisAttachment != null) ? thisAttachment : null;      
                }
                
                if(existingPropAtt != null)
                {
                    Attachment createContrAtt = new Attachment();
                    createContrAtt.ParentId = createContract.Id;
                    createContrAtt.Body = existingPropAtt.Body;
                    createContrAtt.Name = existingPropAtt.Name;
                    insert createContrAtt; 
                }
				// Fare Rules added here only for 'US' CRM-4135
                if(currentProposal.Opportunity__r.Owner.Country  == 'US')
                {
                    List<QEC_Rule__c> lstQRG = new List<QEC_Rule__c>();
                    
                    for(QEC_Rule_Guidelines__c objQRG : [select id, Deal_Type__c, Location__c , Market_Segment__c, Sequence_Number__c, 
                                                         Name, Text__c, Recommended__c,Duplicate_Check__c from QEC_Rule_Guidelines__c where 
                                                         Location__c =: currentProposal.Opportunity__r.Owner.Country and Recommended__c = true
                                                         order by Sequence_Number__c asc])
                    {
                        lstQRG.add(new QEC_Rule__c(Description__c = objQRG.Text__c,
                                                   Name = objQRG.Name,
                                                   Sequence_Number__c = objQRG.Sequence_Number__c,
                                                   Recommended__c = objQRG.Recommended__c,
                                                   Deal_Type__c = objQRG.Deal_Type__c,
                                                   Location__c = objQRG.Location__c,
                                                   Market_Segment__c = objQRG.Market_Segment__c,
                                                   Contract__c = createContract.Id));
                    }
                    //system.debug('lstQRG:'+lstQRG);
                    //system.debug('currentProposal:'+currentProposal);                
                    insert lstQRG;
                }

                obj.isSuccess = true;
                obj.msg = 'The current Proposal is converted to Contract : '+ createContract.Name;
            }
            else{
                obj.isSuccess = false;
                obj.msg = Label.Convert_Contract_Error;
            }
            return obj;
        }
        
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());    
        }
    }
}