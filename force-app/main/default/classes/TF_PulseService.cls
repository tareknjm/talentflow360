// Internal alert automation; never exposed as an Agentforce action.
public without sharing class TF_PulseService {
    public static Set<Id> updatingIds { get; private set; }
    public static void alert(Set<Id> responseIds) {
        if (responseIds.isEmpty()) return;
        Map<Id,PulseResponse__c> responses=new Map<Id,PulseResponse__c>([SELECT Id,TalentProfile__c,Score__c,AlertTaskId__c,DemoBatch__c FROM PulseResponse__c WHERE Id IN :responseIds WITH SYSTEM_MODE FOR UPDATE]);
        Set<Id> profileIds=new Set<Id>();
        for (PulseResponse__c response : responses.values()) profileIds.add(response.TalentProfile__c);
        Map<Id,TalentProfile__c> profiles=new Map<Id,TalentProfile__c>([SELECT Id,OwnerId,ApprovedBy__c FROM TalentProfile__c WHERE Id IN :profileIds WITH SYSTEM_MODE]);
        List<Task> tasks=new List<Task>();
        List<PulseResponse__c> updates=new List<PulseResponse__c>();
        for (PulseResponse__c response : responses.values()) {
            if (response.Score__c>2 || response.AlertTaskId__c!=null) continue;
            TalentProfile__c profile=profiles.get(response.TalentProfile__c);
            tasks.add(new Task(WhatId=profile.Id,OwnerId=profile.ApprovedBy__c==null ? profile.OwnerId : profile.ApprovedBy__c,
                Subject='Prendre contact — alerte de satisfaction',ActivityDate=Date.today(),Status='Not Started',Priority='High',
                Description=response.DemoBatch__c==TF_DemoData.BATCH ? TF_DemoData.BATCH : 'TalentFlow — suivi confidentiel'));
            updates.add(response);
        }
        Database.insert(tasks,AccessLevel.SYSTEM_MODE);
        updatingIds=new Set<Id>();
        for (Integer index=0;index<updates.size();index++) {
            updates[index].AlertTaskId__c=String.valueOf(tasks[index].Id);
            updatingIds.add(updates[index].Id);
        }
        try { Database.update(updates,AccessLevel.SYSTEM_MODE); }
        finally { updatingIds=null; }
    }
}
