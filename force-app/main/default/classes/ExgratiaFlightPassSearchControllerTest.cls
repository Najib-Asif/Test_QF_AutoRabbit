/**
 * @author: dattaraj.deshmukh@qantas.com.au
 * @date: 6/11/2023
 * @desc: Test class for ExgratiaFlightPassSearchController
 * @history:
 *          6/11/2023   - created   - Dattaraj Deshmukh
 */
@IsTest
public class ExgratiaFlightPassSearchControllerTest {
    
    @testSetup
    public static void setup() 
    {
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        
        Qantas_API__c qantasAPIToken= new Qantas_API__c();
        qantasAPIToken.Name = 'QCC_FlightPassSearchToken';
        qantasAPIToken.EndPoint__c = 'https://api-stage.qantas.com/token';
        qantasAPIToken.ClientId__c = 'asdasdasd';
        qantasAPIToken.ClientSecret__c = 'asdasdasdad';
        qantasAPIToken.Method__c = 'GET';
        qantasAPIToken.Token__c = '';
        lstQantas.add(qantasAPIToken);

        Qantas_API__c qantasAPI= new Qantas_API__c();
        qantasAPI.Name = 'QCC_FlightPassSearch';
        qantasAPI.EndPoint__c = 'https://api-stage.qantas.com/customer/disruption/v1/disruptions';
        qantasAPI.Method__c = 'GET';
        lstQantas.add(qantasAPI);
        
        insert lstQantas;

    }

    /**
     * @desc: method to test array of valid JSON response. 
     */
    @isTest
    static void testSearchFlightPassVoucher() {
        ExgratiaFlightPassSearchController.ExGratiaFlightPassInput exgratiaInput = new ExgratiaFlightPassSearchController.ExGratiaFlightPassInput();
        exgratiaInput.dateOfTravel = Date.today();
        exgratiaInput.ffNumber ='1234567';
        exgratiaInput.flightNumber = 'QN123';
        exgratiaInput.lastName = 'Citizen';
        exgratiaInput.pnrNumber = 'FLE43R';

        List<ExgratiaFlightPassSearchController.ExGratiaFlightPassInput> listOfInput = new List<ExgratiaFlightPassSearchController.ExGratiaFlightPassInput>();
        listOfInput.add(exgratiaInput);

        String sampleBody = '[{"Flight_ID":1,"Flight":"QF0007_SYD_DFW_230809","Flight_date":"2023-08-08T14:00:00.000Z","Flight_IDR":"D","Departing_port":"SYD","ODP":"MKY","Disruption":"Delay","Disruption_reason":"Delay - Due to Qantas where flight is delayed","Disruption_duration":252,"Flight_eligibility":"T","Flight_eligibility_reason":"Eligible - Disruption >= 4 hours for this International flight6","Pax_with_PNR_ID":1,"PNR":"2L2CZF","Travel_plan_ID":"234455026","Pax_first_name":"JARROD","Pax_last_name":"HORNBUCKLE","FF_ID":"0","FF_Tier":"","Cabin_class":"Y","Amount_code":"1BR","Seat_number":"049J","Booking_email":"QFtesting@gmail.com","Booking_phone_number":"","Booking_currency":"AUD","POS_location":"US","Payment_eligibility":"T","Payment_eligibility_reason":"","PNR_remarks_updated_with_eligibility":"T","PNR_remarks_updated_with_card_issuance":"T","ID":1,"Correlation_ID":"234455026_1_1_O","Issuance_email_address_validation":"T","Issuance_email_address_validation_failure_reason":"","Issuance_email":"QFtesting@gmail.com","Issuance_phone_number":"","Issuance_phone_number_validation":"F","Issuance_phone_number_validation_failure_reason":"No phone number","Bespoke_exgratia_payment":"T","Issuance_status":"To be issued","Issuance_failure_reason":"","Amount":"200.00000","Amount_validation":"T","Issuance_currency":"AUD","Issuance_currency_validation":"T","Issuance_currency_validation_failure_reason":"","SMS_type_sent":"","SMS_status_code":"","Batch_ID":"16102","Extraction_datetime":null,"Sequance_No":"","Voucher_ID":"","Issue_date_time":null,"Created_date_time":null,"Last_updated_date_time":null},{"Flight_ID":1,"Flight":"QF0007_SYD_DFW_230809","Flight_date":"2023-08-08T14:00:00.000Z","Flight_IDR":"D","Departing_port":"SYD","ODP":"MKY","Disruption":"Delay","Disruption_reason":"Delay - Due to Qantas where flight is delayed","Disruption_duration":252,"Flight_eligibility":"T","Flight_eligibility_reason":"Eligible - Disruption >= 4 hours for this International flight6","Pax_with_PNR_ID":2,"PNR":"2L2CZF","Travel_plan_ID":"234455036","Pax_first_name":"FRANCESCO","Pax_last_name":"MARINO","FF_ID":"0","FF_Tier":"","Cabin_class":"Y","Amount_code":"1BR","Seat_number":"049K","Booking_email":"QFtesting@gmail.com","Booking_phone_number":"","Booking_currency":"AUD","POS_location":"US","Payment_eligibility":"T","Payment_eligibility_reason":"","PNR_remarks_updated_with_eligibility":"T","PNR_remarks_updated_with_card_issuance":"T","ID":2,"Correlation_ID":"234455036_1_1_O","Issuance_email_address_validation":"T","Issuance_email_address_validation_failure_reason":"","Issuance_email":"QFtesting@gmail.com","Issuance_phone_number":"","Issuance_phone_number_validation":"F","Issuance_phone_number_validation_failure_reason":"No phone number","Bespoke_exgratia_payment":"T","Issuance_status":"To be issued","Issuance_failure_reason":"","Amount":"200.00000","Amount_validation":"T","Issuance_currency":"AUD","Issuance_currency_validation":"T","Issuance_currency_validation_failure_reason":"","SMS_type_sent":"","SMS_status_code":"","Batch_ID":"16102","Extraction_datetime":null,"Sequance_No":"","Voucher_ID":"","Issue_date_time":null,"Created_date_time":null,"Last_updated_date_time":null}]';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExgratiaFlightPassSearchMock(sampleBody));
        List<ExgratiaFlightPassSearchController.ExGratiaFlightPassOutput> exgratiaOutput = ExgratiaFlightPassSearchController.searchFlightPassVoucher(listOfInput);
        Test.stopTest();

        System.assertNotEquals(null, exgratiaOutput, 'Looks like API returned NULL. This is not expected!');
        System.assertEquals(2, exgratiaOutput[0].res.size(), 'List should have size of two as per input');
    }

    /**
     * @desc: method to test when no response is returned.  
     */
    @isTest
    static void testSearchFlightPassVoucherWithNoResults() {
        ExgratiaFlightPassSearchController.ExGratiaFlightPassInput exgratiaInput = new ExgratiaFlightPassSearchController.ExGratiaFlightPassInput();
        exgratiaInput.dateOfTravel = Date.today();
        exgratiaInput.ffNumber ='1234567';
        exgratiaInput.flightNumber = 'QN123';
        exgratiaInput.lastName = 'Citizen';
        exgratiaInput.pnrNumber = 'FLE43R';

        List<ExgratiaFlightPassSearchController.ExGratiaFlightPassInput> listOfInput = new List<ExgratiaFlightPassSearchController.ExGratiaFlightPassInput>();
        listOfInput.add(exgratiaInput);

        String sampleBody = '{"message": "No records availble for given: xxxDx96"}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExgratiaFlightPassSearchMock(sampleBody));
        List<ExgratiaFlightPassSearchController.ExGratiaFlightPassOutput> exgratiaOutput = ExgratiaFlightPassSearchController.searchFlightPassVoucher(listOfInput);
        Test.stopTest();

        System.assertEquals(null, exgratiaOutput, 'API Expected to return NULL for this input.');
    }

    /**
     * @desc: method to test array of valid JSON response. 
     */
    @isTest
    static void testSingleParseWrapper() {
        String sampleBody = '{"Flight_ID":1,"Flight":"QF0007_SYD_DFW_230809","Flight_date":"2023-08-08T14:00:00.000Z","Flight_IDR":"D","Departing_port":"SYD","ODP":"MKY","Disruption":"Delay","Disruption_reason":"Delay - Due to Qantas where flight is delayed","Disruption_duration":252,"Flight_eligibility":"T","Flight_eligibility_reason":"Eligible - Disruption >= 4 hours for this International flight6","Pax_with_PNR_ID":1,"PNR":"2L2CZF","Travel_plan_ID":"234455026","Pax_first_name":"JARROD","Pax_last_name":"HORNBUCKLE","FF_ID":"0","FF_Tier":"","Cabin_class":"Y","Amount_code":"1BR","Seat_number":"049J","Booking_email":"QFtesting@gmail.com","Booking_phone_number":"","Booking_currency":"AUD","POS_location":"US","Payment_eligibility":"T","Payment_eligibility_reason":"","PNR_remarks_updated_with_eligibility":"T","PNR_remarks_updated_with_card_issuance":"T","ID":1,"Correlation_ID":"234455026_1_1_O","Issuance_email_address_validation":"T","Issuance_email_address_validation_failure_reason":"","Issuance_email":"QFtesting@gmail.com","Issuance_phone_number":"","Issuance_phone_number_validation":"F","Issuance_phone_number_validation_failure_reason":"No phone number","Bespoke_exgratia_payment":"T","Issuance_status":"To be issued","Issuance_failure_reason":"","Amount":"200.00000","Amount_validation":"T","Issuance_currency":"AUD","Issuance_currency_validation":"T","Issuance_currency_validation_failure_reason":"","SMS_type_sent":"","SMS_status_code":"","Batch_ID":"16102","Extraction_datetime":null,"Sequance_No":"","Voucher_ID":"","Issue_date_time":null,"Created_date_time":null,"Last_updated_date_time":null}';

        Test.startTest();
        ExgratiaFlightPassSearchWrapper wrapperObj = ExgratiaFlightPassSearchWrapper.parseSingleRecord(sampleBody);
        Test.stopTest();

        System.assertNotEquals(null, wrapperObj, 'Wraper object is expected to be parsed.');
    }


}