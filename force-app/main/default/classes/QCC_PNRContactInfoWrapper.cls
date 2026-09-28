public class QCC_PNRContactInfoWrapper {

	@AuraEnabled public Booking booking;
	
	public class Email {
		@AuraEnabled public String emailId;
		@AuraEnabled public String otherTattooReference;
		@AuraEnabled public String keywordCode;
		@AuraEnabled public String sourceCode;
		@AuraEnabled public String infoTypeCode;
		@AuraEnabled public String emailText;
		@AuraEnabled public String airlineCarrierAlphaCode;
		@AuraEnabled public List<String> passengerIds;
	}

	

	public class Contacts {
		@AuraEnabled public List<Email> email;
		@AuraEnabled public List<Phone> phone;
	}

	public class Phone {
		@AuraEnabled public String phoneId;
		@AuraEnabled public String otherTattooReference;
		@AuraEnabled public String keywordCode;
		@AuraEnabled public String sourceCode;
		@AuraEnabled public String infoTypeCode;
		@AuraEnabled public String countryCode;
		@AuraEnabled public String areaCode;
		@AuraEnabled public String phoneNumber;
		@AuraEnabled public String typeCode;
		@AuraEnabled public String phoneText;
		@AuraEnabled public String airlineCarrierAlphaCode;
		@AuraEnabled public List<String> passengerIds;
	}

	public class Booking {
		@AuraEnabled public String reloc;
		@AuraEnabled public String travelPlanId;
		@AuraEnabled public String bookingId;
		@AuraEnabled public String creationDate;
		@AuraEnabled public String lastUpdatedTimeStamp;
		@AuraEnabled public Contacts contacts;
	}

	
	
}