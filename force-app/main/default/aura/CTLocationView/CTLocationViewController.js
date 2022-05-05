({
    onLocationSelect : function(component, event, helper) {
        const status = event.getParam("status");
        const recordId = event.getParam("recordId");
        component.set("v.recordId", recordId);
        component.set("v.status", status);
    }
})
