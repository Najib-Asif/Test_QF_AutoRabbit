global class QAC_TMCInsertionResponse {
    
    global String gdsCode           {get; set;}
    global String tmcId             {get; set;}
    global Boolean active           {get; set;}
    global String accountId         {get; set;}
    
    public QAC_TMCInsertionResponse(Agency_Info__c tmcInfo){
        this.accountId          = tmcInfo.Account__c;
        this.tmcId              = tmcInfo.Id;  
        this.gdsCode            = tmcInfo.Code__c;
        this.active             = tmcInfo.Active__c;
    }

}