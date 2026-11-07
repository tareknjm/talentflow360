@IsTest
private class TF_ModelTest {
    @TestSetup
    static void permissions() {
        User actor = new User(Alias='tfmodel', Email='model-test@example.invalid', EmailEncodingKey='UTF-8',
            LastName='TF360 Model Test', LanguageLocaleKey='fr', LocaleSidKey='fr_FR', TimeZoneSidKey='GMT',
            ProfileId=UserInfo.getProfileId(), Username='tf360-model-' + EncodingUtil.convertToHex(Crypto.generateAesKey(128)) + '@example.invalid');
        insert actor;
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSet permission : [SELECT Id FROM PermissionSet WHERE Name IN ('TF_HiringApprover', 'TF_Recruiter')]) {
            assignments.add(new PermissionSetAssignment(AssigneeId=actor.Id, PermissionSetId=permission.Id));
        }
        insert assignments;
    }

    private static TalentProfile__c profile(String code) {
        TalentProfile__c profile = new TalentProfile__c(CandidateCode__c=code, Role__c='JavaBackendDeveloper', Status__c='InterviewScheduled');
        insert profile;
        return profile;
    }

    @IsTest
    static void rejectsInvalidData() {
        TalentProfile__c profile = profile('TF-TEST-001');
        Database.SaveResult result = Database.insert(new InterviewSlot__c(
            Start__c=System.now(), End__c=System.now().addMinutes(-30), Recruiter__c=UserInfo.getUserId()
        ), false);
        Assert.isFalse(result.isSuccess(), 'A slot must end after its start.');
        for (Decimal score : new List<Decimal>{0, 6, 1.5}) {
            result = Database.insert(new PulseResponse__c(TalentProfile__c=profile.Id, Score__c=score, SubmittedAt__c=System.now()), false);
            Assert.isFalse(result.isSuccess(), 'Reject invalid score ' + score);
        }
        insert new PulseResponse__c(TalentProfile__c=profile.Id, Score__c=4, SubmittedAt__c=System.now());
        result = Database.insert(new TalentProfile__c(CandidateCode__c='TF-TEST-001', Role__c='QAEngineer'), false);
        Assert.isFalse(result.isSuccess(), 'Candidate code must be unique.');
        result = Database.insert(new InterviewSlot__c(Start__c=System.now().addHours(1), End__c=System.now().addHours(2), Recruiter__c=UserInfo.getUserId(), Status__c='Reserved'), false);
        Assert.isFalse(result.isSuccess(), 'A reservation requires a profile and a key.');
    }

    @IsTest
    static void blocksForgedApprovalEvenForApprover() {
        TalentProfile__c profile = profile('TF-TEST-002');
        profile.Status__c = 'Hired';
        profile.HumanApproved__c = true;
        profile.ApprovedBy__c = UserInfo.getUserId();
        profile.ApprovedAt__c = System.now();
        profile.StartDate__c = Date.today().addDays(7);
        Database.SaveResult result = Database.update(profile, false);
        Assert.isFalse(result.isSuccess(), 'Even an RH permission must not bypass the service gate.');
        Assert.areEqual('InterviewScheduled', [SELECT Status__c FROM TalentProfile__c WHERE Id=:profile.Id].Status__c);
        result = Database.insert(new TalentProfile__c(CandidateCode__c='TF-TEST-FORGED', Role__c='QAEngineer', HumanApproved__c=true), false);
        Assert.isFalse(result.isSuccess(), 'Insert cannot forge approval either.');
    }

    @IsTest
    static void rejectsBulkAndMissingRequestsWithoutMutation() {
        Assert.areEqual(0, TF_HiringService.approve(null).size());
        List<TF_HiringService.Result> results = TF_HiringService.approve(new List<TF_HiringService.Request>{null,null});
        Assert.areEqual(2, results.size());
        for (TF_HiringService.Result result : results) Assert.areEqual('INVALID_INPUT', result.resultCode);
        Assert.isNull(TF_HiringService.approvingId);
    }

    @IsTest
    static void approvalRequiresConfirmationAndValidTransition() {
        User actor = [SELECT Id FROM User WHERE Alias='tfmodel' AND LastName='TF360 Model Test' LIMIT 1];
        System.runAs(actor) {
        TalentProfile__c profile = profile('TF-TEST-003');
        TF_HiringService.Request request = new TF_HiringService.Request();
        request.profileId = profile.Id;
        request.startDate = Date.today().addDays(7);
        request.confirmed = false;
        Assert.areEqual('INVALID_INPUT', TF_HiringService.approve(new List<TF_HiringService.Request>{request})[0].resultCode);
        request.confirmed = true;
        Test.startTest();
        List<TF_HiringService.Result> results = TF_HiringService.approve(new List<TF_HiringService.Request>{request});
        Test.stopTest();
        Assert.areEqual('SUCCESS', results[0].resultCode, results[0].message);
        profile = [SELECT Status__c, HumanApproved__c, ApprovedBy__c, ApprovedAt__c, OnboardingCycle__c FROM TalentProfile__c WHERE Id=:profile.Id];
        Assert.areEqual('Hired', profile.Status__c);
        Assert.isTrue(profile.HumanApproved__c);
        Assert.areEqual(UserInfo.getUserId(), profile.ApprovedBy__c);
        Assert.isNotNull(profile.ApprovedAt__c);
        Assert.isNotNull(profile.OnboardingCycle__c);
        Assert.isNull(TF_HiringService.approvingId, 'Approval gate must close.');
        Assert.areEqual('INVALID_INPUT', TF_HiringService.approve(new List<TF_HiringService.Request>{request})[0].resultCode, 'Repeated approval must not create a new cycle.');
        }
    }
}
