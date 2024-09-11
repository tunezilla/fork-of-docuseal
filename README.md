# Fork

This is a fork of https://github.com/docusealco/docuseal

## Changes

2d840e0c2af82a746e2eff91f4813dd5bf37e398 distribute source at /source.tar.gz

---

60f9996fb4d57897d5d5aa6af80d9fa0d6a6262b + 351730b4f8816d88f9f59eec220062ae2240e8f4 create default user using env vars, disable setup controller

To use, specify env vars in this format:

```
CREATE_DEFAULT_USER=true
DEFAULT_ACCOUNT_COMPANY_NAME=Default Company
DEFAULT_ACCOUNT_TIMEZONE=Etc/UTC
DEFAULT_ACCOUNT_ALLOW_TO_RESUBMIT=false
DEFAULT_ACCOUNT_WITH_SIGNATURE_ID=true
DEFAULT_ACCOUNT_COMBINE_PDF_RESULT=true
DEFAULT_ACCOUNT_APP_URL=http://localhost:3000
DEFAULT_USER_FIRST_NAME=First
DEFAULT_USER_LAST_NAME=LAST
DEFAULT_USER_EMAIL=sample@localhost
DEFAULT_USER_PASSWORD=default
```

---

c924e436b960861450eeffe3742b11fcf0043923 most hardcoded text containing product name can be interpolated at runtime

To use, specify env vars in this format:

```
CONSOLE_URL=http://console.localhost:3000
CLOUD_URL=http://cloud.localhost:3000
CDN_URL=http://cdn.localhost:3000
PRODUCT_URL=http://product.localhost:3000
PRODUCT_NAME=Fork of DocuSeal
SUPPORT_EMAIL=support@fork.localhost
DEFAULT_CERT_NAME=Fork of DocuSeal Self-Host Autogenerated
DEFAULT_EMAIL_FROM=Fork of DocuSeal <info@fork.localhost>
DEFAULT_PAGE_TITLE=Fork of DocuSeal | Open Source Document Signing
DEFAULT_META_TITLE=Fork of DocuSeal | Open Source Document Filing and Signing
DEFAULT_META_DESC=Forked, Open source, self-hosted tool to streamline document filling and signing. Create custom PDF forms to complete and sign with an easy to use online tool.
DEFAULT_SIGN_REASON=Signed with Fork of DocuSeal.co
DEFAULT_SIGN_REASON_NAME=Signed by %<name>s with Fork of DocuSeal.co
```

---

39eada293df6907744c486021a1be948c59386ca allow hiding Github badge, Upgrade badge, Attribution, landing page, logo

To use, specify env vars in this format:

```
SHOW_GITHUB_BADGE=false
SHOW_UPGRADE_BADGE=false
SHOW_ATTRIBUTION=false
SHOW_LANDING_PAGE=false
SHOW_LOGO=false
```

---

836fc60196ea285c35520839f3e325794b52df67 Acroform text fields with the name "Initials" are parsed as initials fields
