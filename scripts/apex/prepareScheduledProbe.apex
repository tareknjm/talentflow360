// Makes ONE pending synthetic Day1 step eligible. This mutation is not the proof:
// the proof requires the later scheduled Flow, CronTrigger and stored execution.
TalentProfile__c profile=[SELECT Id FROM TalentProfile__c WHERE CandidateCode__c='TF-DEMO-001' AND DemoBatch__c='TF360-DEMO-V1' AND Status__c='Hired' WITH USER_MODE];
JourneyStep__c step=[SELECT Id,DueDate__c FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c='Day1' AND DemoBatch__c='TF360-DEMO-V1' AND Status__c='Pending' WITH USER_MODE];
step.DueDate__c=Date.today().addDays(-1);
update step;
System.debug(LoggingLevel.INFO,'TF_SCHEDULE_FIXTURE=READY');
