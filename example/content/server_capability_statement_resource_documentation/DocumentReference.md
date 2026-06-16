Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `_id` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#documentreference). | Supports search retrieval of a known DocumentReference by resource id. |
| `patient` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#documentreference). | Supports patient-scoped retrieval of document references needed for in-scope USCDI+ Quality data access. |
| `patient` + `type` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#documentreference). | Supports patient-scoped retrieval filtered by document type, including clinical note type retrieval. |
| `patient` + `category` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#documentreference). | Supports patient-scoped retrieval filtered by document category. |
| `patient` + `category` + `date` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#documentreference). | Supports patient-scoped retrieval filtered by document category and date so quality workflows can constrain documents to relevant reporting periods. |
