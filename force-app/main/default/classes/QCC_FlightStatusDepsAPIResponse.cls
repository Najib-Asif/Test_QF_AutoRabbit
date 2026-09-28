/*********************************************************************************
Name         : QCC_FlightStatusDepsAPIResponse
Created By   : Leslie Padilla
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE-469
Created Date : 09 September 2019
Usages       : This is the API response class for Flight Status per Departure API
			  
*********************************************************************************/
public class QCC_FlightStatusDepsAPIResponse {
    
    public static QCC_FlightStatusDepsAPIResponse parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new QCC_FlightStatusDepsAPIResponse(parser);
    }
    
    public QCC_FlightStatusDepsAPIResponse(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'flights') {
                        flights = arrayOfFlights(parser);
                    } else if (text == 'lastUpdatedDateTime') {
                        lastUpdatedDateTime = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'QCC_FlightStatusDepsAPIResponse consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public List<Flights> flights {get;set;} 
    public String lastUpdatedDateTime {get;set;} 
    
    private static List<Flights> arrayOfFlights(System.JSONParser p) {
        List<Flights> res = new List<Flights>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Flights(p));
        }
        return res;
    }
    
    public class Flights {
        public List<FlightNumbers> flightNumbers {get;set;} 
        public List<Sectors> sectors {get;set;} 
        
        public Flights(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'flightNumbers') {
                            flightNumbers = arrayOfFlightNumbers(parser);
                        } else if (text == 'sectors') {
                            sectors = arrayOfSectors(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Flights consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    private static List<FlightNumbers> arrayOfFlightNumbers(System.JSONParser p) {
        List<FlightNumbers> res = new List<FlightNumbers>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FlightNumbers(p));
        }
        return res;
    }
    
    private static List<Sectors> arrayOfSectors(System.JSONParser p) {
        List<Sectors> res = new List<Sectors>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Sectors(p));
        }
        return res;
    }
    
    public class FlightNumbers {
        public String airline {get;set;} 
        public Integer code {get;set;} 
        public Boolean primary {get;set;} 
        public String originDate {get;set;} 
        public String threeLetterAirline {get;set;} 
        
        public FlightNumbers(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'airline') {
                            airline = parser.getText();
                        } else if (text == 'code') {
                            code = parser.getIntegerValue();
                        } else if (text == 'primary') {
                            primary = parser.getBooleanValue();
                        } else if (text == 'originDate') {
                            originDate = parser.getText();
                        } else if (text == 'threeLetterAirline') {
                            threeLetterAirline = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'FlightNumbers consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
        
    
    public class Sectors {
        public String sectorId {get;set;} 
        public String from_Z {get;set;} // in json: from
        //public String departurePort {get;set;} // in json: from
        public String to {get;set;} 
        public Departure departure {get;set;} 
        public Arrival arrival {get;set;} 
        public String sectorDiversion {get;set;} 
        
        public Sectors(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'sectorId') {
                            sectorId = parser.getText();
                        } else if (text == 'from') {
                            from_Z = parser.getText();
                            //departurePort = parser.getText();
                        } else if (text == 'to') {
                            to = parser.getText();
                        } else if (text == 'departure') {
                            departure = new Departure(parser);
                        } else if (text == 'arrival') {
                            arrival = new Arrival(parser);
                        } else if (text == 'sectorDiversion') {
                            sectorDiversion = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Sectors consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Departure {
        public String estimated {get;set;} 
        public String actual {get;set;} 
        public String scheduled {get;set;} 
        public String status {get;set;} 
        public String terminal {get;set;} 
        public String gate {get;set;} 
        public String boardingStatus {get;set;} 
        public Boolean eligibleForSubscription {get;set;} 
        
        public Departure(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'estimated') {
                            estimated = parser.getText();
                        } else if (text == 'actual') {
                            actual = parser.getText();
                        } else if (text == 'scheduled') {
                            scheduled = parser.getText();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'terminal') {
                            terminal = parser.getText();
                        } else if (text == 'gate') {
                            gate = parser.getText();
                        } else if (text == 'boardingStatus') {
                            boardingStatus = parser.getText();
                        } else if (text == 'eligibleForSubscription') {
                            eligibleForSubscription = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Departure consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Arrival {
        public String estimated {get;set;} 
        public String actual {get;set;} 
        public String scheduled {get;set;} 
        public String status {get;set;} 
        public String terminal {get;set;} 
        public String gate {get;set;} 
        public Boolean eligibleForSubscription {get;set;} 
        
        public Arrival(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'estimated') {
                            estimated = parser.getText();
                        } else if (text == 'actual') {
                            actual = parser.getText();
                        } else if (text == 'scheduled') {
                            scheduled = parser.getText();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'terminal') {
                            terminal = parser.getText();
                        } else if (text == 'gate') {
                            gate = parser.getText();
                        } else if (text == 'eligibleForSubscription') {
                            eligibleForSubscription = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Arrival consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
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
    
    /*
    private static List<FlightNumbers_Y> arrayOfFlightNumbers_Y(System.JSONParser p) {
        List<FlightNumbers_Y> res = new List<FlightNumbers_Y>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FlightNumbers_Y(p));
        }
        return res;
    }
    */
    
    
    private static List<FlightNumbers_Z> arrayOfFlightNumbers_Z(System.JSONParser p) {
        List<FlightNumbers_Z> res = new List<FlightNumbers_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FlightNumbers_Z(p));
        }
        return res;
    }
    
    public class FlightNumbers_Z {
        public String airline {get;set;} 
        public Integer code {get;set;} 
        public Boolean primary {get;set;} 
        public String originDate {get;set;} 
        public String threeLetterAirline {get;set;} 
        public String registrationNumber {get;set;} 
        
        public FlightNumbers_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'airline') {
                            airline = parser.getText();
                        } else if (text == 'code') {
                            code = parser.getIntegerValue();
                        } else if (text == 'primary') {
                            primary = parser.getBooleanValue();
                        } else if (text == 'originDate') {
                            originDate = parser.getText();
                        } else if (text == 'threeLetterAirline') {
                            threeLetterAirline = parser.getText();
                        } else if (text == 'registrationNumber') {
                            registrationNumber = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'FlightNumbers_Z consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    
    /*
    private static List<FlightNumbers> arrayOfFlightNumbers(System.JSONParser p) {
        List<FlightNumbers> res = new List<FlightNumbers>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FlightNumbers(p));
        }
        return res;
    }
    */
}