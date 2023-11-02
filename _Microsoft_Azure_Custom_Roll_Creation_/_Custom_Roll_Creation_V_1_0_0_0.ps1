#Import module


Import-Module 'Microsoft.Graph.Identity.Governance'


#Create custom role deffinition For Exhange Admin


$params = @{
	description = "Allows the administration of european users in Exchange"
	displayName = "BioTech: Euro Exchange Admin"
	rolePermissions = @(
		@{
			allowedResourceActions = @(
				RoleManagement.ReadWrite.Directory
			)
		}
	)
	isEnabled = $true
}

New-MgRoleManagementDirectoryRoleDefinition -BodyParameter $params


#Create custom role deffinition for SharePoint Admin


$params = @{
	description = "Update basic properties of application registrations"
	displayName = "Application Registration Support Administrator"
	rolePermissions = @(
		@{
			allowedResourceActions = @(
				RoleManagement.ReadWrite.Directory
				#Azure AD: Permission type Delegated (work or school account)
				EntitlementManagement.ReadWrite.All
				#Entitlement Manager Provider: Delegated(work or school account)
			)
		}
	)
	isEnabled = $true
}

New-MgRoleManagementDirectoryRoleDefinition -BodyParameter $params


#Create custom Role deffinition for Teams Admin


$params = @{
	description = "Update basic properties of application registrations"
	displayName = "Application Registration Support Administrator"
	rolePermissions = @(
		@{
			allowedResourceActions = @(
				RoleManagement.ReadWrite.Directory
			)
		}
	)
	isEnabled = $true
}

New-MgRoleManagementDirectoryRoleDefinition -BodyParameter $params


#Create custom deffinition for Helpdesk Admin


$params = @{
	description = "Update basic properties of application registrations"
	displayName = "Application Registration Support Administrator"
	rolePermissions = @(
		@{
			allowedResourceActions = @(
				RoleManagement.ReadWrite.Directory
			)
		}
	)
	isEnabled = $true
}

New-MgRoleManagementDirectoryRoleDefinition -BodyParameter $params


#Create Custom Role


$displayName = "BioTech: Euro Administration"
$description = "Can Manage Exchange, SharePoint, Teams, and Helpdesk for European users."
$templateId = (New-Guid).Guid
 
# Set of permissions to grant
$allowedResourceAction =
@(
    "microsoft.directory/applications/basic/update",
    "microsoft.directory/applications/credentials/update"
)
$rolePermissions = @{'allowedResourceActions'= $allowedResourceAction}
 
# Create new custom admin role
$customAdmin = New-AzureADMSRoleDefinition -RolePermissions $rolePermissions -DisplayName $displayName -Description $description -TemplateId $templateId -IsEnabled $true


#Assign Custom Role


# Get the user and role definition you want to link
$user = Get-AzureADUser -Filter "userPrincipalName eq 'cburl@f128.info'"
$roleDefinition = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Application Support Administrator'"

# Get app registration and construct resource scope for assignment.
$appRegistration = Get-AzureADApplication -Filter "displayName eq 'f/128 Filter Photos'"
$resourceScope = '/' + $appRegistration.objectId

# Create a scoped role assignment
$roleAssignment = New-AzureADMSRoleAssignment -DirectoryScopeId $resourceScope -RoleDefinitionId $roleDefinition.Id -PrincipalId $user.objectId