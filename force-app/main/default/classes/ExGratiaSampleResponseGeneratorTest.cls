@IsTest
public with sharing class ExGratiaSampleResponseGeneratorTest {
    
  

    @isTest
    static void testMockResponse() {
        ExGratiaSampleResponseGenerator.ExGratiaInput exgratiaInput = new ExGratiaSampleResponseGenerator.ExGratiaInput();
        exgratiaInput.dateOfTravel = Date.today();
        exgratiaInput.ffNumber ='1234567';
        exgratiaInput.flightNumber = 'QN123';
        exgratiaInput.lastName = 'Citizen';
        exgratiaInput.pnrNumber = 'FLE43R';

        List<ExGratiaSampleResponseGenerator.ExGratiaInput> listOfInput = new List<ExGratiaSampleResponseGenerator.ExGratiaInput>();
        listOfInput.add(exgratiaInput);

        List<ExGratiaSampleResponseGenerator.ExGratiaOutput> exgratiaOutput = ExGratiaSampleResponseGenerator.execute(listOfInput);
    }
}