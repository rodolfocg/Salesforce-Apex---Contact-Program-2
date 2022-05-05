public class CTPeopleTracingController {

    /*
    * Get traces based on Person IDs in People_Tracing__c
    * Comparing the personId with both Person_1__c and Person_2__c avaialble in People_Tracing__c object
    */
    public static List<People_Tracing__c> getTraces(String personId) {

        List<People_Tracing__c> traces = [SELECT Id, Name, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__r.Health_Status__c, Person_2__r.Token__c, Contact_Date__c, Contact_Type__c FROM 
                                            People_Tracing__c 
                                            WHERE (Person_1__c=:personId 
                                            OR Person_2__c=:personId) 
                                            AND Contact_Date__c = LAST_N_DAYS:30 
                                            ORDER BY Contact_Date__c DESC];

        if(traces != null && traces.size() > 0) {
            return traces;
        }

        return null;
    }

    /*
    * Finding the duplicate records before adding new traces
    * In here (Person A meeting Person B ) is equal to (Person B meeting Person A) - therefore duplicatesMap should contain both of these combinations. 
    */
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces) {
        
        Set<String> uniquePeopleTraces = new Set<String>();
        List<People_Tracing__c> duplicateRecords = new List<People_Tracing__c>();

        for(People_Tracing__c pt: newPeopleTraces) {
            uniquePeopleTraces.add(pt.Person_1__c);
            uniquePeopleTraces.add(pt.Person_2__c);
        }

        //get all exisiting People_Tracing__c records
        List<People_Tracing__c> existingRecords = [SELECT Id, Name, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__r.Health_Status__c, Person_2__r.Token__c, Contact_Date__c, Contact_Type__c FROM 
                                                    People_Tracing__c WHERE Person_1__c IN:uniquePeopleTraces OR Person_2__c IN:uniquePeopleTraces ORDER BY Contact_Date__c DESC];
                                      

        Map<Id, Set<Id>> duplicatesMap = new Map<Id, Set<Id>>();  

        if(existingRecords != null && existingRecords.size() > 0) {
            for(People_Tracing__c pt: existingRecords) {
                
                //Map for person 1 meeting person 2 - using duplicatesMap
                if(!duplicatesMap.containsKey(pt.Person_1__c)){
                    duplicatesMap.put(pt.Person_1__c, new Set<Id>());
                }
                
                duplicatesMap.get(pt.Person_1__c).add(pt.Person_2__c);
                
                //Map for person 2 meeting person 1 - using the same duplicatesMap as above
                if(!duplicatesMap.containsKey(pt.Person_2__c)){
                    duplicatesMap.put(pt.Person_2__c, new Set<Id>());
                }
                
                duplicatesMap.get(pt.Person_2__c).add(pt.Person_1__c);
            }
            
            for(People_Tracing__c pt: newPeopleTraces) {
                if((duplicatesMap.containsKey(pt.Person_1__c) && duplicatesMap.get(pt.Person_1__c).contains(pt.Person_2__c)) ||
                (duplicatesMap.containsKey(pt.Person_2__c) && duplicatesMap.get(pt.Person_2__c).contains(pt.Person_1__c))) {
                    duplicateRecords.add(pt);
                }
            }

            return duplicateRecords;
        }

        return null;
    }
}
