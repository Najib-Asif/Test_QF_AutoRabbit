global class QAC_PaymentEvaluationScheduler implements Schedulable{
    global void execute(System.SchedulableContext sc){
        Database.executeBatch(new QAC_PaymentEvaluation());
    }
}