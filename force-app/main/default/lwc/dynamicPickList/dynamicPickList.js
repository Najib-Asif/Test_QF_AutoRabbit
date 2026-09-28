import { LightningElement, wire, api } from 'lwc';
import getCurrencyOptions from '@salesforce/apex/QCCCurrencyConversionService.getCurrencyOptions'; // Apex method to get currency options

export default class DynamicPickList extends LightningElement {
    @api label = 'Select a Currency'; // Default label
    @api placeholder = 'Start typing a currency...'; // Default placeholder
    @api required = false; // Whether the field is required or not

    allOptions = []; // All currency options fetched from Apex
    filteredOptions = []; // Filtered options based on user input
    inputValue = ''; // Value of the input field
    initialized = false;

    // Wire the Apex method to get currency options dynamically
    @wire(getCurrencyOptions)
    wiredOptions({ error, data }) {
        if (data) {
            this.allOptions = data; // Store the full list of currency options
            this.filteredOptions = this.allOptions; // Initially show all options
        } else if (error) {
            console.error('Error fetching currency options:', error);
        }
    }

    // Render callback to ensure input field is associated with the datalist
    renderedCallback() {
        if (this.initialized) {
            return;
        }
        this.initialized = true;
        let listId = this.template.querySelector('datalist').id;
        this.template.querySelector("input").setAttribute("list", listId);
    }

    // Handle input change and filter the options based on the input value
    handleInputChange(event) {
        this.inputValue = event.target.value;

        // Filter the options based on the input value (case-insensitive)
        if (this.inputValue) {
            this.filteredOptions = this.allOptions.filter(option =>
                option.toLowerCase().includes(this.inputValue.toLowerCase())
            );
            
        } else {
            // If no input, show all options
            this.filteredOptions = this.allOptions;
        }
        // Dispatch currencychanged event to notify parent about the currency being typed
        const inputChangeEvent = new CustomEvent('currencychanged', {
            detail: {
                inputValue : this.inputValue,
                validValue : this.allOptions.includes(this.inputValue)
            }
        });
        this.dispatchEvent(inputChangeEvent);
    }

    // Handle selection from the datalist and notify parent
    handleSelectCurrency(event) {
        const selectedCurrency = event.target.value;
        //const currencySubstring = selectedCurrency.substring(0, 3);
        this.inputValue = selectedCurrency;

        // Dispatch currencychanged event to notify parent with the selected currency
        const currencyChangeEvent = new CustomEvent('currencychanged', {
            detail: {
                inputValue : this.inputValue,
                validValue : this.allOptions.includes(this.inputValue)
            }
        });

        this.dispatchEvent(currencyChangeEvent);
    }

    // Clear the currency input field and notify the parent
    handleClearCurrency() {
        this.inputValue = ''; // Clear the input field value

       
    }

    connectedCallback() {
        this.addEventListener('clearcurrency', this.handleClearCurrency);
    }
}