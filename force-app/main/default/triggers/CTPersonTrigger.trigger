trigger CTPersonTrigger on Person__c (before insert, after update, before update) {
    switch on Trigger.operationType {
        
        when BEFORE_INSERT {
            CTPersonTriggerHandler.beforeInsert(Trigger.New);
        }

        when BEFORE_UPDATE {
            CTPersonTriggerHandler.beforeUpdate(Trigger.New, Trigger.oldMap);
        }

        when AFTER_UPDATE {
            CTPersonTriggerHandler.afterUpdate(Trigger.New, Trigger.oldMap);
        }
    }
}