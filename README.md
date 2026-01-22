# Linear Branch Creator

## Install

```
git clone https://github.com/wulffeld/linear-branch-creator.git
cd linear-branch-creator
bundle install
```

Then symlink the script to somewhere in your PATH.

```
ln -s $(pwd)/linear-branch-creator.rb /usr/local/bin/linear-branch-creator
```

## Configure

Set the following environment variables in a .env file:
- `LINEAR_API_KEY` - Your Linear.app API key
- `INITIALS` - Your initials. Left out if blank or not set.
- `PREFIX_CHOICES` - Which types of prefixes you work with (labels in Linear). Comma separated list. E.g. "chore,bug,feature".
- `ASSIGNEE_EMAIL` - The email address of the owner of the cards.
- `STATES` - The state(s) for the query. Examples: "unstarted" or "backlog,started".
- `MAX_LENGTH` - Maximum length of the branch name. Default is 78.

## Run

```
linear-branch-creator.rb
```

Run the script in your git project to create a new branch with a name based on one of your assigned Linear.app cards.

This will end up creating branches of the form:

```
  chore/DEV-1234-mw-card-title
```
