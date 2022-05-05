public class CTLocationTracingController {
    public static List<Location_Tracing__c> getVisitors(String locationId) {
        List<Location_Tracing__c> locationsTracing = [
            SELECT Id, Visit_Date__c, Location__c, Person__r.Health_Status__c, Person__r.Name,
            FROM Location_Tracing__c
            WHERE Location__c = :locationId
            ORDER BY Visit_Date__c
        ];
        return locationsTracing;
    }

    public static List<Location_Tracing__c> getLocationByPersonIds(Set<Id> personIds) {
        List<Location_Tracing__c> locationsTracing = [
            SELECT Id, Visit_Date__c, Person__r.Name, Location__c
            FROM Location_Tracing__c
            WHERE Person__c IN :personIds AND Visit_Date__c = LAST_N_DAYS:10
        ];
        return locationsTracing;
    }

    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationsIds) {
        List<Location_Tracing__c> locationsTracing = [
            SELECT Id, Visit_Date__c, Person__r.Name, Location__c
            FROM Location_Tracing__c
            WHERE Location__c IN :locationsIds AND Person__r.Health_Status__c = 'Green'
        ];

        return locationsTracing;
    }

    /*
     * Finding the duplicate records.
     * Duplicate records when trying to insert new records (passed in as a List)
     */
    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces) {
        Set<String> locationTraceKeys = new Set<String>();
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        for (Location_Tracing__c lt : [SELECT Id, Person__c, Location__c, Visit_Date__c FROM Location_Tracing__c]) {
            String comparekey = lt.Person__c + '' + lt.Location__c + '' + lt.Visit_Date__c;
            locationTraceKeys.add(comparekey);
        }

        for (Location_Tracing__c lt : newLocationTraces) {
            String comparekey = lt.Person__c + '' + lt.Location__c + '' + lt.Visit_Date__c;
            if (locationTraceKeys.contains(comparekey)) {
                duplicates.add(lt);
            }
        }

        if (duplicates.size() > 0) {
            return duplicates;
        }

        return null;
    }

    public static Map<String, Integer> getStatusCount() {
        Map<String, Integer> healthStatusGroup = new Map<String, Integer>();
        for (AggregateResult ar : [
            SELECT COUNT(Id) locationCount, Location__r.Status__c healthStatus
            FROM Location_Tracing__c
            GROUP BY Location__r.Status__c
        ]) {
            String healthStatus = String.valueOf(ar.get('healthStatus'));
            Integer locationCount = Integer.valueOf(ar.get('locationCount'));
            healthStatusGroup.put(healthStatus, locationCount);
        }

        return healthStatusGroup == null || healthStatusGroup.isEmpty() ? null : healthStatusGroup;
    }
}
