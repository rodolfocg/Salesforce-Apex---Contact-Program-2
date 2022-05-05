({
    updatePersonHealthStatus : function(component) {
        const action = component.get("c.updatePersonHealthStatus");
        
        const recordId = component.get("v.recordId");

        action.setParams({personId : recordId});

        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state === "SUCCESS") {
                //component.set("v.status", "Red");
                this.showToast("Success", "Person Health Status Updated", "success");
                return;
            }

            this.showToast("Error", "An error occurred while updating the Person health status.", "error");
            
        });

        $A.enqueueAction(action);
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
