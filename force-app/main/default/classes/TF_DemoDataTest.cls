@IsTest
private class TF_DemoDataTest {
    @TestSetup static void permission() {
        User actor = new User(Alias='tfdemo', Email='demo-test@example.invalid', EmailEncodingKey='UTF-8',
            LastName='TF360 Demo Test', LanguageLocaleKey='fr', LocaleSidKey='fr_FR',
            TimeZoneSidKey='GMT', ProfileId=UserInfo.getProfileId(),
            Username='tf360-demo-' + EncodingUtil.convertToHex(Crypto.generateAesKey(128)) + '@example.invalid');
        insert actor;
        PermissionSet permission = [SELECT Id FROM PermissionSet WHERE Name='TF_DemoAdmin'];
        insert new PermissionSetAssignment(AssigneeId=actor.Id, PermissionSetId=permission.Id);
    }
    @IsTest static void seedTwiceAndResetTwicePreservesForeignData() {
        User actor = [SELECT Id FROM User WHERE Alias='tfdemo' AND LastName='TF360 Demo Test' LIMIT 1];
        System.runAs(actor) {
            TalentProfile__c foreignProfile = new TalentProfile__c(CandidateCode__c='TF-TEST-FOREIGN', Role__c='QAEngineer');
            insert foreignProfile;
            TF_DemoData.seed();
            TF_DemoData.seed();
            Assert.areEqual(6, [SELECT COUNT() FROM TalentProfile__c WHERE DemoBatch__c='TF360-DEMO-V1']);
            Assert.areEqual(6, [SELECT COUNT() FROM CandidateIdentity__c WHERE DemoBatch__c='TF360-DEMO-V1']);
            Assert.areEqual(8, [SELECT COUNT() FROM InterviewSlot__c WHERE DemoBatch__c='TF360-DEMO-V1']);
            Assert.areEqual(0, Limits.getEmailInvocations());
            TF_DemoData.reset('TF360-DEMO-V1');
            TF_DemoData.reset('TF360-DEMO-V1');
            Assert.areEqual(1, [SELECT COUNT() FROM TalentProfile__c WHERE Id=:foreignProfile.Id]);
            Assert.areEqual(6, [SELECT COUNT() FROM TalentProfile__c WHERE DemoBatch__c='TF360-DEMO-V1']);
            Assert.areEqual(8, [SELECT COUNT() FROM InterviewSlot__c WHERE DemoBatch__c='TF360-DEMO-V1']);
            Assert.areEqual(0, Limits.getEmailInvocations());
        }
    }
    @IsTest static void resetRefusesForeignDependency() {
        User actor = [SELECT Id FROM User WHERE Alias='tfdemo' AND LastName='TF360 Demo Test' LIMIT 1];
        System.runAs(actor) {
            TF_DemoData.seed();
            TalentProfile__c profile = [SELECT Id FROM TalentProfile__c WHERE DemoBatch__c='TF360-DEMO-V1' LIMIT 1];
            insert new JourneyStep__c(TalentProfile__c=profile.Id, Stage__c='Arrival', DueDate__c=Date.today(), StepKey__c='FOREIGN-STEP');
            Boolean refused = false;
            try { TF_DemoData.reset('TF360-DEMO-V1'); } catch (TF_DemoData.DemoException expected) { refused=true; }
            Assert.isTrue(refused);
            Assert.areEqual(6, [SELECT COUNT() FROM TalentProfile__c WHERE DemoBatch__c='TF360-DEMO-V1']);
        }
    }
}
