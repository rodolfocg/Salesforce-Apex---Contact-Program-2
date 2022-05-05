({
    handlePersonSearchClick: function (component, event, helper) {
        var personId = component.find('enter-search').get('v.value');

        if(personId) {
            component.set('v.isSearching', true);
            helper.searchPerson(component, personId);
        } else {
            component.set("v.resultsFound", false);
        }
    },
})
