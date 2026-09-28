@IsTest
public class Freight_AWBRequestJsonTest {
    
    static testMethod void testParse() {
        
        // Parameters to generate startdate and expiry date for Request message
        Datetime befcdformat = System.now();
        String creationDate = string.valueOfGmt(befcdformat);
        CreationDate = CreationDate.replace(' ', 'T' )+ 'Z';
        befcdformat = System.now().addMinutes(10);
        String expireDate = string.valueOfGmt(befcdformat);
        expireDate = expireDate.replace(' ', 'T' )+ 'Z';
        
        // Initialising class 
        Freight_AWBRequestJson awbRequestJson                       = new Freight_AWBRequestJson();
        awbRequestJson.Shipments                                    = new Freight_AWBRequestJson.Shipments();
        
        // Setting up Authentication details
        awbRequestJson.Shipments.AuthorisationToken                 = new Freight_AWBRequestJson.AuthorisationToken();
        awbRequestJson.Shipments.AuthorisationToken.username        = 'Test';
        awbRequestJson.Shipments.AuthorisationToken.password        = 'Test';
        awbRequestJson.Shipments.AuthorisationToken.MessageCreationDateTime = creationDate;
        awbRequestJson.Shipments.AuthorisationToken.MessageExpireDateTime   = expireDate;
        
        // Setting up AWB request parameter
        awbRequestJson.Shipments.TrackingFilters                    = new Freight_AWBRequestJson.TrackingFilters();
        awbRequestJson.Shipments.TrackingFilters.shipmentPrefix     = '081';
        awbRequestJson.Shipments.TrackingFilters.masterDocumentNumber = '12345678';
        
        Test.startTest();
        
        
        string jsonString = awbRequestJson.convertToJsonString(awbRequestJson);
        System.assert(jsonString != '');
        
        Test.stopTest();
    }
}