/*----------------------------------------------------------------------------------------------------------------------
Author:        Gnanavelu
Description:   Apex Class for Campaign Calendar
Inputs:
Test Class:    
************************************************************************************************
History
************************************************************************************************
JIRA : CRM 3924                
-----------------------------------------------------------------------------------------------------------------------*/

public with sharing class QL_CampaignCalendarHelper {
    
    private final static Integer DAY_OF_SIX_WEEKS = 42;
    
    // Get the Month String of Date 
    public static String getOutputDate(Date sDate) {
        return Datetime.newInstance(sDate.year(), sDate.month(), 
            sDate.day()).format('MMMMM') + ', ' + sDate.year();
    }
    
    // Get the dates between some one month
    public static Set<Date> getDatesOfCurrentMonth(Date sDate) {
        Set<Date> dates = new Set<Date>();
        Date eDate = sDate.addMonths(1);
        Integer daysBetween = sDate.daysBetween(eDate);
        for (Integer i = 0; i < daysBetween; i++) {
            dates.add(sDate + i);
        }
        
        return dates;
    }
                                                                                 
    // Get fix weeks
    public static List<Date> getFullDatesOfCurrentMonth(Date sDate) {  
        
        // Get start date and end date  
        StartDateAndEndDate startDateAndEndDate = getStartDateAndEndDate(sDate);
        
        // Get the dates between Start Date and End Date
        List<Date> dates = new List<Date>();
        Date startDate = startDateAndEndDate.startDate;
        Date endDate = startDateAndEndDate.endDate;
        Integer daysBetween = startDate.daysBetween(endDate);
        for (Integer i = 0; i < daysBetween; i++) {
            dates.add(startDate + i);
        }
        
        return dates;
    }
    
    // Used In getDatesOfMonth(Date sDate) and getStartDateAndEndDate(Date sDate)
    public static final Map<String, Integer> weekUtilMap = new Map<String, Integer> { 'Mon' => 1,
                                                                                      'Tue' => 2,
                                                                                      'Wed' => 3,
                                                                                      'Thu' => 4,
                                                                                      'Fri' => 5,
                                                                                      'Sat' => 6,
                                                                                      'Sun' => 7 };
                                                                                      
    // Return the startDate and End Date according to one date
    public static StartDateAndEndDate getStartDateAndEndDate(Date sDate) {
        Date startDate = sDate.addDays(-weekUtilMap.get(Datetime.newInstance(
           sDate.year(), sDate.month(), 1, 0, 0, 0).format('EEE')));

        Date endDate = startDate.addDays(DAY_OF_SIX_WEEKS);
        
        StartDateAndEndDate startDateAndEndDate = new StartDateAndEndDate(startDate, endDate);
        
        return startDateAndEndDate;
    }
    
    public class StartDateAndEndDate {
        public Date startDate              {get; set;}
        public Date endDate                {get; set;}
        public StartDateAndEndDate(Date startDate, Date endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
    
    
    
    // Get the Date set between Start Date and End Date
    // Used In Campaign
    public static Set<Date> getDateSet(Date startDate, Date endDate) {
        Set<Date> dates = new Set<Date>();
        Integer daysBetween = startDate.daysBetween(endDate);
        for (Integer i = 0; i <= daysBetween; i++) {
            dates.add(startDate + i);
        }
        
        return dates;
    }
}