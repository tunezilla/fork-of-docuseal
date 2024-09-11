# Fork

This is a fork of https://github.com/docusealco/docuseal

## Changes

2d840e0c2af82a746e2eff91f4813dd5bf37e398: distribute source at /source.tar.gz

60f9996fb4d57897d5d5aa6af80d9fa0d6a6262b: create default user using env vars, disable setup controller

To use, specify env vars in this format:

```
CREATE_DEFAULT_USER=true
DEFAULT_USER_COMPANY_NAME=Default Company
DEFAULT_USER_TIMEZONE=Etc/UTC
DEFAULT_USER_FIRST_NAME=First
DEFAULT_USER_LAST_NAME=LAST
DEFAULT_USER_EMAIL=sample@localhost
DEFAULT_USER_PASSWORD=default
DEFAULT_USER_APP_URL=http://localhost:3000
```
