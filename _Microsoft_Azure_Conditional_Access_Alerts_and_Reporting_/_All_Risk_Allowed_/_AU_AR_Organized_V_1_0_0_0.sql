Let dataFiltrationStep1 = view() {
    AADRiskyUsers
    | where not(RiskLevel has_any("medium", "hidden", "high", "none", "unknownFutureValue"))
    | where not (RiskLevel has_any("low"))
    | where not(RiskState has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
    | where RiskState has_any("atRisk", "confirmedCompromised")
    | where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)
    | summerise count() by UserPrincipalName
    | take 1
};
Let dataFiltrationStep2 = view() {
  AADRiskyUsers
  | where not(RiskLevel has_any("low", "hidden", "high", "none", "unknownFutureValue"))
  | where not(RiskLevel has_any("medium"))
  | where not(RiskState has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
  | where RiskState has_any("atRisk", "confirmedCompromised")
  | where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)
  | summarize count() by UserPrincipalName
  | take 1
};
Let dataFiltrationStep3 = view() {
  AADRiskyUsers
  | where not(RiskLevel has_any("medium", "hidden", "low", "none", "unknownFutureValue"))
  | where not (RiskLevel has_any("high"))
  | where not(RiskState has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
  | where RiskState has_any("atRisk", "confirmedCompromised")
  | where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)
  | summarize count() by UserPrincipalName
  | take 1
};
let dataFiltrationStep4 = view() {
    SigninLogs
    | mvexpand ConditionalAccessPolicies
    | where not(tostring(ConditionalAccessStatus) has_any("success", "notApplied"))
    | where tostring(ConditionalAccessStatus) has_any("failure")
    | where not(tostring(ConditionalAccessPolicies) has_any("success", "notApplied", "reportOnlyNotApplied"))
    | where tostring(ConditionalAccessPolicies) has_any("failure")
    | where not(Status has_any("successfully", "completed", "satisfied"))
    | where not(AuthenticationDetails has_any("satisfied", "succeeded"))
    | where CreatedDateTime > ago(30m) and CreatedDateTime < ago(10m)
    | project CreatedDateTime, UserPrincipalName, UserType, ResourceDisplayName, AuthenticationRequirement, AuthenticationDetails, IPAddress, DeviceDetail, LocationDetails, Location, Status, ConditionalAccessPolicies, ConditionalAccessStatus, RiskDetail
};
union withsource = "allRiskyUsers_and_policyFailures" dataFiltrationStep1, dataFiltrationStep2, dataFiltrationStep3, dataFiltrationStep4
