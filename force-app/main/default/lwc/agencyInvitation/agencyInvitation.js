import { LightningElement, track, wire } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import INVITATION_TYPE_FIELD from "@salesforce/schema/Asset.Invitation_Type__c";

import { getRecord, generateRecordInputForUpdate, updateRecord } from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";

import getAgencyInvitations from '@salesforce/apex/AgencyInvitationController.getAgencyInvitations';
import sendInvitations from '@salesforce/apex/AgencyInvitationController.sendInvitations';

import PremiumChannelExpiryDays from "@salesforce/label/c.PremiumChannelExpiryDays";
import PNDCExcludedAccreditiationStatus from "@salesforce/label/c.PNDC_Excluded_Accreditiation_Status";

import { EnclosingTabId, setTabLabel } from 'lightning/platformWorkspaceApi';

const TAB_LABEL = 'PNDC Agency Invitation';
const TYPE3 = 'PNDC Email';

export default class AgencyInvitation extends LightningElement {
    @track _searchTermsAgencyBrand = [];
    @track _searchTermsAgencyGroup = [];
    @track _searchTermsIATA = [];
    @track _searchTermsIATACodes = [];
    @track _records = [];
    @track filteredRecords = [];
    
    _selectedAgencyBrand;
    _selectedAgencyIATA;
    showSpinner = false;
    showProgress = false;
    percentComplete = 0;
    emptyMessage = 'Please select the Invitation Type, and search with the relevant parameters to begin.';

    enableResend = false;
    notFoundIATACodes;
    allAccountIds = [];

    selectedInvitationType;
    progressMessage;
    
    /*matchingInfo = {
        primaryField: { fieldPath: 'Name', mode: 'startsWith' },
        additionalFields: [{ fieldPath: 'Phone' }],
    };*/

    qicTypeFilterVal;
    qicTypeFilterOptions;
    handleQicTypeFilterChange(event) {
        this.qicTypeFilterVal = event.detail.value;
        this.applyFilter();
    }

    qicIdFilterVal;
    qicIdFilterOptions;
    handleQicIdFilterChange(event) {
        this.qicIdFilterVal = event.detail.value;
        this.applyFilter();
    }

    aggregatorFilterVal;
    aggregatorFilterOptions;
    handleAggregatorFilterChange(event) {
        this.aggregatorFilterVal = event.detail.value;
        this.applyFilter();
    }

    emailFilterVal;
    emailFilterOptions;
    handleEmailFilterChange(event) {
        this.emailFilterVal = event.detail.value;
        this.applyFilter();
    }

    expiryFilterVal;
    expiryFilterOptions;
    handleExpiryFilterChange(event) {
        this.expiryFilterVal = event.detail.value;
        this.applyFilter();
    }

    statusFilterVal;
    statusFilterOptions;
    handleStatusFilterChange(event) {
        this.statusFilterVal = event.detail.value;
        this.applyFilter();
    }

    handleClearFilter() {
        this.qicTypeFilterVal = undefined;
        this.qicIdFilterVal = undefined;
        this.aggregatorFilterVal = undefined;
        this.emailFilterVal = undefined;
        this.expiryFilterVal = undefined;
        this.statusFilterVal = undefined;
        this.filteredRecords = this._records;
    }

    applyFilter() {
        this.filteredRecords = this._records.filter(rec => ((!this.qicTypeFilterVal || this.qicTypeFilterVal === rec.qicType) && 
                                    (!this.qicIdFilterVal || this.qicIdFilterVal === rec.qicId) && 
                                    (!this.aggregatorFilterVal || this.aggregatorFilterVal === rec.aggregator) && 
                                    (!this.emailFilterVal || this.emailFilterVal === rec.managerEmail) && 
                                    (!this.expiryFilterVal || this.expiryFilterVal === rec.expiryDate) && 
                                    (!this.statusFilterVal || this.statusFilterVal === rec.pndcStatus)
                                            ));
    }

    get filteredRecordCount(){
        return this.filteredRecords ? this.filteredRecords.length : 0;
    }

    get hasNoFilteredRecords(){
        return this.filteredRecords && this.filteredRecords.length > 0;
    }

    get selectedRecordCount() {
        return this.filteredRecords ? this.filteredRecords.filter(record => record.allowInvitation && record.selected).length : 0;
    }

    get searchTermsAgencyBrand()  {
        return (this._searchTermsAgencyBrand && this._searchTermsAgencyBrand.length > 0) ? this._searchTermsAgencyBrand : [];
    }

    get searchTermsAgencyGroup()  {
        return (this._searchTermsAgencyGroup && this._searchTermsAgencyGroup.length > 0) ? this._searchTermsAgencyGroup : [];
    }

    get searchTermsIATA()  {
        return (this._searchTermsIATA && this._searchTermsIATA.length > 0) ? this._searchTermsIATA : [];
    }

    get emailColumnLabel() {
        if (this.selectedInvitationType === 'EOI') return 'Agency Email';
        else if (this.selectedInvitationType === TYPE3) return 'PNDC Email';
        return 'Brand Email';
    }

    get allowEmailUpdate() {
        if (this.selectedInvitationType === TYPE3) return true;
        return false;
    }

    connectedCallback() {
        //this.setupData();
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
                allowInvitation: (index % 10) == 0 ? false : true,
                expiryDate: `${new Date().getDate()}`,
                errorStatus: (index % 20) == 0 ? 'Random Error' : undefined
            };
        });*/
        this.allAccountIds = [];
        if (!data) return [];

        const qicTypeSet = new Set();
        const qicIdSet = new Set();
        const aggregatorSet = new Set();
        const emailSet = new Set();
        const statusSet = new Set();
        const expirySet = new Set();
        const accountIdSet = new Set();
        const PNDCExcludedAccreditiationStatusList = PNDCExcludedAccreditiationStatus ? PNDCExcludedAccreditiationStatus.split(';') : [];

        let mappedRecords = data.map((rec, index) => {
            let agencyGroup = rec?.Account?.Agency_Sales_Region__r?.Name;
            let indexOfSep = agencyGroup?.indexOf('-');
            if (indexOfSep && indexOfSep !== -1) agencyGroup = agencyGroup?.substring(0, indexOfSep)?.trim();
            let agencyBrand = rec?.Account?.Agency_Sales_Region__r?.Name;
            let allowInvitation = false;
            let accreditationStatus = rec?.Account?.AccreditationStatus__c ?? '';

            let pndcStatus = 'Not Invited';
            if (rec.Premium_Channel_Status__c === 'Invited' && Date.parse(rec.Invitation_Expiry_Date__c) < Date.now() ) 
                pndcStatus = 'Expired';
            else if (rec.Premium_Channel_Status__c) {
                pndcStatus = rec.Premium_Channel_Status__c;
            }
            
            let managerEmail = rec?.Account?.Agency_Sales_Region__r?.Email__c;
            if (this.selectedInvitationType === 'EOI') managerEmail = rec?.Account?.Email__c;
            else if (this.selectedInvitationType === TYPE3) managerEmail = rec?.Account?.SecondaryEmail__c;

            let errorStatus;
            if (!managerEmail) {
                errorStatus = 'Manager email is not defined';
            } else if (PNDCExcludedAccreditiationStatusList.includes(accreditationStatus)) {
                errorStatus = 'Accreditation Status is ' + (rec?.Account?.AccreditationStatus__c ?? 'Blank');
            }

            if (managerEmail && 
                (pndcStatus === 'Not Invited' || (pndcStatus === 'Invited' && this.enableResend) ) )
                    allowInvitation = true;

            let qicType = rec?.Account?.AccreditationType__c;

            qicType && qicTypeSet.add(qicType);
            rec.Agency_Identifier__c && qicIdSet.add(rec.Agency_Identifier__c);
            rec.GDS_Name__c && aggregatorSet.add(rec.GDS_Name__c);
            
            managerEmail && emailSet.add(managerEmail);
            pndcStatus && statusSet.add(pndcStatus);
            expirySet.add(rec.Invitation_Expiry_Date__c ?? '');

            accountIdSet.add(rec.AccountId);
            
            return {
                keyIndex: index,
                assetId: rec.Id,
                accountId: rec.AccountId,
                agencyGroup: agencyGroup,
                agencyBrand: agencyBrand,
                agencyName: rec?.Account?.Name,
                qicType: qicType,
                qicId: rec.Agency_Identifier__c,
                aggregator: rec.GDS_Name__c,
                managerEmail: managerEmail,
                pndcStatus: pndcStatus,
                selected: false,
                allowInvitation: allowInvitation,
                accreditationStatus: accreditationStatus,

                expiryDate: rec.Invitation_Expiry_Date__c ?? '',
                errorStatus: errorStatus
            };
        });

        this.qicTypeFilterVal = undefined;
        this.qicTypeFilterOptions = Array.from(qicTypeSet).map(entry => ({ label: entry, value: entry }));
        this.qicTypeFilterOptions.unshift({ label: '--None--', value: undefined });

        this.aggregatorFilterVal = undefined;
        this.aggregatorFilterOptions = Array.from(aggregatorSet).map(entry => ({ label: entry, value: entry }));
        this.aggregatorFilterOptions.unshift({ label: '--None--', value: undefined });

        this.qicIdFilterVal = undefined;
        this.qicIdFilterOptions = Array.from(qicIdSet).map(entry => ({ label: entry, value: entry }));
        this.qicIdFilterOptions.unshift({ label: '--None--', value: undefined });

        this.emailFilterVal = undefined;
        this.emailFilterOptions = Array.from(emailSet).map(entry => ({ label: entry, value: entry }));
        this.emailFilterOptions.unshift({ label: '--None--', value: undefined });

        this.expiryFilterVal = undefined;
        this.expiryFilterOptions = Array.from(expirySet).map(entry => ({ label: entry, value: entry }));
        this.expiryFilterOptions.unshift({ label: '--None--', value: undefined });

        this.statusFilterVal = undefined;
        this.statusFilterOptions = Array.from(statusSet).map(entry => ({ label: entry, value: entry }));
        this.statusFilterOptions.unshift({ label: '--None--', value: undefined });

        this.notFoundIATACodes = undefined;
        if (this._searchTermsIATACodes.length > 0) {
            let notFoundIATACodes = this._searchTermsIATACodes.filter(x => !qicIdSet.has(x));
            if (notFoundIATACodes.length > 0) {
                this.notFoundIATACodes = notFoundIATACodes.join(', ');
            }
        }
        this.allAccountIds = Array.from(accountIdSet);

        return mappedRecords;
    }

    get records () {
        return this.filteredRecords; 
    }

    get hasRecords() {
        return this._records && this._records.length > 0;
    }

    selectAllHandler(evt) {
        this.filteredRecords.forEach(record => {
            if (!record.errorStatus && record.allowInvitation) record.selected = evt.detail.checked;
        });
    }

    selectHandler(evt) {
        console.log(JSON.stringify(evt.target));
        const index = evt.target.name;
        if (!this._records[index].errorStatus && this._records[index].allowInvitation) this._records[index].selected = evt.detail.checked;
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
            //this._searchTermsAgencyBrand.push(evt.target.value);
        } else if (evt.target.name === 'AgencyGroup' && !this._searchTermsAgencyGroup.includes(evt.target.value)) {
            if (evt.target.value != '')this._searchTermsAgencyGroup.push(evt.target.value);
        } else if (evt.target.name === 'AgencyIATA' && !this._searchTermsIATA.includes(evt.target.value)) {
            //this._searchTermsIATA.push(evt.target.value);
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
        this.emptyMessage = 'Please select the Invitation Type, and search with the relevant parameters to begin.';
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
        getAgencyInvitations({
            agencyBrand: this._searchTermsAgencyBrand.map(s => s.Id),
            agencyGroup: this._searchTermsAgencyGroup?.map(x => x+'%'),
            agencyIATA: this._searchTermsIATA.map(s => s.Id),
            agencyIATACodes: this._searchTermsIATACodes
        }).then(result => {
            this._records = this.setupData(result);
            this.handleClearFilter();
            if (this.refs?.selectAll) this.refs.selectAll.checked = false;
            this.emptyMessage = 'No records found. Please review the search parameters.';
            this.showSpinner = false;
        }).catch(error => {
            this.showToast('Error', error.message, 'error');
            this.showSpinner = false;
        })
    }

    async handleConfirmClick() {
        const recToUpdate = this.filteredRecords.filter(record => record.allowInvitation && record.selected);
        if (recToUpdate.length === 0) {
            this.showToast('No records selected', 'Please select at least one record to send an invitation', 'error');
            this.showSpinner = false;
            return;
        }
        const result = await LightningConfirm.open({
            message: 'Please confirm you want to send the Invitation?',
            label: 'Send Invitation Confirmation',
            theme: 'error'
        });
        //Confirm has been closed
        //result is true if OK was clicked
        //and false if cancel was clicked

        if (result) await this.handleSendInvitations(recToUpdate);
    }

    async handleUpdateEmail() {
        if (this.refs.pndcEmail.value === undefined || this.refs.pndcEmail.value === '') {
            this.showToast('Email Update', 'Please add an email address to update', 'error');
            return;
        }
        else if (!this.refs.pndcEmail?.checkValidity()) {
            this.refs.pndcEmail?.reportValidity();
            return;
        } else if (this.allAccountIds === undefined || this.allAccountIds.length === 0) {
            this.showToast('Email Update', 'No Accounts to update', 'error');
            return;
        }

        const result = await LightningConfirm.open({
            message: 'This will update and overwrite the PNDC email address for all (' + this._records.length + ') records in this agency invitation, including records that may be hidden if any filters are applied.',
            label: 'Email Update Confirmation',
            theme: 'error'
        });
        //Confirm has been closed
        //result is true if OK was clicked
        //and false if cancel was clicked

        if (result) {
            try {
                let accountPNDCEmail = this.refs.pndcEmail.value;
                const PNDCExcludedAccreditiationStatusList = PNDCExcludedAccreditiationStatus ? PNDCExcludedAccreditiationStatus.split(';') : [];
                this.percentComplete = 0;
                this.progressMessage = 'Emails are being updated. Please wait while the process is being completed.'
                this.showProgress = true;
                let i = 0, size = 200, recordsUpdated = 0;
                
                while (i < this.allAccountIds.length) {
                    const accountUpdatePromises = this.allAccountIds.slice(i, i + size).map(accountId => updateRecord({
                            fields: { Id: accountId, SecondaryEmail__c: accountPNDCEmail }
                        })
                        .then(result => {
                            let filteredRec = this._records.filter(rec => rec.accountId === accountId);
                            filteredRec.forEach(rec => {
                                rec.managerEmail = accountPNDCEmail;
                                rec.errorStatus = undefined;
                                if (PNDCExcludedAccreditiationStatusList.includes(rec.accreditationStatus)) {
                                    rec.errorStatus = 'Accreditation Status is ' + (rec.accreditationStatus === '' ? 'Blank' : rec.accreditationStatus);
                                }

                                if ((rec.pndcStatus === 'Not Invited' || (rec.pndcStatus === 'Invited' && this.enableResend))) {
                                    rec.allowInvitation = true;
                                }
                            })

                            recordsUpdated++;
                            this.percentComplete = Math.round((recordsUpdated / this.allAccountIds.length) * 100);
                        })
                    );
                    await Promise.all(accountUpdatePromises);
                    i += size;
                }
                this.emailFilterOptions = [{ label: '--None--', value: undefined }, { label: accountPNDCEmail, value: accountPNDCEmail }];
                this.refs.pndcEmail.value = undefined;
                this.showProgress = false;
                this.showToast('Success', 'Email Updated for all entries', 'success', 'sticky');
            } catch (error) {
                this.showToast('Error updating records', error.body.message, 'error');
                this.showSpinner = false;
                this.showProgress = false;
            }
        };
    }

    async handleSendInvitations(recToUpdate) {
        this.showSpinner = true;
        let invitationDate = new Date().toISOString();
        let expiryDate = new Date();
        let daysForExpiry = Number(PremiumChannelExpiryDays);
        if (isNaN(daysForExpiry)) daysForExpiry = 30;
        expiryDate.setDate(expiryDate.getDate() + daysForExpiry);
        expiryDate = expiryDate.toISOString();
        /*const recToUpdate = this.records.filter(record => record.allowInvitation && record.selected);
        if (recToUpdate.length === 0) {
            this.showToast('No records selected', 'Please select at least one record to send an invitation', 'error');
            this.showSpinner = false;
            return;
        }*/
        try {
            this.percentComplete = 0;
            this.progressMessage = 'Invitations are being sent to the selected agencies. Please wait while the process is being completed.'
            this.showProgress = true;
            let i = 0, size = 200, recordsUpdated = 0;
            
            while(i < recToUpdate.length) {
                //console.log('i: ' + i);
                //console.log('size: ' + size);
                //let startTime = new Date();
                //console.log('Start Time: ' + startTime.toISOString());
                const recordUpdatePromises = recToUpdate.slice(i, i+size).map(record => updateRecord({fields:{Id: record.assetId, Premium_Channel_Status__c: 'Invited', 
                    Invitation_Date__c: invitationDate, Invitation_Expiry_Date__c: expiryDate, Invitation_Type__c: this.selectedInvitationType, Invitation_Email__c: record.managerEmail}})
                    .then(result => { 
                        this._records[record.keyIndex].pndcStatus = 'Invited';
                        this._records[record.keyIndex].allowInvitation = this.enableResend; 
                        this._records[record.keyIndex].expiryDate = expiryDate;
                        this._records[record.keyIndex].selected = false;
                        //console.log('Record updated: ' + record.keyIndex);
                        recordsUpdated++;
                        //console.log('recordsUpdated: ' + recordsUpdated);
                        this.percentComplete = Math.round((recordsUpdated / recToUpdate.length) * 100);
                        //return result;
                        })
                );
                await Promise.all(recordUpdatePromises);
                //console.log('Processed: ' + i);
                let endTime = new Date();
                //console.log('End Time: ' + endTime.toISOString());
                //console.log('Diff Time: ' + (endTime - startTime)/1000 + ' seconds');
                i += size;
            }
            
            /*const recordUpdatePromises = recToUpdate.map(record => updateRecord({fields:{Id: record.assetId, Premium_Channel_Status__c: 'Invited', 
                                            Invitation_Date__c: invitationDate, Invitation_Expiry_Date__c: expiryDate, Invitation_Type__c: this.selectedInvitationType}})
                                            .then(result => { 
                                                this._records[record.keyIndex].pndcStatus = 'Invited';
                                                this._records[record.keyIndex].allowInvitation = this.enableResend; 
                                                this._records[record.keyIndex].expiryDate = expiryDate;
                                                this._records[record.keyIndex].selected = false;
                                                //return result;
                                                })
                                        );
            await Promise.all(recordUpdatePromises);*/
            this.showProgress = false;
            await sendInvitations( { managerEmails: [... new Set(recToUpdate.map(record => record.managerEmail))], invitationType: this.selectedInvitationType } );
            this.handleSearch();
            this.showToast('Success', 'Invitation sent', 'success', 'sticky');
        } catch (error) {
            this.showToast('Error updating records', error.body.message, 'error');
            this.showSpinner = false;
            this.showProgress = false;
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
        additionalFields: ['sales_h_region_id__c', 'Brand_Code__c'],
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

    handleEnableResend(evt) {
        this.enableResend = evt.target.checked;
        if (this._records && this._records.length > 0) {
            this._records.filter(rec => rec.pndcStatus === 'Invited' || rec.pndcStatus === 'GDS Rejected' || rec.pndcStatus === 'Expired' || rec.pndcStatus === 'Inactive').forEach(record => {
                record.allowInvitation = (!record.errorStatus && this.enableResend)
            });
            //console.log(JSON.stringify(this._records));
            this.applyFilter();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '0122v000001ImH3AAK', fieldApiName: INVITATION_TYPE_FIELD })
    wiredInvitaionTypePicklistValues;

    @wire(EnclosingTabId) 
    wiredEnclosingTabId(enclosingTabId) {
        if (enclosingTabId) setTabLabel(enclosingTabId, TAB_LABEL);
    }

    get invitationTypeOptions() {
        return this.wiredInvitaionTypePicklistValues?.data?.values;
    }

    async handleInvitationTypeChange(event) {
        if (this.selectedInvitationType) {
            const result = await LightningConfirm.open({
            message: 'Please confirm you want to update Invitation Type? This will reset the form.',
            label: 'Update Invitation Type',
            theme: 'warning'
            });
            //Confirm has been closed
            //result is true if OK was clicked
            //and false if cancel was clicked

            if (result) {
                this.selectedInvitationType = event.detail.value;
                this.handleReset();
            } else {
                this.refs.invitationType.value = this.selectedInvitationType;
            }
        } else {
            this.selectedInvitationType = event.detail.value;
        }
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
}