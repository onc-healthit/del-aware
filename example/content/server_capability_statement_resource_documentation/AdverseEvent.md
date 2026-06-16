Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `subject` | Added in US Quality Core. | Supports subject-scoped retrieval of AdverseEvent resources for quality reporting. This US Quality Core-specific search is needed because AdverseEvent is in scope for USCDI+ Quality but is not profiled by US Core 6.1.0. |
| `subject` + `event` | Added in US Quality Core. | Supports subject-scoped retrieval filtered by adverse event concept. This US Quality Core-specific combination makes the adverse event concept available as a primary retrieval path for quality logic. |
| `subject` + `recorded-date` | Added in US Quality Core. | Supports subject-scoped retrieval filtered by recorded date so quality workflows can constrain adverse events to relevant reporting periods. |
