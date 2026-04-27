/**************************************************************************************
Name:         cc_CINRecallCampaign
Description:  Component to display CIN Response Data on Asset Record Page
Developed by: TCS
=========================================================================================
History
=========================================================================================
VERSION   AUTHOR                        DATE(MM/DD/YYYY)    Description
1.0 -     Shivani R                     09/25/2023          MCS-98 Initial Development
****************************************************************************************/
import { LightningElement, wire, api, track } from 'lwc';
export default class CC_CINRecallCampaign extends LightningElement {
    @api recallcampaigndata;
    @track page = 1;
    @track startingRecord = 1;
    @track endingRecord;
    @track pageSize = 3;
    @track totalPage = 0;
    @track totalNumberOfRecords = 0;
    @track dataToDisplay;
    @track noDataFoundErr = 'No Records Found';
    @track isPreviousDisable;
    @track isNextDisable = false;
    @track selectedRecordId;
    @track selectedRecord;
    @track isRecallData;
    @track showModal;
    @track recallColumns = [
        {
            label: 'Id', fieldName: 'id', type: 'button',
            typeAttributes: {
                label: { fieldName: 'id' },
                name: 'ViewRecord',
                title: 'View Record',
                variant: 'brand',
                disabled: false,
                value: { fieldName: 'id' },
            }
        },
        { label: 'Release Date', fieldName: 'releaseDate', type: 'text', sortable: false },
        { label: 'Type', fieldName: 'type', type: 'text', sortable: false },
        { label: 'Description', fieldName: 'description', type: 'text', sortable: false },
        { label: 'Status', fieldName: 'status', type: 'text', sortable: false }
    ];

    get recordsToDisplay() {
        if (this.hasValue(this.recallcampaigndata)) {
            if (this.startingRecord == 1) {
                this.totalNumberOfRecords = this.recallcampaigndata.length;
                this.totalPage = Math.ceil(this.totalNumberOfRecords / this.pageSize);
                //here we slice the data according page size
                this.dataToDisplay = this.recallcampaigndata.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;
                this.isPreviousDisable = true;
                this.isNextDisable = false;
            }
            else {
                this.isPreviousDisable = false;
                return this.dataToDisplay;
            }
            this.isRecallData = true;

        }
        else {
            this.isRecallData = false;
            console.log('CC_CINRecallCampaign::no data returned');
        }
        this.prevNextBtnCheck();
        return this.dataToDisplay;

    }

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
        else
            this.isNextDisable = true;
    }
    //method to check the 'Previous' and 'Next' button visibility
    prevNextBtnCheck() {
        if (this.page == 1) {
            this.isPreviousDisable = true;
        }
        else {
            this.isPreviousDisable = false;
        }
        if (this.totalPage > this.page) {
            this.isNextDisable = false;
        }
        else {
            this.isNextDisable = true;
        }
    }

    displayRecordPerPage(page) {
        console.log('inside displayRecordPerPage loop--->')
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalNumberOfRecords)
            ? this.totalNumberOfRecords : this.endingRecord;
        this.dataToDisplay = this.recallcampaigndata.slice(this.startingRecord, this.endingRecord);
        //increment by 1 to display the startingRecord count, 
        //so for 2nd page, it will show "Displaying 3 to 6 of 23 records. Page 2 of 8"
        this.startingRecord = this.startingRecord + 1;
        this.prevNextBtnCheck();
    }

    hasValue(val) {
        if (val != null && val != undefined && val != '') {
            return true;
        } else {
            return false;
        }
    }

    viewRecallRecord(event) {
        this.selectedRecordId = event.detail.row.id;
        this.selectedRecord = this.recallcampaigndata.find(record => record.id === this.selectedRecordId);
        this.selectedSource = this.selectedRecord ? this.selectedRecord.source : '';
        this.selectedExpiresDate = this.selectedRecord ? this.selectedRecord.expiresDate : '';
        this.selectedLabourOps = this.selectedRecord ? this.selectedRecord.labourOps : '';
        this.selectedPointRattrape = this.selectedRecord ? this.selectedRecord.pointRattrape : '';
        this.showModal = true;
    }

    CloseModalHandle() {
        this.showModal = false;
    }
}