@IsTest
private class TF_JourneyTest {
    @TestSetup static void user() {
        Profile minimal=[SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce'];
        User actor=new User(Alias='tfjour',Email='journey-test@example.invalid',EmailEncodingKey='UTF-8',LastName='TF360 Journey Test',LanguageLocaleKey='fr',LocaleSidKey='fr_FR',TimeZoneSidKey='GMT',ProfileId=minimal.Id,Username='tf360-journey-'+EncodingUtil.convertToHex(Crypto.generateAesKey(128))+'@example.invalid');
        insert actor;
        List<PermissionSetAssignment> assignments=new List<PermissionSetAssignment>();
        for (PermissionSet permission : [SELECT Id FROM PermissionSet WHERE Name IN ('TF_Recruiter','TF_HiringApprover','TF_DemoAdmin')]) assignments.add(new PermissionSetAssignment(AssigneeId=actor.Id,PermissionSetId=permission.Id));
        insert assignments;
    }
    private static User actor() { return [SELECT Id FROM User WHERE Alias='tfjour' AND LastName='TF360 Journey Test' LIMIT 1]; }
    private static TalentProfile__c approve(User actor,Date arrival) {
        TalentProfile__c profile=new TalentProfile__c(OwnerId=actor.Id,CandidateCode__c='TF-TEST-JOURNEY',Role__c='JavaBackendDeveloper',Status__c='InterviewScheduled',DemoBatch__c=TF_DemoData.BATCH);
        Database.insert(profile,AccessLevel.SYSTEM_MODE);
        System.runAs(actor) {
            TF_HiringService.Request request=new TF_HiringService.Request();request.profileId=profile.Id;request.startDate=arrival;request.confirmed=true;
            TF_HiringService.Result result=TF_HiringService.approve(new List<TF_HiringService.Request>{request})[0];
            Assert.areEqual('SUCCESS',result.resultCode,result.message);
        }
        return profile;
    }
    @IsTest static void realRecordFlowCreatesSixStepsAndReplansOnlyOpenSteps() {
        User actor=actor();Date arrival=Date.today().addDays(10);TalentProfile__c profile=approve(actor,arrival);
        Assert.areEqual(6,[SELECT COUNT() FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id]);
        JourneyStep__c completed=[SELECT Id,DueDate__c,MessagePreview__c FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c='Day30'];
        completed.Status__c='Completed';update completed;
        Database.update(new TalentProfile__c(Id=profile.Id,StartDate__c=arrival.addDays(5),Role__c='QAEngineer'),AccessLevel.SYSTEM_MODE);
        TF_JourneySync.Request sync=new TF_JourneySync.Request();sync.profileId=profile.Id;
        TF_JourneySync.run(new List<TF_JourneySync.Request>{sync,sync});
        Assert.areEqual(6,[SELECT COUNT() FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id]);
        JourneyStep__c preserved=[SELECT DueDate__c,MessagePreview__c FROM JourneyStep__c WHERE Id=:completed.Id];
        Assert.areEqual(completed.DueDate__c,preserved.DueDate__c);Assert.areEqual(completed.MessagePreview__c,preserved.MessagePreview__c);
        JourneyStep__c open=[SELECT DueDate__c,MessagePreview__c FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c='Day60'];
        Assert.areEqual(arrival.addDays(65),open.DueDate__c);Assert.isTrue(open.MessagePreview__c.contains('qualité'));
    }
    @IsTest static void executionIsAtomicRepeatableAndKeepsPreparedStatus() {
        User actor=actor();TalentProfile__c profile=approve(actor,Date.today());
        JourneyStep__c arrival=[SELECT Id FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c='Arrival'];
        TF_ExecuteJourneyStep.Request request=new TF_ExecuteJourneyStep.Request();request.stepId=arrival.Id;
        Assert.areEqual('SUCCESS',TF_ExecuteJourneyStep.run(new List<TF_ExecuteJourneyStep.Request>{request})[0].resultCode);
        Assert.areEqual('ALREADY_COMPLETED',TF_ExecuteJourneyStep.run(new List<TF_ExecuteJourneyStep.Request>{request})[0].resultCode);
        Assert.areEqual(2,[SELECT COUNT() FROM Task WHERE WhatId=:profile.Id]);
        JourneyStep__c executed=[SELECT Status__c,DispatchStatus__c,ExecutedAt__c,ExecutionMode__c,TaskIds__c FROM JourneyStep__c WHERE Id=:arrival.Id];
        Assert.areEqual('Completed',executed.Status__c);Assert.areEqual('Prepared',executed.DispatchStatus__c);
        Assert.areEqual('Scheduled',executed.ExecutionMode__c);Assert.isNotNull(executed.ExecutedAt__c);Assert.areEqual(2,executed.TaskIds__c.split(',').size());
        request.stepId=[SELECT Id FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c='Day90'].Id;
        Assert.areEqual('INVALID_INPUT',TF_ExecuteJourneyStep.run(new List<TF_ExecuteJourneyStep.Request>{request})[0].resultCode);
        Assert.areEqual(0,Limits.getEmailInvocations());
    }
    @IsTest static void simulationIsExplicitAndRestrictedToSyntheticFollowup() {
        User actor=actor();TalentProfile__c profile=approve(actor,Date.today().addDays(10));
        JourneyStep__c step=[SELECT Id FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c='Day60'];
        TF_SimulateJourney.Request request=new TF_SimulateJourney.Request();request.stepId=step.Id;
        System.runAs(actor) { Assert.areEqual('SUCCESS',TF_SimulateJourney.run(new List<TF_SimulateJourney.Request>{request})[0].resultCode); }
        Assert.areEqual('Simulation',[SELECT ExecutionMode__c FROM JourneyStep__c WHERE Id=:step.Id].ExecutionMode__c);
        Task task=[SELECT Subject FROM Task WHERE WhatId=:profile.Id LIMIT 1];Assert.isTrue(task.Subject.startsWith('Simulation J+60'));
        JourneyStep__c early=[SELECT Id FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c='PreArrival'];request.stepId=early.Id;
        System.runAs(actor) { Assert.areEqual('INVALID_INPUT',TF_SimulateJourney.run(new List<TF_SimulateJourney.Request>{request})[0].resultCode); }
    }
    @IsTest static void pulseCreatesOnlyOneAlertPerLowResponse() {
        User actor=actor();TalentProfile__c profile=approve(actor,Date.today());
        TF_SubmitPulse.Request request=new TF_SubmitPulse.Request();request.profileId=profile.Id;request.score=1;
        System.runAs(actor) { Assert.areEqual('SUCCESS',TF_SubmitPulse.run(new List<TF_SubmitPulse.Request>{request})[0].resultCode); }
        PulseResponse__c response=[SELECT Id,AlertTaskId__c,SubmittedAt__c FROM PulseResponse__c WHERE TalentProfile__c=:profile.Id];
        Assert.isNotNull(response.AlertTaskId__c);Assert.isNotNull(response.SubmittedAt__c);
        TF_PulseAlert.Request replay=new TF_PulseAlert.Request();replay.responseId=response.Id;
        TF_PulseAlert.run(new List<TF_PulseAlert.Request>{replay,replay});
        Assert.areEqual(1,[SELECT COUNT() FROM Task WHERE WhatId=:profile.Id]);
        request.score=4;
        System.runAs(actor) { Assert.areEqual('SUCCESS',TF_SubmitPulse.run(new List<TF_SubmitPulse.Request>{request})[0].resultCode); }
        Assert.areEqual(1,[SELECT COUNT() FROM Task WHERE WhatId=:profile.Id]);
        for (Decimal score : new List<Decimal>{0,6,1.5}) {request.score=score;Assert.areEqual('INVALID_INPUT',TF_SubmitPulse.run(new List<TF_SubmitPulse.Request>{request})[0].resultCode);}
        response.AlertTaskId__c=null;
        Assert.isFalse(Database.update(response,false).isSuccess(),'The alert marker cannot be forged or cleared.');
        response=[SELECT Id,Score__c FROM PulseResponse__c WHERE Id=:response.Id];response.Score__c=4;
        Assert.isFalse(Database.update(response,false).isSuccess(),'A recorded answer is immutable.');
    }
}
