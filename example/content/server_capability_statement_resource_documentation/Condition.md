Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#condition). | Supports patient-scoped retrieval of conditions needed for in-scope USCDI+ Quality data access. |
| `patient` + `category` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#condition). | Supports patient-scoped retrieval filtered by condition category, including problem, health concern, and encounter diagnosis use cases. |
| `patient` + `code` | Added in US Quality Core. | Supports patient-scoped retrieval filtered by condition code. US Quality Core makes this combination explicit as a primary retrieval path for quality logic that filters by diagnosis, problem, or health concern code. |
