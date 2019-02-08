# UpdateTriggerContext
An object that holds the list of updated SObjects during an update trigger

### Rationale
When dealing with methods that handle Sobjects from the update trigger, they often end up looking something like this:

EXAMPLE 1:
```
    public void doSomethingOnNameChange(Map<Id, Contact> oldContacts, Map<Id, Contact> newContacts) {
        for (Contact newContact : newContacts.values()) {
            if(oldContacts.containsKey(newContact.Id)) {
                Contact oldContact = oldContacts.get(newContact.id);
                if (newContact.FirstName != oldContact.FirstName || newContact.LastName != oldContact.LastName) {
                    doSomething(newContact);
                }
            }
        }
    }
```

I really don't like how messy this code looks. The main problem is that two parameters are being passed in, and the method needs to filter out SObjects whose name has changed. 
We can extract that out. We can also create an object to hold methods for filtering these Contacts to only return the Contacts that we want.

EXAMPLE 2:
```
    public void doSomethingOnNameChange(UpdateTriggerContext updatedSObjects) {
        List<Contact> newContactsWithNameChange = getNewContactsWithNameChange(updatedSObjects);
        for(Contact contact : newContactsWithNameChange) {
            doSomething(contact);
        }
    }

    private List<Contact> getNewContactsWithNameChange(UpdateTriggerContext updatedSObjects) {
        UpdateTriggerContext contactsWithFirstNameChange = updatedSObjects.filterChange(Contact.firstName);
        UpdateTriggerContext contactsWithLastNameChange = updatedSObjects.filterChange(Contact.lastName);
        List<Contact> newContactsWithNameChange = contactsWithFirstNameChange.union(contactsWithLastNameChange).getNew();
        return newContactsWithNameChange;
    }
```
this `filterChange(fieldName)` method returns all SObjects that have their `field` updated. This helps make the intent much more clear. Instead of trying reason out what the Boolean logic of Example 1 is doing, we can simply use this `filterChange` method to make the intent obvious. This also has the bonus effect of eliminating bugs, which complicated Boolean logic is notorious for. 

### Immutability
Another problem with Example #1 is this `oldContacts.containsKey(newContact.Id)` check. It's certainly necessary because there's no guarantee that `oldContacts` contains that Id. We can pass any map we want into the method; There is no guarantee that this method is run in an update trigger context, or that `newContacts` and `oldContacts` are equal to `Trigger.newMap` and `Trigger.oldMap` respectively. This forces us to put these `containsKey` checks in our methods, or risk `NullPointerExceptions`. `UpdateTriggerContext` avoids this paradigm by guaranteeing that 
- It is running in an update trigger context.
- NewMap contains all the SOBjects in OldMap, and vice-versa. 
- It is immutable. 

This allows us to avoid these unconventional `containsKey` checks because it is _impossible_ for `newMap` to contain anything other than sobjects in `oldmap` and vice-versa.
