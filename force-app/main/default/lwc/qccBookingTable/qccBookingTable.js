import LightningDatatable from 'lightning/datatable';
import datatableColumnClickHandlerTemplate from './datatableColumnClickHandlerTemplate.html';
import clickableCaseNumberTemplate from './clickableCaseNumberTemplate.html'

export default class QccBookingTable extends LightningDatatable {
    static customTypes = {
        clickablePNR: {
            template: datatableColumnClickHandlerTemplate,
            typeAttributes: ['pnrNum']
        },
        clickableCaseNumber:{
            template: clickableCaseNumberTemplate,
            typeAttributes: ['recordId']
        }
    }
}