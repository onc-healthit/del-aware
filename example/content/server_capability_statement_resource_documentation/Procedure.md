Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#procedure). | Supports patient-scoped retrieval of procedures needed for in-scope USCDI+ Quality data access. |
| `patient` + `status` | Added in US Quality Core. | Supports patient-scoped retrieval filtered by procedure status. US Quality Core makes this combination explicit for status-sensitive quality workflows, including not-done procedure cases. |
| `patient` + `date` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#procedure). | Supports patient-scoped retrieval filtered by procedure date so quality workflows can constrain procedures to relevant reporting periods. |
