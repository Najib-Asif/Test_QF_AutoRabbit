public class QAC_PNRDetailsWrapper {
    
    @AuraEnabled public list<FlightDetailsWrapper> flightDetailsWrapper         = new list<FlightDetailsWrapper>();
    @AuraEnabled public list<PassengerDetailsWrapper> passengerDetailsWrapper   = new list<PassengerDetailsWrapper>();
    @AuraEnabled public CaseDefaultValues caseFields;
    @AuraEnabled public PointOfSalesWrapper pointSales;
    
    public Class PointOfSalesWrapper {
        @AuraEnabled public QAC_PointOfSalesParser.PointofSale pointOfSales {get; set;}

        public PointOfSalesWrapper(QAC_PointOfSalesParser.PointofSale pointSales ){
            this.pointOfSales       = pointSales;
        }
    }
    
    public Class FlightDetailsWrapper {
        @AuraEnabled public QCC_PNRFlightInfoWrapper.segments flightDetails {get; set;}
        @AuraEnabled public Boolean selectedFlight {get; set;}
        
        public FlightDetailsWrapper(QCC_PNRFlightInfoWrapper.segments flightDetails, Boolean selected ){
            this.flightDetails      = flightDetails;
            this.selectedFlight     = selected;
        }
    }
    
    public Class PassengerDetailsWrapper {
        @AuraEnabled public QCC_PNRPassengerInfoWrapper.Passengers passengerDetails {get; set;}
        @AuraEnabled public Boolean selectedFlight {get; set;}
        
        public PassengerDetailsWrapper(QCC_PNRPassengerInfoWrapper.Passengers passengerDetails, Boolean selected ){
            this.passengerDetails       = passengerDetails;
            this.selectedFlight         = selected;
        }
    }
    
    public Class CaseDefaultValues{
        @AuraEnabled public Account iataAccount;
        @AuraEnabled public String caseStatus;
        @AuraEnabled public String caseOrigin;
        @AuraEnabled public String pnrNumber;
        @AuraEnabled public String abnNumber;
        @AuraEnabled public String qciCode;
        @AuraEnabled public String passengerName;
        @AuraEnabled public String passengerCount;
        @AuraEnabled public String travelAgentId;
        @AuraEnabled public String firstFligtNumber;
        @AuraEnabled public Date firstFligtDate;
        @AuraEnabled public String gdsValue;

        public CaseDefaultValues(Account acc, String caseSta, String caseOrgn, String pnrNum, String abnNum,String qciCode, String passName, String count, String travelAgentId, String firstFlightNumber, Date firstFlightDate, String gdsValue){
            this.iataAccount = acc;
            this.caseStatus = caseSta;
            this.caseOrigin = caseOrgn;
            this.pnrNumber  = pnrNum;
            this.abnNumber  = abnNum;
            this.qciCode    = qciCode;
            this.passengerName = passName;
            this.passengerCount = count;
            this.travelAgentId = travelAgentId;
            this.firstFligtNumber = firstFlightNumber;
            this.firstFligtDate = firstFlightDate;
            this.gdsValue = gdsValue;
        }
    }
}