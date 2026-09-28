/**
* @File Name : QCCCurrencyConversionServiceTest.cls
* @Description :
* @Author : Sourabh Singh
* @Last Modified By :
* @Last Modified On : August 17, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 17, 2024 |   | Initial Version
**/

@isTest
public class QCCCurrencyConversionServiceTest {
    
    @isTest
    static void testGetCurrencyConversionSuccess() {
        // Setup mock response
        String mockJsonResponse = '{"conversionDetails":[{"conversionRate":{"rate":"1.2345"},"convertedAmount":[{"typeQualifier":"TRU","amount":"100.00"}]}]}';
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockJsonResponse));
        
        // Test the getCurrencyConversion method
        String response = QCCCurrencyConversionService.getCurrencyConversion('BSR', '20230816', 1000.00, 'USD', 'EUR');
        
        // Validate the response
        System.assertNotEquals(null, response);
        System.assertEquals(mockJsonResponse, response);
    }

    @isTest
    static void testProcessCurrencyConversionResponse() {
        // Create a mock JSON response
        String jsonResponse = '{"conversionDetails":[{"conversionRate":{"rate":"1.2345"},"convertedAmount":[{"typeQualifier":"TRU","amount":"100.00"}]}]}';
        
        // Test the processCurrencyConversionResponse method
        Map<String, String> conversionMap = QCCCurrencyConversionService.processCurrencyConversionResponse(jsonResponse);
        
        // Validate the results
        System.assertEquals('1.2345', conversionMap.get('ConversionRate'));
        System.assertEquals('100.00', conversionMap.get('ConvertedAmount'));
    }

    @isTest
    static void testConvertCurrency() {
        // Setup mock response
        String mockJsonResponse = '{"conversionDetails":[{"conversionRate":{"rate":"1.2345"},"convertedAmount":[{"typeQualifier":"TRU","amount":"100.00"}]}]}';
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockJsonResponse));
        
        // Test the convertCurrency method
        Map<String, String> conversionMap = QCCCurrencyConversionService.convertCurrency('BSR', '20230816', 1000.00, 'USD', 'EUR');
        
        // Validate the results
        System.assertEquals('1.2345', conversionMap.get('ConversionRate'));
        System.assertEquals('100.00', conversionMap.get('ConvertedAmount'));
    }

    @isTest
    static void testRoundAmountBasedOnCurrency() {

        //CRM-9185
        TestUtilityDataClassQantas.insertQantasConfigData();

        // Test rounding for IDR
        Decimal amount = QCCCurrencyConversionService.roundAmountBasedOnCurrency(123.45, 'IDR');
        System.assertEquals(130, amount);

        // Test rounding for KRW (already whole number)
        amount = QCCCurrencyConversionService.roundAmountBasedOnCurrency(123.00, 'KRW');
        System.assertEquals(123, amount);

        // Test rounding for KRW (not a whole number)
        amount = QCCCurrencyConversionService.roundAmountBasedOnCurrency(123.45, 'KRW');
        System.assertEquals(124, amount);
    }

    @isTest
    static void testGetCurrencyOptions() {
        // Test the getCurrencyOptions method
        List<String> options = QCCCurrencyConversionService.getCurrencyOptions();
        
        // Validate that the options list is not empty
        System.assertNotEquals(0, options.size());
    }

    @isTest
    static void testCurrencyConversionResponseClasses() {
        // Instantiate and populate CurrencyInfo
        QCCCurrencyConversionService.CurrencyInfo currencyInfo = new QCCCurrencyConversionService.CurrencyInfo();
        currencyInfo.fromCurrency = 'USD';
        currencyInfo.toCurrency = 'EUR';

        // Instantiate and populate ConversionRoundingInfo
        QCCCurrencyConversionService.ConversionRoundingInfo roundingInfo = new QCCCurrencyConversionService.ConversionRoundingInfo();
        roundingInfo.conversionType = 'BSR';
        roundingInfo.currencyCode = 'USD';
        roundingInfo.roundingUnit = '0.01';

        // Instantiate and populate ConversionRate
        QCCCurrencyConversionService.ConversionRate conversionRate = new QCCCurrencyConversionService.ConversionRate();
        conversionRate.dateQualifier = 'Settlement';
        conversionRate.conversionDate = '20230816';
        conversionRate.originCurrency = 'USD';
        conversionRate.rateType = 'Standard';
        conversionRate.rate = '1.2345';
        conversionRate.destinationCurrency = 'EUR';

        // Instantiate and populate ConvertedAmount
        QCCCurrencyConversionService.ConvertedAmount convertedAmount = new QCCCurrencyConversionService.ConvertedAmount();
        convertedAmount.typeQualifier = 'TRU';
        convertedAmount.amount = '100.00';
        convertedAmount.currencyCode = 'EUR';

        // Instantiate and populate ConversionDetail
        QCCCurrencyConversionService.ConversionDetail conversionDetail = new QCCCurrencyConversionService.ConversionDetail();
        conversionDetail.conversionRate = conversionRate;
        conversionDetail.convertedAmount = new List<QCCCurrencyConversionService.ConvertedAmount>{convertedAmount};

        // Instantiate and populate CurrencyConversionResponse
        QCCCurrencyConversionService.CurrencyConversionResponse conversionResponse = new QCCCurrencyConversionService.CurrencyConversionResponse();
        conversionResponse.currencyInfo = currencyInfo;
        conversionResponse.conversionRoundingInfo = new List<QCCCurrencyConversionService.ConversionRoundingInfo>{roundingInfo};
        conversionResponse.conversionDetails = new List<QCCCurrencyConversionService.ConversionDetail>{conversionDetail};

        // Validate the CurrencyConversionResponse object
        System.assertEquals('USD', conversionResponse.currencyInfo.fromCurrency);
        System.assertEquals('EUR', conversionResponse.currencyInfo.toCurrency);
        System.assertEquals('BSR', conversionResponse.conversionRoundingInfo[0].conversionType);
        System.assertEquals('1.2345', conversionResponse.conversionDetails[0].conversionRate.rate);
        System.assertEquals('100.00', conversionResponse.conversionDetails[0].convertedAmount[0].amount);
    }

    // Mock HTTP Response Generator Class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}