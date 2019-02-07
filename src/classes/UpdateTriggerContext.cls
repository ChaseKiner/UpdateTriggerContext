public with sharing class UpdateTriggerContext {
    private Map<Id, SObject> newSObjects;
    private Map<Id, SObject> oldSObjects;

    public UpdateTriggerContext() {
        if(!Trigger.isExecuting || !Trigger.isUpdate) {
           throw new UpdateTriggerNotExecutingException('Not running in Trigger context');
        }
        newSObjects = Trigger.newMap;
        oldSObjects = Trigger.oldMap;
    }

    @TestVisible
    private UpdateTriggerContext(Map<Id, SObject> newSObjects, Map<Id, SObject> oldSObjects) {

        this.newSObjects = newSObjects;
        this.oldSObjects = oldSObjects;
    }

    public Boolean match(Id SObjectId, SObjectField field) {
        return newSObjects.get(SObjectId).get(field) == oldSObjects.get(SObjectId).get(field);
    }

    public UpdateTriggerContext filterByNew(SObjectField field, Object value) {
        Map<Id, SObject> filteredNewSObjects = filterMap(newSObjects, field, value);
        Map<Id, SObject> filteredOldSObjects = filterOld(filteredNewSObjects);

        return new UpdateTriggerContext(filteredNewSObjects, filteredOldSObjects);
    }

    public UpdateTriggerContext filterByOld(SObjectField field, Object value) {
        Map<Id, SObject> filteredOldSObjects = filterMap(oldSObjects, field, value);
        Map<Id, SObject> filteredNewSObjects = filterNew(filteredOldSObjects);

        return new UpdateTriggerContext(filteredNewSObjects, filteredOldSObjects);
    }

    public UpdateTriggerContext filterByNewAndOld(SObjectField field, Object value) {
        return filterByNew(field, value).filterByOld(field, value);
    }

    public UpdateTriggerContext filterChange(SObjectField field) {
        Map<Id, SObject> filteredNewSObjects = new Map<Id, SObject>();
        for (Id id : newSObjects.keySet()) {
            if(match(id, field)) {
                filteredNewSObjects.put(id, getNew(id));
            }
        }
        Map<Id, SObject> filteredOldSObjects = filterOld(filteredNewSObjects);

        return new UpdateTriggerContext(filteredNewSObjects, filteredOldSObjects);
    }

    public UpdateTriggerContext union(UpdateTriggerContext updatedSObjects) {
        Map<Id, SObject> newSObjectMap = new Map<Id, SObject>(getNew());
        newSObjectMap.putAll(updatedSObjects.getNew());
        Map<Id, SObject> oldSObjectMap = new Map<Id, SObject>(getOld());
        oldSObjectMap.putAll(updatedSObjects.getOld());
        return new UpdateTriggerContext(newSObjectMap, oldSObjectMap);
    }

    public Set<Id> getIds() {
        return newSObjects.keySet();
    }

    public SObject getNew(Id id) {
        return newSObjects.get(id);
    }

    public List<SObject> getNew(Set<Id> ids) {
        List<SObject> sObjects = new List<SObject>();
        for (Id id : ids) {
            sObjects.add(getNew(id));
        }
        return sObjects;
    }

    public List<SObject> getNew() {
        return newSObjects.values().clone();
    }

    public SObject getOld(Id id) {
        return oldSObjects.get(id);
    }

    public List<SObject> getOld(Set<Id> ids) {
        List<SObject> sObjects = new List<SObject>();
        for (Id id : ids) {
            sObjects.add(getOld(id));
        }
        return sObjects;
    }

    public List<SObject> getOld() {
        return oldSObjects.values().clone();
    }

    private Map<Id, SObject> filterNew(Map<Id, SObject> filteredOldSObjects) {
        Map<Id, SObject> filteredNewSObjects = new Map<Id, SObject>();
        filteredNewSObjects.putAll(getNew(filteredOldSObjects.keySet()));
        return filteredNewSObjects;
    }

    private Map<Id, SObject> filterOld(Map<Id, SObject> filteredNewSObjects) {
        Map<Id, SObject> filteredOldSObjects = new Map<Id, SObject>();
        filteredOldSObjects.putAll(getOld(filteredNewSObjects.keySet()));
        return filteredOldSObjects;
    }

    private Map<Id, SObject> filterMap(Map<Id, SObject> mapToFilter, SObjectField field, Object value) {
        Map<Id, SObject> filteredMap = new Map<Id, SObject>();
        for (SObject sobj : mapToFilter.values()) {
            if(sobj.get(field) == value) {
                filteredMap.put(sobj.Id, sobj);
            }
        }
        return filteredMap;
    }

    public with sharing class UpdateTriggerNotExecutingException extends Exception {}

}