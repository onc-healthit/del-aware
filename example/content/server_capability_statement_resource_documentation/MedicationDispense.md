Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` | Required by [US Core](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html#medicationdispense). | Supports patient-scoped retrieval of medication dispenses needed for in-scope USCDI+ Quality data access. |
| `patient` + `status` | Added in US Quality Core. | Supports patient-scoped retrieval filtered by dispense status. US Quality Core makes this combination explicit for status-sensitive quality workflows, including declined dispense cases. |
