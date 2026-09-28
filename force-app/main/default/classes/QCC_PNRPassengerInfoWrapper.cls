public class QCC_PNRPassengerInfoWrapper {

	@AuraEnabled public Booking booking;
	
	public class Passengers {
        @AuraEnabled public Boolean isAdded;
		@AuraEnabled public String passengerId;
		@AuraEnabled public String passengerTattoo;
		@AuraEnabled public String parentPassengerId;
		@AuraEnabled public String ageCategoryCode;
		@AuraEnabled public String typeCode;
		@AuraEnabled public String passengerWithInfantIndicator;
		@AuraEnabled public String firstName;
		@AuraEnabled public String lastName;
		@AuraEnabled public String prefix;
		@AuraEnabled public String genderTypeCode;
		@AuraEnabled public String birthDate;
		@AuraEnabled public String age;
		@AuraEnabled public String birthCity;
		@AuraEnabled public String birthCountry;
		@AuraEnabled public String uci;
		@AuraEnabled public String staffTravelType;
		@AuraEnabled public String additionalText;
		@AuraEnabled public String smeId;
		@AuraEnabled public String corpId;
		@AuraEnabled public String cemCustId;
		@AuraEnabled public String qantasFFNo;
		@AuraEnabled public String qantasUniqueId;
	}

	public class Booking {
		@AuraEnabled public String reloc;
		@AuraEnabled public String travelPlanId;
		@AuraEnabled public String bookingId;
		@AuraEnabled public String creationDate;
		@AuraEnabled public String currentPassengerQuantity;
		@AuraEnabled public String lastUpdatedTimeStamp;
		@AuraEnabled public List<Passengers> passengers;
	}

	
}