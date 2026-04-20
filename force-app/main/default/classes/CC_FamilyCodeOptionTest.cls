/**********************************************************************
Purpose:                                                            
Test class for CC_FamilyCodeOption Class.
=======================================================================
History                                                            
-------                                                            
VERSION       AUTHOR                 DATE              DETAIL
1.0        Naresh Mandla           02-12-2024	         STRY0573646 - Test class for Wrapper class
***********************************************************************/
@isTest
private class CC_FamilyCodeOptionTest {
    
    @isTest
    static void testFamilyCodeOption() {
        // Arrange: Create sample data
        String testLabel = 'Test Label';
        String testValue = 'Test Value';
        
        // Act: Create an instance of FamilyCodeOption
        CC_FamilyCodeOption familyCodeOption = new CC_FamilyCodeOption(testLabel, testValue);
        
        // Assert: Verify that the properties are correctly set
        System.assertEquals(testLabel, familyCodeOption.label, 'Label should be set correctly');
        System.assertEquals(testValue, familyCodeOption.value, 'Value should be set correctly');
    }
}