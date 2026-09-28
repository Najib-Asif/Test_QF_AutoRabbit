import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
        { label: 'Title', fieldName: 'Title',wrapText: true },
        { label: 'Last Published Date', fieldName: 'LastPublishedDate',type: "date", initialWidth:170,wrapText: true,
            cellAttributes: { alignment: 'center' },
            typeAttributes:{year: "numeric",
                            month: "2-digit",
                            day: "2-digit"
                           }},
        {label: "Record Type", type: "customImage", initialWidth:130,wrapText: true,
            cellAttributes: { alignment: 'center' },
            typeAttributes: {
                imageUrl: { fieldName: 'Article__c' }},
            },
        {label: '', type: 'button', initialWidth: 130, 
            cellAttributes: { alignment: 'center' },
            typeAttributes: { label: 'View', name: 'view_details', title: 'View knowledge article'}}
    ]
export default class KnowledgeArticleDataTable extends NavigationMixin(LightningElement) {
    @api knowledgeArticles = []; // Articles data passed from Aura
    columns = columns;
    
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'view_details') {
            this.showRowDetails(row.Id);
        }
    }

    showRowDetails(rowId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rowId,
                actionName: 'view'
            }
        });
    }
}