/**********************************************************************
Name:  CC_AccessibilityCheck
Developed by: TCS
=======================================================================
Req: 
  
=======================================================================
Purpose:                                                            
Wrapper Class for Field accessibility check    
=======================================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE              DETAIL
1.0 -    Darshana Amin        01/01/2018      Initial Development
***********************************************************************/
public with sharing class CC_AccessibilityCheck {
    /* Fields associated with Dealer Locator CC - 143 start */
	@AuraEnabled
    public String readaccess {get;set;}
    
    @AuraEnabled
    public String readDealerBC {get;set;}  
    
    @AuraEnabled
    public String readDealerBrand {get;set;}
    
    @AuraEnabled
    public String readDealerCode {get;set;}     
    
    @AuraEnabled
    public String readName {get;set;}
    
    @AuraEnabled
    public String readPhone {get;set;}
    
    @AuraEnabled
    public String readBillingAddress {get;set;}
    
    //changes by Gopesh Banker on 05/02/2018 for CC-569
    @AuraEnabled
    public String readBodyShopHoursOpenTime{get;set;}
    
    @AuraEnabled
    public String readBodyShopHoursClosedTime{get;set;}
    
    @AuraEnabled
    public String readSalesHoursOpenTime{get;set;}
    
    @AuraEnabled
    public String readSalesHoursClosedTime{get;set;}
    
    @AuraEnabled
    public String readServiceHoursOpenTime{get;set;}
    
    @AuraEnabled
    public String readServiceHoursClosedTime{get;set;}
    //changes by Gopesh Banker end here
    /* Fields associated with Dealer Locator CC - 143 end */
    
}