The US Quality Core Server SHALL:

1. Conform to requirements provided in the US Core Server CapabilityStatement and the base FHIR specification
2. Support all US Quality Core profiles that contain at least one USCDI+ Quality data element, as described in the [USCDI+ Quality page](/uscdiquality.html)
3. Support all interactions, search parameters, and combined search parameters that have SHALL conformance expectations as described in this CapabilityStatement
4. Support all USCDI+ Quality flagged data elements, and those flagged as MustSupport from underlying US Core profiles
5. Ensure resources in 'Any' references conform to US Quality Core profiles if the base resource has a US Quality Core profile
6. Implement the RESTful behavior according to the FHIR specification for all US Quality Core interactions
7. Support JSON source formats for all US Quality Core interactions

NOTE: US Quality Core SearchParameters referenced in this CapabilityStatement that are derived from standard FHIR SearchParameters are only defined to document Server and Client expectations, such as comparator expectations, and to support generation tooling.  They SHALL NOT be interpreted as search parameters for searching. Servers and Clients SHOULD use the standard FHIR SearchParameters.
