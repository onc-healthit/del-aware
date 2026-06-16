Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` + `category` + `status` | Added in US Quality Core. | Supports patient-scoped retrieval filtered by observation category and status. US Quality Core makes this combination explicit for status-sensitive quality workflows, including cancelled or otherwise not-final observations. |
| `patient` + `category` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#observation). | Supports patient-scoped retrieval filtered by observation category for in-scope USCDI+ Quality data access. |
| `patient` + `category` + `date` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#observation). | Supports patient-scoped retrieval filtered by category and date so quality workflows can constrain observations to relevant reporting periods. |
| `patient` + `code` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#observation). | Supports patient-scoped retrieval filtered by observation code, including primary code paths used by quality logic. |
