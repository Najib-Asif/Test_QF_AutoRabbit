/***********************************************************************************************************************************

Description: Apex class for retrieving the account relation (TA) Information. 

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Yuvaraj MV				      Account relation  record retrieval class                     T01

Created Date    : 04/05/18 (DD/MM/YYYY)

**********************************************************************************************************************************/

global class QAC_TaInfoWrapper 
{
	global Boolean isActive {get; set;}
    global String id {get; set;}
    global String iataCode {get; set;}
    global String iataName {get; set;}
    /**global String relationship {get; set;}
    global DateTime startDate {get; set;}
    global String relatedAccountID {get; set;}
    global String primaryIATACode {get; set;}
    global String primaryAccountName {get; set;}
    global String primaryAccountID {get; set;}
    global String name {get; set;}**/
    
    
    //public QAC_TaInfoWrapper(Boolean active, DateTime startDate,     String sfTAid,     String relationship,     String relatedIATACode,     String relatedAccountName,     String relatedAccountID,     String primaryIATACode,     String primaryAccountName,     String primaryAccountID,     String name)
    public QAC_TaInfoWrapper(Boolean isActive, String id,    String IATACode,     String IATAName)    
    {
        this.id					=   id;
        this.iataCode			=   IATACode;
        this.iataName			=   IATAName;
        this.isActive			=	isActive;
        /**this.startDate			=   startDate;
        this.relationship		=   relationship;
        this.relatedAccountID	=   relatedAccountID;
        this.primaryIATACode	=   primaryIATACode;
        this.primaryAccountName	=   primaryAccountName;
        this.primaryAccountID	=   primaryAccountID;
        this.name				=   name;**/
        
        
    }
}