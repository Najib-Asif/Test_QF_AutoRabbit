/*==================================================================================================================================
Author:         Abhieet P
Company:        TCS
Purpose:        Freight - Class will be used for parsing the response recieved by iCargo system in JSON format.
Date:           03/08/2017         
TestClass:      Freight_AWBRequestJsonTest

==================================================================================================================================

==================================================================================================================================*/
public class Freight_AWBResponseParsing {
    
    
    /*public class LatestStatus {
public String station;
public String milestone;
public String shipmentdate;
public String weight;
public String pieces;
public string flightDetails;
public String unit;
}

public String xmlnssoapenv;
public ShipmentMilestones shipmentMilestones;


public class ShipmentMilestones {
public ShipmentsTracked shipmentsTracked;
public ShipmentSummary Shipmentsummary; 
public unitOfMeasures unitofmeasures;
}

public class ShipmentsTracked {
public String shipmentPrefix;
public String masterDocumentNumber;
public String origin;
public String destination;
public String consigneeName;
public String shipperName;        
public String shipmentDescription;
public String handlingCode;
public String pieces;
public String weight;
public String weightUnit;
public string units;
public LatestStatus latestStatus;
public List<LatestStatus> history;
}*/
    /*================================================================================================================================== 
Jira CRM-6919  
==================================================================================================================================  */
    public String xmlnssoapenv;
    public shipmentSummary Shipmentsummary;   
    public unitOfMeasures unitOfmeasures;
    public class shipmentSummary{
        public String awb;
        public String origin;
        public String originStationName;
        public String destination;
        public String destinationStationName;
        public String statedPieces;
        public String statedWeight;
        public String statedVolume;
        public String shipmentDescription;
        public String handlingCodes;
        public String product;
        public String agent;
        public String consigneeName;
        public String shipperName;
        public String subProduct;
        public stageSummary stageSummarys;
        public String bookingStatus;
        //public String shipmentOriginName;
        //public String shipmentDestinationName;
        //public String shipmentOriginCode;
        //public String shipmentDestinationCode;
        //public String totalPieces;
        //public String totalWeight;
        //public Double totalVolume;
        //public String productName;
        //public String agentName;
        public shipmentSummary(String awb, String origin, String originStationName, String destination, 
                               String destinationStationName, String statedPieces, String statedWeight, String statedVolume,
                               String shipmentDescription, String handlingCodes, String product, String agent, 
                               String consigneeName, String shipperName, String subProduct, stageSummary ss)
        {
            this.awb = awb;
            this.origin = origin;
            this.originStationName = originStationName;
            this.destination = destination;
            this.destinationStationName = destinationStationName;
            this.statedPieces = statedPieces;
            this.statedWeight = statedWeight;
            this.statedVolume = statedVolume;
            this.shipmentDescription = shipmentDescription;
            this.handlingCodes = handlingCodes;
            this.product = product;
            this.agent = agent;
            this.consigneeName = consigneeName;
            this.shipperName = shipperName;
            this.subProduct = subProduct;
            this.stageSummarys = ss;
        }
        
        
        public shipmentSummary(String awb, String origin, String originStationName, String destination, 
                               String destinationStationName, String statedPieces, String statedWeight, String statedVolume,
                               String shipmentDescription, String handlingCodes, String product, String agent, 
                               String consigneeName, String shipperName, String subProduct, stageSummary ss, String bookingStatus)
        {
            this.awb = awb;
            this.origin = origin;
            this.originStationName = originStationName;
            this.destination = destination;
            this.destinationStationName = destinationStationName;
            this.statedPieces = statedPieces;
            this.statedWeight = statedWeight;
            this.statedVolume = statedVolume;
            this.shipmentDescription = shipmentDescription;
            this.handlingCodes = handlingCodes;
            this.product = product;
            this.agent = agent;
            this.consigneeName = consigneeName;
            this.shipperName = shipperName;
            this.subProduct = subProduct;
            this.stageSummarys = ss;
            this.bookingStatus = bookingStatus;
        }

        public String getAwb() { return this.awb; }
        public String getOrigin() { return this.origin; }
        public String getOriginStationName() { return this.originStationName; }
        public String getDestination() { return this.destination; }
        public String getDestinationStationName() { return this.destinationStationName; }
        public String getStatedPieces() { return this.statedPieces; }
        public String getStatedWeight() { return this.statedWeight; }
        public String getStatedVolume() { return this.statedVolume; }
        public String getShipmentDescription() { return this.shipmentDescription; }
        public String getHandlingCodes() { return this.handlingCodes; }
        public String getProduct() { return this.product; }
        public String getAgent() { return this.agent; }
        public String getConsigneeName() { return this.consigneeName; }
        public String getShipperName() { return this.shipperName; }
        public String getSubProduct() { return this.subProduct; }
        public stageSummary getStageSummarys() { return this.stageSummarys; }
        public String getBookingStatus() { return this.bookingStatus; }

    }
    public class stageSummary{
        public String STAGE_BOOKED;
        public String STAGE_DELIVERY;
        public String STAGE_GOT_YOUR_FREIGHT;
        public String STAGE_INTRANSIT;
        public String STAGE_PREDELIVERY;
        
        public stageSummary(String sb, String sd, String sgyf, String si, String sp)
        {
            this.STAGE_BOOKED = sb;
            this.STAGE_DELIVERY = sd;
            this.STAGE_GOT_YOUR_FREIGHT = sgyf;
            this.STAGE_INTRANSIT = si;
            this.STAGE_PREDELIVERY = sp;
        }
    }
    
    
    public List<shipmentHistory> shipmenthistory= new List<shipmentHistory>();
    public class shipmentHistory{
        public String eventType;
        public String airportCode;
        Public String transactionDate;
        public String transactionDateUtc;
        public String pieces;
        public String weight;
        public eventDetail eventDetails;
        public flightDetail flightDetails;
        public String eventName;
        //V2 structure CRM- 8081
        public String bookingSequence;
        public String stageCode;
        public String stageName;
        public String isLatest;
        
        public shipmentHistory(String eventType, String airportCode, String transactionDate, String transactionDateUtc, 
                               String pieces, String weight, eventDetail eventDetails, flightDetail flightDetails, 
                               String eventName, String bookingSequence, String stageCode, String stageName, String isLatest) 
        {
            this.eventType = eventType;
            this.airportCode = airportCode;
            this.transactionDate = transactionDate;
            this.transactionDateUtc = transactionDateUtc;
            this.pieces = pieces;
            this.weight = weight;
            this.eventDetails = eventDetails;
            this.flightDetails = flightDetails;
            this.eventName = eventName;
            this.bookingSequence = bookingSequence;
            this.stageCode = stageCode;
            this.stageName = stageName;
            this.isLatest = isLatest;
        }

        public eventDetail getEventDetails() { return this.eventDetails;}
    }
    public class flightDetail{
        public String segmentOrigin;
        public String segmentDestination;
        public String flightNumber;
        public String flightDepartureDate;
        public String departureDateStatus;
        public String flightArrivalDate;
        public String arrivalDateStatus;
        //V2 structure CRM- 8081
        public String departureStatus;
        public String arrivalStatus;
        
        public flightDetail(String segmentOrigin, String segmentDestination, String flightNumber, String flightDepartureDate,
                            String departureDateStatus, String flightArrivalDate, String arrivalDateStatus, 
                            String departureStatus, String arrivalStatus)
        {
            this.segmentOrigin = segmentOrigin;
            this.segmentDestination = segmentDestination;
            this.flightNumber = flightNumber;
            this.flightDepartureDate = flightDepartureDate;
            this.departureDateStatus = departureDateStatus;
            this.flightArrivalDate = flightArrivalDate;
            this.arrivalDateStatus = arrivalDateStatus;
            this.departureStatus = departureStatus;
            this.arrivalStatus = arrivalStatus;
        }
    }
    
    public class eventDetail{
        public String uldNumber;
        public String discrepancyReasoncode;
        
        public eventDetail(String uldNumber, string discrepancyReasoncode) {
            this.uldNumber = uldNumber;
            this.discrepancyReasoncode = discrepancyReasoncode ;
        }
        
        public String getUldNumber() { return this.uldNumber; }
        public String getDiscrepancyReasoncode() { return this.discrepancyReasoncode; }
    }
    
    public class unitOfMeasures{
        public String weight;
        public String volume;
        public String length;
        
        public unitOfMeasures(String weight, String volume, String length) {
            this.weight = weight;
            this.volume = volume;
            this.length = length;
        }

        public String getWeight() { return this.weight; }
    }
    /*--Start of V2 Structure CRM-8081--*/
    Public class shipmentStages{
        public STAGE_BOOKED STAGE_BOOKEDS; 
        public STAGE_GOT_YOUR_FREIGHT  STAGE_GOT_YOUR_FREIGHTs;
        public string STAGE_INTRANSIT;
        public string STAGE_PREDELIVERY;
        public string TAGE_DELIVERY;
        public List<events> eventss= new List<events>();
        public string status;
        
    }
    
    public class STAGE_BOOKED{
        public List<events> eventss= new List<events>();
        public string status;
    }
    public class STAGE_GOT_YOUR_FREIGHT{
        public List<events> eventss= new List<events>();
        public string status;
    }
    public class STAGE_INTRANSIT{
        public List<events> eventss= new List<events>();
        public string status;
    }
    public class STAGE_PREDELIVERY{
        public List<events> eventss= new List<events>();
        public string status;
    }
    public class STAGE_DELIVERY{
        public List<events> eventss= new List<events>();
        public string status;
    }
    
    public class events{
        public String eventType;
        public String airportCode;
        Public String transactionDate;
        public String transactionDateUtc;
        public String pieces;
        public String weight;
        public eventDetail eventDetails;
        public flightDetail flightDetails;
        public String eventName;
        public String bookingSequence;
        public String stageCode;
        public String stageName;
        public String isLatest;
    }
    public class ShipmentsTracked {
        public String shipmentPrefix;
        public String masterDocumentNumber;
        public String consigneeName;
        public String shipperName;        
        public string units;
        
    }
    public Freight_AWBResponseParsing(shipmentSummary ss, unitOfMeasures uom, List<shipmentHistory> sh) 
    {
        this.Shipmentsummary = ss;
        this.unitOfMeasures = uom;
        this.shipmentHistory = sh;
    }

    public shipmentSummary getShipmentSummary() { return this.Shipmentsummary; }
    public unitOfMeasures getUnitOfmeasures() { return this.unitOfmeasures; }
    public List<shipmentHistory> getShipmenthistory() { return this.shipmenthistory; }
    
    /*--End of V2 Structure CRM-8081--*/
    public static Freight_AWBResponseParsing parse(String json) {
        return (Freight_AWBResponseParsing) System.JSON.deserialize(json, Freight_AWBResponseParsing.class);
    }
    
    public static Freight_AWBResponseParsing parseWithoutJsonException(String jsonContent) {
        Map<String, Object> jsonMap = (Map<String, Object>) System.JSON.deserializeUntyped(jsonContent);
        Map<String, Object> objMap, objMap1;
        List<Object> objList;
        Freight_AWBResponseParsing.shipmentSummary shipmentSummary = null;
        Freight_AWBResponseParsing.unitOfMeasures unitOfMeasures = null;
        List<Freight_AWBResponseParsing.shipmentHistory> shipmentHistories = new List<Freight_AWBResponseParsing.shipmentHistory>();
        Freight_AWBResponseParsing.stageSummary stageSummary = null;
        Freight_AWBResponseParsing.eventDetail eventDetails = null;
        Freight_AWBResponseParsing.flightDetail flightDetails = null;
        objMap = convertAllValuesToString(jsonMap.get('shipmentSummary'));
        if (objMap != null) {
            objMap1 = convertAllValuesToString(objMap.get('stageSummary'));
            if (objMap1 != null) {
                stageSummary = new Freight_AWBResponseParsing.stageSummary( 
                    (String) objMap1.get('STAGE_BOOKED'),
                    (String) objMap1.get('STAGE_DELIVERY'), 
                    (String) objMap1.get('STAGE_GOT_YOUR_FREIGHT'),
                    (String) objMap1.get('STAGE_INTRANSIT'), 
                    (String) objMap1.get('STAGE_PREDELIVERY')
                );
            }
            shipmentSummary = new Freight_AWBResponseParsing.shipmentSummary(
                (String) objMap.get('awb'),
                (String) objMap.get('origin'), 
                (String) objMap.get('originStationName'),
                (String) objMap.get('destination'),
                (String) objMap.get('destinationStationName'),
                (String) objMap.get('statedPieces'),
                (String) objMap.get('statedWeight'),
                (String) objMap.get('statedVolume'),
                (String) objMap.get('shipmentDescription'), 
                (String) objMap.get('handlingCodes'), 
                (String) objMap.get('product'), 
                (String) objMap.get('agent'),
                (String) objMap.get('consigneeName'), 
                (String) objMap.get('shipperName'), 
                (String) objMap.get('subProduct'), 
                stageSummary,
                (String) objMap.get('bookingStatus')
            );
        }
        System.debug('shipmentSummary - ' + shipmentSummary);
        objMap = convertAllValuesToString(jsonMap.get('unitOfMeasures'));
        if (objMap != null) {
            unitOfMeasures = new Freight_AWBResponseParsing.unitOfMeasures(
                (String) objMap.get('weight'),
                (String) objMap.get('volume'),
                (String) objMap.get('length')
            );
        }
        System.debug('unitOfMeasures - ' + unitOfMeasures);
        objList = (List<Object>) jsonMap.get('shipmentHistory');
        if (objList != null) {
            for (Object currObj : objList) {
                objMap = convertAllValuesToString(currObj);
                if (objMap != null) {
                    flightDetails = null;
                    objMap1 = convertAllValuesToString(objMap.get('flightDetails'));
                    if (objMap1 != null) {
                        flightDetails = new Freight_AWBResponseParsing.flightDetail(
                            (String) objMap1.get('segmentOrigin'),
                            (String) objMap1.get('segmentDestination'),
                            (String) objMap1.get('flightNumber'),
                            (String) objMap1.get('flightDepartureDate'),
                            (String) objMap1.get('departureDateStatus'),
                            (String) objMap1.get('flightArrivalDate'),
                            (String) objMap1.get('arrivalDateStatus'),
                            (String) objMap1.get('departureStatus'),
                            (String) objMap1.get('arrivalStatus')
                        );
                    }
                    eventDetails = null;
                    objMap1 = convertAllValuesToString(objMap.get('eventDetails'));
                    if (objMap1 != null) {
                        eventDetails = new Freight_AWBResponseParsing.eventDetail( (String) objMap1.get('uldNumber') ,
                            (String) objMap1.get('discrepancyReasoncode')  );
                      
                    }
                    shipmentHistories.add(new Freight_AWBResponseParsing.shipmentHistory(
                        (String) objMap.get('eventType'),
                        (String) objMap.get('airportCode'),
                        (String) objMap.get('transactionDate'),
                        (String) objMap.get('transactionDateUtc'),
                        (String) objMap.get('pieces'),
                        (String) objMap.get('weight'),
                        eventDetails,
                        flightDetails,
                        (String) objMap.get('eventName'),
                        (String) objMap.get('bookingSequence'),
                        (String) objMap.get('stageCode'),
                        (String) objMap.get('stageName'),
                        (String) objMap.get('isLatest')
                    ));
                }
            }
        }
        System.debug('Count of shipmentHistories - ' + shipmentHistories.size());
        System.debug('shipmentHistories - ' + shipmentHistories);
        return new Freight_AWBResponseParsing(shipmentSummary, unitOfMeasures, shipmentHistories);
    }
    
    public static Map<String, Object> convertAllValuesToString(Object obj) {
        Map<String, Object> inputMap;
        Object currObj;
        if (obj == null || (obj instanceOf String)) {
            return null;
        }
        inputMap = (Map<String, Object>) obj;
        for (String currElement : inputMap.keySet()) {
            currObj = inputMap.get(currElement);
            if (currObj != null && (currObj instanceOf Boolean || currObj instanceOf Date 
                                    || currObj instanceOf DateTime || currObj instanceOf Decimal
                                    || currObj instanceOf Double || currObj instanceOf Integer
                                    || currObj instanceOf Long)) 
            {
                inputMap.put(currElement, String.valueOf(currObj));
            }
        }
        return inputMap;
    }
        
}