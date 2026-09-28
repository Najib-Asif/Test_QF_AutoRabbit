/**********************************************************************************************************************************
 
    Description: This is the Controller for the VFPage "proposalProductEntry". Enables to display the multiple combinations & based on the combination the related Fares.
                 Also allows user to select multiple fares at a time. Providing the discounts for those fares in next page. So finally user can Save/ Save & More/ Cancel.    
    Method Description: 
    1) proposalProductEntryController: To get the Proposal record to controller & Initialization of variables.
    2) updateAvailableList: Based on the combination selected will display all the available Fares.
    3) addToShoppingCart: Add the selected Fares to a new list.
    4) onSelectAll: Selects all Fares once clicking on the Select All check box.
    5) onSave: Once clicking on the Save button it will save all the selected Fares & links those to the Proposal returns the page to Proposal
    6) onSaveMore: Once clicking on the Save button it will save all the selected Fares & links those to the Proposal returns to the previous page.
    7) onCancel: Won't save the Fares & redirects the page to Proposal page.
    8) ProductWrapper: Wrapper class to enable the Fares to select multiple at a time.
    9) onSelect: Once clicking on the Select button selects all the flagged on Fares to the next page to Save those.
    10) pgntionProducts: To paginate all the Fares in a specified count instead of displaying all at a time.
    11) getFareCombinations: Displays all the Fare combinations.
    12) getBookingClassIds: To get the Fares Ids based on the selected Combination from Fare Discount Guidelines object.
    13) fareCombinationChange: On change of Fare Combincation changes all the Fares.
    14) next: Goes to next page to display next set of fares in a paginated manner.
    15) previous: Goes to previous page to display previous set of fares in a paginated manner.
    16) getPreviousDisplay: To enable/ disable previuos button.
    17) getNextDisplay: To enable/ disable next button. 
    
    VERSION  AUTHOR     DATE              DETAIL
     New     Manjula   07/27/2022     Updated logics for EK changes - CRM 5336,CRM 5406

**********************************************************************************************************************************/

public with sharing class proposalProductEntryController {

    public Proposal__c theOpp {get;set;}
    public String searchString {get;set;}
    public List<Discount_List__c> shoppingCart {get;set;}
    public List<Discount_List__c> shoppingCartToUpdate {get;set;}
    public List<Discount_List__c> shoppingCartToInsert {get;set;}
    
    public Fare_Structure__c[] AvailableProducts {get;set;}
    public Pricebook2 theBook {get;set;}   
    public List<ProductWrapper> productList {get; set;}
    public Set<ProductWrapper> selectedProducts {get; set;}
    public List<ProductWrapper> limitedProducts {get; set;}
    public String toSelect {get; set;}
    public String toUnselect {get; set;}
    public String selectedPicklistValue {get; set;}
    public String pickValue;
    public Decimal Total {get;set;}
    
    public Boolean overLimit {get;set;}
    
    public Boolean multipleCurrencies {get; set;}
    public Boolean displaySelected {get; set;}
    public Boolean displayAvailable {get; set;}
    public Boolean selectAll {get; set;}
    public Boolean displayFareCombination {get; set;}
    public Boolean errorMsg {get; set;}
    public Boolean disableIndividual {get; set;}
   
    public Integer totalRecs = 0;
    public Integer OffsetSize = 0;
    public Integer LimitSize = 100;
    public Boolean isInsert = false;
  
    private Boolean forcePricebookSelection = false;     
    private opportunityLineItem[] forDeletion = new opportunityLineItem[]{};
    private Discount_List__c[] dlForDeletion = new Discount_List__c[]{};
    List<Discount_List__c> getExistingDisLists=new List<Discount_List__c>();
    Map<ID,Discount_List__c> mapEachDisList = new Map<ID,Discount_List__c>();
   
             
    /*
    Method Description: To get the Proposal record to controller & Initialization of variables.
    */
    public proposalProductEntryController(ApexPages.StandardController controller) {

        // Need to know if org has multiple currencies enabled
        multipleCurrencies = UserInfo.isMultiCurrencyOrganization();
        
        productList = new List<ProductWrapper>();
        selectedProducts = new Set<ProductWrapper>();
        limitedProducts = new List<ProductWrapper>();
        displayFareCombination = true;
        displayAvailable = true;        

        // Get information about the Opportunity being worked on  
        getExistingDisLists=[SELECT Id, Name, Proposal__c,Booking_Class_Name__c, Cabin__c, 
                             Category__c, Comment__c, Discount_Threshold_AM__c, Discount_Threshold_NAM__c,Discount_Threshold_TL__c,Discount_Threshold_DO__c, Discount__c, FareStructure__c, 
                             Fare_Combination__c, Fare_Structure_Cabin__c, Fare_Structure_Market_Category__c, Fare_Structure_Market__c, Fare_Structure_Segment__c, Market__c, 
                             Network__c, Product_Code__c, Proposal_Type__c, Qantas_Published_Airfare__c, Route__c, Segment__c, Maximum_Forecast_QF_Share_Int_MCA__c,
                             Minimum_Forecast_QF_Share_Int_MCA__c, Qantas_Annual_Expenditures__c, Approved_Discount__c, QL_Tier_1_Offering__c, QL_Booking_Details__c, Network_Route__c, 
                             QL_QF_EK_Fare_Structure__c, QL_QF_EK__c FROM Discount_List__c where Proposal__c = :controller.getRecord().Id AND  FareStructure__r.Active__c= True];
        theOpp = [select Id,QL_Is_MCA_Revenue_Updated__c, RecordTypeId, Type__c,QL_Discount_Model__c,Forecast_MCA_Revenue__c,QL_QF_EK_Network_Override__c,Includes_R_KMLVS__c from Proposal__c where Id = :controller.getRecord().Id limit 1];
        // Commented for CRM 1990 - As per the Business requirment removed Mainline - H in B deal and added Mainline - Red e-Deal + Q for Corporate Airfares
        // if(theOpp.Type__c == 'Corporate Airfares') selectedPicklistValue = 'Mainline - H in B deal';
        if(theOpp.Type__c == 'Corporate Airfares') selectedPicklistValue = 'Mainline - Red e-Deal + Q';
        if(theOpp.Type__c == 'Qantas Business Savings') selectedPicklistValue = 'Mainline - Red e-Deal';
        shoppingCart = new List<Discount_List__c>(); 
        shoppingCartToUpdate = new List<Discount_List__c>();
        shoppingCartToInsert = new List<Discount_List__c>();
        updateAvailableList();
        selectAll = true; onSelectAll();
        disableIndividual = true; 
        
        if(theOpp.QL_Discount_Model__c == 'Tiered'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'2 Tier applies to MAINLINE only'));
        }
        //Added for CRM 5336 -Display information about QF/EK discounts based on MCA Revenue while adding initial discounts.
        if(theOpp.Forecast_MCA_Revenue__c<100000 && theOpp.QL_Is_MCA_Revenue_Updated__c==false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Customer qualifies for MCA discounts for flights operated by QF and select partner carriers. No discounts are permitted on EK operated flights'));
        }
        if(theOpp.Forecast_MCA_Revenue__c>=100000 && theOpp.QL_Is_MCA_Revenue_Updated__c==false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Customer qualifies for MCA discounts for flights operated by QF, EK and other partner carriers only'));
        }
        //Added as a part of CRM 5337 - Display information while upgrading/degrading forecase MCA revenue
        if(theOpp.Forecast_MCA_Revenue__c<100000 && theOpp.QL_Is_MCA_Revenue_Updated__c==true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'QF/EK fare discounts removed. Customer qualifies for MCA discounts for flights operated by QF and select partner carriers. No discounts are permitted on EK operated flights.'));
        }
        if(theOpp.Forecast_MCA_Revenue__c>=100000 && theOpp.QL_Is_MCA_Revenue_Updated__c==true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Add Tier 1/Offering and Tier 2/Max values. Customer qualifies for MCA discounts for flights operated by QF, EK and other partner carriers only.'));
        }        
        
    }   
   
    /*
    Method Description: Based on the combination selected will display all the available Fares.
    */    
    public void updateAvailableList(){    
        
        if(selectedPicklistValue != null){
        List<Id> bookingClassIds;
        if(selectedPicklistValue != 'All') bookingClassIds = getBookingClassIds(selectedPicklistValue);      
        // We dynamically build a query string and exclude items already in the shopping cart
        String qString = 'select Id,QL_QF_EK__c, Name, Active__c, Route__c, Category__c,Cabin__c, Discount__c, Network__c, Market__c, ProductCode__c,Prod_Code_RededealQ__c, Qantas_Published_Airfare__c, Segment__c from Fare_Structure__c where Active__c=true ';
        //Logic for displaying INT records based on MCA ranges, Network, Category,MCA Revenue,QF/EK Network Override and QF/EK fields
        //Display INT records based on Product codes CRM-8083/CRM-5337/CRM-7822/CRM-9468
        if(selectedPicklistValue == 'International' && theOpp.Forecast_MCA_Revenue__c>=100000  && theOpp.QL_QF_EK_Network_Override__c == False) qString+= 'AND  (QL_QF_EK__c=\'QF-EK\' OR (QL_QF_EK__c=\'QF\' )) AND  (Category__c!=\'Route\') AND Segment__c=\'International\' AND ((ProductCode__c >= \'INT-0043\' and ProductCode__c <=\'INT-0071\') OR (ProductCode__c >= \'INT-0001\' and ProductCode__c <=\'INT-0026\') OR (ProductCode__c >=\'INT-0110\' and ProductCode__c <=\'INT-0119\')) '; 
        if(selectedPicklistValue == 'International' && theOpp.Forecast_MCA_Revenue__c>=100000  && theOpp.QL_QF_EK_Network_Override__c == True) qString+= 'AND  QL_QF_EK__c=\'QF\' AND  (Category__c!=\'Route\') AND Segment__c=\'International\' AND ((ProductCode__c >= \'INT-0072\' and ProductCode__c <= \'INT-0091\')  or ( ProductCode__c >=\'INT-0001\' and  ProductCode__c <=\'INT-0026\') or ( ProductCode__c >=\'INT-0101\' and  ProductCode__c <=\'INT-0119\')) '; 
        if(selectedPicklistValue == 'International' && theOpp.Forecast_MCA_Revenue__c<100000  &&  theOpp.QL_QF_EK_Network_Override__c == False) qString+= 'AND  (QL_QF_EK__c!=\'QF-EK\') AND  (Category__c!=\'Route\') AND Segment__c=\'International\' AND(( ProductCode__c >= \'INT-0001\' AND ProductCode__c <= \'INT-0042\') or ( ProductCode__c >=\'INT-0059\' and  ProductCode__c <=\'INT-0062\')  or ( ProductCode__c >=\'INT-0092\' and  ProductCode__c <=\'INT-0100\')  or ( ProductCode__c >=\'INT-0110\' and  ProductCode__c <=\'INT-0119\')) ';
        // CRM 2402
        if(selectedPicklistValue == 'INT MCA Route Deal') qString+= 'AND (Category__c=\'Route\') AND Segment__c=\'International\'';
        if(selectedPicklistValue == 'INT Non MCA Route Deal') qString+= 'AND (Category__c=\'Route\') AND Segment__c=\'International\'';
        if(selectedPicklistValue != 'All' && selectedPicklistValue != 'International') { qString+= 'and Id IN :bookingClassIds' ; }
       
        // modify this to search other fields if desired
        if(searchString!=null){
            qString+= ' and (QL_QF_EK__c like \'%' + searchString + '%\' or Name like \'%' + searchString + '%\' or ProductCode__c like \'%' + searchString + '%\' or Prod_Code_RededealQ__c like \'%' + searchString + '%\' or Market__c like \'%' + searchString + '%\' or Cabin__c like \'%' + searchString + '%\' or Qantas_Published_Airfare__c like \'%' + searchString + '%\' or Segment__c like \'%' + searchString + '%\' or Category__c like \'%' + searchString + '%\' )';
        }
        
        //<!-- Commented on 8th April for CRM -54 by Prateek 
        qString+= ' order By ProductCode__c';
        system.debug('qString:' +qString);
        
        AvailableProducts = database.query(qString);
        system.debug('AvailableProducts:'+AvailableProducts);
        system.debug('AvailableProducts list size:' +AvailableProducts.size());
        productList.clear();
        for(Fare_Structure__c pe : AvailableProducts){
            ProductWrapper pw = new ProductWrapper(pe);
            productList.add(pw);
            system.debug('productList'+productList);
            
        }
        system.debug('product list size:' +productList.size());
        totalRecs = productList.size();
        pgntionProducts();
        
        }
    }
    
    
    /*
    Method Description: Add the selected Fares to a new list.
    */    
     public void addToShoppingCart(){
    
        // This function runs when a user hits "select" button next to a product
        System.debug('Action Support ** ');
        for(Fare_Structure__c d : AvailableProducts){
            if((String)d.Id==toSelect){
                shoppingCart.add(new Discount_List__c(FareStructure__c = d.Id, Proposal__c = theOpp.Id));
                system.debug('shoppingCart$$$$'+shoppingCart);
                break;
            }
        }
        system.debug('AvailableProducts:'+AvailableProducts);
        updateAvailableList();  
    } 
    /*
    Method Description: Selects all Fares once clicking on the Select All check box.
    */
    
    public void onSelectAll(){
        
        for(ProductWrapper pw : limitedProducts){
            if(selectAll == true) pw.selected = true;
            else if(selectAll == false) pw.selected = false;
        }
    }     
    /*
    Method Description: Once clicking on the Save button it will save all the selected Fares & links those to the Proposal returns the page to Proposal
    */
    public PageReference onSave(){
        // If previously selected products are now removed, we need to delete them
        if(dlForDeletion.size()>0)
            delete(dlForDeletion);
    
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        // Update the selected fares to avoid duplicate entries -CRM 5406
        try{
            List<Proposal__c> proposaltoUpdate = new List<Proposal__c>();
            if(shoppingCartToInsert.size()>0){
                system.debug('insideshoppingCartToInsert'+shoppingCartToInsert);
                insert shoppingCartToInsert;
            }
            
            if(shoppingCartToUpdate.size()>0){
                system.debug('insideshoppingCartToUpdate'+shoppingCartToUpdate);
                update shoppingCartToUpdate;   
            }
            
            //Updates field Includes_R_KMLVS__c -CRM- 9486
            List<Discount_List__c> relatedDiscountLists = [select Id,Name, Proposal__c,Booking_Class_Name__c from Discount_List__c where Proposal__c=: theOpp.Id];
            Boolean includesRandKMLVS = false;
            for(Discount_List__c dl: relatedDiscountLists){
                if(dl.Booking_Class_Name__c == 'R' || dl.Booking_Class_Name__c== 'KMLVS'){
                   includesRandKMLVS= true;
                    break; 
                }
            }
            theOpp.Includes_R_KMLVS__c = includesRandKMLVS;
            update theOpp;
        }
        
        catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }     
        // After save return the user to the Opportunity
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    /*
    Method Description: Once clicking on the Save button it will save all the selected Fares & links those to the Proposal returns to the previous page.
    */
    public PageReference onSaveMore(){
    
        // If previously selected products are now removed, we need to delete them
        if(forDeletion.size()>0)
            delete(forDeletion);
    
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        try{
            if(shoppingCartToInsert.size()>0){
                system.debug('shoppingCartToInsert'+shoppingCartToInsert);
                insert shoppingCartToInsert;
            }
            if(shoppingCartToUpdate.size()>0){
                system.debug('shoppingCartToUpdate'+shoppingCartToUpdate);
                update shoppingCartToUpdate;    
            } 
        }
        catch(Exception e){
            System.debug('****'+e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }  
           
        // After save return the user to the Opportunity
        return null;
        //return new PageReference('/apex/opportunityProductEntry?id=' + ApexPages.currentPage().getParameters().get('Id'));
    }
    /*
    Method Description: Won't save the Fares & redirects the page to Proposal page.
    */
    public PageReference onCancel(){
 
        // If user hits cancel we commit no changes and return them to the Opportunity   
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    /*
    Method Description: Wrapper class to enable the Fares to select multiple at a time.
    */    
    public class ProductWrapper {
        public Boolean selected {get; set;}
        public Fare_Structure__c product {get; set;}
        public ProductWrapper(Fare_Structure__c pe){
            product = pe;
        }
    }
    /*
    Method Description: Once clicking on the Select button selects all the flagged on Fares to the next page to Save those.
    Flagged fares which are already present in discount list related list are updated and new flagged fares are stored in list and inserted on click on save- CRM 5406
    */
    public void onSelect(){
        for(ProductWrapper d : productList){
            if(d.selected == true){
                if(theOpp.Type__c == 'Corporate Airfares')
                {  
                   for(Discount_List__c disList : getExistingDisLists){
                         mapEachDisList.put(disList.FareStructure__c,disList);    
                    }
                    system.debug('mapEachDisList ' + mapEachDisList);
                    system.debug('d.product.Id'+d.product.Id);
                    if(mapEachDisList.containsKey(d.product.Id)){
                    Discount_List__c dlId = mapEachDisList.get(d.product.Id);
                    dlId.QL_QF_EK__c=d.product.QL_QF_EK__c;
                    dlId.FareStructure__c = d.product.Id; 
                   // dlId.Proposal__c = theOpp.Id; 
                    dlId.Qantas_Published_Airfare__c = d.product.Qantas_Published_Airfare__c;
                    dlId.Fare_Combination__c = selectedPicklistValue;
                    dlId.Segment__c = d.product.Segment__c;
                    dlId.Category__c = d.product.Category__c;
                    dlId.Network__c = d.product.Network__c;
                    dlId.Market__c = d.product.Market__c;
                    dlId.Cabin__c = d.product.Cabin__c; 
                    dlId.Proposal_Type__c = theOpp.Type__c;
                    shoppingCartToUpdate.add(dlId);
                    }else{
                    System.debug('shoppingCartelse'+shoppingCart);  
                    shoppingCartToInsert.add(new Discount_List__c(QL_QF_EK__c=d.product.QL_QF_EK__c,FareStructure__c = d.product.Id, Proposal__c = theOpp.Id, Qantas_Published_Airfare__c = d.product.Qantas_Published_Airfare__c, Fare_Combination__c = selectedPicklistValue,Segment__c = d.product.Segment__c,Category__c = d.product.Category__c, Network__c = d.product.Network__c, Market__c = d.product.Market__c, Cabin__c = d.product.Cabin__c, Proposal_Type__c = theOpp.Type__c));
                    }
                    system.debug('updatelist ' + shoppingCartToUpdate);
                    system.debug('insertlist ' + shoppingCart);
                }else if(theOpp.Type__c == 'Qantas Business Savings')
                {
                    Integer discount = 0;
                    Standard_Discounts__c stndrdDiscount;
                    if(selectedPicklistValue != 'International' ) stndrdDiscount = Standard_Discounts__c.getValues(d.product.Name);
                    // CRM - 1994 To Pre-popoulate the Discount values in the Proposal Fare Discount for Mainline - Flex only deal
                    if(selectedPicklistValue == 'Mainline - Flex Only Deal' ) stndrdDiscount = Standard_Discounts__c.getValues(d.product.ProductCode__c);
                    system.debug('Standard discount value other than International' + selectedPicklistValue );
                    // CRM 2054 To Pre-popoulate the Discount values in the Proposal Fare Discount for Mainline - Red-edeal+Q
                    if(selectedPicklistValue == 'Mainline - Red e-Deal + Q' ) stndrdDiscount = Standard_Discounts__c.getValues(d.product.Prod_Code_RededealQ__c);
                    system.debug('Standard discount value other than International' + selectedPicklistValue );
                    if(selectedPicklistValue == 'International') stndrdDiscount = Standard_Discounts__c.getValues(d.product.ProductCode__c);
                    system.debug('Standard discount value of International' + stndrdDiscount );
                    if(stndrdDiscount != null && stndrdDiscount.Fare_Combination__c == selectedPicklistValue)
                    {
                        discount = stndrdDiscount.Default_Discount__c.intValue();
                        system.debug('Discount value is '+ discount );
                    }
                    shoppingCart.add(new Discount_List__c(FareStructure__c = d.product.Id, Proposal__c = theOpp.Id, Qantas_Published_Airfare__c = d.product.Qantas_Published_Airfare__c, Fare_Combination__c = selectedPicklistValue, Segment__c = d.product.Segment__c, Category__c = d.product.Category__c, Network__c = d.product.Network__c, Market__c = d.product.Market__c, Cabin__c = d.product.Cabin__c, Discount__c = discount, QBS_Deafualt_Discount__c = discount, Proposal_Type__c = theOpp.Type__c));
                    system.debug('Inserted values are ' + shoppingCart);
                }
                
            }
        }
        //Proposal 2 Tier Changes - For 2 Tier model,Fare class combination dropdown applies only for Mainline options - CRM 5210
       /* if(theOpp.QL_Discount_Model__c == '2-Tier' && (selectedPicklistValue == 'International' || selectedPicklistValue == 'Regional' )){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'2 Tier applies to MAINLINE only'));
        }*/
        
        if(shoppingCartToInsert.size()==0 && shoppingCartToUpdate.size()==0  ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select atleast one Booking Class'));
        } 
        if(shoppingCartToInsert.size()>0 ){
            shoppingCartToInsert = DiscountListHandler.populateDiscountThreshold(shoppingCartToInsert);
            system.debug('shoppingCartToInsert'+shoppingCartToInsert);
            displaySelected = true;
            displayAvailable = false;
            displayFareCombination = false;
        }
        if(shoppingCartToUpdate.size()>0 ){
            shoppingCartToUpdate = DiscountListHandler.populateDiscountThreshold(shoppingCartToUpdate);
            system.debug('shoppingCartToUpdate'+shoppingCartToUpdate);
            displaySelected = true;
            displayAvailable = false;
            displayFareCombination = false;
        }
        shoppingCart.addAll(shoppingCartToInsert);
        shoppingCart.addAll(shoppingCartToUpdate);
    
    }
    /*
    Method Description: To paginate all the Fares in a specified count instead of displaying all at a time.
    */
    public void pgntionProducts(){
        limitedProducts = new List<ProductWrapper>();
        
        for(Integer i = OffsetSize; i < (LimitSize + OffsetSize) && i < totalRecs ; i++){
            limitedProducts.add(productList.get(i));        
        }
        
    }
    /*
    Method Description: Displays all the Fare combinations.
    */
    public List<SelectOption> getFareCombinations(){
    
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Standard_Discount_Guidelines__c.Fare_Combination__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple)
        {
          String str = f.getValue();
          System.debug('**** '+str);
          if(theOpp.Type__c == 'Qantas Business Savings'){ // Added 'Mainline - Flex Only Deal'as per the CRM-1994 & added'Mainline - Red e-Deal + Q' as per the CRM 2054
              if( str == 'Mainline - Red e-Deal' || str == 'Mainline - Red e-Deal + Q' || str == 'International' || str == 'Regional' || str == 'Mainline - Flex Only Deal') 
              options.add(new SelectOption(f.getLabel(), f.getValue()));
          }else if(theOpp.Type__c == 'Corporate Airfares'){ // Replaced Mainline - H in B deal with Mainline - Red e-Deal + Q as per the CRM-1990 
                  if( str == 'Mainline - Red e-Deal + Q' || str == 'Mainline - Flex Only Deal' || str == 'Mainline - Red e-Deal' || str == 'Mainline - JCYB Deal'  || str == 'International' || str == 'Regional')
              options.add(new SelectOption(f.getLabel(), f.getValue()));
          }
        }       
        return options;
    }
    /*
    Method Description: To get the Fares Ids based on the selected Combination from Fare Discount Guidelines object.
    */
    public List<Id> getBookingClassIds(String pickValue){
        List<Id> allIds = new List<Id>();
        List<Standard_Discount_Guidelines__c> bookingValues = [SELECT Fare_Structure__c FROM Standard_Discount_Guidelines__c where Fare_Combination__c=:pickValue and Active__c=true];
        for(Standard_Discount_Guidelines__c sdg : bookingValues){
            allIds.add(sdg.Fare_Structure__c);
        }
        return allIds;
    }
        
    /*
    Method Description: On change of Fare Combincation changes all the Fares.
    */
    public void fareCombinationChange(){
        
        if(selectedPicklistValue != 'International' && selectedPicklistValue != 'Regional' && selectedPicklistValue != 'DOM Route Deal' && selectedPicklistValue != 'INT MCA Route Deal' && selectedPicklistValue != 'INT Non MCA Route Deal') disableIndividual = true;
        else disableIndividual = false;
        searchString = '';  
           
        updateAvailableList();
        if(selectedPicklistValue != 'International' && selectedPicklistValue != 'Regional' && selectedPicklistValue != 'DOM Route Deal'){ selectAll = true; onSelectAll(); }
        else { selectAll = false; onSelectAll(); }
                      
    }   
        
    // Pagination Next, Previous buttons
    /*
    Method Description: Goes to next page to display next set of fares in a paginated manner.
    */
    public void next(){
        OffsetSize = LimitSize + OffsetSize;
            
        for(ProductWrapper cCon: limitedProducts) {
            selectedProducts.add(cCon);  
        }   
        pgntionProducts();
    }
    /*
    Method Description: Goes to previous page to display previous set of fares in a paginated manner.
    */
     public void previous(){
         OffsetSize = OffsetSize - LimitSize;
            
         for(ProductWrapper cCon: limitedProducts) {
             selectedProducts.add(cCon);  
         }
         pgntionProducts(); 
      } 
      /*
      Method Description: To enable/ disable previuos button.
      */
      public Boolean getPreviousDisplay(){
             if(OffsetSize == 0)
             return true;
             else
             return false;
        }
        /*
        Method Description: To enable/ disable next button. 
        */
        public Boolean getNextDisplay(){
            if((OffsetSize + LimitSize) > totalRecs)
            return true;
            else  
            return false;
        } 
        
}