let dataFiltrationStep1 = view () {
  AADRiskyUsers
  | where not(tostring(RiskLevel) has_any("low", "medium", "hidden", "none",
    "unknownFutureValue")
  | where tostring(RiskLevel) has_any("high")
  | where not(tostring(RiskState) has_any("none", "confirmedSafe", "remediated",
    "dismissed", "unknownFutureValue"))
  | where tostring(RiskState) has_any("atRisk", "confirmedCompromised")
  | where CreatedDateTime > ago(30m) and CreatedDateTime < ago(10m)
  | summarize count() by UserPrincipalName
  | project CreatedDateTime,
  UserPrincipalName,
  RiskLevel,
  RiskState
};
let dataFiltrationStep2 = view () {
SigninLogs
| mvexpand ConditionalAccessPolicies
| where not(tostring(ConditionalAccessStatus) has_any("success", "notApplied"))
| where tostring(ConditionalAccessStatus) has_any("failure")
| where not(tostring(ConditionalAccessPolicies) has_any("success", "notApplied",
  "reportOnlyNotApplied"))
| where tostring(ConditionalAccessPolicies) has_any("failure")
| where not(Status has_any("successfully", "completed", "satisfied"))
| where not(AuthenticationDetails has_any("satisfied", "succeeded"))
| where CreatedDateTime > ago(30m) and CreatedDateTime < ago(10m)
| summarize count() by UserPrincipalName
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
}

union withsource="High Risk Users Report" dataFiltrationStep1,
dataFiltrationStep2
