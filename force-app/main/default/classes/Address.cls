/**********************************************************************
Name: Address
Developed by: TCS
======================================================
Req: 
US000001 - Vehicle and Customer Search
======================================================
Purpose:                                                            
Standard Class for Address attributes.
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 -    Amit Kumar        10/12/2017      Initial Development
***********************************************************************/
public class Address {
	@AuraEnabled public String addressLine1;
	@AuraEnabled public String addressLine2;
	@AuraEnabled public String city;
	@AuraEnabled public String state;
	@AuraEnabled public String zipCode;
}