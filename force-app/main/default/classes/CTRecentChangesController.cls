public with sharing class CTRecentChangesController {
    @AuraEnabled
    public static List<Person__c> getRecentPersonHealthChanges() {
        return CTPersonController.getRecentHealthChanges();
    }

    @AuraEnabled
    public static List<Location__c> getRecentLocationHealthChanges() {
        return CTLocationController.getRecentStatusChanges();
    }

    @AuraEnabled
    public static List<Person__c> searchPeople(String keywords) {
        return CTPersonController.searchPeople(keywords);
    }

    @AuraEnabled
    public static List<Location__c> searchLocations(String keywords) {
        return CTLocationController.searchLocations(keywords);
    }
}
