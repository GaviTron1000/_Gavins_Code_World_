Let _Low_Risk_Filter_ = viewc() {
AADRiskyUsers
| where not(tostring(RiskLevel) has_any("medium", "hidden", "high", "none", "unknownFutureValue"))
| where not tostring(RiskLevel) has_any("low")
| where not(tostring(RiskState) has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
| where tostring(RiskState) has_any("atRisk", "confirmedCompromised")
| where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)
| summarize count() by UserPrincipalName
| take 1
};

Let _Medium_Risk_Filter_ = viewc() {
AADRiskyUsers
| where not(tostring(RiskLevel) has_any("low", "hidden", "high", "none", "unknownFutureValue"))
| where not tostring(RiskLevel) has_any("medium")
| where not(tostring(RiskState) has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
| where tostring(RiskState) has_any("atRisk", "confirmedCompromised")
| where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)
| summarize count() by UserPrincipalName
| take 1
};

Let _High_Risk_Filter_ = viewc() {
AADRiskyUsers
| where not(tostring(RiskLevel) has_any("medium", "hidden", "low", "none", "unknownFutureValue"))
| where not tostring(RiskLevel) has_any("high")
| where not(tostring(RiskState) has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
| where tostring(RiskState) has_any("atRisk", "confirmedCompromised")
| where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)
| summarize count() by UserPrincipalName
| take 1
};

let _Policy_Failure_Filter_ = view() {
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

union withsource = "All Risky Users and Policy Failures" _Low_Risk_Filter_, _Medium_Risk_Filter_, _High_Risk_Filter_, _Policy_Failure_Filter_
