// Conditional Access All Risk Alert Query//
//Version 1.0.0 //
// Author Gavin Stewart//
//Version Date 11-1-2023//
//Details//
// This query grabbs all of the conditional access failures that have been at
the status of Failed for atleast 10 minutes//

SigninLogs
| mvexpand ConditionalAccessPolicies
| where not(tostring(ConditionalAccessPolicies) has_any("failure", "notApplied", "success", "reportOnlyNotApplied"))
| where not(tostring(ConditionalAccessStatus) has_any("failure", "notApplied", "success", "reportOnlyNotApplied"))
| where not(Status has_any("successfully", "completed", "satisfied"))
| where not(AuthenticationDetails has_any("satisfied", "succeeded"))
| where CreatedDateTime > ago(30m) and CreatedDateTime < ago(10m)
| project CreatedDateTime,
    UserPrincipalName,
    UserType,
    ResourceDisplayName,
    AuthenticationRequirement,
    AuthenticationDetails,
    IPAddress,
    DeviceDetail,
    LocationDetails,
    Location,
    Status,
    ConditionalAccessPolicies,
    ConditionalAccessStatus,
    RiskDetail
