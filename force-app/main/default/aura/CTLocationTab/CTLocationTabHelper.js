({
    searchLocation : function(component, locationId) {

        const action = component.get("c.getLocationDetails");

        console.log(locationId);

        //set parameters - JSON object
        action.setParams({
            locationId: locationId,
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state === "SUCCESS") {

                //using the getReturnValue (built in method) to get the return value form Apex action/method
                const resp = response.getReturnValue();

                if(resp != null) {
                    //binding the data to the data table
                    component.set("v.resultsFound", true);
                    component.set("v.name", resp.name);
                    component.set("v.address", resp.address);
                    component.set("v.pin_code", resp.pinCode);
                    component.set("v.red_score", resp.redScore);
                    component.set("v.status", resp.status);
                    component.set("v.status_updated_on", resp.statusUpdateOn);
                    component.set("v.contacts_count", resp.contactsCount);
                
                    if(resp.contactsCount > 0){
                        component.set("v.columns", this.getColumns());
                        component.set("v.data", resp.closeContacts);
                    }
                    console.log(resp.closeContacts);
                    console.log(resp);
                } else {
                    component.set("v.resultsFound", false);
                    this.showToast("Error", `Could not find any results related to the ID: ${locationId}`, "error");
                }
            }

            component.set('v.isSearching', false);
        });

        $A.enqueueAction(action);
    },

    getColumns: function() {
        /**
        * Mapping table columns to the actual field name names based on Person or Location selected
        */
        const columns = [
            {label: 'Name', fieldName: 'name', type: 'text'},
            {label: 'Address', fieldName: 'address', type: 'String'},
            {label: 'Pin Code', fieldName: 'pinCode', type: 'String'},
            {label: 'Red Score', fieldName: 'redScore', type: 'Integer'},
            {label: 'Status Updated On', fieldName: 'statusUpdateOn', type: 'Date'},
            {label: 'Status', fieldName: 'status', type: 'String'},
        ]

        return columns;
    },

    showToast: function (title, message, type) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title,
            message,
            type
        });
        toastEvent.fire();
    }
})
