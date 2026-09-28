/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Controller class of QCC_PossibleRelatedCases LC
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
06-Aug-2018             Purushotham B          Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_PossibleRelatedCasesController {
	/*----------------------------------------------------------------------------------------------      
    Method Name:    getColumns
    Description:    Returns the columns that are needed for lightning datatable of specified lightning component 
    Parameter:          
    Return:         String    
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String getColumns(String componentName) {
        return QCC_CaseSearchResultController.getColumns(componentName);
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    search
    Description:    Search for the Cases 
    Parameter:      String, String, String, String, String    
    Return:         List<Case>    
    ----------------------------------------------------------------------------------------------*/
	@AuraEnabled
    public static List<Case> search(String firstName, String lastName, String email, String phone, String caseId) {
        return QCC_SearchContactInfoController.search(firstName, lastName, email, phone, '', 'QCC_PossibleRelatedCases', caseId);
    }
}