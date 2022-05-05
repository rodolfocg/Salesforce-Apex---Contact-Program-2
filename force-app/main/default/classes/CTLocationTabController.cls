public with sharing class CTLocationTabController {
    /**
     * A wrapper class / custom object to combine a person record and teh contact details of that person for last 30 days.
     * The contacts for last 30 days are stored into a List within the object.
     */
    @AuraEnabled
    public static LocationInformation getLocationDetails(String locationId) {
        LocationInformation locationInformation = new LocationInformation();
        Location__c location = CTLocationController.getLocationById(locationId);
        if (location != null) {
            locationInformation.name = location.Name;
            locationInformation.address = location.Address__c;
            locationInformation.pinCode = location.Pincode__c;
            locationInformation.redScore = Integer.valueOf(location.Red_Score__c);
            locationInformation.status = location.Status__c;
            locationInformation.statusUpdateOn = location.Status_Update_Date__c;
        } else {
            return null;
        }

        List<Location_Tracing__c> traces = CTLocationTracingController.getVisitors(locationId);

        if (traces != null && traces.size() > 0) {
            List<CloseContacts> closeContacts = new List<CloseContacts>();

            for (Location_Tracing__c trace : traces) {
                CloseContacts cc = new CloseContacts();
                cc.id = trace.Person__c;
                cc.status = trace.Person__r.Health_Status__c;
                cc.token = trace.Person__r.Token__c;
                cc.visitDate = trace.Visit_Date__c;

                closeContacts.add(cc);
            }

            locationInformation.contact = closeContacts;
            locationInformation.contactsCount = closeContacts.size();
        }

        return locationInformation;
    }

    /**
     * Adding a wrapper class
     */
    public class LocationInformation {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Integer redScore;
        @AuraEnabled
        public Date statusUpdateOn;
        @AuraEnabled
        public String address;
        @AuraEnabled
        public String pinCode;
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
        public Date visitDate;
        @AuraEnabled
        public String status;
    }
}
