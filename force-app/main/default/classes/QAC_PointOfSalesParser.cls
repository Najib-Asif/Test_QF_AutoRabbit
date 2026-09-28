public class QAC_PointOfSalesParser {

	@AuraEnabled public Booking booking {get;set;} 

	public QAC_PointOfSalesParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'booking') {
						booking = new Booking(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'QAC_PointOfSalesParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class ExternalBookingReferences {
		@AuraEnabled public String airlineCode {get;set;} 
		@AuraEnabled public String reloc {get;set;} 
		@AuraEnabled public String type_Z {get;set;} // in json: type

		public ExternalBookingReferences(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'airlineCode') {
							airlineCode = parser.getText();
						} else if (text == 'reloc') {
							reloc = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ExternalBookingReferences consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PointofSale {
        
		@AuraEnabled public CreatorDetails creatorDetails {get;set;} 
		@AuraEnabled public CreatorDetails ownerDetails {get;set;} 

		public PointofSale(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'creatorDetails') {
							creatorDetails = new CreatorDetails(parser);
						} else if (text == 'ownerDetails') {
							ownerDetails = new CreatorDetails(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'PointofSale consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Booking {
		@AuraEnabled public String reloc {get;set;} 
		@AuraEnabled public String travelPlanId {get;set;} 
		@AuraEnabled public String bookingId {get;set;} 
		@AuraEnabled public String creationDate {get;set;} 
		@AuraEnabled public Integer currentPassengerQuantity {get;set;} 
		@AuraEnabled public String lastUpdatedTimeStamp {get;set;} 
		@AuraEnabled public PointofSale pointofSale {get;set;} 
		@AuraEnabled public List<ExternalBookingReferences> externalBookingReferences {get;set;} 

		public Booking(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'reloc') {
							reloc = parser.getText();
						} else if (text == 'travelPlanId') {
							travelPlanId = parser.getText();
						} else if (text == 'bookingId') {
							bookingId = parser.getText();
						} else if (text == 'creationDate') {
							creationDate = parser.getText();
						} else if (text == 'currentPassengerQuantity') {
							currentPassengerQuantity = parser.getIntegerValue();
						} else if (text == 'lastUpdatedTimeStamp') {
							lastUpdatedTimeStamp = parser.getText();
						} else if (text == 'pointofSale') {
							pointofSale = new PointofSale(parser);
						} else if (text == 'externalBookingReferences') {
							externalBookingReferences = arrayOfExternalBookingReferences(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Booking consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CreatorDetails {
		@AuraEnabled public String travelAgentId {get;set;} 
		@AuraEnabled public String inHouseIdentification {get;set;} 
		@AuraEnabled public String agentType {get;set;} 
		@AuraEnabled public String companyId {get;set;} 
		@AuraEnabled public String locationId {get;set;} 
		@AuraEnabled public String countryCode {get;set;} 

		public CreatorDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'travelAgentId') {
							travelAgentId = parser.getText();
						} else if (text == 'inHouseIdentification') {
							inHouseIdentification = parser.getText();
						} else if (text == 'agentType') {
							agentType = parser.getText();
						} else if (text == 'companyId') {
							companyId = parser.getText();
						} else if (text == 'locationId') {
							locationId = parser.getText();
						} else if (text == 'countryCode') {
							countryCode = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CreatorDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static QAC_PointOfSalesParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new QAC_PointOfSalesParser(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<ExternalBookingReferences> arrayOfExternalBookingReferences(System.JSONParser p) {
        List<ExternalBookingReferences> res = new List<ExternalBookingReferences>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ExternalBookingReferences(p));
        }
        return res;
    }

}