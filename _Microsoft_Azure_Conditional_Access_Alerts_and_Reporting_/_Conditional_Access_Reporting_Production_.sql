//Title: Conditional Access Policy Alert Query For All Failures//

//Author: Gavin Stewart//

//Date: 11-04-2023//

//Version: 1.0.4//

//Description://
//When this query is ran in a Microsoft Azure Log and Anelytic Workspace it will search through all of the//
//Risky user logs, and sign in logs to identify weather a user is risky or if they have failed any Conditional Access Policies//
//After the Query is done running it will spit out data in 4 sections//
//Section 1: All users at a risk level of "low"//
//Section 2: All users at a risk level of "medium"//
//Section 3: All users at a risk level of "high"//
//Section 4: All of the Conditional Access Policies that have been triggered, and are not currently remediated//






//This line Creates the first leg of the query which identifies low risk users//

let dataFiltrationStep1 = view() {

    //Selecting the AADRiskyUsers table, as that is where user risk level is stored//

    AADRiskyUsers

    //This step filters out everything that is not low risk//

    | where not(RiskLevel has_any("medium", "high", "none", "unknownFutureValue"))
    | where (RiskLevel has_any("low"))

    //This step filters out all of the items that have been remediated already//

    | where not(RiskState has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
    | where (RiskState has_any("atRisk", "confirmedCompromised"))

    //This step sets the query time. this rule states that An item has to be atleast 30 minuest old, and it has to be at risk for 10 minutes//

    | where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)

    //This step summarizes all of the users at low risk//

    | summarize count() by UserPrincipalName

    //This is just a needed line break in the query. Please note it will fail if you remove this step//

    | take 1
    };






//This line Creates the first leg of the query which identifies medium risk users//

let dataFiltrationStep2 = view() {

    //Selecting the AADRiskyUsers table, as that is where user risk level is stored//

    AADRiskyUsers

    //This step filters out everything that is not medium risk//

    | where not(RiskLevel has_any("low", "high", "none", "unknownFutureValue"))
    | where (RiskLevel has_any("medium"))

    //This step filters out all of the items that have been remediated already//

    | where not(RiskState has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
    | where (RiskState has_any("atRisk", "confirmedCompromised"))

    //This step sets the query time. this rule states that An item has to be atleast 30 minuest old, and it has to be at risk for 10 minutes//

    | where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)

    //This step summarizes all of the users at low risk//

    | summarize count() by UserPrincipalName

    //This is just a needed line break in the query. Please note it will fail if you remove this step//

    | take 1
};





//This line Creates the first leg of the query which identifies high risk users//

let dataFiltrationStep3 = view() {

    //Selecting the AADRiskyUsers table, as that is where user risk level is stored//

    AADRiskyUsers

    //This step filters out everything that is not high risk//

    | where not(RiskLevel has_any("low", "medium", "none", "unknownFutureValue"))
    | where (RiskLevel has_any("high"))

    //This step filters out all of the items that have been remediated already//

    | where not(RiskState has_any("none", "confirmedSafe", "remediated", "dismissed", "unknownFutureValue"))
    | where (RiskState has_any("atRisk", "confirmedCompromised"))

    //This step sets the query time. this rule states that An item has to be atleast 30 minuest old, and it has to be at risk for 10 minutes//

    | where TimeGenerated > ago(30m) and TimeGenerated < ago(10m)

    //This step summarizes all of the users at low risk//

    | summarize count() by UserPrincipalName

    //This is just a needed line break in the query. Please note it will fail if you remove this step//

    | take 1
};






//This step searched through the logs to identify all conditional access failures//

let dataFiltrationStep4 = view() {

    //Here we are selecting the Sign in log table. this is where all of the conditional access policy triggers are located//

    SigninLogs

    //This line expands the table so that we can dive deeper into the conditional access failures//

    | mvexpand ConditionalAccessPolicies

    //This filters out all of the non failures in the table//
    
    | where not(tostring(ConditionalAccessStatus) has_any("success", "notApplied"))
    | where tostring(ConditionalAccessStatus) has_any("failure")
    | where not(tostring(ConditionalAccessPolicies) has_any("success", "notApplied", "reportOnlyNotApplied"))
    | where tostring(ConditionalAccessPolicies) has_any("failure")
    | where not(Status has_any("successfully", "completed", "satisfied"))
    | where not(AuthenticationDetails has_any("satisfied", "succeeded"))

    //This step sets the query time. this rule states that An item has to be atleast 30 minuest old, and it has to be at risk for 10 minutes//

    | where CreatedDateTime > ago(30m) and CreatedDateTime < ago(10m)

    //This step outupts all of the the Conditional Access failurs//

    | project CreatedDateTime, UserPrincipalName, UserType, ResourceDisplayName, AuthenticationRequirement, AuthenticationDetails, IPAddress, DeviceDetail, LocationDetails, Location, Status, ConditionalAccessPolicies, ConditionalAccessStatus, RiskDetail
};





//This Joins all of the Steps together into one query//

union withsource = "allOutput" dataFiltrationStep1, dataFiltrationStep2, dataFiltrationStep3, dataFiltrationStep4
