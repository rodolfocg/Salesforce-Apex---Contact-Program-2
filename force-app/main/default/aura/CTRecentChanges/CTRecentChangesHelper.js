({
    /**
     * fetch status dynamically based on Person or Location select
     */
    fetchStatus : function(component) {

        const scope = component.get('v.scope');

        const action = scope === "person" ?  component.get("c.getRecentPersonHealthChanges") : component.get("c.getRecentLocationHealthChanges");

        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state === "SUCCESS") {

                //using the getReturnValue (built in method) to get the return value form Apex action/method
                const resp = response.getReturnValue();

                //binding the data to the data table
                component.set("v.data", resp);
                component.set("v.initialResponse", resp);
            }
        });

        $A.enqueueAction(action);
    },

    searchStatus : function(component, keyword) {

        const scope = component.get('v.scope');

        const action = scope === "person" ?  component.get("c.searchPeople") : component.get("c.searchLocations");

        console.log(keyword);

        //set parameters - JSON object
        action.setParams({
            keywords: keyword,
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state === "SUCCESS") {

                //using the getReturnValue (built in method) to get the return value form Apex action/method
                const resp = response.getReturnValue();

                //binding the data to the data table
                component.set("v.data", resp);
            }

            component.set('v.isSearching', false);
        });

        $A.enqueueAction(action);
    },

    getColumns: function(scope) {
        /**
        * Mapping table columns to the actual field name names based on Person or Location selected
        */
        const columns = scope === "person" ? [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Phone', fieldName: 'Mobile__c', type: 'phone'},
            {label: 'Token', fieldName: 'Token__c', type: 'text'},
            {label: 'Status', fieldName: 'Health_Status__c', type: 'text'},
            {label: 'Status Update Date', fieldName: 'Status_Update_Date__c', type: 'date'},
            {label: 'View', type: 'button', initialWidth: 135, typeAttributes: { label: 'View / Update', name: 'view_details', title: 'Click to View Details'}},
        ] : [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'},
            {label: 'Pincode', fieldName: 'Pincode__c', type: 'text'},
            {label: 'Address', fieldName: 'Address__c', type: 'text'},
            {label: 'Red Score', fieldName: 'Red_Score__c', type: 'number'},
            {label: 'Status Update Date', fieldName: 'Status_Update_Date__c', type: 'date'},
            {label: 'View', type: 'button', initialWidth: 135, typeAttributes: { label: 'View / Update', name: 'view_details', title: 'Click to View Details'}},
        ];

        return columns;
    }
})
