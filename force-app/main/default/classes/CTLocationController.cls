public class CTLocationController {
    public static List<Location__c> getRecentStatusChanges() {
        List<Location__c> locations = [
            SELECT Name, Address__c, Red_Score__c, Pincode__c, Status__c, CreatedBy.Name, LastModifiedBy.Name, Owner.Name
            FROM Location__c
            ORDER BY Status_Update_Date__c DESC NULLS LAST
            LIMIT 100
        ];
        return locations;
    }

    public static List<Location__c> searchLocations(String keywords) {
        keywords = '%' + keywords + '%';
        List<Location__c> locations = [
            SELECT Name, Address__c, Red_Score__c, Pincode__c, Status__c, CreatedBy.Name, LastModifiedBy.Name, Owner.Name
            FROM Location__c
            WHERE Pincode__c LIKE :keywords OR Address__c LIKE :keywords
            ORDER BY Status_Update_Date__c DESC NULLS LAST
            LIMIT 100
        ];
        return locations;
    }

    public static Location__c getLocationById(String locationId) {
        List<Location__c> locations = [
            SELECT Id, Name, Address__c, Red_Score__c, Pincode__c, Status__c, CreatedBy.Name, LastModifiedBy.Name, Owner.Name, Status_Update_Date__c
            FROM Location__c
            WHERE Id = :locationId
        ];

        if (locations != null && locations.size() > 0) {
            return locations[0];
        }

        return null;
    }

    public static void updateRedScore(Set<Id> locationIds) {
        List<Location__c> locationToUpdate = new List<Location__c>();

        //Grouping locations by location Ids where the Red health status people visited in last 10 days
        AggregateResult[] redPeoplePerLocation = [
            SELECT Location__c, COUNT(Id) total
            FROM Location_Tracing__c
            WHERE Person__r.Health_Status__c = 'Red' AND Visit_Date__c = LAST_N_DAYS:10 AND Location__c IN :locationIds
            GROUP BY Location__c
        ];

        for (AggregateResult ar : redPeoplePerLocation) {
            String locationId = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = getStatus(redScore);
            locationToUpdate.add(new Location__c(Id = locationId, Red_Score__c = redScore, Status__c = status));
        }

        if (locationToUpdate != null && locationToUpdate.size() > 0) {
            update locationToUpdate;
        }
    }

    //Generate the status for a given location based on the number of Red cases
    public static String getStatus(Integer redScore) {
        if (redScore == 0) {
            return 'Green';
        } else if (redScore <= 5) {
            return 'Yellow';
        } else if (redScore <= 10) {
            return 'Orange';
        } else {
            return 'Red';
        }
    }

    public static Map<String, Integer> getStatusCount() {
        Map<String, Integer> healthStatusGroup = new Map<String, Integer>();

        for (AggregateResult ar : [SELECT Status__c HealthStatus, Count(Id) NumberOfLocations FROM Location__c GROUP BY Status__c]) {
            String healthStatus = String.valueOf(ar.get('HealthStatus'));
            Integer count = Integer.valueOf(ar.get('NumberOfLocations'));
            healthStatusGroup.put(healthStatus, count);
        }

        return healthStatusGroup == null || healthStatusGroup.isEmpty() ? null : healthStatusGroup;
    }
}
