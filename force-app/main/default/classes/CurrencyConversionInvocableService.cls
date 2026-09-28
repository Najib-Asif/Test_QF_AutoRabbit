/**
 * Invocable Apex service for currency conversion.
 * Can be called from Flows or Process Builder to convert currency amounts using a specified conversion type and date.
 */
public class CurrencyConversionInvocableService {
    /**
     * Invocable method to get converted currency rates for a list of requests.
     * Each request specifies the conversion type, date, amount, and currencies.
     * Calls QCCCurrencyConversionService to perform the conversion.
     *
     * @param entries List of Request objects containing conversion details
     * @return List of Result objects with conversion rate and converted value
     */
    @InvocableMethod(label='Get Currency Converted Rate' description='Returns the list of Currency Converted Rate for the specified entries.')
    public static List<Result> getConvertedCurrency(List<Request> entries) {
        List<Result> output = new List<Result>();
        for (Request x : entries) {
            // Call external service to perform currency conversion
            Map<String, String> out = QCCCurrencyConversionService.convertCurrency(x.conversionType, x.conversionDate, x.amount, x.convertFrom, x.convertTo);
            Result y = new Result();
            // Set conversion rate if available
            if (out.containsKey('ConversionRate') && String.isNotblank(out.get('ConversionRate'))) {
                y.conversionRate = Decimal.valueOf(out.get('ConversionRate'));
            }
            // Set converted value if available
            if (out.containsKey('ConvertedAmount') && String.isNotblank(out.get('ConvertedAmount'))) {
                y.convertedValue = Decimal.valueOf(out.get('ConvertedAmount'));
            }
            output.add(y);
        }
        return output;
    }
    
    /**
     * Request class for currency conversion.
     * Used as input to the invocable method from Flows/Process Builder.
     */
    public class Request {
        /**
         * Type of conversion (e.g., BSR). Required.
         */
        @InvocableVariable(label='Conversion Type' description='Defaults to BSR' required=true)
        public String conversionType;
        /**
         * Date of conversion in format ddmmyy. Required.
         */
        @InvocableVariable(label='Conversion Date' description='Conversion Date (Format - ddmmyy)' required=true)
        public String conversionDate;
        /**
         * Amount to convert. Required.
         */
        @InvocableVariable(label='Amount' description='Amount to Convert' required=true)
        public Decimal amount;
        /**
         * Currency code to convert from (e.g., USD). Required.
         */
        @InvocableVariable(label='Original Currency' description='Currency to convert from' required=true)
        public String convertFrom;
        /**
         * Currency code to convert to (e.g., EUR). Required.
         */
        @InvocableVariable(label='New Currency' description='Currency to convert to' required=true)
        public String convertTo;
    }
    
    /**
     * Result class for currency conversion.
     * Returned by the invocable method to Flows/Process Builder.
     */
    public class Result {
        /**
         * The conversion rate used for the currency conversion.
         */
        @InvocableVariable(label='Conversion Rate' description='Conversion Rate')
        public Decimal conversionRate;
        /**
         * The converted value in the new currency.
         */
        @InvocableVariable(label='Converted Value' description='Converted Value in New Currency')
        public Decimal convertedValue;
        /**
         * Constructor initializes values to 0.
         */
        Result () {
            conversionRate = 0;
            convertedValue = 0;
        }
    }
}