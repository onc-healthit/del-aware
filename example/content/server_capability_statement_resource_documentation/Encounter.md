Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `_id` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#encounter). | Supports search retrieval of a known Encounter by resource id. |
| `patient` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#encounter). | Supports patient-scoped retrieval of encounters needed for in-scope USCDI+ Quality data access. |
| `patient` + `type` | Added in US Quality Core. | Supports patient-scoped retrieval filtered by encounter type. US Quality Core makes this combination explicit as a primary retrieval path for quality logic that filters by visit or service type. |
| `patient` + `date` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#encounter). | Supports patient-scoped retrieval filtered by encounter date so quality workflows can constrain encounters to relevant reporting periods. |
