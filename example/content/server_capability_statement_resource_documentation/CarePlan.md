Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` + `category` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#careplan). | Supports patient-scoped retrieval of care plans filtered to the category relevant for USCDI+ Quality data access. |
