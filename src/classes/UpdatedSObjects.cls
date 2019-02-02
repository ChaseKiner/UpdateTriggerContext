public with sharing class UpdatedSObjects {
    private Map<Id, SObject> newSObjects;
    private Map<Id, SObject> oldSObjects;

    public UpdatedSObjects(Map<Id, SObject> newSObjects, Map<Id, SObject> oldSObjects) {
        verifyMapIntegrity(newSObjects, oldSObjects);

        this.newSObjects = newSObjects;
        this.oldSObjects = oldSObjects;
    }


    public Boolean match(Id SObjectId, SObjectField field) {
        return newSObjects.get(SObjectId).get(field) == oldSObjects.get(SObjectId).get(field);
    }

    public UpdatedSObjects filter(SObjectField field, Object value) {
        Map<Id, SObject> filteredNewSObjects = filterMap(newSObjects, field, value);
        Map<Id, SObject> filteredOldSObjects = filterMap(oldSObjects, field, value);

        return new UpdatedSObjects(filteredNewSObjects, filteredOldSObjects);
    }

    public UpdatedSObjects filterChange(SObjectField field) {
        Map<Id, SObject> filteredNewSObjects = new Map<Id, SObject>();
        Map<Id, SObject> filteredOldSObjects = new Map<Id, SObject>();
        for (Id id : newSObjects.keySet()) {
            if(match(id, field)) {
                filteredNewSObjects.put(id, getNew(id));
                filteredOldSObjects.put(id, getOld(id));
            }
        }
        return new UpdatedSObjects(filteredNewSObjects, filteredOldSObjects);
    }

    public Set<Id> getIds() {
        return newSObjects.keySet();
    }

    public SObject getNew(Id id) {
        return newSObjects.get(id);
    }

    public List<SObject> getNew() {
        return newSObjects.values().clone();
    }

    public SObject getOld(Id id) {
        return oldSObjects.get(id);
    }

    public List<SObject> getOld() {
        return oldSObjects.values().clone();
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

    private void verifyMapIntegrity(Map<Id, SObject> newSObjects, Map<Id, SObject> oldSObjects) {
        verifyMapsNotNull(newSObjects, oldSObjects);
        verifyEqualMapSize(newSObjects, oldSObjects);
        SObjectType type = newSObjects.values()[0].getSObjectType();
        for (Id id : newSObjects.keySet()) {
            if (newSObjects.get(id).getSObjectType() != type) {
                throw new MapIntegrityException('All SObjects inside map must be of same type');
            }

        }

    }

    private void verifyEqualMapSize(Map<Id, SObject> newSObjects, Map<Id, SObject> oldSObjects) {
        if (newSObjects.size() != oldSObjects.size()) {
            throw new MapIntegrityException('Map sizes are not the same');
        }
    }

        private void verifyMapsNotNull(Map<Id, SObject> newSObjects, Map<Id, SObject> oldSObjects) {
            if (newSObjects == null || oldSObjects == null) {
                throw new NullMapException('One or both Maps are null');
            }
        }

    public with sharing class NullMapException extends Exception {}
    public with sharing class MapIntegrityException extends Exception {}
}