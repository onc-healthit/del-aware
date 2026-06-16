Search requirements are selected according to the rules described in [Search Requirement Selection](general-requirements.html#search-requirement-selection). The table below summarizes why each required individual search or required search parameter combination is included for this resource.

| Required search | US Core alignment | Rationale |
|---|---|---|
| `patient` | Added in US Quality Core. | Supports patient-scoped retrieval of family member history for quality reporting. This US Quality Core-specific search is needed because FamilyMemberHistory is in scope for USCDI+ Quality but is not profiled by US Core 6.1.0. |
