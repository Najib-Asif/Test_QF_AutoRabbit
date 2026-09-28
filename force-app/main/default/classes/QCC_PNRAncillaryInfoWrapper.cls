public class QCC_PNRAncillaryInfoWrapper {


	public String reloc;
	public String travelPlanId;
	public String bookingId;
	public String creationDate;
	public String lastUpdatedTimeStamp;
	public List<Insurance> insurance;
	public List<Accommodation> accommodation;
	public List<Vehicle> vehicle;
	public List<Other> other;

	

	public class Vehicle {
		public String vehicleSegmentId;
		public String segmentTattooReferenceNumber;
		public String segmentSourceCode;
		public String bookingConfirmationNumber;
		public String travelProductSupplyCode;
		public String vehicleCompanyCode;
		public String vehicleCompanyName;
		public String vehicleGradeCode;
		public String segmentStatusCode;
		public VehicleHire vehicleHire;
		public VehicleHireLocation vehicleHireLocation;
		public List<Tariff> tariff;
	}

	public class PickUp {
		public String cityCode;
		public String airportCode;
		public String locationName;
	}

	public class Insurance {
		public String insuranceId;
		public String insuranceTattoo;
		public String policyCode;
		public String policyName;
		public String insuranceConfirmationNumber;
		public String segmentStatusCode;
		public String insuranceStartLocalDate;
		public String insuranceEndLocalDate;
		public String providerCompanyCode;
		public String providerCompanyName;
		public String providerCountryCode;
		public String tripTypeCode;
		public String totalTripAmount;
		public String totalPremiumAmount;
		public String currencyCode;
	}

	public class Tariff {
		public String tariffId;
		public String guestAgeCategoryCode;
		public String ratePlanCode;
		public String rateCategoryCode;
		public String rateTypeCode;
		public String rateChangeIndicator;
		public String rateAmount;
		public String ccyCode;
	}

	public class VehicleHireLocation {
		public PickUp pickUp;
		public PickUp dropOff;
	}

	public class Accommodation {
		public String accommodationSegmentId;
		public String segmentTattooReferenceNumber;
		public String segmentSourceCode;
		public String accommodationBookingReferenceNumber;
		public String bookingConfirmationNumber;
		public String travelProductSupplyCode;
		public String checkinLocalDate;
		public String checkoutLocalDate;
		public String locatedCityCode;
		public String accommodationChainCode;
		public String accommodationChainName;
		public String accommodationPropertyCode;
		public String accommodationPropertyName;
		public String roomsDeliveredQuantity;
		public String segmentStatusCode;
		public List<Tariff> tariff;
	}

	public class VehicleHire {
		public String pickUpLocalTimestamp;
		public String pickUpUTCTimestamp;
		public String dropOffLocalTimestamp;
		public String dropOffUTCTimestamp;
	}

	public class Other {
		public String otherTattooReferenceNumber;
		public String segmentId;
		public String serviceKeywordCode;
		public String serviceSourceCode;
		public String passengerSegmentRelationTypeCode;
		public String departureCityCode;
		public String arrivalCityCode;
		public String requestStatusCode;
		public String requestPassengerQuantity;
		public String chargeableIndicator;
		public String requestCarrierCode;
		public String serviceGroupCode;
		public String serviceGroupSubCode;
		public String serviceLocalDate;
		public String serviceConsumedIndicator;
		public String additionalText;
	}

}