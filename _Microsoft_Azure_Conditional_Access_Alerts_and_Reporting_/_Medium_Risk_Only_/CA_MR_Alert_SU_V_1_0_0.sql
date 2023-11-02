let dataFiltrationStep1 = view() {
    AADRiskyUsers
    | where not(tostring(RiskLevel) has_any("low", "high", "hidden", "none", "unknownFutureValue"))
    | where tostring(RiskLevel) has_any("medium")
    | where not(tostring(RiskState) has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
    | where tostring(RiskState) has_any("atRisk", "confirmedCompromised")
    | where tostring(UserPrincipalName) has_any("Username") //Fill in with the username that you are searching for EX: ASmith//
    | summarize count() by UserPrincipalName
    | take 1
};
let dataFiltrationStep2 = view() {
    SigninLogs
    | mvexpand ConditionalAccessPolicies
    | where not(tostring(ConditionalAccessStatus) has_any("success", "notApplied"))
    | where tostring(ConditionalAccessStatus) has_any("failure")
    | where not(tostring(ConditionalAccessPolicies) has_any("success", "notApplied", "reportOnlyNotApplied"))
    | where tostring(ConditionalAccessPolicies) has_any("failure")
    | where not(Status has_any("successfully", "completed", "satisfied"))
    | where not(AuthenticationDetails has_any("satisfied", "succeeded"))
    | where tostring(UserPrincipalName) has_any("Username") //Fill in with the username that you are searching for EX: ASmith//
    | project CreatedDateTime, UserPrincipalName, UserType, ResourceDisplayName, AuthenticationRequirement, AuthenticationDetails, IPAddress, DeviceDetail, LocationDetails, Location, Status, ConditionalAccessPolicies, ConditionalAccessStatus, RiskDetail
};
union withsource="Medium Risk Users Report" dataFiltrationStep1, dataFiltrationStep2
