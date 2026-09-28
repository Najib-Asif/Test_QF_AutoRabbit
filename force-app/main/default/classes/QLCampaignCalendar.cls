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

public with sharing class QLCampaignCalendar {
    
    @AuraEnabled public static Date startDate                                     {get; set;}
    @AuraEnabled public static String dateText                                    {get; set;}
    @AuraEnabled public static List<Date> fullDates                               {get; set;} 
    @AuraEnabled public static List<SplitDates> splitDates                        {get; set;}
    @AuraEnabled public static List<DateCampaigns> dateCamp                       {get; set;}
    @AuraEnabled public static RecordTypeOptionsUserIds RTypeOptionsUserIds       {get; set;}     
    
    // Inner class for binding date with Campaigns in this Date.
    public class DateCampaigns {
        
        @AuraEnabled public Date sDate                       {get; set;}
        @AuraEnabled public Boolean isInCurrentMonth         {get; set;}
        
    }
    
    public class RecordTypeOptionsUserIds {
        
        @AuraEnabled public List<Recordtypeoptions> recordTypes    {get; set;}
        @AuraEnabled public List<User> subordinateUsers         {get; set;}
        
        public RecordTypeOptionsUserIds(List<Recordtypeoptions> recordTypes, List<User> subordinateUsers)
        {
            this.recordTypes = recordTypes;
            this.subordinateUsers = subordinateUsers;
        }
        
    }
    
    public class SplitDates {
        @AuraEnabled public List<DateCampaigns> dateCams       {get; set;}
        @AuraEnabled public List<Campaign> campaignsToShow      {get; set;}
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        
        public SplitDates(List<DateCampaigns> dateCams, List<Campaign> campaignsToShow, Integer pageSize, Integer page, Integer total)
        {
            this.dateCams = dateCams;
            this.campaignsToShow = campaignsToShow;
            this.pageSize = pageSize;
            this.page = page;
            this.total = total;
        }
    }
    
    @AuraEnabled
    public static List<SplitDates> populateDateAndCampaigns(Date paramDate, String view, Date startDate, Date endDate, String recordtypeName, Integer recordToDisply, Integer pageNumber, String recordView, Id ownerId, List<Id> userIds, String[] typeofcampaigns, String[] region) {
        if(recordView==null || recordView=='null'){
            recordView='all';
        }
        system.debug('recordtodisplay'+recordToDisply+' '+paramDate+' '+view+' '+startDate+' '+endDate+' '+recordToDisply+' '+pageNumber
                     +' '+recordtypeName); 
        system.debug('paramDate------'+paramDate);
        system.debug('view------'+view);
        system.debug('startDate------'+startDate);
        system.debug('endDate------'+endDate);
        system.debug('recordtypeName------'+recordtypeName);
        system.debug('recordToDisply------'+recordToDisply);
        system.debug('pageNumber------'+pageNumber);
        system.debug('recordView------'+recordView);
        system.debug('Region------'+region);  
        system.debug('typeofcampaigns------'+typeofcampaigns); 
        Integer pageSize = recordToDisply;
        Integer offset = (pageNumber - 1) * pageSize;
        Integer total;
        
        Id CampaignrecordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId(); 
        
        String qryStr = '';
        if(recordView == 'all'|| recordView==null){
            if(typeofcampaigns.size() > 0 && region.size() > 0){
                qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                    ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                    ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                    '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND Type IN : typeofcampaigns '+
                    'AND Region__c IN: region ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
                
                total = [Select count() from Campaign 
                         where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                       OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                       OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate))
                         AND Type IN : typeofcampaigns AND Region__c IN: region];
                
            }
            else if(typeofcampaigns.size() > 0 && region.size() == 0){
                qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                    ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                    ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                    '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND Type IN : typeofcampaigns '+
                    'ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
                
                total = [Select count() from Campaign 
                         where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                       OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                       OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate))
                                                                       AND Type IN : typeofcampaigns];
            }
            else if(typeofcampaigns.size() == 0 && region.size() > 0){
                qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                    ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                    ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                    '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND Region__c IN : region '+
                    'ORDER BY Name LIMIT :recordToDisply OFFSET :offset';   
                
                total = [Select count() from Campaign 
                         where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                       OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                       OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate))
                                                                       AND Region__c IN: region];
            }
            else{
                qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                    ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                    ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                    '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) '+
                    'ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
                
                total = [Select count() from Campaign 
                         where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                       OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                       OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate))];
            }
            
            /*  qryStrt = 'Select count() from Campaign where RecordTypeId=:CampaignrecordtypeId'+
' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) '+
'OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate))';*/
            
        }
        else if(recordView == 'myactivecampaigns'){
            if(typeofcampaigns.size() > 0 && region.size() > 0){
                qryStr = 'Select Id, Name, StartDate, EndDate, Status, OwnerId, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                    ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                    ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                    '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId =:ownerId '+
                    'AND (Status = \'Planned\' OR Status = \'In Progress\' OR Status = \'Pending Reporting\' OR Status = \'Active\')'+
                    'AND Type IN : typeofcampaigns AND Region__c IN : region ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
                
                total = [Select count() from Campaign 
                         where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                       OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                       OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId =:ownerId
                         AND Type IN : typeofcampaigns AND Region__c IN : region];
            }
            else if(typeofcampaigns.size() > 0 && region.size() == 0){
                qryStr = 'Select Id, Name, StartDate, EndDate, Status, OwnerId, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                    ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                    ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                    '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId =:ownerId '+
                    'AND (Status = \'Planned\' OR Status = \'In Progress\' OR Status = \'Pending Reporting\' OR Status = \'Active\')'+
                    'AND Type IN : typeofcampaigns ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
                
                total = [Select count() from Campaign 
                         where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                       OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                       OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId =:ownerId
                                                                       AND Type IN : typeofcampaigns];
            }
            else if(typeofcampaigns.size() == 0 && region.size() > 0){
                qryStr = 'Select Id, Name, StartDate, EndDate, Status, OwnerId, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                    ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                    ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                    '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId =:ownerId '+
                    'AND (Status = \'Planned\' OR Status = \'In Progress\' OR Status = \'Pending Reporting\' OR Status = \'Active\')'+
                    'AND Region__c IN : region ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
                
                total = [Select count() from Campaign 
                         where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                       OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                       OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId =:ownerId
                                                                       AND Region__c IN : region];
            }
            else{
                qryStr = 'Select Id, Name, StartDate, EndDate, Status, OwnerId, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                    ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                    ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                    '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId =:ownerId '+
                    'AND (Status = \'Planned\' OR Status = \'In Progress\' OR Status = \'Pending Reporting\' OR Status = \'Active\')'+
                    'ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
                
                total = [Select count() from Campaign 
                         where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                       OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                       OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId =:ownerId];
            }
        }
        else if(recordView == 'myteamscampaigns'){
            if(typeofcampaigns.size() > 0 && region.size() > 0){
            qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds '+
                'AND Type IN : typeofcampaigns AND Region__c IN : region ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
            
            total = [Select count() from Campaign 
                     where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                   OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                   OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds
                                                                   AND Type IN : typeofcampaigns AND Region__c IN : region];
            }
            else if(typeofcampaigns.size() > 0 && region.size() == 0){
            qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds '+
                'AND Type IN : typeofcampaigns ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
            
            total = [Select count() from Campaign 
                     where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                   OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                   OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds
                                                                   AND Type IN : typeofcampaigns];
             system.debug('Query to fetch campaign comes from here');
             system.debug('Query 1-----------'+Database.query('select id, name, Type from Campaign where Type IN : typeofcampaigns'));
            }
            else if(typeofcampaigns.size() == 0 && region.size() > 0){
            qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds '+
                'AND Region__c IN : region ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
            
            total = [Select count() from Campaign 
                     where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                   OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                   OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds
                                                                   AND Region__c IN : region];
            }
            else{
            qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds '+
                'ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
            
            total = [Select count() from Campaign 
                     where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                   OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                   OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds];
            }
        }
        else{
            System.debug('Before callout------');
            String listViewFilterCondition = getListviewFilters(recordView,'Campaign');
            if(typeofcampaigns.size() > 0 && region.size() > 0){
            qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate))  '+
                'AND ('+listViewFilterCondition+') '+
                'AND Type IN : typeofcampaigns AND Region__c IN : region ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
            
            total = [Select count() from Campaign 
                     where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                   OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                   OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds
                                                                   AND Type IN : typeofcampaigns AND Region__c IN : region];
            }
            else if(typeofcampaigns.size() > 0 && region.size() == 0){
            qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) '+
                'AND ('+listViewFilterCondition+') '+
                'AND Type IN : typeofcampaigns ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
            
            total = [Select count() from Campaign 
                     where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                   OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                   OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds
                                                                   AND Type IN : typeofcampaigns];
             system.debug('Query to fetch campaign comes from here');
             system.debug('Query 1-----------'+Database.query('select id, name, Type from Campaign where Type IN : typeofcampaigns'));
            }
            else if(typeofcampaigns.size() == 0 && region.size() > 0){
            qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) '+
                'AND ('+listViewFilterCondition+') '+
                'AND Region__c IN : region ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
            
            total = [Select count() from Campaign 
                     where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                   OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                   OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds
                                                                   AND Region__c IN : region];
            }
            else{
            qryStr = 'Select Id, Name, StartDate, EndDate, Status, Region__c, Type from Campaign where RecordTypeId=:CampaignrecordtypeId' +
                ' AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate)'+
                ' OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ' +
                '((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) '+
                'AND ('+listViewFilterCondition+') '+
                'ORDER BY Name LIMIT :recordToDisply OFFSET :offset';
            
            total = [Select count() from Campaign 
                     where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
                                                                   OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) 
                                                                   OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) AND OwnerId IN: userIds];
            }
        }
        
        system.debug('Query to fetch campaign-----'+qryStr);
        List<Campaign> camp = Database.query(qryStr);
        /* List<Campaign> camp = [Select Id, Name, StartDate, EndDate, Status from Campaign 
where RecordTypeId=:CampaignrecordtypeId AND ((StartDate <=:startDate AND EndDate >=:endDate) OR (StartDate >=:startDate AND EndDate <=:endDate) 
OR (StartDate <=:startDate AND (EndDate >=:startDate AND EndDate <=:endDate)) OR ((StartDate >=:startDate AND StartDate <=:endDate) AND EndDate >=:endDate)) 
ORDER BY Name LIMIT :recordToDisply OFFSET :offset];*/
        system.debug('campaigns12'+camp);
        splitDates = new List<SplitDates>();
        if(view =='monthlyview')
        {
            // Get the First Date of current Month
            startDate = Date.newInstance(paramDate.year(), paramDate.month(), 1);
            
            system.debug('start date'+startDate);
            // For example: March, 2012
            dateText = QL_CampaignCalendarHelper.getOutputDate(startDate);
            // Get the dates of current month
            fullDates = QL_CampaignCalendarHelper.getFullDatesOfCurrentMonth(startDate);
            system.debug('fullDates'+fullDates);
            Set<Date> datesInCurrentMonth = QL_CampaignCalendarHelper.getDatesOfCurrentMonth(startDate);
            system.debug('datesInCurrentMonth'+datesInCurrentMonth);
            
            dateCamp = new List<DateCampaigns>();
            
            for(Date dt :datesInCurrentMonth)
            {
                DateCampaigns dateCampt= new DateCampaigns();
                dateCampt.sDate = dt;
                dateCampt.isInCurrentMonth = true;
                dateCamp.add(dateCampt);
            }
            
            SplitDates splitDateMonth = new SplitDates(dateCamp, camp, pageSize, pageNumber, total);
            splitDates.add(splitDateMonth);
            system.debug('beforereturn'+splitDates);
            
        }else if(view ==  'yearlyview')
        {
            dateCamp = new List<DateCampaigns>();
            List<Campaign> campYear = new List<Campaign>(camp);
            SplitDates splitDateYear = new SplitDates(dateCamp, campYear, pageSize, pageNumber, total);
            splitDates.add(splitDateYear);
            system.debug('yearlyveiw'+splitDates);
        }
        return splitDates;
    }
    
    public class Recordtypeoptions {
        
        @AuraEnabled public String label                       {get; set;}
        @AuraEnabled public String value				       {get; set;}
        
        public Recordtypeoptions (String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled
    public static RecordTypeOptionsUserIds getRecordCampaignRecordtypes(Id loginUserId)
    {
        List<Recordtypeoptions> rtypeList = new List<Recordtypeoptions>();
        //RTypeOptionsUserIds = new RecordTypeOptionsUserIds();
        Schema.SObjectType objType = Campaign.SObjectType;
        List<Recordtypeoptions> RecordTypes = new List<Recordtypeoptions>();     
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        if (infos.size() > 1) {
            for (RecordTypeInfo info : infos) {
                system.debug('info '+info);
                if (info.isAvailable() && !info.isMaster())
                {
                    rtypeList.add(new Recordtypeoptions(info.getName(),info.getDeveloperName()));
                    //RTypeOptionsUserIds.recordTypes.add(new Recordtypeoptions(info.getName(),info.getDeveloperName()));
                    
                }
            }
        } 
        else {rtypeList.add(new Recordtypeoptions(infos[0].getName(),infos[0].getDeveloperName()));}
        system.debug('valuesrtype '+RTypeOptionsUserIds);
        RTypeOptionsUserIds = new RecordTypeOptionsUserIds(rtypeList, RoleUtils.getRoleSubordinates(loginUserId)); 
        return RTypeOptionsUserIds;
    }
    
    @AuraEnabled
    public static List<SplitDates> nextMonth(Date paramDate, String view, Date startDate, Date endDate, String recordtypeName, Integer recordToDisply, Integer pageNumber, String recordView, Id ownerId, List<Id> userIds, String[] typeofcampaigns, String[] region) {
        return populateDateAndCampaigns(paramDate.addMonths(1), view, startDate, endDate, recordtypeName, recordToDisply, pageNumber, recordView, ownerId, userIds, typeofcampaigns, region);
    }
    
    @AuraEnabled
    public static List<SplitDates> previousMonth(Date paramDate, String view, Date startDate, Date endDate, String recordtypeName, Integer recordToDisply, Integer pageNumber, String recordView, Id ownerId, List<Id> userIds, String[] typeofcampaigns, String[] region) {
        return populateDateAndCampaigns(paramDate.addMonths(-1), view, startDate, endDate, recordtypeName, recordToDisply, pageNumber, recordView, ownerId, userIds, typeofcampaigns, region);
    }
    
    // Fetch the list views available for the Campaign object
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCampaignListViews() {
        List<ListView> listViews = [SELECT Id, Name FROM ListView WHERE SObjectType = 'Campaign'];
        List<Map<String, String>> options = new List<Map<String, String>>();
        // Add custom options
        options.add(new Map<String, String>{'value' => 'all', 'label' => 'All'});
        options.add(new Map<String, String>{'value' => 'myactivecampaigns', 'label' => 'My Active Campaigns'});
        options.add(new Map<String, String>{'value' => 'myteamscampaigns', 'label' => 'My Team\'s Campaigns'});
        
        for (ListView lv : listViews) {
            if(lv.Name!='My Active Campaigns'){
                Map<String, String> option = new Map<String, String>();
                option.put('value', lv.Id);
                option.put('label', lv.Name);
                options.add(option);
            }

        }
        system.debug(options);
        return options;
    }
    
    public static String getListviewFilters(String filterId, String objectName) {
        
        //Getting sessionId
        String sessionId;
        if(Test.isRunningTest()) { 
        	sessionId = '00Dxxxxxxxxxxxx!AQMAQH...';
        } else {
            String content = Page.GetSessionId.getContent().toString();
            Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        	 sessionId = content.substring(s, e);
        }
        HttpRequest req = new HttpRequest();
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String endPointURL = baseUrl+'/services/data/v50.0/sobjects/'+ objectName +'/listviews/'+ filterId +'/describe';
        req.setEndpoint(endPointURL);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        Http http = new Http();
        HttpResponse response = http.send(req);
        system.debug('response---'+response);
        if( response.getStatusCode() == 200 ) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String query = ((String) tokenResponse.get('query')).replaceFirst('(?i)SELECT[\\s\\S]*?FROM','SELECT Id FROM');
            system.debug(query);
            String[] whereParts = query.split('(?i)WHERE');
            if (whereParts.size() > 1) {
            	String whereClause = whereParts[1].trim();
            	if (whereClause.toUpperCase().contains('ORDER BY')) {
                	whereClause = whereClause.split('(?i)ORDER BY')[0].trim(); // Keep only what's before 'ORDER BY'
            	}
            	system.debug('Generated CONDITION----'+whereClause);
            	return whereClause;  // Return the clean WHERE clause
        	}
            
        }return null;
 
	}
    
}