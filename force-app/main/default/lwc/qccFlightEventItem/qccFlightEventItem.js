import { LightningElement, api } from 'lwc';
import qSVG from '@salesforce/resourceUrl/QantasSVG';

export default class QccFlightEventItem extends LightningElement {
    @api flghtEvnt;
    qantasLogo = qSVG + '#qsvg';    
}