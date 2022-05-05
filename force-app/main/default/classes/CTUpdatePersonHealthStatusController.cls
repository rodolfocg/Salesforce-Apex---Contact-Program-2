public with sharing class CTUpdatePersonHealthStatusController {
    @AuraEnabled
    public static void updatePersonHealthStatus(String personId) {
        Person__c person = new Person__c(Id = personId);
        person.Health_Status__c = 'Red';
        update person;
    }
}
