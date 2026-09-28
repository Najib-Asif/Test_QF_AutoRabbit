/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath/Benazir Amir 
Company:       Capgemini
Description:   Wrapper Class Simulates  Account,QBR Product Request received from QCP
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
09-Nov-2017    Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
global class AccountQBRProductWrapper {
      public class Company {
                public String abn;
                public String name;
                public String industry;
                public String subIndustry;
                public String entityType;
                public String gstRegistered;
        }
     public Company company;
        public String membershipNumber;
        public String status;
        public Date membershipStartDate;
        public String airlineLevel;
        

        
       
}