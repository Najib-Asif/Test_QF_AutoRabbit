/*==================================================================================================================================
Author:         Abhieet P
Company:        TCS
Purpose:        Freight - Class will be used for creating requesting JSON to be sent to iCargo system for AWB Integration
Date:           03/08/2017         
TestClass:      Freight_AWBRequestJsonTest

==================================================================================================================================

==================================================================================================================================*/


public class Freight_AWBRequestJson {

    public Shipments shipments;

    public class AuthorisationToken {
        public String UserName;
        public String Password;
        public String MessageCreationDateTime;
        public String MessageExpireDateTime;
    }

    public class TrackingFilters {
        public String shipmentPrefix;
        public String masterDocumentNumber;
    }

    public class Shipments {
        public AuthorisationToken AuthorisationToken;
        public TrackingFilters trackingFilters;
    }

    
    public String convertToJsonString(Freight_AWBRequestJson m) {
        return JSON.serializePretty(m);
    }
}