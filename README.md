# Linear Branch Creator

Run the script from another git project to create a new branch with a name based on one of your assigned Linear.app cards.

## Setup

Clone this and then set the following environment variables in a .env file:

- `LINEAR_API_KEY` - Your Linear.app API key
- `INITIALS` - Your initials.
- `PREFIX_CHOICES` - Which types of prefixes you work with. Comma separated list. E.g. "chore,bug,feature".

This will end up creating branches of the form:

```
  chore/mw-dev-1234-card-title
```
