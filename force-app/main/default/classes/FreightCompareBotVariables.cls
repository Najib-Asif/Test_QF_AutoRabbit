//Jira: CRM-7264: This class compares and returns the boolean value for chatbot
public with sharing class FreightCompareBotVariables 
{
    @InvocableMethod(label = 'Compare counts')
    public static List<boolean> GetCounts(List<Integer> getInitCount) 
    {
        List<boolean> listBoolean=new List<boolean>();
        boolean agentNotAvail=false;
        if(getInitCount.size()>0 && getInitCount[0]!=null)
        {
      if(getInitCount[0]>=2)
            {
                agentNotAvail=true;    
            }
            listBoolean.add(agentNotAvail);
        }
        return listBoolean ;
    }
}