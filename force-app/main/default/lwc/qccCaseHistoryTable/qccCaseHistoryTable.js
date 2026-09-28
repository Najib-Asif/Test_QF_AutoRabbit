import { LightningElement, wire, api, track } from 'lwc';
import getCaseCommentFromPNR from '@salesforce/apex/QCC_CaseHistoryTableController.getCaseCommentFromPNR';
import getCaseData from '@salesforce/apex/QCC_CaseHistoryTableController.getCaseData';
import retrieveCaseComments from '@salesforce/apex/QCC_CaseHistoryTableController.retrieveCaseComments'; // Raghav
import getCaseCommentFromContact from '@salesforce/apex/QCC_CaseHistoryTableController.getCaseCommentFromContact';
import getCaseCommentFromFFNumber from '@salesforce/apex/QCC_CaseHistoryTableController.getCaseCommentFromFFNumber';
import getCaseCommentFromContact2 from '@salesforce/apex/QCC_CaseHistoryTableController.retrieveCaseCommentsContact';
import getCaseCommentFromCase from '@salesforce/apex/QCC_CaseHistoryTableController.getCaseCommentFromCase';

import { MessageContext, subscribe } from 'lightning/messageService';
import QCC_CASE_CHANNEL from '@salesforce/messageChannel/QCC_Case_Channel__c';
import {subscribe as empSubscribe, onError} from 'lightning/empApi';


export default class QccCaseHistoryTable extends LightningElement {
    @api recordId;
    @track columns = [];
    @track caseData = [];
    @track contactData = [];
    @track pnr;
    @track conName;
    @track caseContactId;
    @track savedContactId;
    @track ffNumber;
    @track savedFFNumber;
    @track visible = false;
    @track noPNR;
    @track caseCommentsData = [];
     norecord = false;
     dataSize;
     enableInfiniteLoading = false;
    @track tableRefresh;
    @api historyType  //Raghav
    @api isHistoryTypePNR = false; //Raghav
    @api isHistoryTypeCon = false; //Raghav
    @api isHistoryTypeCase = false;

    defaultSortDirection = 'asc'
    sortDirection = 'asc';
    sortedBy;
    displayText = 'No items to display.'
    rowLimit = 50;   // Limit for to get records for LazyLoading
    rowOffSet = 0;  //Offset for CaseComment of the Contact 
    pnrOffSet = 0;  //Offset for CaseComment of the PNR 
   

	connectedCallback() {
        console.log("@@@@ connectedCallback check8");
        // Callback invoked whenever a new event message is received
        
        this.loadcaseData();
        this.subscribeToMessageChannel();
        this.subscribeToPlatformEvent();
               
    }

renderedCallback()
{
    console.log('@@@ rendered callback');
     this.initScrollSync();

}
initScrollSync() {
    const wrapper1 = this.template.querySelector('.wrapper1');
    const wrapper2 = this.template.querySelector('.wrapper2');

    if (wrapper1 && wrapper2) {
        // Ensure the event listeners aren't added more than once
        if (!this._listenersAdded) {
            this._listenersAdded = true;

            wrapper1.addEventListener('scroll', () => {
                wrapper2.scrollLeft = wrapper1.scrollLeft;
            });

            wrapper2.addEventListener('scroll', () => {
                wrapper1.scrollLeft = wrapper2.scrollLeft;
            });
        }
    }
}

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.caseData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.caseData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    onHandleSortContact(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.contactData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.contactData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        console.log("@@@@ subscribeToMessageChannel");
        this.subscription = subscribe(
            this.messageContext, QCC_CASE_CHANNEL,
            (message) => this.handleMessage(message)
        );

        
    }

    subscribeToPlatformEvent() {
        const channel = '/event/QCC_PNR_History_Event__e';
        const replayId = -1;

        empSubscribe(channel, replayId, event => {
            console.log('Received Platform Event: ', JSON.stringify(event));
            this.refreshTable();
        }).then(response => {
            console.log('Subscribed to Platform Event channel: ', response.channel);
        }).catch(error => {
            console.error('Error subscribing to Platform Event channel: ', error);
        });

        onError(error => {
            console.error('Received error from EMP API: ', error);
        });
    }
    handleMessage(message) {
        console.log("@@@@ handleMessage subscribeToMessageChannel");
        console.log('@@@@ handleMessage ' + JSON.stringify(message.payloadData.action));
        console.log('@@@@ handleMessage ' + JSON.stringify(message));
        console.log('message.payloadData.pnrValue::*****'+message.payloadData.pnrValue);
        this.pnr = message.payloadData.pnrValue;
		//this.historyType='pnr';
        this.refreshTable();
        //this.loadcaseData();
    }

    loadcaseData() {
        console.log('loadCaseData::::****');
        getCaseData({ caseId: this.recordId })
            .then((data) => {
                let mcontactId;
                let mFFNumber;
               let contactRecordTypeName;
                if (data && data.length > 0) {
                    data.forEach((row) => {
                        this.pnr = row.Booking_PNR__c;
                        mcontactId = row.ContactId;
                        this.savedContactId = row.ContactId;
                        mFFNumber = row.Frequent_Flyer_Number__c;
                        this.savedFFNumber = row.Frequent_Flyer_Number__c;
                        this.conName = row.Contact ? row.Contact.Name : '';
                        contactRecordTypeName = row.Contact ? row.Contact.RecordType.Name : '';
                    });
                    if(this.historyType == 'contact' && this.conName !== undefined && this.conName.toLowerCase().includes('null') && contactRecordTypeName !== undefined && contactRecordTypeName.toLowerCase() == 'placeholder')
                    {
                        this.norecord = true;
                        this.displayText = 'Case has No Contact -Please update the case contact order to see the contact history.';
                        return;
                    }
                    this.getColumns();
                     debugger;
                    if (this.pnr != null && this.pnr != undefined && this.pnr != '' && this.historyType == 'pnr') {
                        //this.loadDataFromPNR();  
                        this.loadCaseCommentHistory();   
                        this.isHistoryTypePNR = true;
                    } else if ((this.pnr == null || this.pnr == undefined) && this.historyType == 'pnr') {

                        this.loadDataFromCase();
                        this.isHistoryTypePNR = true;
                    } else if (mcontactId != null && mcontactId != undefined && mcontactId != '' && this.historyType === 'contact') {
                        this.caseContactId = mcontactId;
                        this.loadDataFromContact2();
                        this.isHistoryTypePNR = false;
                        this.isHistoryTypeCon = true;
                    } else if (this.historyType === 'casehistory') {
                        this.caseContactId = mcontactId;
                        //this.loadDataFromContact();
                        this.loadDataFromContact2();  //Edited by Raghav
                        this.isHistoryTypePNR = false;
                        //this.isHistoryTypeCase = true; //Commented by Raghav
                        this.isHistoryTypeCon = true;   //Edited by Raghav
                    } else if (mFFNumber != null && mFFNumber != undefined && mFFNumber != '') {
                        this.ffNumber = mFFNumber;
                        this.loadDataFromFFNumber();
                        this.isHistoryTypePNR = false;
                        this.isHistoryTypeCon = false;
                    }
                }
            })
            .catch((error) => {
                this.error = error.message;
                console.error(error);
            });
    }



    refreshTable() {
        console.log('refreshTable::::****');
        getCaseData({ caseId: this.recordId })
            .then((data) => {
                let mcontactId;
                let mFFNumber;
               let contactRecordTypeName;
                if (data && data.length > 0) {
                    data.forEach((row) => {
                        this.pnr = row.Booking_PNR__c;
                        mcontactId = row.ContactId;
                        this.savedContactId = row.ContactId;
                        mFFNumber = row.Frequent_Flyer_Number__c;
                        this.savedFFNumber = row.Frequent_Flyer_Number__c;
                        this.conName = row.Contact ? row.Contact.Name : '';
                        contactRecordTypeName = row.Contact ? row.Contact.RecordType.Name : '';
                    });
                    if(this.historyType == 'contact' && this.conName !== undefined && this.conName.toLowerCase().includes('null') && contactRecordTypeName !== undefined && contactRecordTypeName.toLowerCase() == 'placeholder')
                    {
                        this.norecord = true;
                        this.displayText = 'Case has No Contact -Please update the case contact order to see the contact history.';
                        return;
                    }
                    this.getColumns();
                    debugger;
                    if (this.pnr != null && this.pnr != undefined && this.pnr != '' && this.historyType == 'pnr') {
                        
                        //this.loadDataFromPNR();   // Commented by Raghav
                        this.caseData=[];
                        this.pnrOffSet=0;
                        this.loadCaseCommentHistory();   //Added by Raghav 
                        this.isHistoryTypePNR = true;
                    } else if ((this.pnr == null || this.pnr == undefined) && this.historyType == 'pnr') {
                        this.caseData=[];
                        this.loadDataFromCase();

                    } else if (mcontactId != null && mcontactId != undefined && mcontactId != '' && this.historyType === 'contact') {
                        
                        this.caseContactId = mcontactId;
                        this.contactData=[];
                        this.rowOffSet=0;
                        this.loadDataFromContact2();
                        this.isHistoryTypePNR = false;
                        this.isHistoryTypeCon = true;

                    } else if (this.historyType === 'casehistory') {
                        
                        this.caseContactId = mcontactId;
                        //this.loadDataFromContact();
                        this.loadDataFromContact2();  //Edited by Raghav
                        this.isHistoryTypePNR = false;
                        //this.isHistoryTypeCase = true; //Commented by Raghav
                        this.isHistoryTypeCon = true;   //Edited by Raghav
                    } else if (mFFNumber != null && mFFNumber != undefined && mFFNumber != '') {
                        
                        this.ffNumber = mFFNumber;
                        this.loadDataFromFFNumber();
                        this.isHistoryTypePNR = false;
                        this.isHistoryTypeCon = false;
                    }
                }
            })
            .catch((error) => {
                this.error = error.message;
                console.error(error);
            });
    }


    // Raghav Starts

    loadCaseCommentHistory() {

retrieveCaseComments({ pnr: this.pnr, caseId: this.recordId, limitSize: this.rowLimit, offset: this.pnrOffSet })
    .then((data) => {

        if (data && data.length > 0) {
            this.tableRefresh = data;
            this.dataSize = data.length;

            if (this.dataSize == 0 && this.caseData.length == 0) {
                this.visible = false;
                this.norecord = true;
                console.log('@@this.datasize is empty ');
            } else if (this.dataSize != 0) {
                console.log('@@this.datasize is NOT empty');
                this.visible = true;
                this.norecord = false;
                console.log('@@this.datasize is NOT empty and this.visible value' + this.visible);
            }
            this.enableInfiniteLoading = (data.length != 0);

            let fieldData = {};

            data.forEach((pnrHistory) => {
                if (!fieldData[pnrHistory.PNRNumber]) {
                    fieldData[pnrHistory.PNRNumber] = [];
                }
                pnrHistory.caseCommentHistoryList.forEach((row) => {
                    let fieldLine = {
                        Id: row.CaseCommentId,
                        CaseId: row.CaseId,
                        CaseType: row.CaseType,
                        Caller: row.Caller,
                        CommentBody: row.CommentBody,
                        CaseNumber: row.CaseNumber,
                        DateOpened: new Date(row.CommentDate),
                        CaseStatus: row.CaseStatus,
                        Duration: row.Duration,
                        Consultant: row.Consultant,
                        UniqueNum :   row.UniqueNum,
                        PnrNo: row.pnr,
                        Contact: row.ContactName
                    };
                    fieldData[pnrHistory.PNRNumber].push(fieldLine);
                });
            });

            //fieldData.sort((a, b) => new Date(b.DateOpened) - new Date(a.DateOpened));
            let uniqueRecords = Object.entries(fieldData).map(([pnrNumber, caseComments]) => ({
                pnrNumber: pnrNumber,
                caseComments: caseComments
            }));

            // Merge uniqueRecords with existing this.caseData
            uniqueRecords.forEach((newRecord) => {
                let existingRecordIndex = this.caseData.findIndex(record => record.pnrNumber === newRecord.pnrNumber);
                if (existingRecordIndex !== -1) {
                    // If PNR already exists, merge case comments
                    this.caseData[existingRecordIndex].caseComments = [
                        ...this.caseData[existingRecordIndex].caseComments,
                        ...newRecord.caseComments
                    ];
                    this.caseData[existingRecordIndex].caseComments.sort((a, b) => new Date(b.DateOpened) - new Date(a.DateOpened));
                } else {
                    // If PNR does not exist, add new record
                    this.caseData.push(newRecord);
                    this.caseData[this.caseData.length - 1].caseComments.sort((a, b) => new Date(b.DateOpened) - new Date(a.DateOpened));
                }
            });
            console.log('Merged caseData:::' + JSON.stringify(this.caseData));


        } else {
            if (this.caseData.length == 0) {
                this.visible = false;
                this.norecord = true;
            }
        }
    })
    .catch((error) => {
        this.error = error.message;
        console.error(error);
    });

    }
    
    // Raghav Ends

    loadDataFromPNR() {
        console.log('loadDatafromPNR');
        getCaseCommentFromPNR({ pnr: this.pnr, limitSize: this.rowLimit, offset: this.rowOffSet })
            .then((data) => {
                console.log('this is the data>>>>', data);
                if (data && data.length > 0) {
                    this.tableRefresh = data;
                    let fieldData = [];
                    this.dataSize = data.length;

                    if (this.dataSize == 0 && this.caseData.length == 0) {
                        this.visible = false;
                        this.norecord = true;
                    }
                    else if (this.dataSize != 0) {
                        this.visible = true;
                        this.norecord = false;
                    }
                    let i=0;
                    data.forEach((row) => {
                       i++;
                        let fieldLine = {};
                        fieldLine.Id = row.Id;
                        fieldLine.PnrNo = this.pnr;
                        fieldLine.CaseId = row.Parent.Id;
                        fieldLine.CaseType = row.Parent.Type;
                        fieldLine.CommentBody = row.CommentBody;
                        if (row.Parent.Contact !== undefined) {
                            fieldLine.Contact = row.Parent.Contact.Name;//Added on Aug24
                        }
                        fieldLine.CaseNumber = row.Parent.CaseNumber;
                        fieldLine.DateOpened = row.CreatedDate;
                        fieldLine.CaseStatus = row.Parent.Status;
                        fieldData.push(fieldLine);

                    })
                    this.getColumns();
                    //this.caseData = fieldData;
                    let updatedRecords = [...this.caseData, ...fieldData];
                    let uniqueRecordSet = new Set(updatedRecords.map((record) => record.Id));
                    this.caseData = [...uniqueRecordSet].map((uniqueId) =>
                        updatedRecords.find((record) => record.Id === uniqueId)
                    );
                    //this.loadCaseCommentHistory();
                } //Raghav
                else {
                    console.log('this is else>>>');
                    this.visible = false;
                    this.norecord = true;
                }
            })
            .catch((error) => {
                this.error = error.message;
                console.error(error);
            });
    }

    loadDataFromContact() {
        getCaseCommentFromContact({ contactId: this.caseContactId })
            .then((data) => {
                this.tableRefresh = data;
                let fieldData = [];
                console.log('this is the case hisotry data>>>' + this.tableRefresh);
                this.dataSize = data.length;
                if (this.dataSize == 0) {
                    this.visible = false;
                    this.norecord = true;
                }
                else if (this.dataSize != 0) {
                    this.visible = true;
                    this.norecord = false;
                }
                data.forEach((row) => {
                    let fieldLine = {};
                    fieldLine.Id = row.Id;
                    fieldLine.CaseId = row.Parent.Id
                    if (row.Parent.Contact) {
                        fieldLine.Contact = row.Parent.Contact.Name;
                    }
                    // fieldLine.Contact = row.Parent.Contact.Name;
                    fieldLine.CommentBody = row.CommentBody;
                    fieldLine.CaseNumber = row.Parent.CaseNumber;
                    fieldLine.DateOpened = row.CreatedDate;
                    fieldLine.CaseStatus = row.Parent.Status;
                    // fieldLine.CaseType=row.Parent.CaseType;
                    // fieldLine.Duration = row.Duration;
                    // fieldLine.Consultant = row.Parent.Consultant;
                    // fieldLine.Caller = row.Caller;
                    // fieldLine.PnrNo = row.PnrNo;
                    fieldData.push(fieldLine);
                })
								this.getColumns(); //Added for CRM-7694 Contact History Tab Loading  
                this.caseData = fieldData;
            });

    }
    loadDataFromContact2() {
        // alert('testcon',this.caseContactId);
        console.log('loadDataFromContact2::::');
        getCaseCommentFromContact2({ ContactId: this.caseContactId, caseId: this.recordId, limitSize: this.rowLimit, offset: this.rowOffSet })
            .then((data) => {
                this.tableRefresh = data;
                let fieldData = [];
                //console.log('testlog:::' + JSON.stringify(data));
                this.dataSize = data.length;
                if (this.dataSize == 0 && this.contactData.length == 0) {
                    this.visible = false;
                    this.norecord = true;
                }
                else if (this.dataSize != 0) {
                    this.visible = true;
                    this.norecord = false;
                }
                this.enableInfiniteLoading = (data.length != 0);
                data.forEach((row) => {
                    let fieldLine = {};
                    fieldLine.Id = row.CaseCommentId;
                    fieldLine.CaseId = row.CaseId;
                    //  if(row.Parent.Contact){
                    fieldLine.Contact = row.ContactName;
                    fieldLine.PnrNo = row.PnrNo;
                    //  }
                    //  fieldLine.Contact = row.Parent.Contact.Name;
                    fieldLine.CaseType = row.CaseType;
                    fieldLine.Duration = row.Duration;
                    fieldLine.Consultant = row.Consultant;
                    fieldLine.Caller = row.Caller;
                    fieldLine.CommentBody = row.CommentBody;
                    fieldLine.CaseNumber = row.CaseNumber;
                    fieldLine.DateOpened = new Date(row.CommentDate);
                    fieldLine.CaseStatus = row.CaseStatus;
                    fieldLine.UniqueNum =   row.UniqueNum;
                    fieldData.push(fieldLine);
                })

                fieldData.sort((a, b) => new Date(b.DateOpened) - new Date(a.DateOpened));

                // Combine the existing contactData with the new fieldData
                let combinedRecords = [...this.contactData, ...fieldData];

                // Create a Map to ensure unique records based on UniqueNum
                let uniqueRecordMap = new Map();
                // Populate the Map with records, ensuring no duplicates based on UniqueNum
                combinedRecords.forEach(record => {
                    uniqueRecordMap.set(record.UniqueNum, {
                        ...record,
                        Id: record.UniqueNum // Update the Id to be the UniqueNum
                    });
                });

            // Convert the Map back to an array
            this.contactData = Array.from(uniqueRecordMap.values());
            });

    }

    loadDataFromFFNumber() {
        getCaseCommentFromFFNumber({ ffNumber: this.ffNumber })
            .then((data) => {
                this.tableRefresh = data;
                let fieldData = [];

                this.dataSize = data.length;
                if (this.dataSize == 0) {
                    this.visible = false;
                    this.norecord = true;
                }
                else if (this.dataSize != 0) {
                    this.visible = true;
                    this.norecord = false;
                }
                data.forEach((row) => {
                    let fieldLine = {};
                    fieldLine.Id = row.Id;
                    fieldLine.CaseId = row.Parent.Id
                    fieldLine.Contact = row.Parent.Contact.Name;
                    fieldLine.CommentBody = row.CommentBody;
                    fieldLine.CaseNumber = row.Parent.CaseNumber;
                    fieldLine.DateOpened = row.CreatedDate;
                    fieldLine.CaseStatus = row.Parent.Status;
                    fieldData.push(fieldLine);
                })

                this.caseData = fieldData;
            });
    }

    loadDataFromCase() {
        this.noPNR = true;
        getCaseCommentFromCase({ CaseID: this.recordId })
            .then((data) => {
                this.tableRefresh = data;
                let fieldData = [];

                this.dataSize = data.length;
                if (this.dataSize == 0) {
                    this.visible = false;
                    this.norecord = true;
                }
                else if (this.dataSize != 0) {
                    this.visible = true;
                    this.norecord = false;
                }
                
                data.forEach((row) => {
                    let fieldLine = {};
                    debugger;
                    fieldLine.Id = row.Id;
                    fieldLine.CaseId = row.ParentId;

                    if (row.Parent.Contact !== undefined) {
                        fieldLine.Contact = row.Parent.Contact.Name;
                    }
                    fieldLine.CommentBody = row.CommentBody;
                    fieldLine.CaseNumber = row.Parent.CaseNumber;
                    fieldLine.DateOpened = row.CreatedDate;
                    fieldLine.CaseStatus = row.Parent.Status;
                    fieldData.push(fieldLine);
                })

                this.caseCommentsData = fieldData;
            });
    }

    getColumns() {
        console.log('testlogm', this.historyType);
        if (this.pnr != null && this.pnr != undefined && this.pnr != '' && this.historyType == 'pnr') {
            let column = [
                {
                    label: 'Date',
                    fieldName: 'DateOpened',
                    wrapText: true,
                    type: 'date',
                    typeAttributes: { day: "2-digit", month: "2-digit", year: "2-digit", hour: '2-digit', minute: '2-digit', hour12: false },
                    sortable: true,
                    initialWidth: 120
                },

                {
                    label: 'Type',
                    wrapText: true,
                    fieldName: 'CaseType',
                    type: 'text',
                    sortable: true,
                    initialWidth: 80
                },
                // {
                //     label: 'PNR',
                //     wrapText: true,
                //     fieldName: 'PnrNo',
                //     type: 'text',
                //     sortable: true,
                //     initialWidth: 80
                // },
                {
                    label: 'Case Comment',
                    fieldName: 'CommentBody',
                    wrapText: true, // Set to false to prevent text wrapping
                    type: 'richText',
                    initialWidth: 350,
                    sortable: true
                },
                {
                    label: 'Caller',
                    wrapText: true,
                    fieldName: 'Caller',
                    sortable: true,
                    initialWidth: 120
                },
                {
                    label: 'Contact',
                    wrapText: true,
                    fieldName: 'Contact',
                    sortable: true,
                    initialWidth: 120
                },
                {
                    label: 'Status',
                    wrapText: true,
                    fieldName: 'CaseStatus',
                    sortable: true,
                    initialWidth: 80
                },
                {
                    label: 'Case',
                    fieldName: 'CaseNumber',
                    wrapText: true,
                    sortable: true,
                    initialWidth: 75,
                    type: 'clickableCaseNumber',
                    typeAttributes: {
                        recordId: { fieldName: 'CaseId' },
                    },
                },
                {
                    label: 'Time',
                    wrapText: true,
                    type: 'text',
                    fieldName: 'Duration',
                    sortable: true,
                    initialWidth: 80
                },
                {
                    label: 'Consultant',
                    wrapText: true,
                    fieldName: 'Consultant',
                    sortable: true,
                    initialWidth: 120
                }
            ];
            this.columns = column;
        } 

        else if ((this.pnr == null || this.pnr == undefined || this.pnr == '') && this.historyType == 'pnr') {
            
            let column = [   
                {
                    label: 'Date',
                    fieldName: 'DateOpened',
                    wrapText: true,
                    type: 'date',
                    typeAttributes: { day: "2-digit", month: "2-digit", year: "2-digit", hour: '2-digit', minute: '2-digit', hour12: false },
                    sortable: true,
                    initialWidth: 120
                },

                {
                    label: 'Type',
                    wrapText: true,
                    fieldName: 'CaseType',
                    type: 'text',
                    sortable: true,
                    initialWidth: 80
                },
                // {
                //     label: 'PNR',
                //     wrapText: true,
                //     fieldName: 'PnrNo',
                //     type: 'text',
                //     sortable: true,
                //     initialWidth: 80
                // },
                {
                    label: 'Case Comment',
                    fieldName: 'CommentBody',
                    wrapText: true, // Set to false to prevent text wrapping
                    type: 'richText',
                    initialWidth: 350,
                    sortable: true
                },
                {
                    label: 'Caller',
                    wrapText: true,
                    fieldName: 'Caller',
                    sortable: true,
                    initialWidth: 120
                },
                {
                    label: 'Contact',
                    wrapText: true,
                    fieldName: 'Contact',
                    sortable: true,
                    initialWidth: 120
                },
                {
                    label: 'Status',
                    wrapText: true,
                    fieldName: 'CaseStatus',
                    sortable: true,
                    initialWidth: 80
                },
                {
                    label: 'Case',
                    fieldName: 'CaseNumber',
                    wrapText: true,
                    sortable: true,
                    initialWidth: 75,
                    type: 'clickableCaseNumber',
                    typeAttributes: {
                        recordId: { fieldName: 'CaseId' },
                    },
                },
                {
                    label: 'Time',
                    wrapText: true,
                    type: 'text',
                    fieldName: 'Duration',
                    sortable: true,
                    initialWidth: 80
                },
                {
                    label: 'Consultant',
                    wrapText: true,
                    fieldName: 'Consultant',
                    sortable: true,
                    initialWidth: 120
                }    
                
            ];
            this.columns = column;
            console.log('Inisde column functions'+this.columns);
        } 
        
        else if (this.historyType === 'casehistory' || (this.savedContactId != null && this.savedContactId != undefined && this.savedContactId != '' && this.historyType === 'contact')) {
            let column = [
                {
                    label: 'Date',
                    fieldName: 'DateOpened',
                    wrapText: true,
                    type: 'date',
                    typeAttributes: { day: "2-digit", month: "2-digit", year: "2-digit", hour: '2-digit', minute: '2-digit', hour12: false },
                    sortable: true,
                    initialWidth: 120
                },

                {
                    label: 'Type',
                    wrapText: true,
                    fieldName: 'CaseType',
                    type: 'text',
                    sortable: true,
                    initialWidth: 80
                },
                {
                    label: 'PNR',
                    wrapText: true,
                    fieldName: 'PnrNo',
                    type: 'text',
                    sortable: true,
                    initialWidth: 80
                },
                {
                    label: 'Case Comment',
                    fieldName: 'CommentBody',
                    wrapText: true, // Set to false to prevent text wrapping
                    type: 'richText',
                    initialWidth: 350,
                    sortable: true
                },
                {
                    label: 'Caller',
                    wrapText: true,
                    fieldName: 'Caller',
                    sortable: true,
                    initialWidth: 120
                },
                // {
                //     label: 'Contact',
                //     wrapText: true,
                //     fieldName: 'Contact',
                //     sortable: true,
                //     initialWidth: 120
                // },
                {
                    label: 'Status',
                    wrapText: true,
                    fieldName: 'CaseStatus',
                    sortable: true,
                    initialWidth: 80
                },
                {
                    label: 'Case',
                    fieldName: 'CaseNumber',
                    wrapText: true,
                    sortable: true,
                    initialWidth: 75,
                    type: 'clickableCaseNumber',
                    typeAttributes: {
                        recordId: { fieldName: 'CaseId' },
                    },
                },
                {
                    label: 'Time',
                    wrapText: true,
                    type: 'text',
                    fieldName: 'Duration',
                    sortable: true,
                    initialWidth: 80
                },
                {
                    label: 'Consultant',
                    wrapText: true,
                    fieldName: 'Consultant',
                    sortable: true,
                    initialWidth: 120
                }
            ];
            this.columns = column;
        }
        else if (this.historyType === 'casehistory') {
            let column = [
                {
                    label: 'Date',
                    fieldName: 'DateOpened',
                    wrapText: true,
                    type: 'date',
                    typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric", hour: '2-digit', minute: '2-digit', hour12: true },
                    sortable: true,
                    initialWidth: 120
                },
                /*
               {
                    label: 'Contact',
                    wrapText: true,
                    fieldName: 'Contact',
                    sortable: true,
                    initialWidth: 100
                }, 
                */

                {
                    label: 'Case Comment',
                    fieldName: 'CommentBody',
                    wrapText: true,
                    initialWidth: 350,
                    sortable: true
                },
                {
                    label: 'Case',
                    fieldName: 'CaseNumber',
                    wrapText: true,
                    sortable: true,
                    initialWidth: 75,
                    type: 'clickableCaseNumber',
                    typeAttributes: {
                        recordId: { fieldName: 'CaseId' },
                    },
                },
                {
                    label: 'Status',
                    wrapText: true,
                    fieldName: 'CaseStatus',
                    sortable: true,
                    initialWidth: 80
                }];
            this.columns = column;
        }
    }

    // Raghav Ends

    handleLoadMoreRecords(event) {
        //event.preventDefault();
        if (this.historyType == 'contact') {
            const { target } = event;


            // Increment rowOffSet by rowLimit for the next iteration
            this.rowOffSet += this.rowLimit;

            // Call the API to load more data
            this.loadDataFromContact2();

            // Update isLoading in the target to indicate loading state
            target.isLoading = false;

        }
        if (this.historyType == 'pnr') {
            //const currentRecord = this.caseData;
            const { target } = event;


            // Increment rowOffSet by rowLimit for the next iteration
            this.pnrOffSet += this.rowLimit;

            // Call the API to load more data
            //this.loadDataFromPNR();
            this.loadCaseCommentHistory();

            // Update isLoading in the target to indicate loading state
            target.isLoading = false;

        }


    }

}