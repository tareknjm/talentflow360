public with sharing class TF_DemoData {
    public static final String BATCH = 'TF360-DEMO-V1';

    private static void authorize() {
        if (!FeatureManagement.checkPermission('TF_DemoTools')) throw new DemoException('Démonstration non autorisée.');
        Organization org = [SELECT OrganizationType FROM Organization WITH SYSTEM_MODE LIMIT 1];
        if (org.OrganizationType != 'Developer Edition') throw new DemoException('Outil limité à une Developer Edition.');
    }

    public static void seed() {
        authorize();
        Set<String> codes = new Set<String>();
        for (Integer index=1; index<=6; index++) codes.add('TF-DEMO-00' + index);
        Map<String, TalentProfile__c> existing = new Map<String, TalentProfile__c>();
        for (TalentProfile__c profile : [SELECT Id, CandidateCode__c, DemoBatch__c FROM TalentProfile__c WHERE CandidateCode__c IN :codes WITH SYSTEM_MODE]) {
            if (profile.DemoBatch__c != BATCH) throw new DemoException('Un code de démonstration est déjà utilisé hors du lot.');
            existing.put(profile.CandidateCode__c, profile);
        }
        Map<String, CandidateIdentity__c> identities = new Map<String, CandidateIdentity__c>();
        for (CandidateIdentity__c identity : [SELECT Id, CandidateCode__c, DemoBatch__c FROM CandidateIdentity__c WHERE CandidateCode__c IN :codes WITH SYSTEM_MODE]) {
            if (identity.DemoBatch__c != BATCH) throw new DemoException('Un code identité existe hors du lot.');
            identities.put(identity.CandidateCode__c, identity);
        }
        List<TalentProfile__c> profiles = new List<TalentProfile__c>();
        List<CandidateIdentity__c> missingIdentities = new List<CandidateIdentity__c>();
        for (Integer index=1; index<=6; index++) {
            String code = 'TF-DEMO-00' + index;
            if (!existing.containsKey(code)) profiles.add(new TalentProfile__c(
                CandidateCode__c=code, Role__c=Math.mod(index,2)==0 ? 'QAEngineer' : 'JavaBackendDeveloper',
                JavaEvidence__c=index==6 ? 'NotProvided' : 'DeclaredProject',
                SpringEvidence__c=index==6 ? 'NotProvided' : 'RecordedAssessment',
                Availability__c=index==6 ? null : Date.today().addDays(7),
                Status__c='ReadyForReview', DemoBatch__c=BATCH
            ));
            if (!identities.containsKey(code)) missingIdentities.add(new CandidateIdentity__c(
                CandidateCode__c=code, FullName__c='Personne fictive ' + index,
                Email__c='talent' + index + '@example.invalid', DemoBatch__c=BATCH
            ));
        }
        Database.insert(profiles, AccessLevel.SYSTEM_MODE);
        Database.insert(missingIdentities, AccessLevel.SYSTEM_MODE);
        existing.clear();
        for (TalentProfile__c profile : [SELECT Id, CandidateCode__c FROM TalentProfile__c WHERE DemoBatch__c=:BATCH WITH SYSTEM_MODE]) existing.put(profile.CandidateCode__c, profile);
        Set<String> keys = new Set<String>();
        for (Integer index=1; index<=8; index++) keys.add(BATCH + '-SLOT-' + index);
        Set<String> present = new Set<String>();
        for (InterviewSlot__c slot : [SELECT DemoKey__c, DemoBatch__c FROM InterviewSlot__c WHERE DemoKey__c IN :keys WITH SYSTEM_MODE]) {
            if (slot.DemoBatch__c != BATCH) throw new DemoException('Un créneau existe hors du lot.');
            present.add(slot.DemoKey__c);
        }
        List<InterviewSlot__c> slots = new List<InterviewSlot__c>();
        for (Integer index=1; index<=8; index++) {
            String key = BATCH + '-SLOT-' + index;
            if (present.contains(key)) continue;
            Datetime start = Datetime.newInstance(Date.today().addDays(index), Time.newInstance(10,0,0,0));
            slots.add(new InterviewSlot__c(
                Start__c=start, End__c=start.addMinutes(45), Recruiter__c=UserInfo.getUserId(),
                Status__c=index==8 ? 'Reserved' : 'Available',
                TalentProfile__c=index==8 ? existing.get('TF-DEMO-006').Id : null,
                ReservationKey__c=index==8 ? 'TF-DEMO-OCCUPIED' : null,
                DemoKey__c=key, DemoBatch__c=BATCH
            ));
        }
        Database.insert(slots, AccessLevel.SYSTEM_MODE);
    }

    public static void reset(String confirmation) {
        authorize();
        if (confirmation != BATCH) throw new DemoException('Confirmer le nom exact du lot synthétique.');
        List<TalentProfile__c> profiles = [SELECT Id FROM TalentProfile__c WHERE DemoBatch__c=:BATCH WITH SYSTEM_MODE];
        Set<Id> ids = new Map<Id,TalentProfile__c>(profiles).keySet();
        // Never cascade into records which have not themselves been marked as demo data.
        Integer unmarked = [SELECT COUNT() FROM InterviewSlot__c WHERE TalentProfile__c IN :ids AND (DemoBatch__c = null OR DemoBatch__c != :BATCH) WITH SYSTEM_MODE];
        unmarked += [SELECT COUNT() FROM JourneyStep__c WHERE TalentProfile__c IN :ids AND (DemoBatch__c = null OR DemoBatch__c != :BATCH) WITH SYSTEM_MODE];
        unmarked += [SELECT COUNT() FROM PulseResponse__c WHERE TalentProfile__c IN :ids AND (DemoBatch__c = null OR DemoBatch__c != :BATCH) WITH SYSTEM_MODE];
        if (unmarked > 0) throw new DemoException('Références hors lot présentes : reset refusé.');
        List<Task> tasks = [SELECT Id, Description FROM Task WHERE WhatId IN :ids WITH SYSTEM_MODE];
        for (Task task : tasks) if (task.Description != BATCH) throw new DemoException('Tâche hors lot présente : reset refusé.');
        Database.delete(tasks, AccessLevel.SYSTEM_MODE);
        Database.delete([SELECT Id FROM PulseResponse__c WHERE DemoBatch__c=:BATCH WITH SYSTEM_MODE], AccessLevel.SYSTEM_MODE);
        Database.delete([SELECT Id FROM JourneyStep__c WHERE DemoBatch__c=:BATCH WITH SYSTEM_MODE], AccessLevel.SYSTEM_MODE);
        Database.delete([SELECT Id FROM InterviewSlot__c WHERE DemoBatch__c=:BATCH WITH SYSTEM_MODE], AccessLevel.SYSTEM_MODE);
        Database.delete(profiles, AccessLevel.SYSTEM_MODE);
        Database.delete([SELECT Id FROM CandidateIdentity__c WHERE DemoBatch__c=:BATCH WITH SYSTEM_MODE], AccessLevel.SYSTEM_MODE);
        Database.delete([SELECT Id FROM AgentAudit__c WHERE DemoBatch__c=:BATCH WITH SYSTEM_MODE], AccessLevel.SYSTEM_MODE);
        seed();
    }

    public class DemoException extends Exception {}
}
