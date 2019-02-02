@IsTest
private class UpdatedSObjectsTest {

    static Integer s_num = 1;

    @isTest
    static void UpdatedSObjects_givenNullMaps_shouldThrowException() {
        Boolean exceptionThrow = false;
        Test.startTest();
        try {
            UpdatedSObjects updatedSObjects = new UpdatedSObjects(null, null);
        }
        catch (Exception e) {
            exceptionThrow = true;
        }
        System.assertEquals(true, exceptionThrow);
    }

    @isTest
    static void UpdatedSObjects_givenOneNullMap_shouldThrowException() {
        Boolean exceptionThrow = false;
        Test.startTest();
        try {
            UpdatedSObjects updatedSObjects = new UpdatedSObjects(null, new Map<Id, SObject>());
        }
        catch (Exception e) {
            exceptionThrow = true;
        }
        System.assertEquals(true, exceptionThrow);
    }

    @isTest
    static void UpdatedSObjects_givenMapsOfDifferentSizes_shouldThrowException() {
        Boolean exceptionThrow = false;
        Test.startTest();
        Map<Id, SObject> sObjectsByIds = new Map<Id, SObject>();
        Contact contact = createMockContact();
        sObjectsByIds.put(contact.Id, contact);
        try {
            UpdatedSObjects updatedSObjects = new UpdatedSObjects(sObjectsByIds, new Map<Id, SObject>());
        }
        catch (Exception e) {
            exceptionThrow = true;
        }
        System.assertEquals(true, exceptionThrow);
    }

    private static Contact createMockContact() {
        Contact contact = new Contact();
        contact.Id = getFakeId(Contact.getSObjectType());
        return contact;
    }


    private static String getFakeId(Schema.SObjectType sot) {
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() +
                '0'.repeat(12-result.length()) + result;
    }
}