/*********************************************************************************
Name         : QCC_CustomerFlightsWrapper 
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 25 October 2019
Usages       : This class is used in QCC_FeeWaiverRelatedListController
*********************************************************************************/
public class QCC_FeeWaiverWrapper {
    public class FeeWaiverWrapper {    
        public List<DetailWrapper> feeWaivers;
        public String nextPage;
    }
    
    public class DetailWrapper{
        public String travelPlanId;
        public String bookingId;
        public String reloc;
        public String creationDate;
        public String otherTattoo;
        public String category;
        public String subCategoryCode;
        public String feeTypeCode;
        public String points;
        public String amount;
        public String currencyCode;
        public String feeWaiverCreationDate;
        public String creationOffice;
        public String agentSignin;
        public String activeInd;
    }
}