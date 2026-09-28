/***********************************************************************************************************************************

Description: Test Method-Lightning component handler for the convert contract functionality

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam                CRM-2797    Test Method LEx-Contract Convert                                           T01
Ajay					AE - 82		to add Record Type on Contract Payments & Payments object
Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
@isTest
public class QL_ConvertContractControllerTest {
    // Ajay : added for JIRA : AE - 82
    public static Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
    // Ajay : ended
    @isTest 
    public static void convertContractTest() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
    
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String OppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business and Government').getRecordTypeId();
        
        Trigger_Status__c ts = new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = true);
        insert ts;    
        Trigger_Status__c tsSplCon = new Trigger_Status__c(Name = 'SpecialConditionsTrigger', Active__c = true);
        insert tsSplCon;    
        //Create Account
        Account testacc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                      RecordTypeId = accRTId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N');
        insert testacc;
        //Create Contact
        Contact testcon = new Contact(FirstName='Bob',LastName='Test',AccountId=testacc.id,Function__c = 'IT',Business_Types__c = 'Agency',Email = 'abc@test.com');
        insert testcon;        
        //Create Oppotunity
        Opportunity validOpp = new Opportunity(Name = 'Opp2'+testacc.Name , AccountId = testacc.Id,Proposed_Market_Share__c = 70,Proposed_International_Market_Share__c = 50,
                                               Amount = 500000, Category__c = 'Corporate Airfares', CloseDate = Date.Today(),Proposed_MCA_Routes_Market_Share__c = 90,
                                               StageName = 'Qualify',Forecast_MCA_Revenue__c=20000);
        insert validOpp;
        //Create Proposal
        Proposal__c propErr = new Proposal__c(Name = 'Proposal0', Account__c = validOpp.AccountId, Opportunity__c = validOpp.Id,
                                              Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                              Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',
                                              MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),
                                              Qantas_Annual_Expenditure__c = 500000, Forecast_MCA_Revenue__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Accepted by Customer',
                                              NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                              DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                              Approval_Required_Others__c = false,QL_Discount_Model__c ='Tiered'
                                             );
        insert propErr;
        //Create Contract
        Contract__c contr = new Contract__c(Name = 'Sample Contract', Account__c = propErr.Account__c, Opportunity__c = propErr.Opportunity__c, Proposal__c = propErr.Id,
                                            Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                            Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = false,
                                            MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = Date.Today(),
                                            Qantas_Annual_Expenditure__c = 500000, QL_Forecast_MCA_Revenue__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer',QL_Discount_Model__c ='Tiered',QL_Effective_Tier__c ='Tier 1'                                             
                                           );
        insert contr; 
        
        //Create Proposal
        Proposal__c validProp = new Proposal__c(Name = 'Proposal1', Account__c = validOpp.AccountId, Opportunity__c = validOpp.Id,Contact__c=testcon.Id,
                                                Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                                Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',TMC_Code__c=null,
                                                MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),Approval_Required_Others__c = false,
                                                Qantas_Annual_Expenditure__c = 500000, Forecast_MCA_Revenue__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Accepted by Customer',
                                                NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                                DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                                Agent_Email__c='abc@test.com',Agent_Address__c='testaddr',Agent_Name__c='test',Travel_Fund__c='No',
                                                Legal_TC__c='sample test2',Deal_Type__c='Share',Proposal_Start_Date__c=Date.Today(), Proposal_End_Date__c=Date.Today().addDays(20),
                                                Agent_Fax__c='123456789',Commercial_TC__c = 'sample test1',Frequent_Flyer_Status_Upgrade_Offer__c='',Qantas_Club_Join_Discount_Offer__c='',Qantas_Club_Discount_Offer__c='',
                                                Travel_Fund_Amount__c=null,Standard__c='No',Additional_Change_Details__c='',QL_Discount_Model__c ='Tiered'
                                               );
         insert validProp;
        
        //Create Contract
        Contract__c contr1 = new Contract__c(Name = 'Sample Contract', Account__c = validProp.Account__c, Opportunity__c = validProp.Opportunity__c, Proposal__c = validProp.Id,
                                            Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                            Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = false,
                                            MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = Date.Today(),
                                            Qantas_Annual_Expenditure__c = 500000, QL_Forecast_MCA_Revenue__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer',QL_Discount_Model__c ='Tiered',QL_Effective_Tier__c ='Tier 1'                                             
                                           );
       // insert contr1;
        Fare_Structure__c fs = new Fare_Structure__c(Name = 'J', Active__c = true, Cabin__c = 'Business', 
                                                     Category__c = 'Mainline', Market__c = 'Australia', 
                                                     ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                     Segment__c = 'Domestic'
                                                    );
        insert fs;
        
        // create a disc list
        List<Discount_List__c> discList = new List<Discount_List__c>();
        for(Integer i=1;i<4;i++){
            Discount_List__c disc = new Discount_List__c(FareStructure__c = fs.Id, Proposal__c = validProp.Id, 
                                                         Qantas_Published_Airfare__c = fs.Qantas_Published_Airfare__c, 
                                                         Fare_Combination__c = 'Mainline - H in B deal', Segment__c = fs.Segment__c,
                                                         Category__c = fs.Category__c, Network__c = fs.Network__c, 
                                                         Market__c = fs.Market__c, Cabin__c = fs.Cabin__c, 
                                                         Proposal_Type__c = validProp.Type__c, Discount__c = 40,
                                                         Approval_Comment_NAM__c = 'test', Approval_Comment_Pricing__c = 'test2',
                                                         Comment__c = 'test', Discount_Threshold_AM__c = 5,Discount_Threshold_NAM__c = 10,Route_Origin__c = 'SYD',Route_Destination__c ='MEL',QL_Tier_1_Offering__c=6
                                                        );
            discList.add(disc);
        }
        if(!discList.isEmpty()){
            insert discList;
        }
         Contract_Discount_List__c cdl = new Contract_Discount_List__c();
            cdl.Contract__c = contr.id;
            cdl.Discount__c = 5;
            cdl.FareStructure__c = fs.id;
            cdl.QL_Tier_1_Offering__c = 6;
        insert  cdl;
        
        // create a CP List
        List<Contract_Payments__c> cpList = new List<Contract_Payments__c>();

        // create a CFI List
        List<Charter_Flight_Information__c> cfiList = new List<Charter_Flight_Information__c>();

        for(Integer i=1;i<4;i++){
            Contract_Payments__c cp = new Contract_Payments__c(Proposal__c = validProp.Id, RecordTypeId = cpRTId); // Ajay : added record type for JIRA:AE-82
            cpList.add(cp);
            Charter_Flight_Information__c cf = new Charter_Flight_Information__c(Proposal__c = validProp.Id);
            cfiList.add(cf);
        }
        if(!cpList.isEmpty())
            insert cpList;
        
        if(!cfiList.isEmpty())
            insert cfiList;
        Test.StartTest();
        //Invoke the controller methods
          QL_ConvertContractController.getConvertedContract(propErr.Id);
          QL_ConvertContractController.getConvertedContract(validProp.Id);
        Test.StopTest(); 
        
        
               
    }
   //Validate for the attachments 
    public static void addAttachment(Id parentId){
            Blob b = Blob.valueOf('Test Data');
            
            Attachment attch = new Attachment();
            attch.ParentId = parentId;
            attch.Name = 'Test attachment for Parent';
            attch.Body = b;

          insert attch;
    }
}