public with sharing class prodregextensions {
//public List<AEQCC_Variance__c> aeqccvariance  {get; set;} 
    Public id prodregid;
    public prodregextensions (ApexPages.StandardController stdController)
    {
        prodregid = stdcontroller.getRecord().id;
    }
    public List<AEQCC_Variance__c> getrelatedCustObjRecs() {
   List<AEQCC_Variance__c> conList = New List<AEQCC_Variance__c>();
       for(Product_Registration__c pr:[select id,name,(select Name, CurrencyIsoCode, Product_Link__c, YTD_Total_Qantas_Revenue__c, LYTD_Total_Qantas_Revenue__c, 
                                                       YTD_Domestic_Qantas_Revenue__c, LYTD_Domestic_Qantas_Revenue__c, YTD_International_Qantas_Revenue__c, 
                                                       LYTD_International_Qantas_Revenue__c, YTD_Domestic_Other_Carrier_Revenue__c, LYTD_Domestic_Other_Carrier_Revenue__c, 
                                                       YTD_International_Other_Carrier_Revenue__c, LYTD_International_Other_Carrier_Revenue__c, YTD_Total_Other_Carrier_Revenue__c, 
                                                       LYTD_Total_Other_Carrier_Revenue__c, YTD_Total_Air_Revenue__c, LYTD_Total_Air_Revenue__c, YTD_Total_Dom_Revenue__c, 
                                                       LYTD_Total_Dom_Revenue__c, YTD_Total_Intl_Revenue__c, LYTD_Total_Intl_Revenue__c, YTD_Domestic_Qantas_Marketshare__c, 
                                                       LYTD_Domestic_Other_Carrier_Marketshare__c, LYTD_Domestic_Qantas_Marketshare__c, YTD_Domestic_Other_Carrier_Marketshare__c, 
                                                       YTD_International_Qantas_Marketshare__c, LYTD_International_Qantas_Marketshare__c, YTD_Int_Other_Carrier_Marketshare__c, 
                                                       LYTD_International_Other_Carrier_Markets__c, YoY_Total_Qantas_Revenue__c, YoY_Domestic_Qantas_Revenue__c, 
                                                       YoY_Domestic_Qantas_Marketshare__c, YoY_Intl_Qantas_Revenue__c, YoY_Intl_Qantas_MarketShare__c, 
                                                       YoY_Total_Other_Carrier_Revenue__c, YoY_Dom_Other_Carrier_Revenue__c, YoY_Dom_Other_Carrier_Marketshare__c, 
                                                       YoY_Intl_Other_Carrier_Revenue__c, YoY_Intl_Other_Carrier_Marketshare__c, YoY_Total_Air_Reveue__c, YoY_Dom_QF_MS_Indicator__c, 
                                                       YoY_Dom_QF_Revenue_Indicator__c, YoY_Intl_QF_MS_Indicator__c, YoY_Intl_QF_Revenue_Indicator__c, YoY_Total_QF_Revenue_Indicator__c, 
                                                       YoY_Total_Air_Revenue_Indicator__c, YoY_Dom_Other_Carrier_MS_Indicator__c, YoY_Dom_Other_Carrier_Revenue_Indicator__c, 
                                                       YoY_Intl_Other_Carrier_MS_Indicator__c, YoY_Intl_Other_Carrier_Revenue_Indicator__c, 
                                                       YoY_Total_Other_Carrier_Revenue_Indicato__c,Reporting_Period__c
                                                       from AEQCC_Variance__r) from Product_Registration__c where id=:prodregid]){
           for(AEQCC_Variance__c aev:pr.AEQCC_Variance__r)
               conList.add(aev); 
       }
       return conList;
    }
}