/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 11-30-2023
 * @last modified by  : Praveen Sampath
**/
public without sharing class ExGratiaSampleResponseGenerator {
	@InvocableMethod
    public static List<ExGratiaOutput> execute (List<ExGratiaInput> requestList) {
        
        List<StaticResource> exGratiaResource = [Select Id, Body from StaticResource Where Name='ExgratiaSampleJSON' LIMIT 1];
        
        List<ExgratiaFlightPassSearchWrapper> res = ExgratiaFlightPassSearchWrapper.parse(exGratiaResource[0].body.toString());
        //List<ExGratiaMockResponse> res = ExGratiaMockResponse.parse(exGratiaResource[0].body.toString());
        ExGratiaOutput exGrationOutputVar = new ExGratiaOutput();
        exGrationOutputVar.res = res; 
        return (new List<ExGratiaOutput>{exGrationOutputVar}); 
    }
    
    
    public class ExGratiaInput {
        @InvocableVariable(label='FF Number' description='yourDescription' required=false)
        public String ffNumber;
        
        @InvocableVariable(label='PNR Number' description='yourDescription' required=false)
        public String pnrNumber;
        
        @InvocableVariable(label='Last Name' description='yourDescription' required=true)
        public String lastName;
        
        @InvocableVariable(label='Date of Travel' description='yourDescription' required=true)
        public Date dateOfTravel;
        
        @InvocableVariable(label='Flight Number' description='yourDescription' required=true)
        public String flightNumber;
        
    }
    
    public class ExGratiaOutput{
         @InvocableVariable(label='Response' description='yourDescription' required=true)
         public List<ExgratiaFlightPassSearchWrapper> res;
    }
    
    
}