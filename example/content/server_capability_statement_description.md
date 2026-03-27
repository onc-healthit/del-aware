This capability statement describes the expected capabilities of the US Quality Core Servers
which is responsible for responding to USCDI+ Quality V1 queries submitted by US Quality Core Clients.
It describes a minimum set of FHIR RESTful operations and search parameters necessary to enable access
to the set of USCDI+ Quality V1 data that is in scope of this implementation guide.  For more information
about which USCDI+ Quality data elements are in scope, please review the [USCDI+ Quality](uscdiquality.html) section
of this implementation guide.

US Quality Core Servers **SHALL** support the capabilities described in the [US
Core Server CapabilityStatement
STU6.1](https://hl7.org/fhir/us/core/STU6.1/CapabilityStatement-us-core-server.html).
Some RESTFUL operations and search parameters described in the US Quality Core Server CapabilityStatement are redundant
to the US Core Server CapabilityStatement, but are listed here to highlight which
capabilities are specifically relevant to USCDI+ Quality V1.

The US Quality Core Implementation Guide v1 is derived from the QI-Core Implementation Guide STU6. It adopts
all profiles within the [QI-Core Implementation Guide STU6](https://hl7.org/fhir/us/qicore/STU6/) to enable a more seamless adoption of this
implementation guide.  However, only those profiles that contain USCDI+ Quality V1 data are required to be supported
by US Quality Core Servers.  The FHIR RESTful operations and search parameters in this capability statement
reflects this scope.
