/**********************************************************************
Name:  CC_AccountContactCaseWrapper
Developed by: TCS
======================================================
Req: 
US- CC-91 - Develop Custom Search Functionality for
Account,Contact, Case, Vehicle Search
======================================================
Purpose:                                                            
Wrapper Class for Account Contact and Case list.
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 -    Amit Kumar        27/12/2017      Initial Development
***********************************************************************/

public class CC_AccountContactCaseWrapper {
    @AuraEnabled public Account[] listOfAccounts=null;
 	@AuraEnabled public Contact[] listOfContacts=null;
    @AuraEnabled public Case[] listOfCases=null;
}