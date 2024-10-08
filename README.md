# Fork

This is a fork of https://github.com/docusealco/docuseal

No support offered beyond this readme, sorry <3

## Fork Goals

In prod, a service uses AWS S3. In dev, the service uses progressive replacements instead (file drivers, https://github.com/minio/minio , etc).

In prod, a service uses DocuSign. In dev, the service can use progressive replacements instead (a stub, this fork, etc).

This fork does **not** strive to be secure, functional, production-ready, supported, or API-compatible with any other offerings. Instead, this fork is insecure, broken, development-ready, unsupported, and API-incompatible with other offerings.

## Fork Changes

2d840e0c2af82a746e2eff91f4813dd5bf37e398 distribute source at /source.tar.gz

---

60f9996fb4d57897d5d5aa6af80d9fa0d6a6262b + 351730b4f8816d88f9f59eec220062ae2240e8f4 + 25668515aa2ca9f268d7bad536dd11caa9965bca + 60cd46d81a0f6aca7ce73c0bce8bb893aca09818 create default user using env vars, disable setup controller

To use, specify env vars in this format:

```sh
CREATE_DEFAULT_USER=true
DEFAULT_ACCOUNT_COMPANY_NAME=Default Company
DEFAULT_ACCOUNT_TIMEZONE=Etc/UTC
DEFAULT_ACCOUNT_ALLOW_TO_RESUBMIT=false
DEFAULT_ACCOUNT_WITH_SIGNATURE_ID=true
DEFAULT_ACCOUNT_COMBINE_PDF_RESULT=true
DEFAULT_ACCOUNT_APP_URL=http://localhost:3000
DEFAULT_ACCOUNT_WEBHOOK_URL=http://receiver.localhost:3000 # optional, 60cd46d81a0f6aca7ce73c0bce8bb893aca09818
DEFAULT_USER_FIRST_NAME=First
DEFAULT_USER_LAST_NAME=LAST
DEFAULT_USER_EMAIL=sample@localhost
DEFAULT_USER_PASSWORD=default
DEFAULT_USER_ACCESS_TOKEN=some-token-here # optional, 25668515aa2ca9f268d7bad536dd11caa9965bca

```

---

c924e436b960861450eeffe3742b11fcf0043923 most hardcoded text containing product name can be interpolated at runtime

To use, specify env vars in this format:

```sh
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

```sh
SHOW_GITHUB_BADGE=false
SHOW_UPGRADE_BADGE=false
SHOW_ATTRIBUTION=false
SHOW_LANDING_PAGE=false
SHOW_LOGO=false
```

---

836fc60196ea285c35520839f3e325794b52df67 Acroform text fields with the name "Initials" are parsed as initials fields

---

99075c7575643701fe83bed2f526c73e22b7941d + dd68be31ef8528100a3030f041326450eb3d11bf Upload PDFs as templates over the API

To use:

```sh
curl \
  -X POST \
  -H "X-Auth-Token: $MY_AUTH_TOKEN_HERE" \
  "http://localhost:3000/api_fork/templates" \
  -F "folder_name=optional folder name here" \
  -F "name=optional template name here" \
  -F "files[]=@some.pdf"

# sample output:
# {
#   "id": 1,
#   "slug": "rJaErPQ7rLMmrd",
#   "name": "optional_file_name",
#   "schema": [
#     {
#       "attachment_uuid": "184b348b-1751-4631-80f3-7d3c7e664518",
#       "name": "optional_file_name",
#       "pending_fields": true
#     }
#   ],
#   "fields": [
#     {
#       "uuid": "4b918248-fff5-48c0-bde9-60d695adc9b6",
#       "required": false,
#       "preferences": {},
#       "areas": [
#         {
#           "page": 123,
#           "x": 0.611832158528145,
#           "y": 0.6663091377733432,
#           "w": 0.245264381564182,
#           "h": 0.08789746879045952,
#           "attachment_uuid": "184b348b-1751-4631-80f3-7d3c7e664518"
#         }
#       ],
#       "name": "Signature",
#       "type": "signature",
#       "submitter_uuid": "9d07f55d-1056-4469-9d1a-8c3a22560a1c"
#     },
#     {
#       "uuid": "999a2369-7550-4b20-820a-49fbe8ae146e",
#       "required": false,
#       "preferences": {},
#       "areas": [
#         {
#           "page": 456,
#           "x": 0.7755746914036514,
#           "y": 0.9470239579992635,
#           "w": 0.1001216242549674,
#           "h": 0.02803335352599508,
#           "attachment_uuid": "184b348b-1751-4631-80f3-7d3c7e664518"
#         }
#       ],
#       "name": "Initials",
#       "type": "initials",
#       "submitter_uuid": "9d07f55d-1056-4469-9d1a-8c3a22560a1c"
#     }
#   ],
#   "submitters": [
#     {
#       "name": "First Party",
#       "uuid": "9d07f55d-1056-4469-9d1a-8c3a22560a1c"
#     }
#   ],
#   "author_id": 1,
#   "archived_at": null,
#   "created_at": "2024-09-12T17:29:37.146Z",
#   "updated_at": "2024-09-12T17:29:38.139Z",
#   "source": "api",
#   "folder_id": 2,
#   "external_id": null,
#   "preferences": {},
#   "application_key": null,
#   "folder_name": "API",
#   "author": {
#     "id": 1,
#     "first_name": "First",
#     "last_name": "Last",
#     "email": "sample@localhost"
#   },
#   "documents": [
#     {
#       "id": 1,
#       "uuid": "184b348b-1751-4631-80f3-7d3c7e664518",
#       "url": "http://localhost:3000/file/snipped/optional_file_name.pdf",
#       "preview_image_url": "http://localhost:3000/file/snipped/0.jpg",
#       "filename": "optional_file_name.pdf"
#     }
#   ]
# }
```

---

9517524c12d03fca4ff21073961b49f1241ab226 Acroform Signature and Initials fields can be marked as required by default.

To use, specify env vars in this format:

```sh
ACROFORM_SIGNATURE_FIELDS_REQUIRED=true
```
