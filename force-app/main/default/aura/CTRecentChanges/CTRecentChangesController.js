({
    doInit : function(component, event, helper) {

        const scope = component.get('v.scope');

        const columns = helper.getColumns(scope);

        component.set("v.columns", columns);

        helper.fetchStatus(component);
    },

    search: function(component, event, helper) {
        
        const scope = component.get('v.scope');

        const columns = helper.getColumns(scope);

        component.set("v.columns", columns);
    },

    handleKeyUp: function (component, event, helper) {
        var isEnterKey = event.keyCode === 13;
        var keyword = component.find('enter-search').get('v.value');
        var initialResponse = component.get('v.initialResponse');

        if(!keyword) {
            component.set('v.data', initialResponse);
        } else {
            if (isEnterKey) {
                component.set('v.isSearching', true);
                helper.searchStatus(component, keyword);
            }
        }
    },

    handleRowAction: function (component, event, helper) {
        const action = event.getParam('action');
        const row = event.getParam('row');
        const scope = component.get('v.scope');
        switch (action.name) {
            case 'view_details':
                const appEvent = scope === "person" ? $A.get("e.c:CTPersonSelectEvent") : $A.get("e.c:CTLocationSelectEvent")
                appEvent.setParam("recordId", row.Id);
                appEvent.setParam( "status", scope === "person" ? row.Health_Status__c : row.Status__c);
                appEvent.fire();
                break;
        }
    }
})
