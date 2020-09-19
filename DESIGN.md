# Process Flow

## Interactive Process

1. User logs in as guest.
2. User enters `@newreq` command.
3. Program asks for email address.
4. TODO: Program validates that email address is not blacklisted.
5. Program validates that there is not a current request for that email address.
    1. If existing request is expired, delete the expired request and continue.
6. Program asks for character name.
7. Program validates that the character does not yet exist.
8. Program validates that there is no existing request for that name.
    1. If existing request is expired, delete the expired request and continue.
9. Show AUP.
10. User confirms consent to AUP.
11. Program creates a reservation entry with the following parameters:
    1. Requested name
    2. Email address
    3. Expiration systime (configurable duration)
    4. Validation code
12. Program sends contents of reservation entry in human-readable format to USERLOG.
13. inotify/incron detects write event to user log.
14. Server-side processor script sends email to user's email address.
15. User logs back in as a guest.
16. User enters `@confirmreq` command.
17. User enters validation code.
18. Program confirms that the validation code is valid and not expired.
19. If the code is valid and not expired:
    1. Program prompts for password and confirmation.
    2. Program creates character and sets password.
    3. Program transfers descriptor to new character.
    4. Reservation entry is deleted.
20. If the code is not valid:
    1. Return an error and refer the user to `@newreq` command.
21. If the code is expired:
    1. Return an error and refer the user to repeat the request process.
    2. Delete expired reservation entry.
