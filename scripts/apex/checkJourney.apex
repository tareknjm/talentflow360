// Technical smoke on synthetic data. This does not prove a human clicked the screen.
TalentProfile__c profile=[SELECT Id,Status__c FROM TalentProfile__c WHERE CandidateCode__c='TF-DEMO-001' AND DemoBatch__c='TF360-DEMO-V1' WITH USER_MODE];
System.assertEquals('InterviewScheduled',profile.Status__c,'Run the concurrency fixture first, or use the normal reservation action.');
TF_HiringService.Request hiring=new TF_HiringService.Request();hiring.profileId=profile.Id;hiring.startDate=Date.today().addDays(7);hiring.confirmed=true;
TF_HiringService.Result hired=TF_HiringService.approve(new List<TF_HiringService.Request>{hiring})[0];
System.assertEquals('SUCCESS',hired.resultCode,hired.message);
System.assertEquals(6,[SELECT COUNT() FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id WITH USER_MODE]);
Date shifted=Date.today().addDays(8);
update new TalentProfile__c(Id=profile.Id,StartDate__c=shifted,Role__c='QAEngineer');
JourneyStep__c replan=[SELECT DueDate__c,MessagePreview__c FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c='Day60' WITH USER_MODE];
System.assertEquals(shifted.addDays(60),replan.DueDate__c);System.assert(replan.MessagePreview__c.contains('qualité'));
for (JourneyStep__c step : [SELECT Id FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND Stage__c IN ('Day30','Day60','Day90') WITH USER_MODE]) {
    TF_SimulateJourney.Request simulation=new TF_SimulateJourney.Request();simulation.stepId=step.Id;
    System.assertEquals('SUCCESS',TF_SimulateJourney.run(new List<TF_SimulateJourney.Request>{simulation})[0].resultCode);
}
System.assertEquals(3,[SELECT COUNT() FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id AND ExecutionMode__c='Simulation' WITH USER_MODE]);
TF_SubmitPulse.Request low=new TF_SubmitPulse.Request();low.profileId=profile.Id;low.score=1;
System.assertEquals('SUCCESS',TF_SubmitPulse.run(new List<TF_SubmitPulse.Request>{low})[0].resultCode);
PulseResponse__c response=[SELECT Id,AlertTaskId__c FROM PulseResponse__c WHERE TalentProfile__c=:profile.Id WITH USER_MODE];
System.assertNotEquals(null,response.AlertTaskId__c);
TF_PulseAlert.Request replay=new TF_PulseAlert.Request();replay.responseId=response.Id;TF_PulseAlert.run(new List<TF_PulseAlert.Request>{replay});
low.score=4;System.assertEquals('SUCCESS',TF_SubmitPulse.run(new List<TF_SubmitPulse.Request>{low})[0].resultCode);
System.assertEquals(4,[SELECT COUNT() FROM Task WHERE WhatId=:profile.Id WITH USER_MODE]);
System.assertEquals(0,Limits.getEmailInvocations());
System.debug(LoggingLevel.INFO,'TF_JOURNEY_SMOKE=SUCCESS; STEPS=6; SIMULATIONS=3; ALERTS=1; NO_AGENTFORCE_OR_UI_PROOF');
