/**************************************************************************************
Name: CC_ArticleImageIllustration
Description: Component to display image when no relavent Articles found in sitewebform
Developed by: TCS
=========================================================================================
Req:
 - MCS-36
=========================================================================================
History
=========================================================================================
VERSION   AUTHOR                        DATE(MM/DD/YYYY)    
1.0 -    Shivani                          Jul- 2023        
****************************************************************************************/
import { LightningElement, api } from 'lwc';
export default class cc_ArticleImageIllustration extends LightningElement 
{
  @api message;
}