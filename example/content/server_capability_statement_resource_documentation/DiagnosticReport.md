Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#diagnosticreport). | Supports patient-scoped retrieval of diagnostic reports needed for in-scope USCDI+ Quality data access. |
| `patient` + `category` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#diagnosticreport). | Supports patient-scoped retrieval filtered by report category, including laboratory and clinical-note report categories. |
| `patient` + `category` + `date` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#diagnosticreport). | Supports patient-scoped retrieval filtered by report category and date so quality workflows can constrain reports to relevant reporting periods. |
| `patient` + `code` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#diagnosticreport). | Supports patient-scoped retrieval filtered by report code, including code-oriented retrieval paths used by quality logic. |
