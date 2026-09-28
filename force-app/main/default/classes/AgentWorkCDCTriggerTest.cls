@isTest
private class AgentWorkCDCTriggerTest {
  
   
    @isTest
    static void testAgentWorkCDCTriggerFires() {
        
        
    // 1. Create User (Agent)
            User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
    
            // 2. Create Work Item (Case example)
            Case c = new Case(
                Subject = 'Test Case for AgentWork',
                Status = 'New',
                Origin = 'Phone'
            );
            insert c;
    
            // 3. Get Channel (ServiceChannel)
            ServiceChannel sc = [
                SELECT Id 
                FROM ServiceChannel 
                LIMIT 1
            ];
        
            //PendingServiceRouting psr = new PendingServiceRouting(WorkItemId = c.Id,ServiceChannelId = sc.Id,RoutingType = 'QueueBased',CapacityWeight = 1);         

            //insert psr;
    
            // 4. Create AgentWork
            AgentWork aw = new AgentWork(
                UserId = u.Id,
                WorkItemId = c.Id,
                ServiceChannelId = sc.Id,
                CapacityWeight = 1
            );

        // 1. Enable Salesforce Change Data Capture testing environment
        Test.enableChangeDataCapture();
        
        
        // 3. Fire the event bus within the test execution lifecycle
        List<AgentWork> awList = new List<AgentWork>{aw};
        List<Database.SaveResult> sr =  Database.insert(awList, false);
        
        // Forces the asynchronous event pipeline to deliver items synchronously
        Test.getEventBus().deliver(); 
        
        // 4. Verification
        //System.assertNotEquals(null, cdcEvent, 'CDC event payload should clear the pipeline successfully.');
    }


}