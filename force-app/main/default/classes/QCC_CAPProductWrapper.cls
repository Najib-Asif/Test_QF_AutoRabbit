/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   QCC CAP Product Wrapper
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
31-Oct-2017      Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_CAPProductWrapper {
    /*--------------------------------------------------------------------------------------      
    Method Name:        CAPProdRequestWrap
    Description:        CAP Product Request Wrapper
    Parameter:          
    --------------------------------------------------------------------------------------*/    
    public class CAPProdRequestWrap{
        public String system_x;
        public String ffNo;
        public String customerId;
        public Long fromTimestamp; 
        public Long toTimestamp;
        public Integer productsPerPage;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        CAPProdResponseWrap
    Description:        
    Parameter:          CAP Product Response Wrapper 
    --------------------------------------------------------------------------------------*/    
    public class CAPProdResponseWrap{
        @AuraEnabled public List<CAPProdInfoWrap> product;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        CAPProdInfoWrap
    Description:        
    Parameter:          CAP Prod Info Wrapper New List 
    --------------------------------------------------------------------------------------*/    
    public class CAPProdInfoWrap{
        @AuraEnabled public String travelPlanID;
        @AuraEnabled public String bookingID;
        @AuraEnabled public String pnr;
        @AuraEnabled public Date pnrCreationDate;
        @AuraEnabled public String type;
        @AuraEnabled public Integer segmentTattoo;
        @AuraEnabled public String mktCarrier;
        @AuraEnabled public String mktFlightNo;
        @AuraEnabled public Date departureDate;
        @AuraEnabled public String departureSTR;
        @AuraEnabled public Date departureUTCDate;
        @AuraEnabled public Time departureTime;
        @AuraEnabled public Time departureUTCTime;
        @AuraEnabled public Long timestamp;
        @AuraEnabled public String departurePort;
        @AuraEnabled public Date arrivalDate;
        @AuraEnabled public Date arrivalUTCDate;
        @AuraEnabled public Time arrivalTime;
        @AuraEnabled public Time arrivalUTCTime;
        @AuraEnabled public String arrivalPort;
    }

}