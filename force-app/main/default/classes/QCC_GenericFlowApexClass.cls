public class QCC_GenericFlowApexClass {
    
    @InvocableMethod
    public static List<String> callMethodWithName(list<inputParameter> inputParam) {       
        string methodName = '';
        List<id> recordIds = new list<id>();
        List<String> retResults = new List<String>();
        for(inputParameter iparam : inputParam){
            methodName = iparam.methodName;
            recordIds.addall(iparam.recordIds);
            retResults.add('matchWithInputParmSize');
        }
        if(methodName == 'Call_TV_API'){
            System.enqueueJob(new QCC_TravelVoucherCall(recordIds));
        }
     /* //bank search API to be called in a chained way from currency conversion api: 21/8/2024:CDP2-531:Sourabh  
        if(methodName == 'Call_BankSearch_API'){
            System.enqueueJob(new QCC_BankSearchCall(recordIds));
        } */
        if(methodName == 'Call_CurrencyConversion_API'){
            System.enqueueJob(new QCC_CurrencyConversionCall(recordIds));
        }
        return retResults;
    }
    public class inputParameter{
        @InvocableVariable public List<id> recordIds;
        @InvocableVariable public String methodName;
    }
}