public class QCC_FlightInfoResponse {
	public List<flight> flights{get;set;}
	public String errorMessage{get;set;}
	public class flight{
		public String marketingCarrier{get;set;}
		public String marketingFlightNo{get;set;}
		public String suffix{get;set;}
		public String departureAirportCode{get;set;}
		public String departureAirportName{get;set;}
		public String arrivalAirportCode{get;set;}
		public String arrivalAirportName{get;set;}
		public String departureTerminal{get;set;}
		public String departureGate{get;set;}
		public String arrivalTerminal{get;set;}
		public String arrivalGate{get;set;}
		public String equipmentTailNumber{get;set;}
		public String equipmentTypeCode{get;set;}
		public String equipmentSubTypeCode{get;set;}
		public String flightStatus{get;set;}
		public String flightDuration{get;set;}
		public String delayDuration{get;set;}
		public String scheduledDepartureUTCTimeStamp{get;set;}
		public String estimatedDepartureUTCTimeStamp{get;set;}
		public String actualDepartureUTCTimeStamp{get;set;}
		public String scheduledArrivalUTCTimeStamp{get;set;}
		public String estimatedArrivalUTCTimeStamp{get;set;}
		public String actualArrivalUTCTimeStamp{get;set;}
		public String scheduledDepartureLocalTimeStamp{get;set;}
		public String estimatedDepartureLocalTimeStamp{get;set;}
		public String actualDepartureLocalTimeStamp{get;set;}
		public String scheduledArrivalLocalTimeStamp{get;set;}
		public String estimatedArrivalLocalTimeStamp{get;set;}
		public String actualArrivalLocalTimeStamp{get;set;}
		public String primaryBaggageCarousel{get;set;}
		public String secondaryBaggageCarousel{get;set;}
		public AirDiversion airDiversion;
		public List<Delay> delay{get;set;}
	}

	public class AirDiversion {
		public String unScheduledArrivalAirport;
		public String scheduledDepartureUTCTimeStamp;
		public String estimatedDepartureUTCTimeStamp;
		public String actualDepartureUTCTimeStamp;
		public String scheduledArrivalUTCTimeStamp;
		public String estimatedArrivalUTCTimeStamp;
		public String actualArrivalUTCTimeStamp;
		public String scheduledDepartureLocalTimeStamp;
		public String estimatedDepartureLocalTimeStamp;
		public String actualDepartureLocalTimeStamp;
		public String scheduledArrivalLocalTimeStamp;
		public String estimatedArrivalLocalTimeStamp;
		public String actualArrivalLocalTimeStamp;
	}
	public class Delay {
		public String reasonCode;	//max 3 chars
		public String shortDescription;	//max 40 chars
		public String longDescription;	//max 200 chars
		public String delayDuration;	//max 4 chars tiny int as string
	}
}