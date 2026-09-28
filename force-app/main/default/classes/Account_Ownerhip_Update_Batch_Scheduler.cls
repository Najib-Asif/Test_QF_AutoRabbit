global class Account_Ownerhip_Update_Batch_Scheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      Account_Ownership_Update_Daily_Batch aa = new Account_Ownership_Update_Daily_Batch();
      Database.executeBatch(aa);
   }
}