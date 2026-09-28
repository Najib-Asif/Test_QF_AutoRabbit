/* 
* Created By : Ajay | TCS | Cloud Developer 
* Purpose : to test the parsing class
* Main Class : QAC_AgencySecondaryParsing
*/

@IsTest
public class QAC_AgencySecondaryParsing_Test {
    
    @IsTest
    public static QAC_AgencySecondaryParsing testParse() {
        String json = '{'+
        '  \"primaryAgencyBusiness\": \"Agency Prospect\",'+
        '  \"agencyAddressLine1\": \"street\",'+
        '  \"city\": \"Melbourne\",'+
        '  \"stateCode\": \"NSW\",'+
        '  \"countryCode\": \"AU\",'+
        '  \"postalCode\": \"2135\",'+
        '  \"phoneNumber\": \"+61-02-123456789\",'+
        '  \"employees\": \"6000\",'+
        '  \"accountEmail\": \"test@example.com\",'+
        '  \"atasNumber\": \"12346\",'+
        '  \"agencyWebSite\": \"somesite.com\",'+
        '  \"dialCode\": \"+61\",'+
        '  \"phoneCountryCode\": \"02\"'+
        '}';
        
        QAC_AgencySecondaryParsing obj = QAC_AgencySecondaryParsing.parse(json);
        System.assert(obj != null);
        return obj;
    }
}