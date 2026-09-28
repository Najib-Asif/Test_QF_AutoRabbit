public class QCC_PNRSSRInfoWrapper {


	public class Seat {
		public String seatRequestId;
		public String serviceKeywordCode;
		public String serviceSourceCode;
		public String otherTattooReferenceNumber;
		public String passengerSegmentRelationTypeCode;
		public String departureCityCode;
		public String arrivalCityCode;
		public String requestStatusCode;
		public String airlineCarrierAlphaCode;
		public String requestSeatNumber;
		public String specialAssistancePassengerTypeCode;
		public String chargeableIndicator;
		public String serviceTotalFareAmount;
		public String fareCurrencyCode;
		public String serviceGroupCode;
		public String serviceGroupSubCode;
		public String gaugeChangeLocalDate;
		public String partialSegmentIndicator;
		public String additionalText;
		public List<Characteristics> characteristics;
	}

	public Booking booking;
	
	public class Characteristics {
		public String typecode;
		public String code;
	}

	public class Meal {
		public String mealRequestId;
		public String serviceKeywordCode;
		public String serviceSourceCode;
		public String otherTattooReferenceNumber;
		public String passengerSegmentRelationTypeCode;
		public String airlineCarrierAlphaCode;
		public String requestStatusCode;
		public String chargeableIndicator;
		public String serviceTotalFareAmount;
		public String fareCurrencyCode;
		public String serviceGroupCode;
		public String serviceGroupSubCode;
		public String additionalText;
	}

	public class Bag {
		public String bagRequestId;
		public String serviceKeywordCode;
		public String serviceSourceCode;
		public String otherTattooReferenceNumber;
		public String passengerSegmentRelationTypeCode;
		public String departureCityCode;
		public String arrivalCityCode;
		public String requestStatusCode;
		public String chargeableIndicator;
		public String serviceTotalFareAmount;
		public String fareCurrencyCode;
		public String airlineCarrierAlphaCode;
		public String serviceGroupCode;
		public String serviceGroupSubCode;
		public String serviceLocalDate;
		public String serviceConsumedIndicator;
		public String additionalText;
	}

	public class Booking {
		public String reloc;
		public String travelPlanId;
		public String bookingId;
		public String creationDate;
		public String lastUpdatedTimeStamp;
		public List<ServiceRequest> serviceRequest;
	}

	public class Loyalty {
		public String loyaltyRequestId;
		public String serviceKeywordCode;
		public String serviceSourceCode;
		public String otherTattooReferenceNumber;
		public String passengerSegmentRelationTypeCode;
		public String requestStatusCode;
		public String requestCarrierCode;
		public String schemeOperatorCode;
		public String ffCardNumber;
		public String revenueClass;
		public String upgradeClass;
		public String ffUpgradeCertificate;
		public String allianceCarrierCode;
		public String customerValue;
		public String airlinePriorityCode;
		public String airineTierLevelCode;
		public String airlineTierDescription;
		public String alliancePriorityCode;
		public String allianceTierLevelCode;
		public String allianceTierDescription;
		public String validFFIndicator;
		public String serviceActionCode;
		public String additionalText;
	}

	public class Document {
		public String docRequestId;
		public String serviceKeywordCode;
		public String serviceSourceCode;
		public String otherTattooReferenceNumber;
		public String issuingCountryCode;
		public String passengerSegmentRelationTypeCode;
		public String airlineCarrierAlphaCode;
		public String requestStatusCode;
		public String docNumber;
		public String docTypeCode;
		public String firstName;
		public String midName;
		public String lastName;
		public String genderTypeCode;
		public String infantIndicator;
		public String birthDate;
		public String issueDate;
		public String expiryDate;
		public String issuePlaceText;
		public String nationality;
		public String additionalText;
	}

	public class ServiceRequest {
		public String passengerId;
		public String segmentId;
		public String passengerTattoo;
		public String segmentTattoo;
		public List<Loyalty> loyalty;
		public List<Meal> meal;
		public List<Seat> seat;
		public List<Bag> bag;
		public List<Document> document;
		public List<Other> other;
	}

	public class Other {
		public String otherRequestId;
		public String serviceKeywordCode;
		public String serviceSourceCode;
		public String otherTattooReferenceNumber;
		public String passengerSegmentRelationTypeCode;
		public String departureCityCode;
		public String arrivalCityCode;
		public String requestStatusCode;
		public String requestPassengerQuantity;
		public String chargeableIndicator;
		public String serviceTotalFareAmount;
		public String fareCurrencyCode;
		public String requestCarrierCode;
		public String serviceGroupCode;
		public String serviceGroupSubCode;
		public String serviceLocalDate;
		public String serviceConsumedIndicator;
		public String additionalText;
	}

	
	
}