//Test class: Case_controller_test - code coverage 78%
//Added Error Msg for Freight MBG checklist record - CRM 10831
public class Case_Controller {
    
    public static final String FREIGHT_MBG_ERROR_MSG = 'MBG Checklist should be checked to close the case.';
    @AuraEnabled
    public static String getProfileName(){
       return [Select profile.Name from User where Id=:UserInfo.getUserId()].Profile.Name;
    }
        
    @AuraEnabled
    public static List<Frequent_Flyer_Information__c> getFFInfo(Id caseId){
        
        return [Select id, Name, Frequent_Flyer_Number__c, Freq_Flyer_Expiry_Date__c, Upgrade_Tier_Requested__c, Request_Type__c from Frequent_Flyer_Information__c
               where Case__c = :caseId];  
    }
    
    @AuraEnabled
    public static String updateCaseValidation(String caseId, String status){
        system.debug('Got the params from LWC ----- caseId : '+caseId+' , status : '+status);
        try{
            
            List<Case_Checklist_Info__c> casechecklist = [ Select id,OTF__c, Number_and_Weight_of_Affected_Pieces__c,
                      Reason_for_Lodgment__c,Copy_of_Airway_Bill__c,Copy_of_House_Airway_Bill__c,
                      Intent_to_Claim_Acknowledgement_Receipt__c,
                      Destruction_Certificate__c,Invoice_and_or_Packing_List__c,Evidence_of_Attempts_on_Mitigate_losses__c,
                      Repair_Quotation__c,Subrogation_Letter__c,Loss_Adjustor_Marine_Surveyor_s_Report__c,MBG_Checklist__c,Rejected__c,
                      RecordType.DeveloperName, createdDate from Case_Checklist_Info__c 
                      where Case__c = :caseId order by createdDate desc];
            
            
            Case c = [SELECT Id, AccountId,Status, Type, Sub_Type_1__c, Sub_Type_2__c,Freight_AWB_Number__c,Freight_Port__c,Freight_Shipment__c,Claim_Stage__c,
                      Product__c,Freight_Resolve_Reason__c,RecordType.DeveloperName
                      FROM Case 
                      WHERE Id = :caseId LIMIT 1];
            
            Boolean isAWBMandatory = false;
            String errorMessage = '';
            
            if(status=='Closed'){
                
                if(c.Status=='Closed'){
                    errorMessage += 'The case is already closed';
                    return errorMessage;
                 }
                  //trigger validation when type=special moves and OTF is madatory while closing case CRM-9763
                  if (!casechecklist.isEmpty() && casechecklist[0].RecordType.DeveloperName == 'Freight_Special_Moves') {
                        system.debug('No OTF ------');
                      Case_Checklist_Info__c caselist= casechecklist[0];
                       if (( caselist.OTF__c == False) && c.Type =='Special Moves' ) {
                       errorMessage += 'OTF is required .\n';
                      }    
                    }
        system.debug('casechecklist---'+casechecklist);
        if (!casechecklist.isEmpty() && casechecklist[0].RecordType.DeveloperName == 'Freight_Claims'){
                      Case_Checklist_Info__c caselist= casechecklist[0];
                      if (c.Type =='Claims' && c.Freight_Shipment__c=='International' && (c.Sub_Type_2__c =='Formal Claim' && c.Claim_Stage__c !='with Customer')&&(caselist.Number_and_Weight_of_Affected_Pieces__c == 'Requested' || caselist.Reason_for_Lodgment__c == 'Requested' || caselist.Copy_of_Airway_Bill__c == 'Requested' || caselist.Copy_of_House_Airway_Bill__c == 'Requested' || caselist.Intent_to_Claim_Acknowledgement_Receipt__c == 'Requested' || caselist.Destruction_Certificate__c	 == 'Requested' || caselist.Invoice_and_or_Packing_List__c == 'Requested' || caselist.Evidence_of_Attempts_on_Mitigate_losses__c	 == 'Requested'|| caselist.Repair_Quotation__c == 'Requested' || caselist.Subrogation_Letter__c == 'Requested'|| caselist.Loss_Adjustor_Marine_Surveyor_s_Report__c == 'Requested' || caselist.Subrogation_Letter__c == 'Requested'))  
                      {      
                       errorMessage += 'Please update the Freight checklist fields to a value other than Requested before saving the record\n';
                    }
                        
                    }
                
                 if (!casechecklist.isEmpty() && casechecklist[0].RecordType.DeveloperName == 'Freight_MBG') { // CRM-10831
                        Case_Checklist_Info__c caselist= casechecklist[0];
                       if (( caselist.MBG_Checklist__c == False && caselist.Rejected__c== False)) { // CRM-12151 added Rejected condition
                        errorMessage += FREIGHT_MBG_ERROR_MSG;
                      }    
                    }
                      
                
                if(!(c.Type=='Invalid Case' || c.Freight_Resolve_Reason__c=='Duplicate Case')){
                    // Ensure Type field is populated
                    if (String.isBlank(c.Type)) {
                        errorMessage += 'The Type field is mandatory.\n';
                    }
                    if (String.isBlank(c.AccountId)) {
                        errorMessage += 'Account is required.\n';
                    }
                  
                    
                    if(String.isNotBlank(c.Type) && String.isNotBlank(c.Sub_Type_1__c)){
                        
                        //For Booking Type
                        if(c.Type=='Booking'){
                            List<String> subType2List = new List<String>{'Amendments','Cancelled','Confirmed','Pre-Alert','Status','Booked'};
                            if(String.isNotBlank(c.Sub_Type_2__c) && subType2List.contains(c.Sub_Type_2__c)){
                                isAWBMandatory = true;
                            }
                        }
                        
                        //For Claims Type
                        if(c.Type=='Claims'){
                            List<String> subType1List = new List<String>{'Animal','Damaged','Delay','Missing','Lost Documents','MBG'};
                            List<String> subType2List = new List<String>{'Formal Claim','Intent to Claim'};
                            if(String.isNotBlank(c.Sub_Type_1__c) && subType1List.contains(c.Sub_Type_1__c)){
                                if(String.isNotBlank(c.Sub_Type_2__c) && subType2List.contains(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }else if(String.isBlank(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }
                            } 
                        }
                        
                        //For Customer Query Type
                        if(c.Type=='Customer Query'){
                            List<String> subType1List = new List<String>{'Customs','Damaged','Documentation','Tracking'};
                            List<String> subType2List = new List<String>{'Reporting Issues','Status','Formal Claim','Intent to Claim','Amendments','Data capture',
                                                        'Mapping','Missing','Check-in Status','Delivery','On-carriage','Storage Location','Uplift Status'};
                            if(String.isNotBlank(c.Sub_Type_1__c) && subType1List.contains(c.Sub_Type_1__c)){
                                if(String.isNotBlank(c.Sub_Type_2__c) && subType2List.contains(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }else if(String.isBlank(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }
                            }
                        }
                        
                        //For Disruption Type
                        if(c.Type=='Disruption'){
                            List<String> subType1List = new List<String>{'Damaged','Dangerous Goods Rejected','DIM Restriction','Downgrade','Flight Cancellation',
                                                            'Flight Delay','Flight Diverted','Missed Connection','Missed Cutoff','Offload','Terminal Error',
                                                            'Weight Restriction','Unable to locate freight.','Capacity','Failed uplift','No attempt to get uploaded'};
                            List<String> subType2List = new List<String>{'Formal Claim','Intent to Claim'};
                            if(String.isNotBlank(c.Sub_Type_1__c) && subType1List.contains(c.Sub_Type_1__c)){
                                if(String.isNotBlank(c.Sub_Type_2__c) && subType2List.contains(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }else if(String.isBlank(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }
                            }
                        }
                        
                        //For Export Moves and Special Moves Types
                        if(c.Type=='Export Moves' || c.Type=='Special Moves'){
                            List<String> subType1List = new List<String>{'AVI','Firearms',' Human Remains'};
                            List<String> subType2List = new List<String>{'Booked','OK to Forward','OK to transit'};
                            if(String.isNotBlank(c.Sub_Type_1__c) && subType1List.contains(c.Sub_Type_1__c)){
                                if(String.isNotBlank(c.Sub_Type_2__c) && subType2List.contains(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }else if(String.isBlank(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }
                            }
                        }
                        
                        //For NCR Type
                        if(c.Type=='NCR'){
                            List<String> subType1List = new List<String>{'Damaged'};
                            List<String> subType2List = new List<String>{'Formal Claim','Intent to Claim'};
                            if(String.isNotBlank(c.Sub_Type_1__c) && subType1List.contains(c.Sub_Type_1__c)){
                                if(String.isNotBlank(c.Sub_Type_2__c) && subType2List.contains(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }else if(String.isBlank(c.Sub_Type_2__c)){
                                    isAWBMandatory = true;
                                }
                            }
                        }
                    }
                    
                    system.debug('Is AWB Manadtory----'+isAWBMandatory);
                    // Additional logic for checking RecordType and AWB field
                    if (isAWBMandatory && c.RecordType.DeveloperName.contains('Freight')
                        && String.isBlank(c.Freight_AWB_Number__c)
                        && (String.isBlank(c.Freight_Port__c) || String.isBlank(c.Product__c))) {
                        errorMessage += 'The AWB field is mandatory. Please enter AWB number\n or Port, Product and Commodity fields to proceed\n';
                    }
                    // If there are validation errors, return the error message
                    if (String.isNotBlank(errorMessage)) {
                        return errorMessage.trim();
                    }
                }
            }
                

            // Close the Case if no errors
            c.Status = status;
            try{
                update c;
            }
            catch(DMLException e){
                String errorMsg = e.getMessage();
                if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                   errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                }
               return errorMsg.trim();
            }
            
            return 'Success'; // Indicate successful closure
        }
        catch (Exception e) {
            // Log the error and return a friendly message
           throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
        
    }

}