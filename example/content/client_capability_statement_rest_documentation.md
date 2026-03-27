The US Quality Core Client SHALL:

1. Support fetching and querying US Quality Core profiles that contain at least one USCDI+ Quality flagged element, using the supported RESTful interactions and search parameters declared in the US Quality Core Server CapabilityStatement
2. Recognize and process all MustSupport and USCDI+ Quality flagged elements in US Quality Core
3. Treat all modifying attributes as MustSupport, even if not explicitly declared
4. SHALL NOT process resource instances that include unknown modifying attributes
5. Be simultaneously conformant with US Quality Core profiles and US Core profiles. As such, the more restrictive bindings between US Core and US Quality Core SHALL be adhered to. For example, all value sets that are required in US Core SHALL be required by US Quality Core, regardless of the binding strength in US Quality Core.

NOTE: US Core SearchParameters referenced in this CapabilityStatement that are derived from standard FHIR SearchParameters are only defined to document Server and Client expectations, such as comparator expectations, and to support generation tooling.  They SHALL NOT be interpreted as search parameters for searching. Servers and Clients SHOULD use the standard FHIR SearchParameters.
