({

    getStatusCount: function(component) {
        const scope = component.get("v.scope");

        const action = scope === "person" ? component.get("c.getPersonHealthStatusCount") : component.get("c.getLocationHealthStatusCount");


        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state === "SUCCESS") {

                //using the getReturnValue (built in method) to get the return value form Apex action/method
                const resp = response.getReturnValue();
                component.set('v.statusCount', resp);
                return;
            }

            console.log(`An error occurred when fetching ${scope} data.`);
            
        });

        $A.enqueueAction(action);
    },
})
