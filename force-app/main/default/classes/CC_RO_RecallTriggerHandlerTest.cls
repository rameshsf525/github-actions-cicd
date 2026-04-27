/**********************************************************************
Name:  CC_RO_RecallTriggerHandlerTest
Developed by: TCS

=======================================================================
Purpose:   
Test class for CC_RO_RecallTriggerHandler, CC_RO_RecallTriggerHelper, CC_RO_RecallTrigger
=======================================================================
History                                                            
-------                                                            
VERSION         AUTHOR            DATE              DETAIL
1.0 -       Pratyush Varma     02/21/2018       Initial Development
***********************************************************************/
@isTest 
public class CC_RO_RecallTriggerHandlerTest {
    /**********************************************************************************
	* Function    : testCC_RO_RecallTriggerHandler
	* Parameters  : None
	* Purpose     : Tests the trigger CC_RO_RecallTrigger
	* Returns     : None
	**********************************************************************************/
    public testmethod static void testCC_RO_RecallTriggerHandler(){
        
        //Create required custom settings.
        CC_RO_Test_Utility.createRequiredCustomSetting();
        
        Test.startTest();
        
        //Create a object of Recall and insert it.
        List<CC_Recall__c> listOfRecalls = new List<CC_Recall__c>();
        
        CC_Recall__c objRecall1= new CC_Recall__c();
        objRecall1.CC_SourceRecallNumber__c='12345';
        objRecall1.Name='Testing Recall 1';
        
        listOfRecalls.add(objRecall1);
        insert listOfRecalls;
        
        //Update the object's Source recall number.
        listOfRecalls[0].CC_SourceRecallNumber__c='1234';
		update listOfRecalls; 
        
        //Create another object of Recall with same Source Recall Number and try to insert it.
        CC_Recall__c objRecall2= new CC_Recall__c();
        objRecall2.CC_SourceRecallNumber__c='1234';
        objRecall2.Name='Testing Recall 2';
        
        listOfRecalls.add(objRecall2);
        try{
            insert listOfRecalls[1];
        }
        catch(Exception e)
        {
            system.debug('Error 1: '+e.getMessage());
        }
        
        //Remove the object from the list and add one with different Source Recall Number. Then try to insert it.
        listOfRecalls.remove(1);
        
        objRecall2.CC_SourceRecallNumber__c='12345';
        
        listOfRecalls.add(objRecall2);
        
        try{
            insert listOfRecalls[1];
        }
        catch(Exception e)
        {
            system.debug('Error 2: '+e.getMessage());
        }
        
        //Update the above object with Source Recall number as an existing Source Recall Number.
        
        listOfRecalls[1].CC_SourceRecallNumber__c='1234';
        
        try{
            update listOfRecalls[1];
        }
        catch(Exception e)
        {
            system.debug('Error 3: '+e.getMessage());
        }
        
        system.assertNotEquals(listOfRecalls[0],listOfRecalls[1]);
        
        //Call the remaining functions of the trigger to test them.
        CC_RO_RecallTriggerHandler objRecallTriggerHandler = new CC_RO_RecallTriggerHandler();
        objRecallTriggerHandler.afterInsert(null);
        objRecallTriggerHandler.afterDelete(null);
        objRecallTriggerHandler.afterUpdate(null, null);
        objRecallTriggerHandler.afterUndelete(null);
        objRecallTriggerHandler.beforeDelete(null);
        
        Test.stopTest();
    }	
}