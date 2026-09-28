@isTest
public class Test_OpptyMaintenanceTriggerHandler{
    
    public static testMethod void OpptymaintenanceUpdate(){
        List<Opportunity_main__c> Opptymaincustom = new List<Opportunity_main__c>();
        //List<Opportunity_main__c> Opptymaincustom = new List<Opportunity_main__c>();
        //List<Opportunity_main__c> OpptymaincustomobjforQBS = new List<Opportunity_main__c>();
        //List<Opportunity_main__c> OpptymaincustomforQBS = new List<Opportunity_main__c>();
        
        List<Opportunity_Maintenance__c> Opptymain = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> Opptymaintenance = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> OpptymainforCA = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> OpptymainupdateforCA = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> caOpptymainupdate = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> inactivecaOpptymainupdate = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> OpptymainupdateforQBS = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> qbsOpptymainupdate = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> inactiveqbsOpptymainupdate = new List<Opportunity_Maintenance__c>();
        List<Opportunity_Maintenance__c> OpptymainforQBS = new List<Opportunity_Maintenance__c>();

        // Custom setting creation
        TestUtilityDataClassQantas.enableTriggers();

        OpptymainforCA = TestUtilityDataClassQantas.getOpportunityMaintenanceforCA();
        OpptymainforQBS = TestUtilityDataClassQantas.getOpportunityMaintenanceforQBS();
        
        
        
        for(Opportunity_Maintenance__c caOpptymain : OpptymainforCA){
            Opptymaincustom.add(new Opportunity_main__c(Name = 'Corporate Airfares', Create_an_Opportunity_before_in_months__c = caOpptymain.Create_an_Opportunity_before_in_months__c, 
                                                         Close_Date__c = caOpptymain.Close_Date__c, Active__c = caOpptymain.Active__c));
        }
        
        
        for(Opportunity_Maintenance__c qbsOpptymain : OpptymainforQBS){
            Opptymaincustom.add(new Opportunity_main__c(Name = 'Qantas Business Savings', Create_an_Opportunity_before_in_months__c = qbsOpptymain.Create_an_Opportunity_before_in_months__c, 
                                                         Close_Date__c = qbsOpptymain.Close_Date__c, Active__c = qbsOpptymain.Active__c));
        }
        
        insert Opptymaincustom;
        
        for(Opportunity_Maintenance__c opm : OpptymainforCA){
            opm.Create_an_Opportunity_before_in_months__c = 4;
            OpptymainupdateforCA.add(opm);
        }
        
        update OpptymainupdateforCA;
        
        for(Opportunity_Maintenance__c opmt : OpptymainupdateforCA){
            opmt.Close_Date__c = Date.Today().addDays(2);
            caOpptymainupdate.add(opmt);
        }
        
        update caOpptymainupdate;
        
        for(Opportunity_Maintenance__c opmaint : caOpptymainupdate){
            opmaint.Active__c = false;
            inactivecaOpptymainupdate.add(opmaint);
        }
        
        update inactivecaOpptymainupdate;
        
        for(Opportunity_Maintenance__c opm : OpptymainforQBS){
            opm.Create_an_Opportunity_before_in_months__c = 4;
            OpptymainupdateforQBS.add(opm);
        }
        
        update OpptymainupdateforQBS;
        
        for(Opportunity_Maintenance__c opmt : OpptymainupdateforQBS){
            opmt.Close_Date__c = Date.Today().addDays(2);
            qbsOpptymainupdate.add(opmt);
        }
        
        update qbsOpptymainupdate;
        
        for(Opportunity_Maintenance__c opmaint : qbsOpptymainupdate){
            opmaint.Active__c = false;
            inactiveqbsOpptymainupdate.add(opmaint);
        }
        
        update inactiveqbsOpptymainupdate;
    }
}