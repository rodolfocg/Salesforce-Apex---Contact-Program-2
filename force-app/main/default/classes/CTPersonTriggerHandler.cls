public with sharing class CTPersonTriggerHandler {

    public static void beforeInsert(List<Person__c> newRecords) {
        for(Person__c personRecord: newRecords){

            /*
            * Creating a token using persons mobile no
            * Set the health status to Green initially
            */
            personRecord.Token__c = CTPersonController.getToken(personRecord.Mobile__c);
            personRecord.Health_Status__c = 'Green';
        }
    }

    public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecords) {

        for(Person__c personRecord: newRecords){
            //change the update date only if the Health Status has been updated
            if(oldRecords.get(personRecord.Id).Health_Status__c != personRecord.Health_Status__c) {
                personRecord.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecords) {

        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();

        for(Person__c personRecord: newRecords){

            //Status change records
            if(oldRecords.get(personRecord.Id).Health_Status__c != personRecord.Health_Status__c) {
                statusChange.add(personRecord.Id);
            }

            //Status changed to red
            if(personRecord.Health_Status__c == 'Red' && oldRecords.get(personRecord.Id).Health_Status__c  != 'Red') {
                redStatus.add(personRecord.Id);
            }
        }

        //the following events occure when the status of person(s) become red
        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();
        Set<Id> alreadyProcessed = new Set<Id>();

        alreadyProcessed.addAll(redStatus);

        List<Person__c> personToUpdate = new List<Person__c>();

        //Adding cohabitants
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));

        //adding primary contacts
        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContacts);

        //Adding neighbours
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));

        //adding secondary contacts
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));

        for(Id pid: orangeStatus) {
            personToUpdate.add(new Person__c(Id=pid, Health_Status__c = 'Orange'));
        }

        for(Id pid: yellowStatus) {
            personToUpdate.add(new Person__c(Id=pid, Health_Status__c = 'Yellow'));
        }

        if(personToUpdate.size() > 0) {
            update personToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByPersonIds(statusChange);

        if(locationTraces != null && locationTraces.size() > 0){
            Set<Id> locationIds = new Set<Id>();
            for(Location_Tracing__c trace: locationTraces) {
                locationIds.add(trace.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);
        }
    }
}
