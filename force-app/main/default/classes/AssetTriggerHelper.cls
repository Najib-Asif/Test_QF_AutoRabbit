/*----------------------------------------------------------------------------------------------------------------------
Author:        Benazir Amir/Praveen Sampath 
Company:       Capgemini
Description:   Class to be invoked from Asset Trigger
Inputs:        
Test Class:    AssetTriggerHelperTest. 
************************************************************************************************
History     Refactored the code to remove system debug and commented code that is not required
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
public class AssetTriggerHelper{

    /*--------------------------------------------------------------------------------------      
    Method Name:        calculateAssetFeesandDiscounts
    Description:        corporate scheme field updates with published rates and applied discounts
    Parameter:           new Map and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void convertingAssetType(Map<Id,Asset> newAssetMap, map<Id,Asset> oldAssetMap){
        try{
            //Get record type and published fees from custom settings
            String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
            Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName );
            String publicSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Public Scheme Rec Type');
            Id publicSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', publicSchemeRecTypeName );
            
            Map<Id, Id> accOwnerMap = new Map<Id, Id>();
            Set<Id> setAccId = new Set<Id>();
            for(Asset objAsset: newAssetMap.values()){
                if(objAsset.RecordtypeId == corpSchemeRecTypeId && objAsset.RecordtypeId != oldAssetMap.get(objAsset.Id).RecordtypeId){
                    setAccId.add(objAsset.AccountId);
                }
            }
            
            //Get Corp account Owner Id
            for(Account acc: [Select Id, OwnerId from Account where Id IN: setAccId]){
                accOwnerMap.put(acc.Id, acc.OwnerId);
            }

            for(Asset objAsset: newAssetMap.values()){
                Asset objOldAsset = oldAssetMap.get(objAsset.Id);
                if(objAsset.RecordtypeId != objOldAsset.RecordtypeId){
                    if(objAsset.RecordtypeId == corpSchemeRecTypeId){
                        AssetObjectHelper.convertPublicSchmeToCorporateSchemeUI(objAsset, accOwnerMap.containsKey(objAsset.AccountId)?accOwnerMap.get(objAsset.AccountId):Null);
                    }else if(objAsset.RecordtypeId == publicSchemeRecTypeId){
                        AssetObjectHelper.convertCorporateSchmeToPublicSchemeUI(objAsset);
                    }
                }
            }
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Asset Triggers - Loyalty', 'AssetTriggerHelper', 
                                     'convertingAssetType', String.valueOf(''), String.valueOf(''),false,'', ex);
        
        }

    }
   
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        calculateAssetFeesandDiscounts
    Description:        corporate scheme field updates with published rates and applied discounts
    Parameter:          List of new and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void calculateAssetFeesandDiscounts(List<Asset> newAssetList, map<Id,Asset> oldAssetMap){
        try{
            //Get record type and published fees from custom settings
            String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
            Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName );
            String publicSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Public Scheme Rec Type');
            Id publicSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', publicSchemeRecTypeName );
            
            //Scheme Fees Metadata 
            Map<String, SchemeFees__c> mapSchemeFee = new Map<String, SchemeFees__c>();
            for(SchemeFees__c  fee: SchemeFees__c.getall().values() ){
                mapSchemeFee.put(fee.Currency__c+''+fee.Scheme_Type__c, fee);
            }
            
            for(Asset objAsset: newAssetList){
                //Old Asset values 
                Asset objOldAsset  = oldAssetMap != Null? oldAssetMap.get(objAsset.Id): Null;
                Boolean isValid = false;

                //Check Old Map and New Map, To find it is a Valid Update to recalculate
                if(objAsset.Batch_Run__c){
                    isValid = true;
                }else if(objOldAsset == Null){
                    isValid = true;
                }
                else if(objOldAsset != Null){
                    List<Schema.FieldSetMember> lstAssetFields = SObjectType.Asset.FieldSets.Scheme_Fee_Fields.getFields();
                    for(Schema.FieldSetMember assetField: lstAssetFields){
                        if(objAsset.get(assetField.getFieldPath()) != objOldAsset.get(assetField.getFieldPath())){
                            isValid = true;
                            break;
                        }
                    }
                }

                  
                if(isValid && (objAsset.RecordTypeId == publicSchemeRecTypeId || objAsset.RecordTypeId == corpSchemeRecTypeId))
                {
                    
                    //Get GST % from custom setting
                    objAsset.Applied_GST__c = Double.valueOf(CustomSettingsUtilities.getConfigDataMap('GST Rate '+objAsset.Scheme_Currency__c));
                    string selectedCurrency = (objAsset.Scheme_Currency__c == 'AUD') || (objAsset.Scheme_Currency__c == 'NZD') ? objAsset.Scheme_Currency__c : '000'; 
                    objAsset.CurrencyIsoCode = objAsset.Scheme_Currency__c;

                    //Get Scheme Base on Currency and Scheme Type
                    SchemeFees__c currentScheme =  mapSchemeFee.containsKey(selectedCurrency+''+objAsset.Scheme_Discount_Type__c)?mapSchemeFee.get(selectedCurrency+''+objAsset.Scheme_Discount_Type__c):Null;
                    
                    if(currentScheme != Null){
                        system.debug('currentScheme########'+currentScheme);
                         //Get Join Discount and Fee Discount percent
                        Decimal feeDiscount = 0;
                        Decimal joiningDiscount = 0;
                        //Adding Flat Disount for Public Scheme CRM-10572
                        if(objAsset.RecordTypeId == publicSchemeRecTypeId )
                        {
                         feeDiscount =  Double.valueOf(CustomSettingsUtilities.getConfigDataMap('Public Scheme Discount Rate'));
                         joiningDiscount = Double.valueOf(CustomSettingsUtilities.getConfigDataMap('Public Scheme Joining Discount Rate'));
                        }
                        else
                        {
                        if(objAsset.Override_Waiver_Discounts_Active__c == true){
                            feeDiscount = objAsset.Member_Fee_Discount__c == Null?0 :objAsset.Member_Fee_Discount__c;
                            joiningDiscount = objAsset.Qantas_Club_Join_Discount__c == Null?0 :objAsset.Qantas_Club_Join_Discount__c;
                        }else{
                            feeDiscount = objAsset.Qantas_Club_Member_Discount_Offer__c == Null?0 :objAsset.Qantas_Club_Member_Discount_Offer__c;
                            joiningDiscount = objAsset.Qantas_Club_Join_Discount_Offer__c == Null?0 :objAsset.Qantas_Club_Join_Discount_Offer__c;
                            
                        }
                        }
                        
                        
                        Integer roundOffNumber = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('SchemesPointRoundOffNumber'));
                        
                        //Don't Calculate Point and Fee when Override is true
                        if(objAsset.Override_Fees_Calculation__c != true){
                            objAsset.Join_Fee_Gross__c = currentScheme.Published_Join_Fee__c *((100-joiningDiscount)/100);
                            Integer joinPoints = Integer.valueOf(currentScheme.Join_Fee_Points__c *((100-joiningDiscount)/100));
                            objAsset.Join_Fee_Points__c = roundOffNumber*Math.round((joinPoints/roundOffNumber));
                            
                            objAsset.X1_Year_Membership_Fee_Gross__c = currentScheme.Published_1_Year_Membership_Fee__c *((100-feeDiscount)/100);
                            Integer oneYRPoints = Integer.valueOf(currentScheme.X1_Year_Membership_Fee_Points__c *((100-feeDiscount)/100));
                            objAsset.X1_Year_Membership_Fee_Points__c = roundOffNumber*Math.round((oneYRPoints/roundOffNumber));

                            objAsset.X2_Year_Membership_Fee_Gross__c = currentScheme.Published_2_Year_Membership_Fee__c *((100-feeDiscount)/100);
                            Integer twoYRPoints = Integer.valueOf(currentScheme.X2_Year_Membership_Fee_points__c *((100-feeDiscount)/100)); 
                            objAsset.X2_Year_Membership_Fee_Points__c = roundOffNumber*Math.round((twoYRPoints/roundOffNumber));
                            
                            objAsset.X1_Year_Membership_Renewal_Fee__c =  currentScheme.X1_Year_Membership_Renewal_Fee_Published__c*((100-feeDiscount)/100);
                            Integer oneYRRenewalPoints = Integer.valueOf(currentscheme.X1_Yr_Mship_Renewal_Fee_Points_Published__c*((100-feeDiscount)/100));
                            objAsset.X1_Year_Membership_Renewal_Fee_Points__c = roundOffNumber*Math.round((oneYRRenewalPoints/roundOffNumber));
                            
                           
                            objAsset.X2_Year_Membership_Renewal_Fee__c =  currentScheme.X2_Year_Membership_Renewal_Fee_Published__c*((100-feeDiscount)/100);
                            Integer twoYRRenewalPoints = Integer.valueOf(currentscheme.X2_Yr_Mship_Renewal_Fee_Points_Published__c*((100-feeDiscount)/100));
                            objAsset.X2_Year_Membership_Renewal_Fee_Points__c = roundOffNumber*Math.round((twoYRRenewalPoints/roundOffNumber));
                     
                        }

                        //All Join Fee Calculation
                        objAsset.Join_Fee_Published__c = currentScheme.Published_Join_Fee__c;
                        objAsset.Join_Fee_GST__c = currentScheme.Join_Fee_Exculde_GST__c || objAsset.Join_Fee_Gross__c == Null? 0 :objAsset.Applied_GST__c*(objAsset.Join_Fee_Gross__c  /(100.0+objAsset.Applied_GST__c));
                        objAsset.Join_Fee_Points_Published__c = currentScheme.Join_Fee_Points__c;
                        
                        //All First Year Calculation
                        objAsset.X1_Year_Membership_Fee_Published__c = currentScheme.Published_1_Year_Membership_Fee__c;
                        objAsset.X1_Year_Membership_Fee_GST__c = currentScheme.Membership_Fee_Exclude_GST__c || objAsset.X1_Year_Membership_Fee_Gross__c == Null? 0 :objAsset.Applied_GST__c*(objAsset.X1_Year_Membership_Fee_Gross__c  /(100.0+objAsset.Applied_GST__c));
                        objAsset.X1_Year_Membership_Fee_Points_Published__c = currentScheme.X1_Year_Membership_Fee_Points__c;
                        objAsset.X1_Year_Membership_Renewal_Fee_Published__c = currentScheme.X1_Year_Membership_Renewal_Fee_Published__c;
                        objAsset.X1_Yr_Mship_Renewal_Fee_Points_Published__c = currentScheme.X1_Yr_Mship_Renewal_Fee_Points_Published__c;
                        objAsset.X1_Year_Membership_Renewal_Fee_GST__c =  currentScheme.Membership_Fee_Exclude_GST__c || objAsset.X1_Year_Membership_Renewal_Fee__c == Null? 0 :objAsset.Applied_GST__c*(objAsset.X1_Year_Membership_Renewal_Fee__c/(100.0+objAsset.Applied_GST__c));
                        //All Secound year Calculation
                        objAsset.X2_Year_Membership_Fee_Published__c = currentScheme.Published_2_Year_Membership_Fee__c;
                        objAsset.X2_Year_Membership_Fee_GST__c = currentScheme.Membership_Fee_Exclude_GST__c || objAsset.X2_Year_Membership_Fee_Gross__c == Null? 0 :objAsset.Applied_GST__c*(objAsset.X2_Year_Membership_Fee_Gross__c  /(100.0+objAsset.Applied_GST__c));
                        objAsset.X2_Year_Membership_Fee_Points_Published__c = currentScheme.X2_Year_Membership_Fee_points__c;
                        objAsset.X2_Year_Membership_Renewal_Fee_Published__c = currentScheme.X2_Year_Membership_Renewal_Fee_Published__c;
                        objAsset.X2_Yr_Mship_Renewal_Fee_Points_Published__c = currentScheme.X2_Yr_Mship_Renewal_Fee_Points_Published__c;
                        objAsset.X2_Year_Membership_Renewal_Fee_GST__c =  currentScheme.Membership_Fee_Exclude_GST__c || objAsset.X2_Year_Membership_Renewal_Fee__c == Null? 0 :objAsset.Applied_GST__c*(objAsset.X2_Year_Membership_Renewal_Fee__c/(100.0+objAsset.Applied_GST__c));
                       
              
                    }
                }


                //Back to false after Batch Run
                if(objAsset.Batch_Run__c){
                    objAsset.Batch_Run__c = false;
                }
            }
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Asset Triggers - Loyalty', 'AssetTriggerHelper', 
                                     'calculateAssetFeesandDiscounts', String.valueOf(''), String.valueOf(''),false,'', ex);
        }   
    }
    
   /*--------------------------------------------------------------------------------------      
    Method Name:        calculateFourthYearMembership
    Description:        All Fourth year Calculation. Only for Public Scheme - Commented for CRM- 10164
    
    --------------------------------------------------------------------------------------*/
    
   /* Public static void calculateFourthYearMembership (Asset objAsset, SchemeFees__c currentScheme, Decimal roundOffNumber, Decimal feeDiscount ){
      if( currentScheme.Published_4_Year_Membership_Fee__c != Null){
            objAsset.X4_Year_Membership_Fee_Published__c =currentScheme.Published_4_Year_Membership_Fee__c;
            objAsset.X4_Year_Membership_Fee_Gross__c = currentScheme.Published_4_Year_Membership_Fee__c *((100-feeDiscount)/100);
            objAsset.X4_Year_Membership_Fee_GST__c = currentScheme.Membership_Fee_Exclude_GST__c? 0 :objAsset.Applied_GST__c*(objAsset.X4_Year_Membership_Fee_Gross__c  /(100.0+objAsset.Applied_GST__c));
        }
        if(currentScheme.Published_4_Year_Membership_Fee_Points__c != Null ){
            objAsset.X4_Year_Membership_Fee_Points_Published__c = currentScheme.Published_4_Year_Membership_Fee_Points__c;
            Integer fourYRPoints = Integer.valueOf(currentScheme.Published_4_Year_Membership_Fee_Points__c*((100-feeDiscount)/100));
            objAsset.X4_Year_Membership_Fee_Points__c = roundOffNumber*Math.round((fourYRPoints/roundOffNumber));
        }
    
    }*/
}