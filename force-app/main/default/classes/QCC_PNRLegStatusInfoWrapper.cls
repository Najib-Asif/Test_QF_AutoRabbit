public class QCC_PNRLegStatusInfoWrapper {

	public class Acceptance {
		public String statusCode;
		public String originTypeCode;
		public String channelTypeCode;
		public String cancelReasonCode;
	}

	public Booking booking;
	
	public class PassengerFlightStatus {
		public String passengerSegmentId;
		public String segmentId;
		public String passengerId;
		public String passengerTattoo;
		public String segmentTattoo;
		public String travellerProductId;
		public String reservationStatusCode;
		public String bookedCabinClass;
		public String bookedReservationClass;
		public List<Leg> leg;
	}

	public class Booking {
		public String reloc;
		public String travelPlanId;
		public String bookingId;
		public String creationDate;
		public String lastUpdatedTimeStamp;
		public List<PassengerFlightStatus> passengerFlightStatus;
	}

	public class Regrade {
		public String statusCode;
		public String authorizer;
		public String reasonCode;
		public String targetCabinClass;
	}

	public class CheckinBag {
		public String checkInBagId;
		public String poolId;
		public String tagNumber;
		public String referenceId;
		public String acceptanceStatusCode;
		public String sourceTypeCode;
		public String tagTypeCode;
		public String airlineCarrierNumberCode;
		public String bagJourneyOriginAirportCode;
		public String finalDestinationAirportCode;
		public String weight;
		public String specialRequirementTypeCode;
		public String comment;
	}

	public class Leg {
		public String legId;
		public String originAirportCode;
		public String destinationAirportCode;
		public String otherTattoo;
		public String bagPoolId;
		public String hoPoolIndicator;
		public String legSequenceNumber;
		public String seatNumber;
		public String seatPreferenceCode;
		public String onLoadStatusCode;
		public String forcedAcceptanceIndicator;
		public String freezeAcceptanceIndicator;
		public String boardingPassPrintStatusCode;
		public String baggageStatusCode;
		public Acceptance acceptance;
		public String boardingStatusCode;
		public String customerRecordStatusCode;
		public String waitListStatusCode;
		public String transferStatusCode;
		public Regrade regrade;
		public String checkinCarrierCode;
		public String involuntaryCompensationIndicator;
		public String compensationStatusCode;
		public String compensationReasonText;
		public List<CheckinBag> checkinBag;
	}
}