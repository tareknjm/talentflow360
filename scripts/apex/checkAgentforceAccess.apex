Id currentUserId = UserInfo.getUserId();

List<String> relevantLicenses = new List<String>();
for (PermissionSetLicenseAssign assignment : [
    SELECT PermissionSetLicense.DeveloperName
    FROM PermissionSetLicenseAssign
    WHERE AssigneeId = :currentUserId
]) {
    String licenseName = assignment.PermissionSetLicense.DeveloperName;
    if (licenseName.containsIgnoreCase('Agent') || licenseName.containsIgnoreCase('Einstein')) {
        relevantLicenses.add(licenseName);
    }
}
relevantLicenses.sort();

List<String> relevantPermissionSets = new List<String>();
for (PermissionSetAssignment assignment : [
    SELECT PermissionSet.Name
    FROM PermissionSetAssignment
    WHERE AssigneeId = :currentUserId
]) {
    String permissionSetName = assignment.PermissionSet.Name;
    if (permissionSetName.containsIgnoreCase('Agent') || permissionSetName.containsIgnoreCase('Einstein')) {
        relevantPermissionSets.add(permissionSetName);
    }
}
relevantPermissionSets.sort();

System.debug('TF_AGENT_LICENSES=' + JSON.serialize(relevantLicenses));
System.debug('TF_AGENT_PERMISSION_SETS=' + JSON.serialize(relevantPermissionSets));
