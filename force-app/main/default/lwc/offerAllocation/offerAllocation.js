import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, generateRecordInputForUpdate, createRecord, updateRecord, } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllocations from '@salesforce/apex/AgencyInvitationController.getAllocations';
import LightningConfirm from 'lightning/confirm';
import { EnclosingTabId, setTabLabel } from 'lightning/platformWorkspaceApi';
const TAB_LABEL = 'Offer Allocation';

export default class OfferAllocation extends LightningElement {
    @api recordId;
    @track _searchTermsAgencyBrand = [];
    @track _searchTermsAgencyGroup = [];
    @track _searchTermsIATA = [];
    @track _searchTermsIATACodes = [];
    @track _records = [];
    @track filteredRecords = [];
    @track offerDetailsList;
    _selectedAgencyBrand;
    _selectedAgencyIATA;

    notFoundIATACodes;
    showSpinner = false;
    selectedOfferId;
    offerDisplayInfo = { primaryField: 'Name', additionalFields: ['OfferCode__c'], };
    offerMatchingInfo = {
        primaryField: { fieldPath: 'Name', mode: 'startsWith' },
        additionalFields: [{ fieldPath: 'OfferCode__c' }],
    };

    emptyMessage = 'Please search with relevent parameters to allocate..';

    showProgress = false;
    percentComplete = 0;
    progressMessage;

    offerColumns = [
        { label: 'Offer Code', fieldName: 'OfferCode__c', hideDefaultActions: true },
        { label: 'Marketing Description', fieldName: 'Marketing_Description__c', hideDefaultActions: true  },
        { label: 'Offer Audience', fieldName: 'Offer_Audience__c', hideDefaultActions: true  },
        { label: 'Offer Start Date', fieldName: 'Offer_Start_Date__c', type: 'date', hideDefaultActions: true  },
        { label: 'Offer End Date', fieldName: 'Offer_End_Date__c', type: 'date', hideDefaultActions: true  }
    ];

    handleOfferPickerChange(evt) {
        evt.stopPropagation();
        this.selectedOfferId = evt.detail.recordId;
        if (!evt.detail.recordId) {
            this.offerDetailsList = undefined;
            this.handleReset();
        }
    }

    @wire(getRecord, { recordId: '$selectedOfferId',  
                        fields: ['Offer_Catalogue__c.Name', 'Offer_Catalogue__c.OfferCode__c', 
                            'Offer_Catalogue__c.Marketing_Description__c', 'Offer_Catalogue__c.Offer_Audience__c',
                            'Offer_Catalogue__c.Offer_Start_Date__c', 'Offer_Catalogue__c.Offer_End_Date__c' ] 
                    })
    wiredOffer({ error, data }) {
        if (data) {
            this.offerDetailsList = [generateRecordInputForUpdate(data).fields];
        }
        else if (error) {
            console.error('Error fetching Offer Details: ' + JSON.stringify(error));
        }
    }

    qicIdFilterVal;
    qicIdFilterOptions;
    handleQicIdFilterChange(event) {
        this.qicIdFilterVal = event.detail.value;
        this.applyFilter();
    }

    emailFilterVal;
    emailFilterOptions;
    handleEmailFilterChange(event) {
        this.emailFilterVal = event.detail.value;
        this.applyFilter();
    }

    statusFilterVal;
    statusFilterOptions;
    handleStatusFilterChange(event) {
        this.statusFilterVal = event.detail.value;
        this.applyFilter();
    }

    allocationFilterVal;
    allocationFilterOptions;
    handleAllocationFilterChange(event) {
        this.allocationFilterVal = event.detail.value;
        this.applyFilter();
    }

    billingCountryCodeFilterVal;
    billingCountryCodeFilterOptions;
    handleBillingCountryCodeFilterChange(event) {
        this.billingCountryCodeFilterVal = event.detail.value;
        this.applyFilter();
    }

    handleClearFilter() {
        this.qicIdFilterVal = undefined;
        this.emailFilterVal = undefined;
        this.statusFilterVal = undefined;
        this.allocationFilterVal = undefined;
        this.billingCountryCodeFilterVal = undefined;
        this.filteredRecords = this._records;
    }

    applyFilter() {
        this.filteredRecords = this._records.filter(rec => (
                                    (!this.allocationFilterVal || this.allocationFilterVal === rec.offerAllocated) && 
                                    (!this.qicIdFilterVal || this.qicIdFilterVal === rec.qicId) && 
                                    (!this.emailFilterVal || this.emailFilterVal === rec.managerEmail) && 
                                    (!this.statusFilterVal || this.statusFilterVal === rec.pndcStatus) &&
                                    (!this.billingCountryCodeFilterVal || this.billingCountryCodeFilterVal === rec.billingCountryCode)
                                            ));
    }

    get searchTermsAgencyBrand()  {
        return this._searchTermsAgencyBrand.length > 0 ? this._searchTermsAgencyBrand : undefined;
    }

    get searchTermsAgencyGroup()  {
        return this._searchTermsAgencyGroup.length > 0 ? this._searchTermsAgencyGroup : undefined;
    }

    get searchTermsIATA()  {
        return this._searchTermsIATA.length > 0 ? this._searchTermsIATA : undefined;
    }

    connectedCallback() {
        //this.setupData();
        this.selectedOfferId = this.recordId;
    }

    setupData(data) {
        /*this._records = [...Array(20)].map((_, index) => {
            return {
                keyIndex: index,
                agencyGroup: `Agency Group (${index})`,
                agencyBrand: `Agency Brand (${index})`,
                agencyName: `Agency Name (${index})`,
                qicId: `QIC Id (${index})`,
                aggregator: `Aggregator (${index})`,
                managerEmail: `manager_(${index})@test.com`,
                pndcStatus: `None`,
                selected: false,
                allowAllocation: (index % 10) == 0 ? false : true,
                expiryDate: `${new Date().getDate()}`,
                errorStatus: (index % 20) == 0 ? 'Random Error' : undefined
            };
        });*/
        if (!data) return [];

        const qicIdSet = new Set();
        const emailSet = new Set();
        const statusSet = new Set();
        const allocatedSet = new Set();
        const billingCountryCodeSet = new Set();

        let mappedRecords = [];
        let keyIndex = 0;
        /*const statusSet = Object.keys(data);
        statusSet.forEach(key => {
            let mappedRecordsPerKey = data[key].map((rec, index) => {
                let offerAllocatedStr = rec?.Offer_Allocations__r?.[0]?.Status__c === 'Allocated' ? 'Allocated' : 'Not Allocated';


                rec.Qantas_Industry_Centre_ID__c && qicIdSet.add(rec.Qantas_Industry_Centre_ID__c);
                rec?.Agency_Sales_Region__r?.Email__c && emailSet.add(rec?.Agency_Sales_Region__r?.Email__c);
                allocatedSet.add(offerAllocatedStr);
                return {
                    keyIndex: keyIndex++,
                    accountId: rec.Id,
                    agencyBrand: rec?.Agency_Sales_Region__r?.Name,
                    agencyName: rec?.Name,
                    qicId: rec?.Qantas_Industry_Centre_ID__c,
                    managerEmail: rec?.Agency_Sales_Region__r?.Email__c,
                    pndcStatus: key,
                    billingCountryCode: rec?.BillingCountryCode,
                    selected: false,
                    allocatedOffers: rec?.Offer_Allocations__r,
                    offerAllocated: offerAllocatedStr,
                    allowAllocation: true,  //rec?.Offer_Allocations__r === undefined,
                    errorStatus: undefined //rec?.Offer_Allocations__r === undefined ? undefined : 'Offer Already Allocated'
                };
            });
            mappedRecords = mappedRecords.concat(mappedRecordsPerKey);
        });*/
        
        data.forEach(record => {
            if (record?.Assets === undefined || record?.Assets.length === 0) return;

            let offerAllocatedStr = record?.Offer_Allocations__r?.[0]?.Status__c === 'Allocated' ? 'Allocated' : 'Not Allocated';

            record.Qantas_Industry_Centre_ID__c && qicIdSet.add(record.Qantas_Industry_Centre_ID__c);
            record?.Agency_Sales_Region__r?.Email__c && emailSet.add(record?.Agency_Sales_Region__r?.Email__c);
            record?.BillingCountryCode && billingCountryCodeSet.add(record?.BillingCountryCode);
            record?.Assets?.[0].Premium_Channel_Status__c && statusSet.add(record?.Assets?.[0].Premium_Channel_Status__c);

            allocatedSet.add(offerAllocatedStr);
            mappedRecords.push( {
                keyIndex: keyIndex++,
                accountId: record.Id,
                agencyBrand: record?.Agency_Sales_Region__r?.Name,
                agencyName: record?.Name,
                qicId: record?.Qantas_Industry_Centre_ID__c,
                managerEmail: record?.Agency_Sales_Region__r?.Email__c,
                pndcStatus: record?.Assets?.[0].Premium_Channel_Status__c,
                billingCountryCode: record?.BillingCountryCode,
                selected: false,
                allocatedOffers: record?.Offer_Allocations__r,
                offerAllocated: offerAllocatedStr,
                allowAllocation: true,  //record?.Offer_Allocations__r === undefined,
                errorStatus: undefined //record?.Offer_Allocations__r === undefined ? undefined : 'Offer Already Allocated'
            });
        });
        
        this.qicIdFilterVal = undefined;
        this.qicIdFilterOptions = Array.from(qicIdSet).map(entry => ({ label: entry, value: entry }));
        this.qicIdFilterOptions.unshift({ label: '--None--', value: undefined });

        this.emailFilterVal = undefined;
        this.emailFilterOptions = Array.from(emailSet).map(entry => ({ label: entry, value: entry }));
        this.emailFilterOptions.unshift({ label: '--None--', value: undefined });

        this.statusFilterVal = undefined;
        this.statusFilterOptions = Array.from(statusSet).map(entry => ({ label: entry, value: entry }));
        this.statusFilterOptions.unshift({ label: '--None--', value: undefined });

        this.billingCountryCodeFilterVal = undefined;
        this.billingCountryCodeFilterOptions = Array.from(billingCountryCodeSet).map(entry => ({ label: entry, value: entry }));
        this.billingCountryCodeFilterOptions.unshift({ label: '--None--', value: undefined });

        this.allocationFilterVal = undefined;
        this.allocationFilterOptions = Array.from(allocatedSet).map(entry => ({ label: entry, value: entry }));
        this.allocationFilterOptions.unshift({ label: '--None--', value: undefined });

        this.notFoundIATACodes = undefined;
        if (this._searchTermsIATACodes.length > 0) {
            let notFoundIATACodes = this._searchTermsIATACodes.filter(x => !qicIdSet.has(x));
            if (notFoundIATACodes.length > 0) {
                this.notFoundIATACodes = notFoundIATACodes.join(', ');
            }
        }

        return mappedRecords;
    }

    get records () {
        return this.filteredRecords; 
    }

    get hasRecords() {
        return this._records && this._records.length > 0;
    }

    get filteredRecordCount(){
        return this.filteredRecords ? this.filteredRecords.length : 0;
    }

    get selectedRecordCount() {
        return this.filteredRecords ? this.filteredRecords.filter(record => record.selected).length : 0;
    }

    selectAllHandler(evt) {
        this.filteredRecords.forEach(record => {
            if (!record.errorStatus && record.allowAllocation) record.selected = evt.detail.checked;
        });
    }

    selectHandler(evt) {
        console.log(JSON.stringify(evt.target));
        const index = evt.target.name;
        if (!this._records[index].errorStatus && this._records[index].allowAllocation) this._records[index].selected = evt.detail.checked;
    }

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (!isEnterKey) return;

        evt.target.reportValidity();
        if (!evt.target.checkValidity()) {
            return;
        }
        evt.target.reportValidity();
        if (evt.target.name === 'AgencyBrand' && !this._searchTermsAgencyBrand.includes(evt.target.value)) {
            this._searchTermsAgencyBrand.push(evt.target.value);
        } else if (evt.target.name === 'AgencyGroup' && !this._searchTermsAgencyGroup.includes(evt.target.value)) {
            this._searchTermsAgencyGroup.push(evt.target.value);
        } else if (evt.target.name === 'AgencyIATA' && !this._searchTermsIATA.includes(evt.target.value)) {
            this._searchTermsIATA.push(evt.target.value);
        }
        evt.target.value = '';
    }

    handleRemoveAgencyBrand(evt) {
        evt.preventDefault();
        let index = this._searchTermsAgencyBrand.findIndex(x => x.Id === evt.detail.name);
        if (index !== -1) this._searchTermsAgencyBrand.splice(index, 1);
    }
    handleRemoveAgencyGroup(evt) {
        evt.preventDefault();
        let index = this._searchTermsAgencyGroup.indexOf(evt.detail.name);
        if (index !== -1) this._searchTermsAgencyGroup.splice(index, 1);
    }
    handleRemoveAgencyIATA(evt) {
        evt.preventDefault();
        let index = this._searchTermsIATA.findIndex(x => x.Id === evt.detail.name);
        if (index !== -1) this._searchTermsIATA.splice(index, 1);
    }

    handleReset() {
        this._searchTermsAgencyBrand = [];
        this._searchTermsAgencyGroup = [];
        this._searchTermsIATA = [];
        this._searchTermsIATACodes = [];
        this.refs?.bulkLoad && (this.refs.bulkLoad.value = '');
        this._records = [];
        this.emptyMessage = 'Please search with relevent parameters to allocate..';
        this.handleClearFilter();
    }

    handleSearch() {
        let bulkLoadData = this.refs.bulkLoad.value;
        this._searchTermsIATACodes = [];
        if (bulkLoadData) {
            const bulkLoadIATASet = new Set();
            bulkLoadData.split(/,|\r\n|\n/)?.forEach(element => {
                let x = element.trim();
                if (x !== '') {
                    bulkLoadIATASet.add(x);
                }
            });
            this._searchTermsIATACodes = Array.from(bulkLoadIATASet);
        } 
        if (this._searchTermsIATACodes.length === 0 && this._searchTermsAgencyBrand?.length === 0 && this._searchTermsAgencyGroup?.length === 0 && this._searchTermsIATA?.length === 0) {
            this.showToast('No search terms provided', 'Please provide at least one search term', 'error');
            return;
        }
        this.showSpinner = true;
        getAllocations({
            agencyBrand: this._searchTermsAgencyBrand.map(s => s.Id),
            agencyGroup: this._searchTermsAgencyGroup?.map(x => x+'%'),
            agencyIATA: this._searchTermsIATA.map(s => s.Id),
            agencyIATACodes: this._searchTermsIATACodes,
            selectedOfferId: this.selectedOfferId
        }).then(result => {
            this._records = this.setupData(result);
            this.emptyMessage = 'No records found. The IATAs record may not exist or is not an active PNDC. Please review the search parameters.';
            this.handleClearFilter();
            if (this.refs?.selectAll) this.refs.selectAll.checked = false;
            this.showSpinner = false;
        }).catch(error => {
            this.showToast('Error', error.message, 'error');
            this.showSpinner = false;
        })
    }

    async handleAllocate() {
        //const recToCreate = this.filteredRecords.filter(record => record.allowAllocation && record.selected && (record?.allocatedOffers === undefined));
        const recToAllocate = this.filteredRecords.filter(record => record.allowAllocation && record.selected 
                                    && (record?.offerAllocated === 'Not Allocated'));
        if (recToAllocate.length === 0) {
            this.showToast('No records selected', 'Please select at least one unallocated record to Allocate', 'error');
            this.showSpinner = false;
            return;
        }
        const result = await LightningConfirm.open({
            message: 'Please confirm you want to allocate the Offer to the selected records?',
            label: 'Confirm Allocation',
            theme: 'error'
        });
        //Confirm has been closed
        //result is true if OK was clicked
        //and false if cancel was clicked

        if (result) await this.doAllocations(recToAllocate);
    }

    async doAllocations(recToAllocate) {
        this.showSpinner = true;
        let curdatetime = new Date().toISOString();
        try {
            this.percentComplete = 0;
            this.progressMessage = 'Offers are being allocated. Please do not navigate away from this page...';
            this.showProgress = true;
            let i = 0, size = 200, recordsUpdated = 0;
            while (i < recToAllocate.length) {
                const recordAllocatePromises = recToAllocate.slice(i, i + size).map( record => {
                    let allocPromise;
                    let fields = { Id: record?.allocatedOffers?.[0]?.Id,
                                            Offer_Catalogue__c: this.selectedOfferId, 
                                            Account__c: record.accountId,
                                            Status__c: 'Allocated',
                                            Effective_Date__c: curdatetime
                                            };
                    if (record?.allocatedOffers?.[0]?.Id === undefined) {
                        allocPromise =  createRecord({apiName: 'Offer_Allocation__c', fields});
                    } else {
                        allocPromise =  updateRecord({fields});
                    }
                    allocPromise = allocPromise.then(result => { 
                            this._records[record.keyIndex].allocatedOffers = [{...fields, Id: result.id}]; 
                            this._records[record.keyIndex].offerAllocated = 'Allocated';
                            this._records[record.keyIndex].selected = false;
                            recordsUpdated++;
                            this.percentComplete = Math.round((recordsUpdated / recToAllocate.length) * 100);
                            //return result;
                            });
                    return allocPromise;
                });
                await Promise.all(recordAllocatePromises);
                i += size;
            }
            this.handleSearch();
            this.showProgress = false;
            this.showToast('Success', 'Offer Allocated to '+ recToAllocate.length +' IATAs', 'success', 'sticky');
        } catch (error) {
            console.log('Error updating records --> ' + JSON.stringify(error));
            this.showToast('Error updating records', JSON.stringify(error), 'error');
            this.showSpinner = false;
        }
    }

    async handleDeAllocate() {
        const recToDeAllocate = this.filteredRecords.filter(record => record.allowAllocation && record.selected && (record?.allocatedOffers !== undefined));
        if (recToDeAllocate.length === 0) {
            this.showToast('No records selected', 'Please select at least one Allocated record to De-Allocate', 'error');
            this.showSpinner = false;
            return;
        }
        const result = await LightningConfirm.open({
            message: 'Please confirm you want to De-allocate the Offer from the selected records?',
            label: 'Confirm De-Allocation',
            theme: 'error'
        });
        //Confirm has been closed
        //result is true if OK was clicked
        //and false if cancel was clicked

        if (result) {
            this.showSpinner = true;
            let curdatetime = new Date().toISOString();
            try {
                //const recordDeletePromises = recToDeAllocate.map(record => deleteRecord(record.allocatedOffers[0].Id));
                this.percentComplete = 0;
                this.progressMessage = 'Offers are being allocated. Please do not navigate away from this page...';
                this.showProgress = true;
                let i = 0, size = 200, recordsUpdated = 0;
                while (i < recToDeAllocate.length) {
                    const recordDeAllocatePromises = recToDeAllocate.slice(i, i + size).map(record => {
                        let deAllocPromise;
                        let fields = { Id: record?.allocatedOffers?.[0]?.Id,
                                                Status__c: 'Deallocated',
                                                Effective_Date__c: curdatetime
                                                };
                        deAllocPromise =  updateRecord({fields});
                        deAllocPromise = deAllocPromise.then(result => { 
                                this._records[record.keyIndex].allocatedOffers[0].Status__c = 'Deallocated';
                                this._records[record.keyIndex].allocatedOffers[0].Effective_Date__c = curdatetime; 
                                this._records[record.keyIndex].offerAllocated = 'Not Allocated';
                                this._records[record.keyIndex].selected = false;
                                recordsUpdated++;
                                this.percentComplete = Math.round((recordsUpdated / recToDeAllocate.length) * 100);
                                //return result;
                                });
                        return deAllocPromise;
                    });
                    await Promise.all(recordDeAllocatePromises);
                    i += size;
                }
                this.handleSearch();
                this.showProgress = false;
                this.showToast('Success', 'Offer De-Allocated from '+ recToDeAllocate.length +' IATAs', 'success', 'sticky');
            } catch (error) {
                console.log('Error updating records --> ' + JSON.stringify(error));
                this.showToast('Error updating records', JSON.stringify(error), 'error');
                this.showSpinner = false;
            }
        }
    }

    //Fields and function for Agency Brand Record Picker 
    get agencyBrandFilter() { 
        //let x = this._searchTermsAgencyBrand;
        return { criteria: [
            { fieldPath: 'Active__c', operator: 'eq', value: true },
            { fieldPath: 'Id', operator: 'nin', value: this._searchTermsAgencyBrand.map(s => s.Id) },

            ],
            filterLogic: '1 AND 2',
            };
    }

    agencyBrandDisplayInfo = {
        primaryField: 'Name',
        additionalFields: ['sales_h_region_id__c'],
    };

    handleAgencyBrandPickerChange(evt) {
        console.log(JSON.stringify(evt));
        evt.stopPropagation();
        if (!evt.detail.recordId) return;
        this._selectedAgencyBrand = evt.detail.recordId;
        //this._searchTermsAgencyBrand.push(evt.detail.recordId);
        //this.refs.agencyBrandPicker.clearSelection();
    }

    @wire(getRecord, { recordId: '$_selectedAgencyBrand',  fields: 'Sales_Region__c.Name' })
    wiredAgencyBrandPicker({ error, data }) {
        if (data) {
            let x = generateRecordInputForUpdate(data).fields;
            this._searchTermsAgencyBrand.push({Id: x.Id, Name: x.Name});
            this._selectedAgencyBrand = undefined;
            this.refs.agencyBrandPicker.clearSelection();
        }
    }

    //Fields and function for IATA/ARC/TIDS Record Picker 
    get agencyIATAFilter() { 
        return { criteria: [
                    { fieldPath: 'Active__c', operator: 'eq', value: true },
                    { fieldPath: 'RecordType.DeveloperName', operator: 'eq', value: 'Agency_Account' },
                    { fieldPath: 'Id', operator: 'nin', value: this._searchTermsIATA.map(s => s.Id) },
                ],
            filterLogic: '1 AND 2 AND 3',
        };
    }

    agencyIATADisplayInfo = {
        primaryField: 'Name',
        additionalFields: ['Qantas_Industry_Centre_ID__c'],
    };

    agencyIATAmatchingInfo = {
        primaryField: { fieldPath: 'Name', mode: 'startsWith' },
        additionalFields: [{ fieldPath: 'Qantas_Industry_Centre_ID__c' }],
    };

    handleagencyIATAPickerChange(evt) {
        console.log(JSON.stringify(evt));
        evt.stopPropagation();
        if (!evt.detail.recordId) return;
        this._selectedAgencyIATA = evt.detail.recordId;
        //this._searchTermsIATA.push(evt.detail.recordId);
        //this.refs.agencyIATAPicker.clearSelection();
    }

    @wire(getRecord, { recordId: '$_selectedAgencyIATA',  fields: 'Account.Name' })
    wiredAgencyIATAPicker({ error, data }) {
        if (data) {
            let x = generateRecordInputForUpdate(data).fields;
            this._searchTermsIATA.push({Id: x.Id, Name: x.Name});
            this._selectedAgencyIATA = undefined;
            this.refs.agencyIATAPicker.clearSelection();
        }
    }

    @wire(EnclosingTabId) 
    wiredEnclosingTabId(enclosingTabId) {
        if (enclosingTabId && !this.recordId) setTabLabel(enclosingTabId, TAB_LABEL);
    }

    showToast(title, message, variant, mode = 'dismissible ') {
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    /*handleFilesSelected(evt) {
        const files = evt.detail.files;
        if (files.length > 0) {
            const file = files[0];
            this.showSpinner = true;
            // start reading the uploaded csv file
            this.processCsvFile(file);
        }
    }

    async processCsvFile(file) {
        try {
            const csvData = await this.loadSelectedFile(file);
            //console.log("#### result = "+JSON.stringify(result));
            // execute the logic for parsing the uploaded csv file
            const Iatas = this.parseCSVForIATAs(csvData);
            if (Iatas.length > 0) {
                const accountData = await getAgencyNamesFromIATAs({agencyIATA: Iatas});
                if (accountData && accountData.length > 0) {
                    this._searchTermsIATA = [];
                    accountData.forEach(record => {
                        this._searchTermsIATA.push({Id: record.Id, Name: record.Name});
                    });
                    this.handleSearch();
                    
                }  else {
                    this.showToast('Error Finding Records', 'No Valid records found. Please ensure that the IATA numbers are valid and active in the system', 'error');
                    this.showSpinner = false;
                }
            } else {
                this.showToast('No Records', 'No Valid entries found in file', 'error');
                this.showSpinner = false;
            }
        } catch (e) {
            this.showToast('Error Processing File', e, 'error');
            this.showSpinner = false;
        }
    }

    async loadSelectedFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            reader.onload = () => {
                console.log("#### reader.result = "+JSON.stringify(reader.result));
                resolve(reader.result);
            };
            reader.onerror = () => {
                console.log("#### reader.error = "+JSON.stringify(reader.error));
                reject(reader.error);
            };
            console.log("#### file = "+JSON.stringify(file));
            reader.readAsText(file);
        });
    }

    parseCSVForIATAs(csv) {
        // parse the csv file and treat each line as one item of an array
        const lines = csv.split(/\r\n|\n/);
        //console.log("#### lines = "+JSON.stringify(lines));
        // parse the first line containing the csv column headers
        const headers = lines[0].split(',');
        console.log("#### headers = "+JSON.stringify(headers));
        const data = [];
        
        // iterate through csv file rows and transform them to format supported by the datatable
        lines.forEach((line, i) => {
          if (i === 0) return;
      
          const currentline = line.split(',');
          if (currentline.length > 0 || currentline[0] !== '') {
            data.push(currentline[0]);
          }
        });
        console.log("#### data = "+JSON.stringify(data));
        return data;
      }*/
}