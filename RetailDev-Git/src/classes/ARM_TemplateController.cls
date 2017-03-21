/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_TemplateController
 * Description: Controller class of lighting component ARM_Template
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
public with sharing class ARM_TemplateController {
    private static final string DESIGNATED_CONTACT = 'Designated Contact';
    @AuraEnabled
    public static User getCurrentUser() {
        User u = [SELECT id, FirstName, LastName, Name, FullPhotoUrl  
                  FROM User 
                  WHERE id = :UserInfo.getUserId() 
                  LIMIT 1];
        return u;
    }
   
    @AuraEnabled 
   public static List<ARM_Navigation_Item__c> getNavigationList() {
        String officeLocation = getOfficeLocation();
        
        // Make sure we can access the database before even trying
        if (!Schema.sObjectType.ARM_Navigation_Item__c.isAccessible()) {
            return new List<ARM_Navigation_Item__c>();
        }
        
        
        return [SELECT Id, Display_Name__c, 
                  Page_URL__c, Order__c, 
                (SELECT Id 
                 FROM Attachments order by CreatedDate desc LIMIT 1)
                  FROM ARM_Navigation_Item__c 
                  WHERE Retail_Function__r.Name = :officeLocation
                  AND Is_Active__c = true
                  ORDER BY ORDER__c ASC];
        
   }
    
   @AuraEnabled 
   public static List<ARM_Sub_Navigation_Item__c> getSubNavigationList(String navigationId) {
    //   System.debug('navigationId::::' + navigationId);
      if(String.isBlank(navigationId)){
       	return new List<ARM_Sub_Navigation_Item__c>();  
      }
   	  // Make sure we can access the field database before even trying
      if (!Schema.sObjectType.ARM_Sub_Navigation_Item__c.isAccessible() 
      	|| !Schema.sObjectType.ARM_Sub_Navigation_Item__c.fields.Display_Name__c.isAccessible()) {
            return new List<ARM_Sub_Navigation_Item__c>();
      }
      List<ARM_Sub_Navigation_Item__c> subNavigation = [SELECT Id, Display_Name__c, 
											              Page_URL__c, Order__c, 
											               (SELECT Id 
											             FROM Attachments order by CreatedDate desc LIMIT 1) 
											              FROM ARM_Sub_Navigation_Item__c 
											              WHERE Navigation_Item__c = :navigationId
											              AND Is_Active__c = true
											              ORDER BY ORDER__c ASC];
      return subNavigation;
   }  
   
   @AuraEnabled 
   public static List<ARM_Navigation_Item__c> getCurrentNavigationItemId(String pageURL) {
       
       String officeLocation = getOfficeLocation();
       
      // Make sure we can access the database before even trying
      if (!Schema.sObjectType.ARM_Navigation_Item__c.isAccessible()) {
         return new List<ARM_Navigation_Item__c>();
      }
       
       
       List<ARM_Navigation_Item__c> lst = [SELECT Id, Display_Name__c  
                  FROM ARM_Navigation_Item__c 
                  WHERE Page_URL__c = :pageURL
                  AND Retail_Function__r.Name = : officeLocation];
       
        
       return lst;
   }
    
    @AuraEnabled
    public static Integer getNumberRestaurants() {
    	// Make sure we can access the database before even trying
	      if (!Schema.sObjectType.User.isAccessible()) {
	         return 0;
	      }
	      
        /*  Retrieve the number of Accounts where current user is a Designated Contact contact role */
        User u = [SELECT ContactId 
                  FROM User 
                  WHERE id = :UserInfo.getUserId() 
                  LIMIT 1];
        
        // Make sure we can access the database before even trying
	      if (!Schema.sObjectType.AccountContactRole.isAccessible()) {
	         return 0;
	      }
        
        List<AccountContactRole> AccountContactRoles = [ 
            SELECT AccountId 
            FROM AccountContactRole
            WHERE ContactId = :u.ContactId
            AND Role = :DESIGNATED_CONTACT
        ];
        return AccountContactRoles.size();
    }
    
    @AuraEnabled
    public static String getOfficeLocation() {
    	
    	// Make sure we can access the database before even trying
	      if (!Schema.sObjectType.User.isAccessible()) {
	         return '';
	      }
    	
        /*  Retrieve the Account where current user is a Designated Contact contact role */
        User u = [ SELECT ARM_physicalDeliveryOfficeName__c 
                  FROM User 
                  WHERE id = :UserInfo.getUserId() 
                  LIMIT 1];
        return u.ARM_physicalDeliveryOfficeName__c ;
    }
    
    @AuraEnabled
    public static ARM_Retail_Function__c getBrandAttributes() {
        String officeLocation = getOfficeLocation();
        
        ARM_Retail_Function__c retailFunction = new ARM_Retail_Function__c( SubNavigationBackgroundColor__c = '',
                                                 NavigationBackgroundColor__c = '',
                                                 LogoBackgroundColor__c = '',
                                                 SelectedNavBackgroundColor__c = '',
                                                 SelectedNavFontColor__c = '',
                                                 NavLinkFontSize__c = '',
                                                 NavLinkColor__c = '',
                                                 SubNavFontSize__c = '',
                                                 SubNavFontColor__c = '', 
                                                 WelcomeTextColor__c = '');
        if(!String.isBlank(officeLocation)){
            
            // Make sure we can access the database before even trying
	      if (!Schema.sObjectType.ARM_Retail_Function__c.isAccessible()) {
	         return retailFunction;
	      }
            
            List<ARM_Retail_Function__c> lst = [SELECT id , 
                  SubNavigationBackgroundColor__c, 
                  NavigationBackgroundColor__c,
                  LogoBackgroundColor__c,
                  SelectedNavBackgroundColor__c,
                  SelectedNavFontColor__c, 
                  NavLinkFontSize__c,
                  NavLinkColor__c,
                  SubNavFontSize__c,
                  SubNavFontColor__c,
                  WelcomeTextColor__c
                  FROM ARM_Retail_Function__c 
                  WHERE Name = : officeLocation];
            if(!lst.isEmpty()){
               retailFunction = lst[0];
            }
            
        }
            
        return retailFunction;
    }
    
    @AuraEnabled
    public static String getBrandImageURL() {
        
        
        String officeLocation = getOfficeLocation();
        
        String imageUrl = '/s.gif';
        if(officeLocation != NULL){
            
          // Make sure we can access the database before even trying
	      if (!Schema.sObjectType.ARM_Brand_Image__c.isAccessible()) {
	         return imageUrl;
	      }
            
            List<ARM_Brand_Image__c> lst = [SELECT id , (Select id from attachments)
                  FROM ARM_Brand_Image__c 
                  WHERE Is_Active__c = true
                  AND Image_Type__c = 'Logo'
                  AND Retail_Function__r.Name = : officeLocation];
            
            if(!lst.isEmpty() && !lst[0].attachments.isEmpty()){
               imageUrl = '/servlet/servlet.FileDownload?file=' + lst[0].attachments[0].id;
            }
            
        }
            
        return imageUrl;
        
    }
    
    @AuraEnabled
    public static String getBrandMobileImageURL() {
        
        
        String officeLocation = getOfficeLocation();
        
        String imageUrl = '/s.gif';
        if(officeLocation != NULL){
            
            
            // Make sure we can access the database before even trying
	      if (!Schema.sObjectType.ARM_Brand_Image__c.isAccessible()) {
	         return imageUrl;
	      }
            
            List<ARM_Brand_Image__c> lst = [SELECT id , (Select id from attachments)
                  FROM ARM_Brand_Image__c 
                  WHERE Is_Active__c = true
                  AND Image_Type__c = 'Mobile Logo'
                  AND Retail_Function__r.Name = : officeLocation];
            if(!lst.isEmpty() && !lst[0].attachments.isEmpty()){
               imageUrl = '/servlet/servlet.FileDownload?file=' + lst[0].attachments[0].id;
            }
            
        }
            
        return imageUrl;
        
    }
    
    
    @AuraEnabled
    public static String getBannerImageURL() {
        String officeLocation = getOfficeLocation();
        
        String imageUrl = '/s.gif';
        if(officeLocation != NULL){
            
            // Make sure we can access the database before even trying
	      if (!Schema.sObjectType.ARM_Brand_Image__c.isAccessible()) {
	         return imageUrl;
	      }
            
            List<ARM_Brand_Image__c> lst = [SELECT id , (Select id from attachments)
                  FROM ARM_Brand_Image__c 
                  WHERE Is_Active__c = true
                  AND Image_Type__c = 'Banner'
                  AND Retail_Function__r.Name = : officeLocation];
                  
            if(!lst.isEmpty() && !lst[0].attachments.isEmpty()){
               imageUrl = '/servlet/servlet.FileDownload?file=' + lst[0].attachments[0].id;
               
            }
            
        }
            
        return imageUrl;
    }
    
    @AuraEnabled
    public static String getBannerMobileLogoURL() {
        String officeLocation = getOfficeLocation();
        
        String imageUrl = '/s.gif';
        if(officeLocation != NULL){
            
            // Make sure we can access the database before even trying
	      if (!Schema.sObjectType.ARM_Brand_Image__c.isAccessible()) {
	         return imageUrl;
	      }
            
            List<ARM_Brand_Image__c> lst = [SELECT id , (Select id from attachments)
                  FROM ARM_Brand_Image__c 
                  WHERE Is_Active__c = true
                  AND Image_Type__c = 'Mobile Banner Logo'
                  AND Retail_Function__r.Name = : officeLocation];
            if(!lst.isEmpty() && !lst[0].attachments.isEmpty()){
               imageUrl = '/servlet/servlet.FileDownload?file=' + lst[0].attachments[0].id;
               
            }
            
        }
            
        return imageUrl;
    }
}