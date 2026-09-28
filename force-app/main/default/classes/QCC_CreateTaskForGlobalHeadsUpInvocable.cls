/*********************************************************************************
Name         : QCC_CreateTaskForGlobalHeadsUpInvocable
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 30 September 2019
Usages       : This class is used to create task record for every user that is part of QANTAS VIP Service Team public group.
*********************************************************************************/
public class QCC_CreateTaskForGlobalHeadsUpInvocable {
    //@Purpose: This method execute the whole logic to create task record.
    //@input parameters:
    //	1. flightEventRecords - The list of flight event records that will come from the process builder.
    //@return type: None
    @InvocableMethod
    public static void execute(List<Event__c> flightEventRecords) {
        try {
            List<Id> flightEventIds = new List<Id>();
            for(Event__c flightEventRecord : flightEventRecords) {
                flightEventIds.add(flightEventRecord.Id);
            }
            System.debug('flightEventIds: ' + flightEventIds);

            //Get all flight event record information necessary for create task notification.
            List<Event__c> newFlightEventRecords = [
                SELECT Id, Affected_Ports__c, Start_Date__c, End_Date__c, QCC_Local_Start_Time__c,
                QCC_Local_End_Time__c, Global_Event_Sub_Type__c, Comments__c, OwnerId
                FROM Event__c
                WHERE Id IN: flightEventIds
            ];
            System.debug('newFlightEventRecords: ' + newFlightEventRecords);

            List<Task> taskToBeCreatedList = new List<Task>();

            //Get all user id which is part of QANTAS VIP Service Team public group and QF-QDC-OM-VIP-TL role.
            List<Id> groupMemberIds = new List<Id>();
            groupMemberIds.addAll(QCC_UtilityHelper.getAllUserFromPublicGroup('QANTAS VIP Service Team'));

            System.debug('groupMemberIds: ' + groupMemberIds);

            List<Group> groupRecords = [SELECT Id, RelatedId, Type FROM Group WHERE Id IN: groupMemberIds];
            List<Id> roleIds = new List<Id>();
            List<Id> roleWithSubordinateIds = new List<Id>();
            for(Group groupRecord : groupRecords) {
                if (groupRecord.Type == 'Role') {
                    roleIds.add(groupRecord.RelatedId);
                } else if (groupRecord.Type == 'RoleAndSubordinates' || groupRecord.Type == 'roleAndSubordinatesInternal') {
                    roleWithSubordinateIds.add(groupRecord.RelatedId);
                }
            }

            Set<User> userRecords = new Set<User>();

            //Get all user per User in Public Group
            userRecords.addAll(QCC_UtilityHelper.getAllUserByIds(groupMemberIds));

            //Get all user per Role in Public Group
            userRecords.addAll(QCC_UtilityHelper.getAllUserByUserRoleIds(roleIds));

            //Get all user per RoleAndSubordinates in Public Group
            List<Id> finalRoleWithSubordinateIds = new List<Id>();
            Map<Id, List<UserRole>> userRoleHierarchyMap = QCC_UtilityHelper.getUserRoleHierarchyMap();
            System.debug('userRoleHierarchyMap: ' + userRoleHierarchyMap);
            for(Id roleWithSubordinateId : roleWithSubordinateIds) {
                finalRoleWithSubordinateIds.addAll(QCC_UtilityHelper.getSubHierarchyRoleIds(roleWithSubordinateId, userRoleHierarchyMap));
            }

            System.debug('finalRoleWithSubordinateIds: ' + finalRoleWithSubordinateIds);

            userRecords.addAll(QCC_UtilityHelper.getAllUserByUserRoleIds(finalRoleWithSubordinateIds));

            System.debug('userRecords: ' + userRecords);

            for(Event__c newFlightEventRecord : newFlightEventRecords) {
                DateTime currentDate = System.now();
                DateTime startDate = DateTime.valueOf(String.valueOf(newFlightEventRecord.Start_Date__c) + ' ' + String.valueOf(newFlightEventRecord.QCC_Local_Start_Time__c));
                DateTime endDate = DateTime.valueOf(String.valueOf(newFlightEventRecord.End_Date__c) + ' ' + String.valueOf(newFlightEventRecord.QCC_Local_End_Time__c));

                //Check if end Date time is later than current date time. Create task if later.
                if (endDate >= currentDate) {
                    String notificationMessage = 'A Global Heads Up has been created for <Affected Port> between <Start Time> and <End Time>. The reason for this Heads Up is <Sub-Type>. Comments have been added: <Comments>';
                    notificationMessage = notificationMessage.replace('<Affected Port>', newFlightEventRecord.Affected_Ports__c);
                    notificationMessage = notificationMessage.replace('<Start Time>', startDate.format('dd/MM/y HH:mm'));
                    notificationMessage = notificationMessage.replace('<End Time>', endDate.format('dd/MM/y HH:mm'));
                    notificationMessage = notificationMessage.replace('<Sub-Type>', newFlightEventRecord.Global_Event_Sub_Type__c);

                    if (newFlightEventRecord.Comments__c != null) {
                        notificationMessage = notificationMessage.replace('<Comments>', newFlightEventRecord.Comments__c);
                    } else {
                        notificationMessage = notificationMessage.replace('<Comments>', 'None');
                    }

                    //Create task for every user
                    for(User userRecord : userRecords) {
                        Task newTaskRecord = new Task();
                        newTaskRecord.OwnerId = userRecord.Id;
                        newTaskRecord.Subject = notificationMessage;
                        newTaskRecord.WhatId = newFlightEventRecord.Id;
                        newTaskRecord.Status = 'Not Started';
                        newTaskRecord.Priority = 'High';
                        newTaskRecord.IsReminderSet = true;
                        newTaskRecord.ReminderDateTime = startDate;

                        taskToBeCreatedList.add(newTaskRecord);
                    }
                }
            }

            System.debug('taskToBeCreatedList: ' + taskToBeCreatedList);
            if(!taskToBeCreatedList.isEmpty()) {
                insert taskToBeCreatedList;
            }
        } catch(Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Create Task For Global Heads Up', 'QCC_CreateTaskForGlobalHeadsUpInvocable', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }
}