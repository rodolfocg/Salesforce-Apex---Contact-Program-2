public with sharing class CTPersonTabController {
    /**
     * A wrapper class / custom object to combine a person record and teh contact details of that person for last 30 days.
     * The contacts for last 30 days are stored into a List within the object.
     */
    @AuraEnabled
    public static UserInformation getPersonDetails(String personId) {
        UserInformation userInformation = new UserInformation();
        Person__c person = CTPersonController.getPersonById(personId);
        if (person != null) {
            userInformation.name = person.Name;
            userInformation.token = person.Token__c;
            userInformation.statusUpdateOn = person.Status_Update_Date__c;
            userInformation.phone = person.Mobile__c;
            userInformation.status = person.Health_Status__c;
        } else {
            return null;
        }
        List<People_Tracing__c> traces = CTPeopleTracingController.getTraces(personId);

        if (traces != null && traces.size() > 0) {
            List<CloseContacts> closeContacts = new List<CloseContacts>();
            Set<Id> uniqueIds = new Set<Id>();
            uniqueIds.add(personId);

            for (People_Tracing__c trace : traces) {
                CloseContacts cc = new CloseContacts();
                if (!uniqueIds.contains(trace.Person_1__c)) {
                    cc.id = trace.Person_1__c;
                    cc.status = trace.Person_1__r.Health_Status__c;
                    cc.token = trace.Person_1__r.Token__c;
                    cc.contactDate = trace.Contact_Date__c;
                }

                if (!uniqueIds.contains(trace.Person_2__c)) {
                    cc.id = trace.Person_2__c;
                    cc.status = trace.Person_2__r.Health_Status__c;
                    cc.token = trace.Person_2__r.Token__c;
                    cc.contactDate = trace.Contact_Date__c;
                }

                closeContacts.add(cc);
            }

            userInformation.contact = closeContacts;
            userInformation.contactsCount = closeContacts.size();
        }

        return userInformation;
    }

    /**
     * Adding a wrapper class
     */
    public class UserInformation {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String token;
        @AuraEnabled
        public Date statusUpdateOn;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Integer contactsCount = 0;

        /**
         * Using the CloseContacts wrapper class below return the object
         */
        @AuraEnabled
        public List<CloseContacts> contact;
    }

    public class CloseContacts {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String token;
        @AuraEnabled
        public Date contactDate;
        @AuraEnabled
        public String status;
    }
}
