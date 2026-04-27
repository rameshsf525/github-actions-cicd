/**********************************************************************
Name:  CC_RecallTriggerHandler
Developed by: TCS
=======================================================================
Req: 
US000001 - Use Trigger Framework
=======================================================================
Purpose:                                                            
This is a single handler class for all Recall Trigger.
All the business logic is written in helper class.
=======================================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 -    Vaishali Mankar    2/15/2018        Initial Development
              
***********************************************************************/ 
public class CC_RO_RecallTriggerHandler implements CC_ITriggerHandler{
    
    /*******************************************************************

Purpose:  Checks to see if the trigger has been disabled in Custom Setting

Parameters: List<SObject>

Returns: void

Throws : None

********************************************************************/
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean isTriggerDisabled = true;    
    // Checks to see if the trigger has been disabled in Custom Setting
    public Boolean isDisabled(){
        CC_Global_OnOff_Switch__c triggerGlobalSwitchObj = CC_Global_OnOff_Switch__c.getInstance();
        if((null!=triggerGlobalSwitchObj)&&(triggerGlobalSwitchObj.Is_Trigger_Active__c==true)&&CC_TriggerController.isRORecallTriggerActive){
            isTriggerDisabled=false;
        }
        return isTriggerDisabled;
    }
    public void beforeInsert(List<sObject> listOfNewRecalls){
        CC_RO_RecallTriggerHelper.checkForUniqueRecallCode(listOfNewRecalls);
    }
    public void beforeUpdate(Map<Id, sObject> mapOfIdSObjectNew, Map<Id, sObject> mapOfIdSObjectOld) {
      Map<Id, CC_Recall__c> MapofOldRecalls =  (Map<Id, CC_Recall__c>)mapOfIdSObjectOld;  
        CC_RO_RecallTriggerHelper.checkForUniqueRecallCode(mapOfIdSObjectNew.values(), MapofOldRecalls); 
    }
    public void beforeDelete(Map<Id, SObject> mapOfIdSObjectOld) {
        // write business logic to be implemented in before delete operation
    }
    public void afterInsert(Map<Id, SObject> mapOfIdSObjectNew) {
       
    }
    public void afterUpdate(Map<Id, SObject> mapOfIdSObjectNew, Map<Id, SObject> mapOfIdSObjectOld) {
       
    }
    public void afterDelete(Map<Id, SObject> mapOfIdSObjectOld) {
        // write business logic to be implemented in after delete operation
    }
    public void afterUndelete(Map<Id, SObject> mapOfIdSObjectOld) {
        // write business logic to be implemented in after undelete operation
    }
}