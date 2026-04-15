import { LightningElement, api, wire, track } from 'lwc';
import getCaseAgeDispositionHistory from '@salesforce/apex/CC_CaseAgeDispositionHistoryController.getCaseAgeDispositionHistory';
//STRY0553354 - Start
import updateCaseDisposition from '@salesforce/apex/CC_CaseAgeDispositionHistoryController.updateCaseDisposition';
import CASE_AGE_DISPOSITION_FIELD from "@salesforce/schema/Case.CC_Case_Age_Disposition__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
//STRY0553354 - End
export default class CC_CaseAgedDispositionHistory extends LightningElement {

    @api recordId;
    caseagedisposition = CASE_AGE_DISPOSITION_FIELD; //STRY0553354 

    @track columns = [
        {
            label: 'Date',
            fieldName: 'CreatedDate',
            type: 'date',
            typeAttributes:{
                month: "2-digit",
                day: "2-digit",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        {
            label: 'User',
            fieldName: 'UserLink',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'UserName' }, 
                target: '_self',
                tooltip: { fieldName: 'UserName' }
            }
        },
        {
            label: 'Original Value',
            fieldName: 'OldValue',
            type: 'text'
        },
        {
            label: 'New Value',
            fieldName: 'NewValue',
            type: 'text'
        }

    ];
    @track error;
    @track caseHistoryList ;
    @track noRecordsFlag = false;
    //STRY0553354 - Start
    @track isLoading = false; 
    wiredCaseHistoryResult;

    @wire(getCaseAgeDispositionHistory, { caseIdStr: '$recordId' })
    wiredCaseHistory(result) {
        this.wiredCaseHistoryResult = result;
        if (result.data) {
            this.processCaseHistoryData(result.data);
        } else if (result.error) {
            this.error = result.error;
            this.handleError(result.error);
        }
    }

    handleSuccess() {
        this.isLoading = false;
        this.showToast('Case Age Disposition updated successfully.', 'success');
        this.refreshCaseHistory();
    }

    handleError(error) {
        this.isLoading = false;
        let errorMessage = 'An unknown error occurred.';
        if (error && error.body && error.body.message) {
            errorMessage = this.extractRelevantMessage(error.body.message);
        } else if (error && error.message) {
            errorMessage = this.extractRelevantMessage(error.message);
        }
        this.showToast(errorMessage, 'error');
       
    }

    handleSubmit(event) {
        this.isLoading = true;
        event.preventDefault();
        const fields = event.detail.fields;
        updateCaseDisposition({ caseId: this.recordId, disposition: fields.CC_Case_Age_Disposition__c })
            .then(() => {
                this.handleSuccess();
            })
            .catch(error => {
                this.handleError(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(message, variant) {
        const event = new ShowToastEvent({
            title: variant === 'error' ? 'Error' : 'Success',
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
    /*extractRelevantMessage(fullMessage) {
        const relevantMessage = fullMessage.split(':').slice(1).join(':').trim();
        return relevantMessage || fullMessage;
    }*/
        extractRelevantMessage(fullMessage) {
            // Split the message by colon
            const parts = fullMessage.split(':');
            if (parts.length > 1) {
                // Return the part between the first colon and the last period or colon
                return parts.slice(1, parts.length - 1).join(':').trim();
            }
            return fullMessage;
        }
    


    refreshCaseHistory() {
        refreshApex(this.wiredCaseHistoryResult);
    }
    //STRY0553354 - End

    processCaseHistoryData(data) {
            let tempRecs = [];
            data.forEach( ( record ) => {
                let tempRec = Object.assign( {}, record );  
                tempRec.UserLink = window.location.origin + '/' + tempRec.CreatedById;

                let tempUserObj = Object.assign( {}, record.CreatedBy );  
                tempRec.UserName = tempUserObj.Name;

                tempRecs.push( tempRec );
            });
            if(tempRecs == null || tempRecs == undefined || tempRecs.length == 0){
                this.caseHistoryList = null;
                this.noRecordsFlag = true;
        } else {
            this.caseHistoryList = tempRecs;
            this.noRecordsFlag = false;
        }
        this.error = undefined;
    }
    }
        