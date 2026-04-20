/**********************************************************************
Name:  CC_ErrorMessagesInternal
Developed by: TCS
=======================================================================
Req: 
Keep all the Error Messages in this class which is used for logging.
These error messages will be for Dev and Support Team consumption and will 
not be displayed to end users. 
(If the error messages will be displayed to end users. Use Custom Labels 
instead of using the class.)
=======================================================================
Purpose:   
This is a constant class to keep all Error messages values. This messages
will not be shown to end users. This will help in Code Maintenance.
=======================================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 - 	 Amit Kumar		 22/01/2018		  Initial Development

***********************************************************************/

global class CC_ErrorMessagesInternal {
    
    //START: Amit - Error messages related to RO
    //GD stands for Global Describe
  	public static Final String RCL_GD_NULL_ERROR = 'Error occurred while dynamically getting Fields from Recall Contact List Object. Please ensure sourceObject name is correct.';
    public static Final String RCL_CUSTOMER_RECORDTYPE_NOT_FOUND_FOR_ACCOUNT_ERROR = 'Error occurred while getting the Account:Customer record type Id. May be the Account:Customer record type is not added.';
	public static Final String GO_PREDICTIVE_PROACTIVE_RECORDTYPE_NOT_FOUND_FOR_CM_ERROR = 'Error occurred while getting the Campaign Member:RO Genesys Predictive And RO Genesys Proactive record type Id.';
	public static Final String GO_POSTAL_RECORDTYPE_NOT_FOUND_FOR_CM_ERROR = 'Error occurred while getting the Campaign Member:RO Postal record type Id.';
    public static Final String RCL_FAILED_SETTING_ACCOUNTID_IN_CONTACT_ERROR = 'Error occurred while setting Account ID in Contact.';
    public static Final String RCL_FAILED_SETTING_ACCOUNTID_CONTACTID_IN_VEHICLE_ERROR = 'Error occurred while setting AccountID and contactID in Asset.';
    public static Final String STATUS_INPROGRESS_UPDATE_ERROR = 'Error occurred while updating control file status to In Progress.';
    public static Final String FETCH_ACCOUNTCONTACTRELATION_ERROR = 'Error occurred while fetching accountContactRelation List from Salesforce.';
    public static Final String FETCH_VEHICLE_CONTACTS_ERROR = 'Error occurred while fetching Vehicle Contact List from Salesforce.';
    public static Final String FETCH_VEHICLE_RECALL_ERROR = 'Error occurred while fetching Vehicle Recall List from Salesforce.';
    public static Final String FETCH_CONTROL_RECORD_ERROR = 'Error occurred while fetching Recall Control List from Salesforce.';
    public static Final String RCL_SETTING_ACC_CNTCT_VEH_ID_ERROR = 'Error occurred while setting AccountID, contactID and AssetID in Recall Contact List records.';
    public static Final String SENDING_IT_EMAIL_ERROR = 'Error occurred while sending Batch Summary Email to IT support team.';
    public static Final String SENDING_BUSINESS_EMAIL_ERROR = 'Error occurred while sending Batch Summary Email to Business stakeholders.';
    public static Final String RECALL_CONTACT_LIST_PROCESSING_ERROR = 'Error occurred while processing recall contact records. The batch processing is abnormally terminated.';
    
    public static Final String RCL_VIN_SUPPRESSION_GD_NULL_ERROR = 'Error occurred while dynamically getting Fields from VIN Suppression List Object. Please ensure sourceObject name is correct.';
    public static Final String RCL_VIN_SUPPRESSION_CAMPAIGN_MEMBER_STATUS_UPDATE_ERROR = 'Error occurred while updating status of Campaign members.';
    public static Final String RCL_VIN_SUPPRESSION_RECALL_CONTACT_STATUS_UPDATE_ERROR = 'Error occurred while updating status of Recall Contact Records.';
    public static Final String RCL_VIN_SUPPRESSION_RECORD_STATUS_UPDATE_ERROR = 'Error occurred while upserting list of VIN Suppression Records.';
    //END: Amit - Error messages related to RO
}