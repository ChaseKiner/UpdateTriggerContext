@IsTest
private class UpdateTriggerContextTest {

    static Integer s_num = 1;

    @isTest
    static void UpdatedSObjects_givenNonTriggerContext_shouldThrowException() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            UpdateTriggerContext updatedSObjects = new UpdateTriggerContext();
        }
        catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assertEquals(true, exceptionThrown);
    }
    
    @isTest
    static void match_givenFieldThatDoesNotMatchSObjectType_shouldThrowException() {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Contact c = createMockContact();
        contactMap.put(c.Id, c);
        UpdateTriggerContext updatedSObjects = new UpdateTriggerContext(contactMap, contactMap);
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            updatedSObjects.match(c.Id, Account.Name);
        }
        catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assertEquals(true, exceptionThrown);
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