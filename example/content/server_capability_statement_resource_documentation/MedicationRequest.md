Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` + `intent` + `do-not-perform` | Added in US Quality Core. | Supports negation workflows by enabling retrieval of medication requests that indicate the requested medication should not be performed, while preserving the patient and intent context. |
| `patient` + `intent` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#medicationrequest). | Supports patient-scoped retrieval of medication requests filtered by intent, including medication orders relevant to quality reporting. |
