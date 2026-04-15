/**********************************************************************
Purpose:                                                            
Wrapper class for NAFTA_NotificationRecallPartsAvailable Class.
=======================================================================
History                                                            
-------                                                            
VERSION       AUTHOR                 DATE              DETAIL
1.0        Naresh Mandla           02-12-2024	         STRY0573646 - Wrapper class
***********************************************************************/
public class CC_FamilyCodeOption {
    @AuraEnabled public String label { get; set; }
    @AuraEnabled public String value { get; set; }

    public CC_FamilyCodeOption(String label, String value) {
        this.label = label;
        this.value = value;
    }
}