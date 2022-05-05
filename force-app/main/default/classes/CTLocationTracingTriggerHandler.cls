public with sharing class CTLocationTracingTriggerHandler {

    public static void beforeInsert(List<Location_Tracing__c> newRecords){
        
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newRecords);

        if(duplicates != null && duplicates.size() > 0){
            for(Location_Tracing__c trace: duplicates){
                trace.addError('Duplicate Location Trace detected with' + ' * Location:' + trace.Location__c + ' * Person:' + trace.Person__c + ' * Visit Date:' + trace.Visit_Date__c);
            }
        }
    }
}
