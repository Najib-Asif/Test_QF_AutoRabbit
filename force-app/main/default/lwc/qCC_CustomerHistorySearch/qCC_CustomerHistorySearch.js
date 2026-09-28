import { LightningElement, api, track, wire } from 'lwc';
import generateCustomerHistoryTables from '@salesforce/apex/QCC_CustomerHistorySearchController.generateCustomerHistoryTables';
import generateCustomerHistoryPerPage from '@salesforce/apex/QCC_CustomerHistorySearchController.generateCustomerHistoryPerPage';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

export default class QCC_CustomerHistorySearch extends LightningElement {
    @track searchKey = ''; // Search key from the user passed to the Apex
    @track keyCounter = 0; // keyCounter is used in the html for the elements inside the iterator templates
    @track returnList = []; // list used in the lightning table 
    @track searchList = []; // temporary list for processing logic in lwc
    @track error; // for publishing error messages
    @api returnList; // exposing the list
    @api recordId=''; // recordId from the Lightning Page
    connectedCallback() {  // This is only for debugging purpose to identify the recordId
        console.log('record id', this.recordId);
    }

    // keyCounter is used in the html for the elements inside the iterator templates
    @api
    get keyCounter() {
        return this.keyCounter;
    }

    set keyCounter(value) {
       this.keyCounter++;
    }

    @wire(generateCustomerHistoryTables, { searchKey: '$searchKey', recordId: '$recordId' })
    searchReturn(result){
        var form = this;
        form.searchList = JSON.parse(JSON.stringify(result));
        if (form.searchList.data) {
            form.searchList.data.forEach(function (currentTable) {
                currentTable = form.prepareDataTable(currentTable);
            });
        }
        
        form.returnList = form.searchList;
        if (typeof(form.returnList.data) !== 'undefined') {
            form.returnList.data.forEach(function (currentTable) {
                if (currentTable.tableData.length >= currentTable.totalRecordCount) {
                    currentTable.isInfiniteLoadingEnabled = false;
                } else {
                    currentTable.isInfiniteLoadingEnabled = true;
                }

                if (currentTable.tableData.length >= 10) {
                    currentTable.tableClass = 'datatable-set-height';
                } else {
                    currentTable.tableClass = 'datatable-remove-height';
                }
            });
        }
    }

    loadMoreData(event) {
        var form = this;
        var datatable = event.target;
        var tableId = datatable.getAttribute("data-id");
        
        try {
            form.returnList.data.forEach(function (currentTable) {
                if (!datatable.isLoading && currentTable.tableId == tableId) {
                    datatable.isLoading = true;
                    currentTable.loadMoreStatusMessage = 'Loading';
                    currentTable.pageNumber = currentTable.pageNumber + 1;
    
                    generateCustomerHistoryPerPage({
                        searchKey: form.searchKey, 
                        recordId: form.recordId,
                        pageNumber: currentTable.pageNumber,
                        tableName: currentTable.tableName
                    })
                    .then((result) => {
                        var newData = JSON.parse(JSON.stringify(result));
                        newData = form.prepareData(newData, currentTable.tableTypeAttributes);
                        currentTable.tableData = currentTable.tableData.concat(newData);
                        if (currentTable.tableData.length >= currentTable.totalRecordCount) {
                            datatable.enableInfiniteLoading = false;
                            currentTable.loadMoreStatusMessage = 'No more data to load';
                        } else {
                            currentTable.loadMoreStatusMessage = '';
                        }
                        datatable.isLoading = false;
                    });
                }
            });
        } catch(Err) {

        }
    }

    prepareDataTable(currentTable) {
        if (typeof(currentTable) !== 'undefined') {
            currentTable.tableColumns.forEach(function (column) {
                if (column.type == 'url') {
                    column.typeAttributes = { label : { fieldName: column.typeAttributes.fieldName } };
                }
            });
            
            currentTable.tableData = this.prepareData(currentTable.tableData, currentTable.tableTypeAttributes);
        }

        return currentTable;
    }

    prepareData(records, typeAttributes) {
        records.forEach(function (recordData) {
            typeAttributes.forEach(function (urlField) {
                recordData[urlField.urlFieldName] = '/' + recordData[urlField.urlFieldNameSource];
                if (typeof(urlField.fieldNameSource) !== 'undefined') {
                    if (urlField.fieldNameSource.includes('.')) {
                        var splittedString = urlField.fieldNameSource.split(".");
                        var objectRecord = recordData[splittedString[0]];
                        recordData[urlField.fieldName] = objectRecord[splittedString[1]];
                    } else {
                        recordData[urlField.fieldName] = recordData[urlField.fieldNameSource];
                    }
                }

                if (typeof(recordData['Body']) !== 'undefined') {
                    recordData['Body'] = recordData['Body'].replace(/<\/?[^>]+(>|$)/g, "");
                }
            });
        });

        return records;
    }
    
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        const searchKey = event.target.value;
        if (searchKey.length >= 3) {
            window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
                this.searchKey = searchKey;
            }, DELAY);
        }
    }
}