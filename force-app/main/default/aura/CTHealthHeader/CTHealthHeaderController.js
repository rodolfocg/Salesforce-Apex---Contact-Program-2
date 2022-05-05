({
    /**
     * Create Person or Location (custom) record based on the "scope value defined".
     * the "e.force:createRecord" event will bring a modal up based on the scope selected with the fillable fields to the frontend.
     * The record creation will also be handled automatically by this event.
     */
    createRecord : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var scope = component.get("v.scope");
        createRecordEvent.setParams({
            "entityApiName": scope === "person" ? "Person__c" : "Location__c"
        });
        createRecordEvent.fire();
    },

    doInit : function(component, event, helper) {
        helper.getStatusCount(component);
    },

    selectedScope: function(component, event, helper) {
        helper.getStatusCount(component);
    }
})
