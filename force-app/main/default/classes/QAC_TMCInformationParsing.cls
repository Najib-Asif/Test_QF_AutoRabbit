/*
 * Created By : Shoban P | TCS
 * Purpose : to create API for TMC Operations and responses for the same
*/
global class QAC_TMCInformationParsing {
    
    global String gdsCode           {get; set;}
    global String pseudoCityCode    {get; set;}
    global Boolean isActive         {get; set;}
    global String agencyProductFare {get; set;}
    global String name              {get; set;}
    global DateTime lastInactiveDate {get; set;}
    global String id                {get;set;} 
    global Id accountId             {get;set;}
    
    public QAC_TMCInformationParsing(Agency_Info__c tmcInfo){
        this.id             = tmcInfo.Id;
        this.name               = tmcInfo.Name;  
        this.gdsCode            = tmcInfo.Code__c;
        this.pseudoCityCode     = tmcInfo.PCC__c;    
        this.agencyProductFare  = tmcInfo.Agency_Product_Fares__c;
        this.isActive           = tmcInfo.Active__c;  
        this.lastInactiveDate   = tmcInfo.Last_Inactive_Date__c;
    }
    
    public static QAC_TMCInformationParsing parser(String json) {
        return (QAC_TMCInformationParsing) System.JSON.deserialize(json, QAC_TMCInformationParsing.class);
    }
}