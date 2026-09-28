/***********************************************************************************************************************************

Description: Apex controller for Proposal Health Indicator Lightning component

History:
======================================================================================================================
Name                    Jira        Description                                                          Tag
======================================================================================================================
Yuvaraj MV               			Apex controller for Proposal Health Indicator Lightning component    T01
Ajay					AE - 82		to add Record Type on Contract Payments & Payments object

Created Date    :         21/07/2018 (DD/MM/YYYY)
**********************************************************************************************************************************/

public class QL_ProposalHealthIndicatorController 
{
    // Ajay : added for JIRA : AE - 82
    public static Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();    
    // Ajay : ended   
    @AuraEnabled
    public static String proposalComputePercentage(String recordId,String sObjectName)
    {
        String proposalHealth = '';
        String finproposalHealth='';
        Integer discList=0;
        string proposalType='';
        string strfreqFlyStatUpOff='';
        string strgrpTravelOffer='';
        string strContractPay='';
        string strqClubDisc='';
        Boolean boolActive=false;
        Integer noofqfeknotexists=0;
        Integer noofqfekexists=0;
        Integer qClubDisc=0;
        Integer freqFlyStatUpOff=0;
        Integer grpTravelOffer=0;
        Integer contractPayment=0;
        Integer businessCase=0;
        Integer contractExist=0;
        Integer active=0;
        Decimal NumofGreen =0.0;
        Decimal NumofRed = 0.0;
        List<Proposal__c> propToUpd = new List<Proposal__c>();
        
        system.debug('recordId:'+recordId);
        
        Proposal__c proposal = [Select Account__c,Account__r.BillingCountry,QL_IsQFEKPresent__c,Forecast_MCA_Revenue__c,Active__c, Type__c, Approval_Status__c,Qantas_Club_Discount__c, Frequent_Flyer_Status_Upgrade__c, Frequent_Flyer_Status_Upgrade_Offer__c, Group_Travel_Offer__c, Travel_Fund__c,Mandate_Business_Case__c,QL_QF_EK_Network_Override__c
                                from proposal__c where id=:recordId];
        system.debug('proposal:'+proposal);
         
        
        List<Discount_List__c> lstDiscList = New List<Discount_List__c>();
        lstDiscList = [select Id,Approval_Required_NAM__c,Approval_Required_Pricing__c,Approval_Required_DO__c,Segment__c,QL_QF_EK_Fare_Structure__c,Network__c from Discount_List__c where proposal__c=:recordId];
        system.debug('lstDiscList:'+lstDiscList);
        
        //Param 1 if Proposal is Active?
        boolActive = proposal.Active__c;
        if(boolActive==true)
            active = 1;
        else
            active = 0;
        
        //Param 2 if Discount list is available - Min rowcount >= 1
        //EK Changes CRM-5393
        if (lstDiscList.size() > 0 ){  
            for(Discount_List__c dlint:lstDiscList){
                if( dlint.Segment__c=='International' && proposal.Account__r.BillingCountry=='AU'){             
                    if((proposal.Forecast_MCA_Revenue__c>=100000 ||proposal.Forecast_MCA_Revenue__c<=100000) && dlint.QL_QF_EK_Fare_Structure__c!='QF-EK' && (proposal.QL_QF_EK_Network_Override__c == False ||proposal.QL_QF_EK_Network_Override__c == True) && dlint.Network__c == 'Non-MCA'){//CRM-8086
                        system.debug('Inside if'+dlint.QL_QF_EK_Fare_Structure__c);
                        noofqfeknotexists= noofqfeknotexists + 1 ;
                        
                    }
                    if((proposal.Forecast_MCA_Revenue__c>=100000 ||proposal.Forecast_MCA_Revenue__c<=100000)  && (dlint.QL_QF_EK_Fare_Structure__c=='QF' || dlint.QL_QF_EK_Fare_Structure__c=='QF-EK') &&  (proposal.QL_QF_EK_Network_Override__c == False ||proposal.QL_QF_EK_Network_Override__c == True)  && dlint.Network__c == 'MCA'){//CRM-8086
                        system.debug('Inside if'+dlint.QL_QF_EK_Fare_Structure__c);
                        noofqfekexists= noofqfekexists + 1 ;
                    }
                    if(proposal.Forecast_MCA_Revenue__c<100000 && dlint.QL_QF_EK_Fare_Structure__c=='QF-EK'){
                        system.debug('Inside if'+dlint.QL_QF_EK_Fare_Structure__c);
                        proposal.QL_IsQFEKPresent__c= True;  //CRM-5258 - Capturing this field for deal support case
                        
                    }
                }
              
            }              
            if(((proposal.Forecast_MCA_Revenue__c>=100000 || proposal.Forecast_MCA_Revenue__c<=100000) && noofqfeknotexists > 0 && noofqfekexists == 0 ) || ((proposal.Forecast_MCA_Revenue__c>=100000 || proposal.Forecast_MCA_Revenue__c<=100000) && noofqfeknotexists == 0 && noofqfekexists == 0))//CRM-8086
            { 
                discList=0;
                NumofRed = NumofRed + 1; 
                // proposal.Mandate_Business_Case__c = True;                
            }
            else{
                discList=1; 
                NumofGreen = NumofGreen + 1 ;                
            }
        }                                 
        else{
            discList=0;
            NumofRed = NumofRed + 1;
        } 
        
        //Param 3 type of proposal - Qantas Business Savings or Corporate Airfares
        proposalType = proposal.Type__c;    

        //Param 4 frequent flyer status update - Yes or No
        strfreqFlyStatUpOff = proposal.Frequent_Flyer_Status_Upgrade__c;
        system.debug('strfreqFlyStatUpOff:'+strfreqFlyStatUpOff);
        If (strfreqFlyStatUpOff =='Yes')
        {
            freqFlyStatUpOff=1; 
            NumofGreen = NumofGreen + 1 ;
        }
        Else if(strfreqFlyStatUpOff =='No')
            freqFlyStatUpOff=2; 
        Else 
            freqFlyStatUpOff=2; 
        system.debug('freqFlyStatUpOff:'+freqFlyStatUpOff);
        
        //Param 5 group travel offer - Yes or No
        strgrpTravelOffer = proposal.Group_Travel_Offer__c;
        if(strgrpTravelOffer == 'Yes'){
            grpTravelOffer=1;
            NumofGreen = NumofGreen + 1 ;
        }
        Else if(strgrpTravelOffer =='No')
            grpTravelOffer=2;
        Else
            grpTravelOffer=2;
        system.debug('grpTravelOffer:'+grpTravelOffer);
        
        //Param 6 Contract payment - Yes or No
        strContractPay = proposal.Travel_Fund__c;
        If(strContractPay == 'Yes')
        {
            // Ajay : added for JIRA : AE - 82
            List<Contract_Payments__c> existContracts = [SELECT Id FROM Contract_Payments__c where Proposal__c =: recordId AND RecordTypeId =: cpRTId];
            // Ajay : ended
            
            //If Contract exists
            If(existContracts.size()>0)
            {
                contractExist=1;
                contractPayment=1;
                NumofGreen = NumofGreen + 1;
            }
            Else 
            {
                contractExist=0;
                contractPayment=0;
                NumofRed = NumofRed + 1;
            }  
        }
        Else if (strContractPay == 'No')
            contractPayment=2;
        Else 
            contractPayment=2;
        system.debug('contractPayment********'+contractPayment);
        
        //Param 7 If Business Case exists
        List<Business_Case__c> existBussCase = [SELECT Id FROM Business_Case__c where Proposal__c =: recordId];
        //If(existBussCase.Size()>0 ){
        If(existBussCase.Size() == 0){
            businessCase=2;
            system.debug('inside Mandate business check');
            proposal . Mandate_Business_Case__c = False;
        }   
        else{
            businessCase=1;
            NumofGreen = NumofGreen + 1 ;
            proposal . Mandate_Business_Case__c = False;
        }
        If(lstDiscList.size()>0){       
            for(Discount_List__c dl:lstDiscList){                    
                   if(dl.Approval_Required_NAM__c != false || dl.Approval_Required_Pricing__c != false || dl.Approval_Required_DO__c!=false){
                    If(existBussCase.Size()>0){
                        system.debug('inside Mandate business check1');
                        businessCase=1;
                        NumofGreen = NumofGreen + 1 ;
                        proposal.Mandate_Business_Case__c = False;
                    }
                    else
                    {
                        businessCase=0;
                        proposal.Mandate_Business_Case__c = True;
                        //NumofRed = NumofRed + 1;
                        system.debug('inside Mandate business check222');
                    }
                }                
              
            }
            if(proposal.Forecast_MCA_Revenue__c>=100000 && noofqfeknotexists > 0 && noofqfekexists == 0){ // Bug Fix - CRM 5488
                 proposal.Mandate_Business_Case__c = True;                
            }
            
            If ( businessCase == 0){
                NumofRed = NumofRed + 1;
                proposal.Mandate_Business_Case__c = True;
                system.debug('inside Mandate business check333');
            }
        }
        //Added for CRM-3487
        propToUpd.add(proposal);
        
        //Param 8 Qantas Club discount
        strqClubDisc = proposal.Qantas_Club_Discount__c;
        if(strqClubDisc=='Yes'){
            NumofGreen = NumofGreen + 1 ;
            qClubDisc=1;
        }
        Else if(strqClubDisc=='No')
            qClubDisc=2;
        else
            qClubDisc=2;
        
        If(proposalType=='Qantas Business Savings')
        {
            // double tempValue = active + discList + freqFlyStatUpOff + grpTravelOffer + contractPayment + businessCase + qClubDisc;
            // system.debug('tempValue:'+ tempValue);
            system.debug('NumofGreen******'+NumofGreen);
            system.debug('NumofRed******'+NumofRed);
            double tempValue1=((NumofGreen)/(NumofGreen+NumofRed))*100;
            system.debug('tempValue1:'+ tempValue1);
            proposalHealth=String.valueOf(tempValue1);
            //proposalHealth = String.valueOf(Math.round((discList + freqFlyStatUpOff + grpTravelOffer + contractPayment)/4 * 100));
            finproposalHealth = proposalHealth+'*'+string.valueOf(active)+'*'+String.valueOf(discList)+'*'+String.valueOf(freqFlyStatUpOff)+'*'+strfreqFlyStatUpOff+'*'+String.valueOf(grpTravelOffer)+'*'+strgrpTravelOffer+'*'+String.valueOf(contractPayment)+'*'+strContractPay+'*'+String.valueOf(contractExist)+'*'+String.valueOf(businessCase)+'*'+String.valueOf(qClubDisc)+'*'+strqClubDisc+'*'+proposalType;
            system.debug('proposal . Mandate_Business_Case__c'+proposal . Mandate_Business_Case__c);
        }
        
        Else If (proposalType=='Corporate Airfares')
        {
            //double tempValue = active + discList + freqFlyStatUpOff + grpTravelOffer + contractPayment + businessCase + qClubDisc;
            // system.debug('tempValue:'+ tempValue);
            system.debug('NumofGreen******'+NumofGreen);
            system.debug('NumofRed******'+NumofRed);
            double tempValue1=((NumofGreen)/(NumofGreen+NumofRed))*100;
            system.debug('tempValue1:'+ tempValue1);
            proposalHealth=String.valueOf(tempValue1);
            //proposalHealth = String.valueOf(Math.round((discList + freqFlyStatUpOff + grpTravelOffer + contractPayment + contractExist + businessCase)/6 * 100));
            finproposalHealth = proposalHealth+'*'+string.valueOf(active)+'*'+String.valueOf(discList)+'*'+String.valueOf(freqFlyStatUpOff)+'*'+strfreqFlyStatUpOff+'*'+String.valueOf(grpTravelOffer)+'*'+strgrpTravelOffer+'*'+String.valueOf(contractPayment)+'*'+strContractPay+'*'+String.valueOf(contractExist)+'*'+String.valueOf(businessCase)+'*'+String.valueOf(qClubDisc)+'*'+strqClubDisc+'*'+proposalType;
            system.debug('proposal . Mandate_Business_Case__c*****'+proposal . Mandate_Business_Case__c);
        }
        //Added for CRM-3487
        if(propToUpd.size()>0 && proposal.Approval_Status__c== 'Not Required')
            update propToUpd; 
        system.debug('finproposalHealth:'+ finproposalHealth);
        return finproposalHealth;
    }
}