import { LightningElement , api } from 'lwc';
export default class QccUsDotDelayedBaggage extends LightningElement {
    @api EmdNumberValue;
    numericValue = '';

    handleInputChange(event) {
        // Remove non-numeric characters
        this.EmdNumberValue = event.target.value.replace(/\D/g, '');
    }

    handleKeyPress(event) {
        // Prevent non-numeric characters during input
        const charCode = event.which ? event.which : event.keyCode;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }
}