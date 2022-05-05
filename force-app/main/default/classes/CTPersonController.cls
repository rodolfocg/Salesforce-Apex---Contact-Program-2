public class CTPersonController {
    public static String getToken(String mobileNo) {
        Blob value = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);
        return EncodingUtil.base64Encode(hash);
    }

    public static List<Person__c> getRecentHealthChanges() {
        List<Person__c> persons = [
            SELECT Name, Mobile__c, CreatedBy.Name, LastModifiedBy.Name, Health_Status__c, Status_Update_Date__c, Token__c
            FROM Person__c
            ORDER BY Status_Update_Date__c DESC NULLS LAST
            LIMIT 100
        ];
        return persons;
    }

    public static List<Person__c> searchPeople(String keywords) {
        keywords = '%' + keywords + '%';
        List<Person__c> persons = [
            SELECT Name, Mobile__c, CreatedBy.Name, LastModifiedBy.Name, Health_Status__c, Status_Update_Date__c, Token__c
            FROM Person__c
            WHERE Name LIKE :keywords OR Mobile__c LIKE :keywords OR Token__c LIKE :keywords
            ORDER BY Status_Update_Date__c DESC NULLS LAST
            LIMIT 100
        ];

        return persons;
    }

    public static Person__c getPersonById(String personId) {
        List<Person__c> persons = [
            SELECT Id, Name, Mobile__c, CreatedBy.Name, LastModifiedBy.Name, Health_Status__c, Status_Update_Date__c, Token__c
            FROM Person__c
            WHERE Id = :personId
        ];

        if (persons != null && persons.size() > 0) {
            return persons[0];
        }

        return null;
    }

    public static Map<String, Integer> getHealthStatusCount() {
        Map<String, Integer> healthStatusGroup = new Map<String, Integer>();

        for (AggregateResult ar : [
            SELECT Health_Status__c HealthStatus, Count(Id) NumberOfPeople
            FROM Person__c
            GROUP BY Health_Status__c
        ]) {
            String healthStatus = String.valueOf(ar.get('HealthStatus'));
            Integer count = Integer.valueOf(ar.get('NumberOfPeople'));
            healthStatusGroup.put(healthStatus, count);
        }

        return healthStatusGroup == null || healthStatusGroup.isEmpty() ? null : healthStatusGroup;
    }

    /*
     * Fetching the list of people who live together (Cohabitants)
     * Cohabitants belong to the Orange category
     * Making sure their heath status is already not Red or Orange
     * Only making sure unique person IDs are returned. Ex: Person1 have met with Person2, and Person2 have met with Person5 - in this case we have multiple Person2 recs
     */
    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<String> healthStatuses = new List<String>{ 'Red', 'Orange' };

        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Person_2__c, Person_1__c, Name, Contact_Type__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :personIds
                OR Person_1__c IN :personIds)
                AND Contact_Type__c = 'Cohabitant'
                AND (Person_1__r.Health_Status__c NOT IN :healthStatuses
                OR Person_2__r.Health_Status__c NOT IN :healthStatuses)
        ];

        Set<Id> cohabitants = new Set<Id>();

        for (People_Tracing__c pt : peopleTraces) {
            //adding person Person_1__c and Person_2__c to th list if not exist
            if (!alreadyProcessed.contains(pt.Person_1__c)) {
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if (!alreadyProcessed.contains(pt.Person_2__c)) {
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return cohabitants;
    }

    /**
     * Selecting the neighbours where their health status is Green (Yello, Orange and Red will be ignored)
     * Neighbours belong to the Yellow category
     */
    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Person_2__c, Person_1__c, Name, Contact_Type__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :personIds
                OR Person_1__c IN :personIds)
                AND Contact_Type__c = 'Neighbour'
                AND (Person_1__r.Health_Status__c = 'Green'
                OR Person_2__r.Health_Status__c = 'Green')
        ];

        Set<Id> neighbours = new Set<Id>();

        for (People_Tracing__c pt : peopleTraces) {
            //adding person Person_1__c and Person_2__c to th list if not exist
            if (!alreadyProcessed.contains(pt.Person_1__c)) {
                neighbours.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if (!alreadyProcessed.contains(pt.Person_2__c)) {
                neighbours.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return neighbours;
    }

    /*
     * Fetching the primary contacts
     * Primary contacts belong to the Orange category
     * The status "Other" will be used
     */
    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<String> healthStatuses = new List<String>{ 'Red', 'Orange' };

        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Person_2__c, Person_1__c, Name, Contact_Type__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :personIds
                OR Person_1__c IN :personIds)
                AND Contact_Type__c = 'Other'
                AND (Person_1__r.Health_Status__c NOT IN :healthStatuses
                OR Person_2__r.Health_Status__c NOT IN :healthStatuses)
                AND Contact_Date__c = LAST_N_DAYS:10
        ];

        Set<Id> primaryContacts = new Set<Id>();

        for (People_Tracing__c pt : peopleTraces) {
            //adding person Person_1__c and Person_2__c to th list if not exist
            if (!alreadyProcessed.contains(pt.Person_1__c)) {
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if (!alreadyProcessed.contains(pt.Person_2__c)) {
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return primaryContacts;
    }

    /*
     * Fetching the secondary contacts
     * Secondary contacts belongs to Yellow category
     * The status "Other" will be used
     * In order to fetch Secondary contacts we need to pass the primary contacts as a parameter returned from the function getPrimaryContacts above
     */
    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactIds, Set<Id> alreadyProcessed) {
        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Person_2__c, Person_1__c, Name, Contact_Type__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :primaryContactIds
                OR Person_1__c IN :primaryContactIds)
                AND Contact_Type__c = 'Other'
                AND (Person_1__r.Health_Status__c = 'Green'
                OR Person_2__r.Health_Status__c = 'Green')
                AND Contact_Date__c = LAST_N_DAYS:10
        ];

        Set<Id> secondaryContacts = new Set<Id>();

        for (People_Tracing__c pt : peopleTraces) {
            //adding person Person_1__c and Person_2__c to th list if not exist
            if (!primaryContactIds.contains(pt.Person_1__c)) {
                secondaryContacts.add(pt.Person_1__c);
            }

            if (!primaryContactIds.contains(pt.Person_2__c)) {
                secondaryContacts.add(pt.Person_2__c);
            }
        }

        return secondaryContacts;
    }
}
