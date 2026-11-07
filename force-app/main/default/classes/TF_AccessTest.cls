@IsTest
private class TF_AccessTest {
    @TestSetup static void users() {
        Profile minimal = [SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce'];
        List<User> actors = new List<User>();
        for (String alias : new List<String>{'tfagent','tfrh','tfrec'}) actors.add(new User(
            Alias=alias, Email=alias+'@example.invalid', EmailEncodingKey='UTF-8',
            LastName='TF360 Access Test', LanguageLocaleKey='fr', LocaleSidKey='fr_FR',
            TimeZoneSidKey='GMT', ProfileId=minimal.Id,
            Username='tf360-' + alias + '-' + EncodingUtil.convertToHex(Crypto.generateAesKey(128)) + '@example.invalid'
        ));
        insert actors;
        Map<String,Id> permissions = new Map<String,Id>();
        for (PermissionSet permission : [SELECT Id, Name FROM PermissionSet WHERE Name IN ('TF_Recruiter','TF_AgentAccess','TF_HiringApprover')]) permissions.put(permission.Name,permission.Id);
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (User actor : actors) {
            assignments.add(new PermissionSetAssignment(AssigneeId=actor.Id, PermissionSetId=permissions.get(actor.Alias=='tfagent' ? 'TF_AgentAccess' : 'TF_Recruiter')));
            if (actor.Alias=='tfrh') assignments.add(new PermissionSetAssignment(AssigneeId=actor.Id, PermissionSetId=permissions.get('TF_HiringApprover')));
        }
        insert assignments;
    }
    @IsTest static void agentCannotReadPrivateFields() {
        User actor = [SELECT Id FROM User WHERE Alias='tfagent' AND LastName='TF360 Access Test' LIMIT 1];
        System.runAs(actor) {
            Assert.isFalse(Schema.sObjectType.CandidateIdentity__c.isAccessible());
            Assert.isFalse(Schema.sObjectType.PulseResponse__c.isAccessible());
            Assert.isFalse(Schema.sObjectType.TalentProfile__c.fields.HumanApproved__c.isAccessible());
            Assert.isFalse(Schema.sObjectType.TalentProfile__c.fields.ApprovedBy__c.isAccessible());
            Assert.isFalse(Schema.sObjectType.TalentProfile__c.fields.ApprovedAt__c.isAccessible());
            Assert.isFalse(Schema.sObjectType.JourneyStep__c.fields.MessagePreview__c.isAccessible());
            Assert.isTrue(Schema.sObjectType.TalentProfile__c.fields.CandidateCode__c.isAccessible());
        }
    }
    @IsTest static void recruiterCannotReadForeignProfileOrApprove() {
        TalentProfile__c profile = new TalentProfile__c(CandidateCode__c='TF-TEST-PRIVATE', Role__c='QAEngineer');
        Database.insert(profile, AccessLevel.SYSTEM_MODE);
        User actor = [SELECT Id FROM User WHERE Alias='tfrec' AND LastName='TF360 Access Test' LIMIT 1];
        System.runAs(actor) {
            Assert.areEqual(0, [SELECT COUNT() FROM TalentProfile__c WHERE Id=:profile.Id WITH USER_MODE]);
            TF_HiringService.Request request = new TF_HiringService.Request();
            request.profileId=profile.Id; request.startDate=Date.today(); request.confirmed=true;
            Assert.areEqual('NOT_AVAILABLE_OR_NOT_ACCESSIBLE', TF_HiringService.approve(new List<TF_HiringService.Request>{request})[0].resultCode);
            Assert.isFalse(Schema.sObjectType.TalentProfile__c.fields.HumanApproved__c.isUpdateable());
        }
    }
    @IsTest static void minimumAccessApproverCanUseOnlyAuthorizedPath() {
        User actor = [SELECT Id FROM User WHERE Alias='tfrh' AND LastName='TF360 Access Test' LIMIT 1];
        TalentProfile__c profile = new TalentProfile__c(CandidateCode__c='TF-TEST-RH', Role__c='QAEngineer', Status__c='InterviewScheduled', OwnerId=actor.Id);
        Database.insert(profile, AccessLevel.SYSTEM_MODE);
        System.runAs(actor) {
            TF_HiringService.Request request = new TF_HiringService.Request();
            request.profileId=profile.Id; request.startDate=Date.today().addDays(7); request.confirmed=true;
            TF_HiringService.Result result = TF_HiringService.approve(new List<TF_HiringService.Request>{request})[0];
            Assert.areEqual('SUCCESS', result.resultCode, result.message);
            TalentProfile__c approved = [SELECT ApprovedBy__c FROM TalentProfile__c WHERE Id=:profile.Id WITH USER_MODE];
            Assert.areEqual(actor.Id, approved.ApprovedBy__c);
        }
    }
}
