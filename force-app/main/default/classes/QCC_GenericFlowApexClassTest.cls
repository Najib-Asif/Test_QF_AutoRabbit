@isTest
public class QCC_GenericFlowApexClassTest {

    @isTest
    static void testCallMethodWithName() {
       
        
        QCC_GenericFlowApexClass.inputParameter inputParam = new QCC_GenericFlowApexClass.inputParameter();
        inputParam.recordIds = new List<Id>();
        inputParam.recordIds.add(UserInfo.getuserid());        
        inputParam.methodName = 'Call_TV_API';

        List<QCC_GenericFlowApexClass.inputParameter> inputParams = new List<QCC_GenericFlowApexClass.inputParameter> { inputParam };

        Test.startTest();
        try{
            List<String> result = QCC_GenericFlowApexClass.callMethodWithName(inputParams);
        }catch(exception e){
        }
        Test.stopTest();

    }
}