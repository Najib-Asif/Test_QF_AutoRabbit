public with sharing class AEQCCrebate {
Public id prodregid;
    public AEQCCrebate (ApexPages.StandardController stdController)
    {
        prodregid = stdcontroller.getRecord().id;
    }
  public List<AEQCC_Rebates__c> getrelatedCustObjRecs1() {  
      List<AEQCC_Rebates__c> conList = New List<AEQCC_Rebates__c>();
        for(Product_Registration__c pr:[select id,name,(select Name,CurrencyIsoCode,Cheque_Amount__c,Date_Processed__c,Prod_Reg_Link__c,
                                                        Rebate_Payment__c,Rebate_Sent_to__c,Rebate_term__c,Rebate_Tier__c,Rebate_Year__c
                                                        from AEQCC_Rebates__r order by Rebate_Year__c DESC,Rebate_term__c DESC) from Product_Registration__c where id=:prodregid ])
            {
           for(AEQCC_Rebates__c aer:pr.AEQCC_Rebates__r)
               conList.add(aer); 
       }
       return conList;
  
  }

}