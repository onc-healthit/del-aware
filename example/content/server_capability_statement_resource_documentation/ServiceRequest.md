Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `_id` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#servicerequest). | Supports search retrieval of a known ServiceRequest by resource id. |
| `patient` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#servicerequest). | Supports patient-scoped retrieval of service requests needed for in-scope USCDI+ Quality data access. |
| `patient` + `category` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#servicerequest). | Supports patient-scoped retrieval filtered by service request category. |
| `patient` + `category` + `authored` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#servicerequest). | Supports patient-scoped retrieval filtered by category and authored date so quality workflows can constrain service requests to relevant reporting periods. |
| `patient` + `code` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#servicerequest). | Supports patient-scoped retrieval filtered by service request code, including primary code paths used by quality logic. |
| `patient` + `do-not-perform` | Added in US Quality Core. | Supports negation workflows by enabling retrieval of service requests that indicate the requested action should not be performed. |
