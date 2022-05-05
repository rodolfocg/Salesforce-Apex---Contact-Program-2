public with sharing class CTLocationTriggerHandler {

    public static void beforeInsert(List<Location__c> newRecords) {

        for(Location__c newLocation: newRecords){
            newLocation.Status__c = 'Green';
        }
    }

    public static void beforeUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecords) {

        for(Location__c newLocation: newRecords){
            if(newLocation.Status__c != oldRecords.get(newLocation.Id).Status__c){
                newLocation.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecords) {

        Set<Id> statusChangeLocIds = new Set<Id>();
        Set<Person__c> updatePersonSet = new Set<Person__c>();

        for(Location__c location: newRecords){
            if(location.Status__c == 'Red' && oldRecords.get(location.Id).Status__c != 'Red') {
                statusChangeLocIds.add(location.Id);
            }
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(statusChangeLocIds);

        List<Person__c> updatePersonList = new List<Person__c>();

        for(Location_Tracing__c lt: locationTraces){
            //this will avoid duplicates
            updatePersonSet.add(new Person__c(Id=lt.Person__c, Health_Status__c = 'Yellow'));
        }

        updatePersonList.addAll(updatePersonSet);

        if(updatePersonList.size() > 0){
            update updatePersonList;
        }
    }
}
