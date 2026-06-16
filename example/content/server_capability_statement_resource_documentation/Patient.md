Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `_id` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#patient). | Supports retrieval of a known Patient by resource id, which is the normal starting point for patient-scoped USCDI+ Quality data access. |
