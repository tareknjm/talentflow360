// Development account only: grants the three agreed roles to the connected demo operator.
// TF_AgentAccess is not a restriction and is deliberately not assigned to this RH account.
Organization target = [SELECT OrganizationType FROM Organization WITH USER_MODE LIMIT 1];
System.assertEquals('Developer Edition', target.OrganizationType, 'Development org required.');
Set<String> names = new Set<String>{'TF_Recruiter','TF_HiringApprover','TF_DemoAdmin'};
Set<Id> assigned = new Set<Id>();
Id actor = UserInfo.getUserId();
for (PermissionSetAssignment existing : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=:actor WITH USER_MODE]) assigned.add(existing.PermissionSetId);
List<PermissionSetAssignment> missing = new List<PermissionSetAssignment>();
for (PermissionSet permission : [SELECT Id FROM PermissionSet WHERE Name IN :names WITH USER_MODE]) {
    if (!assigned.contains(permission.Id)) missing.add(new PermissionSetAssignment(AssigneeId=actor, PermissionSetId=permission.Id));
}
Database.insert(missing, AccessLevel.USER_MODE);
System.debug(LoggingLevel.INFO, 'TF_DEMO_PERMISSIONS=SUCCESS');
