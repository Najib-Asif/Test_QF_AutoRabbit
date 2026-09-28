/**
* @File Name : QCCCurrencyConversionService.cls
* @Description : Used for currency conversion using the Amadeus web service
* @Author : Sourabh Singh
* @Last Modified By :
* @Last Modified On : August 16, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 16, 2024 |   | Initial Version
**/

public without sharing class QCCCurrencyConversionService {

/**
 * @description This method sends an HTTP POST request to an external currency conversion service
 *              to retrieve the conversion details for a specified amount, conversion type, date, and currency pair.
 *              The method returns the response from the service as a JSON string.
 * 
 * @param conversionType The type of conversion to perform (e.g., 'BSR' for base standard rate).
 * @param conversionDate The date for which the currency conversion is to be applied, in the format 'YYYYMMDD'.
 * @param amount The amount to be converted, provided as a Decimal.
 * @param convertFrom The ISO code of the currency to convert from (e.g., 'USD').
 * @param convertTo The ISO code of the currency to convert to (e.g., 'EUR').
 * 
 * @return A JSON string containing the currency conversion details returned by the external service. The JSON string
 *         typically includes information such as the conversion rate and the converted amount.
 */
	@AuraEnabled(cacheable=false)
    public static String getCurrencyConversion(String conversionType, String conversionDate, Decimal amount, String convertFrom, String convertTo) {
             
        
        // Create the JSON body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('conversionType', conversionType);
        requestBody.put('conversionDate', conversionDate);
        requestBody.put('amount', amount);
        requestBody.put('convertFrom', convertFrom);
        requestBody.put('convertTo', convertTo);
        
        // Convert the map to a JSON string
        String jsonBody = JSON.serialize(requestBody);
              
        HttpResponse res; 
        try {
            // Send the request and receive the response
            res = QCC_RecoveryIntegrationUtility.actualHttpCall('callout:QCC_Recovery_Currency_Conversion_NC', jsonBody);
            
            // Check for a successful response
            if (res.getStatusCode() == 200) {
                // Return the response body as a JSON string
                return res.getBody();
            } else {
                // Handle any errors (e.g., log the error, throw an exception)
                System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
                throw new CalloutException('Failed to get currency conversion. HTTP Status: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            // Handle any  exceptions
            System.debug('CalloutException: ' + e.getMessage());
            throw e;
        }
    }
    
/*
 * @description This method processes a JSON response from a currency conversion service,
 *              extracts the conversion rate and the amount for the 'TRU' type qualifier,
 *              and returns the results in a Map<String, Decimal>. This method is accessible
 *              from both Lightning Web Components (LWC) and Salesforce Flows.
 * 
 * @param jsonResponse A JSON string representing the currency conversion response.
 *                     The JSON is expected to conform to the structure of the 
 *                     CurrencyConversionResponse class.
 * 
 * @return A Map<String, Decimal> containing:
 *         - 'ConversionRate': The conversion rate as a Decimal.
 *         - 'ConvertedAmount': The amount corresponding to the 'TRU' type qualifier, if available.
 */
	@AuraEnabled(cacheable=false)
    public static Map<String, String> processCurrencyConversionResponse(String jsonResponse) {
        // Initialize the map to store conversion details
        Map<String, String> conversionMap = new Map<String, String>();

        // Deserialize the JSON response into the wrapper class
        CurrencyConversionResponse response = (CurrencyConversionResponse) JSON.deserialize(jsonResponse, CurrencyConversionResponse.class);

        // Access the rate value from the first item in conversionDetails
        if (response != null && !response.conversionDetails.isEmpty()) {
            // Parse the conversion rate and add it to the map
            conversionMap.put('ConversionRate', response.conversionDetails[0].conversionRate.rate); 
            // Loop through the converted amounts and add relevant ones to the map
            for (ConvertedAmount ca : response.conversionDetails[0].convertedAmount) {
                if ('TRU'.equals(ca.typeQualifier)) {
                    conversionMap.put('ConvertedAmount', ca.amount);
                }
            }
        } else {
            System.debug('No conversion details found in the response.');
        }

        // Return the map containing the conversion details
        return conversionMap;
    }

/**
 * @description This method converts a given amount from one currency to another using a specified conversion type and date.
 *              It first retrieves the conversion data as a JSON response from the currency conversion service, processes
 *              the JSON response to extract relevant conversion details, and returns these details as a Map<String, String>.
 * 
 * @param conversionType The type of conversion to perform (e.g., 'BSR' for base standard rate).
 * @param conversionDate The date for which the currency conversion is to be applied, in the format 'YYYYMMDD'.
 * @param amount The amount to be converted, provided as a Decimal.
 * @param convertFrom The ISO code of the currency to convert from (e.g., 'USD').
 * @param convertTo The ISO code of the currency to convert to (e.g., 'EUR').
 * 
 * @return A Map<String, String> containing key-value pairs of conversion details. The keys typically include:
 *         - 'ConversionRate': The rate at which the conversion was performed.
 *         - 'ConvertedAmount': The converted amount corresponding to the 'TRU' type qualifier, if applicable.
 */
    @AuraEnabled(cacheable=false)
    public static Map<String, String> convertCurrency(String conversionType, String conversionDate, Decimal amount, String convertFrom, String convertTo) {
       Map<String, String> mapResponse = new Map<String, String>(); 
       try{
       String jsonResponse = getCurrencyConversion(conversionType, conversionDate, amount, convertFrom, convertTo);
       if(String.isNotBlank(jsonResponse))
             mapResponse = processCurrencyConversionResponse(jsonResponse);
        } catch (Exception e) {
            // Handle any  exceptions
            System.debug('Exception: ' + e.getMessage());
            throw e;
        }     
       return mapResponse;
    }

 //special currency treatment functions
 public static Decimal roundAmountBasedOnCurrency(Decimal amount, String currencyCode) {
        // List of currencies that require rounding up to the nearest 10
        List<String> currenciesToRoundToNearest10 = CustomSettingsUtilities.getConfigDataMap('currenciesToRoundToNearest10').split(';');

        //CDP2-994 
        // Currency that requires rounding up to the nearest whole number if not already whole
        List<String> roundToWholeNumberCurrency = CustomSettingsUtilities.getConfigDataMap('currenciesToRoundToWholeNumber').split(';');//CRM-9185: Adding XPF

        // Check if the currency requires rounding up to the nearest 10
        if (currenciesToRoundToNearest10.contains(currencyCode)) {
            // Round up the amount to the nearest 10
            amount = Math.ceil(amount / 10) * 10;
        } 
        // Check if the currency is KRW
        else if (roundToWholeNumberCurrency.contains(currencyCode)) {
            // Round up to the nearest whole number if the amount is not already a whole number
            if (amount != Math.floor(amount)) {
                amount = Math.ceil(amount);
            }
        }

        return amount;
    }   

//wrapper classes

public class CurrencyConversionResponse {
    public CurrencyInfo currencyInfo { get; set; }
    public List<ConversionRoundingInfo> conversionRoundingInfo { get; set; }
    public List<ConversionDetail> conversionDetails { get; set; }
}

public class CurrencyInfo {
    public String fromCurrency { get; set; }
    public String toCurrency { get; set; }
}

public class ConversionRoundingInfo {
    public String conversionType { get; set; }
    public String currencyCode { get; set; }   
    public String roundingUnit { get; set; }
}

public class ConversionDetail {   
    public ConversionRate conversionRate { get; set; }
    public List<ConvertedAmount> convertedAmount { get; set; }
}

public class ConversionRate {
    public String dateQualifier { get; set; }
    public String conversionDate { get; set; }   
    public String originCurrency { get; set; }
    public String rateType { get; set; }
    public String rate { get; set; }
    public String destinationCurrency { get; set; }
}

public class ConvertedAmount {
    public String typeQualifier { get; set; }
    public String amount { get; set; }
    public String currencyCode { get; set; }   
}

@AuraEnabled(cacheable=true)
    public static List<String> getCurrencyOptions() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Recovery__c.Original_Currency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }

}