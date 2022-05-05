({
    searchPerson : function(component, personId) {

        const action = component.get("c.getPersonDetails");

        console.log(personId);

        //set parameters - JSON object
        action.setParams({
            personId: personId,
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
                    component.set("v.phone", resp.phone);
                    component.set("v.token", resp.token);
                    component.set("v.health_status", resp.status);
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
                    this.showToast("Error", `Could not find any results related to the ID: ${personId}`, "error");
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
            {label: 'Token', fieldName: 'token', type: 'text'},
            {label: 'Contact Date', fieldName: 'contactDate', type: 'Date'},
            {label: 'Status', fieldName: 'status', type: 'text'},
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
