/**************************************************************************************
Name:         cc_WarrantyClaims
Description:  Component to display CIN Response Data on Asset Record Page
Developed by: TCS
=========================================================================================
History
=========================================================================================
VERSION   AUTHOR                        DATE(MM/DD/YYYY)    Description
1.0 -     Shivani R                     09/25/2023         MCS-98: Initial Development
****************************************************************************************/
import { LightningElement,api,track } from 'lwc';
export default class Cc_CIN_RecallDataModal extends LightningElement {
    @api recordid;
    @api expiresdate;
    @api source;
    @api labourops;
    @api pointrattrape;
    @api recallcampaigndata;
    @track selectedSource;
    @track selectedExpiresDate;
    @track selectedLabourOps;
    @track selectedfieldDesc;
    @track selectedAgency;
    @track selectedPointRattrape;
    @track selectedSafetyDesc;
    @track selectedGroup;
    @track selectedSubGroup;
    @track selectedRepairDesc;
    @track selectedOptionCode;
    @track selectedNotes;

    connectedCallback() {
        this.viewRecallRecord();
    }
    closeHandler(){
       this.dispatchEvent(new CustomEvent('close'))
    }
    viewRecallRecord() {
        this.selectedRecord=this.recallcampaigndata.find(record=>record.id===this.recordid);
        this.selectedSource = this.selectedRecord ? this.selectedRecord.source:'';
        this.selectedExpiresDate=this.selectedRecord ? this.selectedRecord.expiresDate:'';
        this.selectedLabourOps=this.selectedRecord ? this.selectedRecord.labourOps:'';
        this.selectedPointRattrape=this.selectedRecord ? this.selectedRecord.pointRattrape:'';
        this.selectedAgency=this.selectedRecord ? this.selectedRecord.governmentAgency:'';
        this.selectedfieldDesc=this.selectedRecord ? this.selectedRecord.fieldActionDescription:'';
        this.selectedSafetyDesc=this.selectedRecord ? this.selectedRecord.safetyRiskDescription:'';
        this.selectedGroup=this.selectedRecord ? this.selectedRecord.recallGroup:'';
        this.selectedSubGroup=this.selectedRecord ? this.selectedRecord.subGroup:'';
        this.selectedRepairDesc=this.selectedRecord ? this.selectedRecord.repairDescription:'';
        this.selectedOptionCode=this.selectedRecord ? this.selectedRecord.optionCode:'';
        this.selectedNotes=this.selectedRecord ? this.selectedRecord.notes:'';
    }

}