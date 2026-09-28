/*----------------------------------------------------------------------------------------------------------------------
Author: Praveen Sampath 
Company: Capgemini  
Purpose: AccountAirlineLevelHandler for Discount Code & Message Populations 
Date: 19/12/2016    
************************************************************************************************
History
************************************************************************************************
06-Mar-2017    Benazir S A               Initial Design           
-----------------------------------------------------------------------------------------------------------------------*/
public class AccountAirlineLevelHandler {
    
    public static String qbdRegRecTypeName = CustomSettingsUtilities.getConfigDataMap('Prd Reg QBD Registration Rec Type');
    public static Id qbdRecId = GenericUtils.getObjectRecordTypeId('Product_Registration__c', qbdRegRecTypeName);
    public static String acqRegRecTypeName = CustomSettingsUtilities.getConfigDataMap('Prd Reg Aquire Registration Rec Type');
    public static Id acqRecId = GenericUtils.getObjectRecordTypeId('Product_Registration__c', acqRegRecTypeName);

        
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateDiscountCodeOnProducts 
    Description:        To Updated QCD GST and Key Contact Id Code on product Registration, when Account is updated.
    Parameter:          New AccountMap and Old AccountMap 
    --------------------------------------------------------------------------------------*/    
    public static void updateDiscountCodeOnProducts(Map<Id,Account> newMapAccount,Map<Id,Account> oldMapAccount){
        
        set<Id> updatedAccountIds = new set<Id>();
        //set<Id> updatedAirLineAccountIds = new set<Id>();
        for(Account acc: newMapAccount.values()){

            //Check for Airline Level Changes
            if(acc.Airline_Level__c != oldMapAccount.get(acc.id).Airline_Level__c){
                updatedAccountIds.add(acc.id);
            }
            //Check for Airline Eligibility
            if(acc.Aquire_Eligibility_f__c  != oldMapAccount.get(acc.Id).Aquire_Eligibility_f__c){
                updatedAccountIds.add(acc.id);
            }
            // When New Acquire is inserted
            if(acc.No_of_Aquires__c != oldMapAccount.get(acc.Id).No_of_Aquires__c ){
                updatedAccountIds.add(acc.id);
            }
            //Update on Account Active Value
            if(acc.Active__c != oldMapAccount.get(acc.Id).Active__c){
                updatedAccountIds.add(acc.id);
            }
            //Check for Corporate deal
            if(acc.Dealing_Flag__c != oldMapAccount.get(acc.Id).Dealing_Flag__c){
                updatedAccountIds.add(acc.id);
            }
            //Check For SME Deal
            if(acc.SME_Deal__c != oldMapAccount.get(acc.Id).SME_Deal__c){
                updatedAccountIds.add(acc.id);
            }
        }
        
        if(updatedAccountIds.isEmpty()) return;

        
        list<Product_Registration__c> accountProducts = [SELECT Id, Key_Contact_Office_ID__c, Active__c, Account__r.Airline_Level__c, Stage_Status__c,
                                                         Account__c, RecordType.Name, RecordTypeId, GDS_QBR_Discount_Code__c, Qantas_Club_Discount_Code__c
                                                         FROM Product_Registration__c Where (RecordTypeId =: acqRecId OR RecordTypeId =: qbdRecId ) 
                                                         AND Account__c IN: updatedAccountIds 
                                                         /*AND (Stage_Status__c ='Active' or Active__c =: true)*/];
        list<Product_Registration__c> updatePR = new list<Product_Registration__c>(); 
        for(Product_Registration__c productReg : accountProducts){
            Account acc = newMapAccount.get(productReg.Account__c);
            productReg = productRegMapping(acc, productReg);
            
            //Updating GCD and QCD Message
            if(productReg.RecordTypeId == acqRecId)
                 productReg = updateQCDAndGCDMessage(acc, productReg);
            
            updatePR.add(productReg);
        }
        if(updatePR.size() > 0){
            update updatePR;
        }
    }

   
    /*--------------------------------------------------------------------------------------      
    Method Name:        productRegMapping 
    Description:        Logic To Update Key Contact Office, GDS COde and QCS Code
                        Invoked from updateDiscountCodeOnProducts and QBDOfficeId_PR_Daily_Update_Batch
    Parameter:          Account and Product Registration 
    --------------------------------------------------------------------------------------*/    
    public static Product_Registration__c productRegMapping(Account acc, Product_Registration__c productReg){
        //Check for Airline Level
        if(acc.Airline_Level__c != null){
            QBD_Online_Office_ID__c officeID = QBD_Online_Office_ID__c.getValues(acc.Airline_Level__c);
            
            if(officeID != null && acc.Active__c == true && 
                ( productReg.Active__c == true ||  productReg.Stage_Status__c == 'Active'))
            {
                //Checking condition for QBD Product
                if(acc.QBD__c == true && acc.Aquire_Blocking_Classification__c != true && acc.Aquire_System__c == true &&
                 acc.Aquire_Eligibility_f__c == 'Y' && productReg.Active__c == true)
                {
                    if(productReg.RecordTypeId == qbdRecId && productReg.Key_Contact_Office_ID__c != officeID.Key_Contact_Office_ID__c){
                        productReg.Key_Contact_Office_ID__c = officeID.Key_Contact_Office_ID__c; // for QBD products only
                    }
                }
                else{
                    productReg.Key_Contact_Office_ID__c = '';
                }

                //Checking condition for Acquire Product
                if(productReg.RecordTypeId == acqRecId && 
                    ( productReg.Key_Contact_Office_ID__c != officeID.Key_Contact_Office_ID__c || 
                      productReg.GDS_QBR_Discount_Code__c != officeID.GDS_QBR_Discount_Code__c ||  
                      productReg.Qantas_Club_Discount_Code__c != officeID.Qantas_Club_Discount_Code__c))
                {
                    system.debug('inside if#######3');
                    if(acc.Aquire_Eligibility_f__c == 'Y'){
                        productReg.Key_Contact_Office_ID__c = officeID.Key_Contact_Office_ID__c; // for QBD products only
                        productReg.GDS_QBR_Discount_Code__c = officeID.GDS_QBR_Discount_Code__c; //GDS Code for Aquire products only
                        productReg.Qantas_Club_Discount_Code__c = officeID.Qantas_Club_Discount_Code__c; //QCD Code for Aquire products only
                    }
                    else{
                        productReg.Key_Contact_Office_ID__c = '';
                        productReg.GDS_QBR_Discount_Code__c = '';
                        productReg.Qantas_Club_Discount_Code__c = '';
                    }
                }

                //newMapAccount.get(productReg.Account__c).Process_QBD_Update__c = false;
            }
            else{
                productReg.Key_Contact_Office_ID__c = '';
                productReg.GDS_QBR_Discount_Code__c = '';
                productReg.Qantas_Club_Discount_Code__c = '';
            }

        }
        else{
            productReg.Key_Contact_Office_ID__c = '';
            productReg.GDS_QBR_Discount_Code__c = '';
            productReg.Qantas_Club_Discount_Code__c = '';
        }
        return productReg;
    }

    
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateQCDAndGCDMessage 
    Description:        Logic To Update GDS QBR Message and QCD Message 
                        Invoked from updateDiscountCodeOnProducts
    Parameter:          Account and Product Registration 
    --------------------------------------------------------------------------------------*/    
    public static Product_Registration__c updateQCDAndGCDMessage(Account acc, Product_Registration__c productReg){
        System.debug('productReg##########'+productReg);
        System.debug('acc#######'+acc);
        //Check account is inActive
        if(acc.Active__c == false){
            productReg.GDS_QBR_Message_Ref__c = '';
            productReg.QCD_Message_Ref__c = '';
        }//Acquire System false 
        else if(acc.Aquire_System__c == false  && acc.Aquire_Eligibility_f__c == 'N' ){
            
            if(productReg.GDS_QBR_Discount_Code__c == Null || productReg.GDS_QBR_Discount_Code__c == ''){
                productReg.GDS_QBR_Message_Ref__c = '';
            }else{
                 productReg.GDS_QBR_Message_Ref__c = '';
            }

            if(productReg.Qantas_Club_Discount_Code__c  == Null || productReg.Qantas_Club_Discount_Code__c  == ''){
                productReg.QCD_Message_Ref__c = '';
            }else{
                productReg.QCD_Message_Ref__c = '';
            }
        }//Airline Level 1
        else if(acc.Aquire_System__c == true && acc.Airline_Level__c == '1' && acc.Aquire_Eligibility_f__c == 'Y'){
            if(productReg.GDS_QBR_Discount_Code__c != Null && productReg.GDS_QBR_Discount_Code__c != ''){
                productReg.GDS_QBR_Message_Ref__c = '';
            }else{
                productReg.GDS_QBR_Message_Ref__c = '';
            }

            if(productReg.Qantas_Club_Discount_Code__c  != Null && productReg.Qantas_Club_Discount_Code__c  != ''){
                productReg.QCD_Message_Ref__c = 'RC005';
            }else{
                productReg.QCD_Message_Ref__c = '';
            }
        }//Airline Level 2
        else if(acc.Aquire_System__c == true && acc.Airline_Level__c == '2' && acc.Aquire_Eligibility_f__c == 'Y' ){
            if(productReg.GDS_QBR_Discount_Code__c != Null && productReg.GDS_QBR_Discount_Code__c != ''){
                productReg.GDS_QBR_Message_Ref__c = '';
            }else{
                 productReg.GDS_QBR_Message_Ref__c = '';
            }

            if(productReg.Qantas_Club_Discount_Code__c  != Null && productReg.Qantas_Club_Discount_Code__c  != '' ){
                productReg.QCD_Message_Ref__c = 'RC005';
            }else{
                productReg.QCD_Message_Ref__c = '';
            }
        }//Airline Level 3
        else if(acc.Aquire_System__c == true && acc.Airline_Level__c == '3' && acc.Aquire_Eligibility_f__c == 'Y' ){
            
            if(productReg.GDS_QBR_Discount_Code__c == Null || productReg.GDS_QBR_Discount_Code__c == ''){
                productReg.GDS_QBR_Message_Ref__c = '';
            }else{
                 productReg.GDS_QBR_Message_Ref__c = '';
            }

            if(productReg.Qantas_Club_Discount_Code__c  != Null && productReg.Qantas_Club_Discount_Code__c  != ''){
                productReg.QCD_Message_Ref__c = 'RC005';
            }else{
                productReg.QCD_Message_Ref__c = '';
            }
        }//SME Deal
        else if(acc.Aquire_System__c == true  && acc.Aquire_Eligibility_f__c == 'Y' && acc.SME_Deal__c == true){
            if(productReg.GDS_QBR_Discount_Code__c == Null || productReg.GDS_QBR_Discount_Code__c == ''){
                productReg.GDS_QBR_Message_Ref__c = 'RC001';
            }else{
                 productReg.GDS_QBR_Message_Ref__c = '';
            }
            if(productReg.Qantas_Club_Discount_Code__c  == Null || productReg.Qantas_Club_Discount_Code__c  == ''){
                productReg.QCD_Message_Ref__c = 'RC004';
            }else{
                productReg.QCD_Message_Ref__c = '';
            }
        }//Corporate Deal
        else if(acc.Aquire_System__c == true  && acc.Aquire_Eligibility_f__c == 'N' && acc.Dealing_Flag__c == 'Y'){
            if(productReg.GDS_QBR_Discount_Code__c == Null || productReg.GDS_QBR_Discount_Code__c == ''){
                productReg.GDS_QBR_Message_Ref__c = 'RC001';
            }else{
                 productReg.GDS_QBR_Message_Ref__c = '';
            }
            if(productReg.Qantas_Club_Discount_Code__c  == Null || productReg.Qantas_Club_Discount_Code__c  == ''){
                productReg.QCD_Message_Ref__c = 'RC004';
            }else{
                productReg.QCD_Message_Ref__c = '';
            }
        }//SME Deal and Airline Eligiblity NO
        else if(acc.Aquire_System__c == true  && acc.Aquire_Eligibility_f__c == 'N' && acc.SME_Deal__c == true){
            if(productReg.GDS_QBR_Discount_Code__c == Null || productReg.GDS_QBR_Discount_Code__c == ''){
                productReg.GDS_QBR_Message_Ref__c = 'RC001';
            }else{
                 productReg.GDS_QBR_Message_Ref__c = '';
            }
            if(productReg.Qantas_Club_Discount_Code__c  == Null || productReg.Qantas_Club_Discount_Code__c  == ''){
                productReg.QCD_Message_Ref__c = 'RC004';
            }else{
                productReg.QCD_Message_Ref__c = '';
            }
        }//Airline Eligiblity NO
        else if(acc.Aquire_System__c == true  && acc.Aquire_Eligibility_f__c == 'N'){
            if(productReg.GDS_QBR_Discount_Code__c == Null || productReg.GDS_QBR_Discount_Code__c == '' ){
                productReg.GDS_QBR_Message_Ref__c = 'RC002';
            }else{
                 productReg.GDS_QBR_Message_Ref__c = '';
            }
            if(productReg.Qantas_Club_Discount_Code__c  == Null || productReg.Qantas_Club_Discount_Code__c  == ''){
                productReg.QCD_Message_Ref__c = 'RC003';
            }else{
                productReg.QCD_Message_Ref__c = '';
            }
        }// None of the above are satisfied
        else{
            productReg.GDS_QBR_Message_Ref__c = '';
            productReg.QCD_Message_Ref__c = '';
        }
        return productReg;
    }
}