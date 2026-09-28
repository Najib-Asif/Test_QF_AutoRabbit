/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath 
Company:       Capgemini
Description:   This is the Helper class for Asset object.
               This Helper class will hold any Generic functionlities related to Asset object
Inputs:        
Test Class:     
************************************************************************************************
History
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
public class AssetObjectHelper {
    
    /*--------------------------------------------------------------------------------------      
Method Name:        convertCorporateSchmeToPublicScheme
Description:        Generic Method to blank Corp Scheme fields and populate Public Scheme field
                    Invoked from batch
Parameter:          Asset object and recordtype Id
--------------------------------------------------------------------------------------*/      
    public static Asset convertCorporateSchmeToPublicScheme( Asset objAsset, Id publicSchemeRecTypeId ){
        if(objAsset != Null){
            objAsset.RecordtypeId = publicSchemeRecTypeId;
            objAsset = convertCorporateSchmeToPublicSchemeUI(objAsset);
        }
        return objAsset;
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        convertCorporateSchmeToPublicSchemeUI
Description:        Generic Method to blank Corp Scheme fields and populate Public Scheme field
Parameter:          Asset object
--------------------------------------------------------------------------------------*/      
    public static Asset convertCorporateSchmeToPublicSchemeUI( Asset objAsset ){
        if(objAsset != Null){
            objAsset.Contract__c  = Null;
            objAsset.Public_Scheme_Start_Date__c = objAsset.Scheme_Start_Date_f__c;
            objAsset.Public_Scheme_End_Date__c = system.today().addYears(3);
            objAsset.Scheme_Cost_Center__c = 'Public';
            objAsset.Override_Fees_Calculation__c = False;
            objAsset.Waiver_Start_Date__c = Null;
            objAsset.Waiver_End_Date__c = Null;
            objAsset.Qantas_Club_Join_Discount__c = Null;
            objAsset.Member_Fee_Discount__c = Null;
            objAsset.SchemeConversionDate__c = system.today();
        }
        return objAsset;
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        convertPublicSchmeToCorporateSchemeUI
Description:        Generic Method to blank Public Scheme fields and populate Corp Scheme field
Parameter:          Asset object and Account owner id
--------------------------------------------------------------------------------------*/      
    public static Asset convertPublicSchmeToCorporateSchemeUI( Asset objAsset, Id ownerId ){
        if(objAsset != Null){
            objAsset.Public_Scheme_Start_Date__c = Null;
            objAsset.Public_Scheme_End_Date__c = Null;
            objAsset.SchemeConversionDate__c = system.today();
            if(ownerId != Null){
                objAsset.OwnerId = ownerId;
            }
           /* objAsset.X4_Year_Membership_Fee_Gross__c = Null; Commented for CRM-10164
            objAsset.X4_Year_Membership_Fee_GST__c = Null;
            objAsset.X4_Year_Membership_Fee_Points__c = Null;
            objAsset.X4_Year_Membership_Fee_Published__c = Null;
            objAsset.X4_Year_Membership_Fee_Points_Published__c = Null;*/
        }
        return objAsset;
    }
}