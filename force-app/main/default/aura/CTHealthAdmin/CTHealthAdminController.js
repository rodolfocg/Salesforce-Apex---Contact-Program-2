({
    handleActive : function(component, event, helper) {
        var tab = event.getSource();
        var healthHeader = component.find("healthHeader");

        //changing the CTHealthHeader (child) title on tab change
        switch (tab.get('v.id')) {
            case 'location_view' :
                healthHeader.set("v.title", "Location View");
                healthHeader.set("v.scope", "location");
                healthHeader.changeStatusCount();
                break;
            case 'person_view' :
                healthHeader.set("v.title", "Person View");
                healthHeader.set("v.scope", "person");
                healthHeader.changeStatusCount();
                break;
            case 'person_tab_view' :
                healthHeader.set("v.title", "Person");
                break;
            case 'location_tab_view' :
                healthHeader.set("v.title", "Location");
                break;
        }
    },
})
