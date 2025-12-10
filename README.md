# Linear Branch Creator

Run the script from another git project to create a new branch with a name based on one of your assigned Linear.app cards.

## Setup

Clone this and then set the following environment variables in a .env file:

- `LINEAR_API_KEY` - Your Linear.app API key
- `INITIALS` - Your initials.
- `PREFIX_CHOICES` - Which types of prefixes you work with. Comma separated list. E.g. "chore,bug,feature".
- `ASSIGNEE_EMAIL` - The email address of the owner of the cards.
- `STATES` - The state(s) for the query. Examples: "unstarted" or "backlog,started".
- `MAX_LENGTH` - Maximum length of the branch name. Default is 78.

This will end up creating branches of the form:

```
  chore/DEV-1234-mw-card-title
```
