/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_IdentityController
 * Description: Controller class of lighting component ARM_Survey_List
 *              Controller class method returns Survey list based on 
 *              accountId
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
public without sharing class ARM_Survey_List_Controller {
	private static final string SURVEY_TYPE_NON_SCAN = 'Non Scan';
    @auraEnabled
    public static List<Account> getAccounts(){
    	// RS : Make sure we can access the database before even trying
        if (!Schema.sObjectType.Account.isAccessible()) {
            return new List<Account>();
        }
        List<Account> accountList = [SELECT Id, Name 
                                     FROM Account 
                                     LIMIT 999];
        return accountList;
    }
    
	@auraEnabled
    public static List<ARM_Survey__c> getSurveys(String accId){
    	// RS : Make sure we can access the database before even trying
        if (!Schema.sObjectType.ARM_Survey__c.isAccessible() || 
        	!Schema.sObjectType.ARM_Survey__c.fields.Name.isAccessible()) {
            return new List<ARM_Survey__c>();
        }
        List<ARM_Survey__c> armSurvey = [SELECT Id, Name 
						                FROM ARM_Survey__c 
						                WHERE Active__c = true 
						                AND Start_Date__c <=: System.today() 
						                AND End_Date__c >=: System.today() 
						                AND Survey_Type_Editable__c = :SURVEY_TYPE_NON_SCAN 
						                AND TDLinx_Acct_Level_E__c =: accId];
        return armSurvey;
    } 
    
    
}