let Filter1 = view () {
  AADRiskyUsers
  | where not(tostring(RiskLevel) has_any("low", "medium", "hidden", "none", "unknownFutureValue")
  | where tostring(RiskLevel) has_any("high")
  | where not(tostring(RiskState) has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
  | where tostring(RiskState) has_any("atRisk", "confirmedCompromised")
  | let tostring(riskyUserRiskLevel) == RiskLevel
  | let tostring(riskyUserRiskState) == RiskState
};

let Filter2 = view () {
SigninLogs
| mvexpand ConditionalAccessPolicies
| where not(tostring(ConditionalAccessStatus) has_any("success", "notApplied"))
| where tostring(ConditionalAccessStatus) has_any("failure")
| where not(tostring(ConditionalAccessPolicies) has_any("success", "notApplied", "reportOnlyNotApplied"))
| where tostring(ConditionalAccessPolicies) has_any("failure")
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
}

union withsource="Final Report" Filter1, Filter2
