/***********************************************************************************************************************************

Description: Apex class for TA Insertion. 

History:
======================================================================================================================
Name                          Description                                               Tag
======================================================================================================================
Yuvaraj MV                  TA record insertion Class                                 T01

Created Date    : 			14/05/18 (DD/MM/YYYY)

**********************************************************************************************************************************/
global class QAC_TAInforWrapper 
{
  	/*
     * Variable Declarations
     */
    global String iataCode 			{get; set;}
    global String iataName			{get; set;}
    

 	/*
     * Constructor
     */
    public QAC_TAInforWrapper(String iataCode, String iataName)
    {
        this.iataCode 			= iataCode;
        this.iataName 			= iataName; 
    }   
    
      /*
     * To Parse deserialise data
     */    
    public static List<QAC_TAInforWrapper> parse(String json) 
    {
		return (List<QAC_TAInforWrapper>) System.JSON.deserialize(json, List<QAC_TAInforWrapper>.class);
	}
 
	/**public static QAC_TAInforAPI parse(String json) 
    {
        return (QAC_TAInforAPI) System.JSON.deserialize(json, QAC_TAInforAPI.class);
    }**/
    
}