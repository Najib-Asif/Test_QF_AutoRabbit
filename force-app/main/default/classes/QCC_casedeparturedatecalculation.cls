/***********************************************************************************************************************************

Description: Populating the Departure Date/Time field on Case to Updated Departure Date/Time for reporting. 

History:
======================================================================================================================
Name                               Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan      Departure Date/Time field                                          T01
                                    
Created Date    : 16/07/2018 (DD/MM/YYYY)

**********************************************************************************************************************************/
public class QCC_casedeparturedatecalculation {
    
    public static void datecalculation(List<Case> caseList )
    {
        if(caseList.size() >0 )
        {
            List<Case> caseList2  = new List<Case>();
            for(Case c: caseList)
            {
                if(c.Departure_Date_Time__c!=null){
                //Case ca = new Case();
                String firstDate = c.Departure_Date_Time__c;
                String month = firstDate.substring(3,5);
                String day = firstDate.substring(0,2);
                String year = firstDate.substring(6,10);          
                //string hour = firstDate.substring(11,13);
                string hour = firstDate.substring(10,13);               
                string minute = firstDate.substring(10,13);               
                //string second = firstDate.substring(17,19);
                string second = firstDate.substring(10,13);

                  
                string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' 
                    + minute +  ':' + second;
                System.debug('stringDate:'+stringDate);
                
                Date myDate = Date.valueOf(stringDate);
                c.Updated_Departure_Date_Time__c = myDate;
                }
            
            }
        }
        
    }
    
}