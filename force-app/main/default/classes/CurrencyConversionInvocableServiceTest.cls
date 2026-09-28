/**
 * Test class for CurrencyConversionInvocableService.
 * Verifies the invocable method for currency conversion and mocks HTTP callouts.
 */
@isTest
public with sharing class CurrencyConversionInvocableServiceTest {
    /**
     * Unit test for getConvertedCurrency invocable method.
     * Prepares a request, sets up a mock HTTP response, and asserts the result.
     */
    @isTest
    static void testGetConvertedCurrency() {
        // Prepare test data for currency conversion
        CurrencyConversionInvocableService.Request req = new CurrencyConversionInvocableService.Request();
        req.conversionType = 'BSR';
        req.conversionDate = '080925';
        req.amount = 100;
        req.convertFrom = 'USD';
        req.convertTo = 'EUR';
        List<CurrencyConversionInvocableService.Request> reqList = new List<CurrencyConversionInvocableService.Request>{req};

        // Setup mock JSON response for the HTTP callout
        String mockJsonResponse = '{"conversionDetails":[{"conversionRate":{"rate":"1.2345"},"convertedAmount":[{"typeQualifier":"TRU","amount":"100.00"}]}]}';
        
        // Register the HTTP callout mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockJsonResponse));

        Test.startTest();
        // Call the invocable method
        List<CurrencyConversionInvocableService.Result> results = CurrencyConversionInvocableService.getConvertedCurrency(reqList);
        Test.stopTest();

        // Assert that the result is as expected
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertNotEquals(null, results[0].conversionRate, 'Conversion rate should not be null');
        System.assertNotEquals(null, results[0].convertedValue, 'Converted value should not be null');
    }

    /**
     * Mock HTTP response generator for simulating callouts in test context.
     */
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        /**
         * Constructor for the mock response generator.
         * @param statusCode HTTP status code to return
         * @param responseBody Body of the mock HTTP response
         */
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        /**
         * Respond method to return the mock HTTP response.
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}