Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` | Added in US Quality Core. | Supports patient-scoped retrieval of device requests for quality reporting. This US Quality Core-specific search is needed because DeviceRequest is in scope for USCDI+ Quality but is not profiled by US Core 6.1.0. |
| `patient` + `code` | Added in US Quality Core. | Supports patient-scoped retrieval filtered by requested device code. This US Quality Core-specific combination makes the device code available as a primary retrieval path for quality logic. |
| `patient` + `do-not-perform` | Added in US Quality Core. | Supports negation workflows by enabling retrieval of device requests that indicate the requested action should not be performed. |
