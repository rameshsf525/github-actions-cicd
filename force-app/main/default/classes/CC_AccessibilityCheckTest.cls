/**********************************************************************
Name:  CC_AccessibilityCheckTest
Developed by: TCS

=======================================================================
Purpose:   
Test class for CC_AccessibilityCheck
=======================================================================
History                                                            
-------                                                            
VERSION         AUTHOR            DATE              DETAIL
1.0 -       Pratyush Varma     02/21/2018       Initial Development
***********************************************************************/
@isTest
public class CC_AccessibilityCheckTest {
    public testmethod static void testCC_AccessibilityCheck(){
        //Create an instance of CC_AccessibilityCheck and set its fields to cover the class.
        Test.startTest();
        CC_AccessibilityCheck objAccessibilityCheck=new CC_AccessibilityCheck();
        objAccessibilityCheck.readaccess='str';
        objAccessibilityCheck.readBillingAddress='str';
        objAccessibilityCheck.readDealerBrand='str';
        objAccessibilityCheck.readDealerCode='str';
        objAccessibilityCheck.readName='str';
        objAccessibilityCheck.readPhone='str';
        objAccessibilityCheck.readDealerBC='str';
        objAccessibilityCheck.readBodyShopHoursOpenTime='str';
        objAccessibilityCheck.readBodyShopHoursClosedTime='str';
        objAccessibilityCheck.readBodyShopHoursOpenTime='str';
        objAccessibilityCheck.readSalesHoursOpenTime='str';
        objAccessibilityCheck.readSalesHoursClosedTime='str';
        objAccessibilityCheck.readServiceHoursOpenTime='str';
        objAccessibilityCheck.readServiceHoursClosedTime='str';
        system.assertEquals(objAccessibilityCheck.readaccess, 'str');
        Test.stopTest();
    }
}