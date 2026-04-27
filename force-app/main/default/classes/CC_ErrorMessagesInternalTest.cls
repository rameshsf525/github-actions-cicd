/**********************************************************************
Name:  CC_ErrorMessagesInternalTest
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
1.0 - 	 Hari		     13/062018		  Initial Development

***********************************************************************/
@isTest
public class CC_ErrorMessagesInternalTest 
{
    @isTest
    public static void CC_ErrorMessagesInternalTestMethod()
    {
        Test.startTest();	
        String Tester = CC_ErrorMessagesInternal.RCL_GD_NULL_ERROR;
        System.assertEquals('Error occurred while dynamically getting Fields from Recall Contact List Object. Please ensure sourceObject name is correct.', Tester);
        Test.stopTest();
    }
}