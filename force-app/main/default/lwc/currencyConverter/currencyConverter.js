/*
 * @file CurrencyConverter.js
 * @author Sourabh Singh
 * @date 10/08/2024
 * @description A Lightning Web Component (LWC) that allows users to convert a monetary value 
 *              from one currency to AUD using a conversion service. The component fetches 
 *              available currencies, handles user input, and performs the currency conversion 
 *              using Apex methods.
 */
import { LightningElement, track } from 'lwc';
import convertCurrency from '@salesforce/apex/QCCCurrencyConversionService.convertCurrency';

export default class CurrencyConverter extends LightningElement {
    monetaryValue;
    refundCurrency;
    equivalentAud;
    conversionRate;
    conversionDate;
    validVal;
    minDate;
    maxDate;
    currencyOptions = [];
    // Define your parameters
    typeQualifier = 'BSR';
    toCurrency = 'AUD';
    errorMsg='';
    isSuccess = false;
    showSpinner = false;
    isConvertButtonDisabled = true;
    handleConversionDateChange(event) {
        this.conversionDate = event.target.value;
        this.checkIfConvertButtonShouldBeEnabled();
    }


    connectedCallback() {
 // Set the default date to today's date in 'YYYY-MM-DD' format        const today = new Date();
 const today = new Date();
         this.conversionDate = today.toISOString().split('T')[0];

        const oneYearAgo = new Date();
        oneYearAgo.setFullYear(today.getFullYear() - 1);
        oneYearAgo.setDate(oneYearAgo.getDate() + 1);
 // Format dates to YYYY-MM-DD
         this.minDate = this.formatDate(oneYearAgo);
        this.maxDate = this.formatDate(today);
    }
    formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return year+'-'+month+'-'+day;
    }

    
    handleMonetaryValueChange(event) {
        this.monetaryValue = event.target.value;
        this.checkIfConvertButtonShouldBeEnabled();
    }
    handleCurrencyChanged(event) {
        this.refundCurrency = event.detail.inputValue;
        this.validVal = event.detail.validValue;
        this.checkIfConvertButtonShouldBeEnabled();
    }
    handleRefundCurrencyChange(event) {
        this.refundCurrency = event.target.value;
        this.checkIfConvertButtonShouldBeEnabled();
    }

    handleCurrencyCleared() {
        this.refundCurrency = '';  // Clear the currency field when the child clears it
        this.checkIfConvertButtonShouldBeEnabled();
    }

    checkIfConvertButtonShouldBeEnabled() {
        const isDateValid = this.conversionDate && this.conversionDate >= this.minDate && this.conversionDate <= this.maxDate;
        this.isConvertButtonDisabled = !(this.monetaryValue && this.refundCurrency && isDateValid && this.validVal);
    }

    handleClear() {
        // Clear the input values
        this.monetaryValue = '';
        this.refundCurrency = '';
        
        // Reset the output values
        this.equivalentAud = null;
        this.conversionRate = null;

        const today = new Date();
        this.conversionDate = today.toISOString().split('T')[0];
        
        // Hide the success message and reset error message
        this.isSuccess = false;
        this.errorMsg = '';
        
        // Hide the spinner
        this.showSpinner = false;
        const clearEvent = new CustomEvent('clearcurrency');
        this.template.querySelector('c-dynamic-pick-list').dispatchEvent(clearEvent); 
        this.checkIfConvertButtonShouldBeEnabled();
    }

    checkIfConvertButtonShouldBeEnabled() {
        const isDateValid = this.conversionDate && this.conversionDate >= this.minDate && this.conversionDate <= this.maxDate;
        this.isConvertButtonDisabled = !(this.monetaryValue && this.refundCurrency && isDateValid && this.validVal);
    }
        handleConvertCurrency() {
        if (this.monetaryValue && this.refundCurrency) {
            this.isSuccess = false;
            this.showSpinner = true;
            convertCurrency({
                conversionType: this.typeQualifier,
                conversionDate: this.getConversionDate(),
                amount: this.monetaryValue,
                convertFrom: this.refundCurrency.substring(0, 3),
                convertTo: this.toCurrency
            })
            .then(result => {
                    // Extracting and printing Conversion Rate and TRUAmount
                    const conversionRate = result['ConversionRate'];
                    const convertedAmount = result['ConvertedAmount'];
    
                    this.equivalentAud = parseFloat(convertedAmount).toFixed(2);
                    this.conversionRate = parseFloat(conversionRate);
                    this.errorMsg = '';
                    this.isSuccess = true;
                    this.showSpinner = false;
    
            })
            .catch(error => {
                console.error(error);
                this.showSpinner = false;
                this.equivalentAud = null;
                this.errorMsg = "Error: Failed to get currency conversion.Please contact your administrator!";
            });
        }
      }
      getConversionDate() {
        let dateString = this.conversionDate; // e.g., '2024-08-09'
        const inputDate = new Date(dateString);
        const todayLocal = new Date();
    
        //Checking if conversion date is today's date
        const isToday = inputDate.toDateString() === todayLocal.toDateString();
        //If conversion date is today's date, getting current GMT date
        if (isToday) {
            dateString = todayLocal.toISOString().split('T')[0];
        }  
        //const dateString = this.conversionDate; //'2024-08-09';
        const parts = dateString.split('-');
        const day = parts[2];
        const month = parts[1];
        const year = parts[0].slice(-2);
        console.log(day+month+year);
        return day+month+year;
    }
    

}