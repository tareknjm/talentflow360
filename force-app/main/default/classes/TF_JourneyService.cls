// Internal automation service, never an Agentforce tool. Deliberate system-mode
// writes are limited to journeys/tasks for profiles already approved by the RH gate.
public without sharing class TF_JourneyService {
    private static final List<String> STAGES=new List<String>{'PreArrival','Arrival','Day1','Day30','Day60','Day90'};
    private static final List<Integer> OFFSETS=new List<Integer>{-7,0,1,30,60,90};

    public static void sync(Set<Id> profileIds) {
        if (profileIds.isEmpty()) return;
        if (profileIds.size()>200) throw new JourneyException('Lot trop grand.');
        Map<Id,TalentProfile__c> profiles=new Map<Id,TalentProfile__c>([
            SELECT Id, OwnerId, Status__c, HumanApproved__c, ApprovedBy__c, ApprovedAt__c, StartDate__c, OnboardingCycle__c, Role__c, DemoBatch__c
            FROM TalentProfile__c WHERE Id IN :profileIds WITH SYSTEM_MODE FOR UPDATE
        ]);
        Map<String,JourneyStep__c> existing=new Map<String,JourneyStep__c>();
        for (JourneyStep__c step : [SELECT Id, StepKey__c, Status__c FROM JourneyStep__c WHERE TalentProfile__c IN :profileIds WITH SYSTEM_MODE]) existing.put(step.StepKey__c,step);
        List<JourneyStep__c> changes=new List<JourneyStep__c>();
        for (TalentProfile__c profile : profiles.values()) {
            if (profile.Status__c!='Hired' || !profile.HumanApproved__c || profile.ApprovedBy__c==null || profile.ApprovedAt__c==null || profile.StartDate__c==null || String.isBlank(profile.OnboardingCycle__c)) continue;
            for (Integer index=0;index<STAGES.size();index++) {
                String key=String.valueOf(profile.Id)+'|'+profile.OnboardingCycle__c+'|'+STAGES[index];
                JourneyStep__c old=existing.get(key);
                if (old!=null && old.Status__c!='Pending' && old.Status__c!='Failed') continue;
                changes.add(new JourneyStep__c(
                    Id=old==null ? null : old.Id, OwnerId=profile.OwnerId,
                    TalentProfile__c=profile.Id, Stage__c=STAGES[index], StepKey__c=key,
                    DueDate__c=profile.StartDate__c.addDays(OFFSETS[index]), Status__c='Pending',
                    DispatchStatus__c='Prepared', AssignedTo__c=profile.ApprovedBy__c,
                    MessagePreview__c=content(STAGES[index],profile.Role__c), DemoBatch__c=profile.DemoBatch__c
                ));
            }
        }
        Database.upsert(changes, JourneyStep__c.Fields.StepKey__c, true, AccessLevel.SYSTEM_MODE);
    }

    private static String content(String stage,String role) {
        String specialty=role=='QAEngineer' ? 'qualité logicielle et stratégie de tests' : 'développement Java et Spring';
        Map<String,String> texts=new Map<String,String>{
            'PreArrival'=>'Préparer le guide et la checklist de bienvenue : ',
            'Arrival'=>'Préparer le matériel et organiser l’accueil avec le référent : ',
            'Day1'=>'Vérifier la checklist d’arrivée et les formations : ',
            'Day30'=>'Préparer le premier bilan et le point de satisfaction : ',
            'Day60'=>'Faire le point sur la progression et les besoins de formation : ',
            'Day90'=>'Préparer le bilan RH d’intégration, sans décision automatique sur l’emploi : '
        };
        return texts.get(stage)+specialty+'.';
    }

    public static List<TF_ActionResult> execute(List<Id> stepIds,Boolean simulate) {
        List<TF_ActionResult> results=new List<TF_ActionResult>();
        if (stepIds==null || stepIds.isEmpty()) return results;
        if (stepIds.size()>200 || (simulate && !FeatureManagement.checkPermission('TF_DemoTools'))) {
            for (Id ignored : stepIds) results.add(new TF_ActionResult('NOT_AVAILABLE_OR_NOT_ACCESSIBLE',null));
            return results;
        }
        Savepoint sp=Database.setSavepoint();
        try {
            Map<Id,JourneyStep__c> steps=new Map<Id,JourneyStep__c>([
                SELECT Id,TalentProfile__c,Stage__c,DueDate__c,Status__c,AssignedTo__c,DemoBatch__c
                FROM JourneyStep__c WHERE Id IN :stepIds WITH SYSTEM_MODE FOR UPDATE
            ]);
            Set<Id> profileIds=new Set<Id>();
            for (JourneyStep__c step : steps.values()) profileIds.add(step.TalentProfile__c);
            Map<Id,TalentProfile__c> profiles=new Map<Id,TalentProfile__c>([SELECT Id,Status__c,HumanApproved__c,ApprovedBy__c FROM TalentProfile__c WHERE Id IN :profileIds WITH SYSTEM_MODE]);
            List<JourneyStep__c> updates=new List<JourneyStep__c>();
            List<Task> tasks=new List<Task>();
            Map<Id,List<Integer>> indexes=new Map<Id,List<Integer>>();
            Map<Id,TF_ActionResult> byId=new Map<Id,TF_ActionResult>();
            for (JourneyStep__c step : steps.values()) {
                TalentProfile__c profile=profiles.get(step.TalentProfile__c);
                if (profile==null || profile.Status__c!='Hired' || !profile.HumanApproved__c || profile.ApprovedBy__c==null) {
                    byId.put(step.Id,new TF_ActionResult('INVALID_INPUT',null)); continue;
                }
                if (step.Status__c=='Completed') { byId.put(step.Id,new TF_ActionResult('ALREADY_COMPLETED',null)); continue; }
                if (step.Status__c!='Pending' || (!simulate && step.DueDate__c>Date.today()) || (simulate && (step.DemoBatch__c!=TF_DemoData.BATCH || !new Set<String>{'Day30','Day60','Day90'}.contains(step.Stage__c)))) {
                    byId.put(step.Id,new TF_ActionResult('INVALID_INPUT',null)); continue;
                }
                List<String> subjects=step.Stage__c=='Arrival' ? new List<String>{'Préparer le matériel','Organiser l’accueil'} : new List<String>{content(step.Stage__c,'').substringBefore(' : ')};
                indexes.put(step.Id,new List<Integer>());
                for (String subject : subjects) {
                    indexes.get(step.Id).add(tasks.size());
                    tasks.add(new Task(WhatId=step.TalentProfile__c,OwnerId=profile.ApprovedBy__c,
                        Subject=(simulate ? 'Simulation J+'+step.Stage__c.substring(3)+' — ' : '')+subject,
                        ActivityDate=step.DueDate__c, Status='Not Started',Priority='Normal',
                        Description=step.DemoBatch__c==TF_DemoData.BATCH ? TF_DemoData.BATCH : 'TalentFlow — suivi interne'));
                }
                step.Status__c='Completed'; step.ExecutedAt__c=System.now();
                step.ExecutionMode__c=simulate ? 'Simulation' : 'Scheduled';
                updates.add(step); byId.put(step.Id,new TF_ActionResult('SUCCESS',null));
            }
            Database.insert(tasks,AccessLevel.SYSTEM_MODE);
            for (JourneyStep__c step : updates) {
                List<String> ids=new List<String>();
                for (Integer index : indexes.get(step.Id)) ids.add(String.valueOf(tasks[index].Id));
                step.TaskIds__c=String.join(ids,',');
            }
            Database.update(updates,AccessLevel.SYSTEM_MODE);
            for (Id stepId : stepIds) results.add(byId.containsKey(stepId) ? byId.get(stepId) : new TF_ActionResult('NOT_AVAILABLE_OR_NOT_ACCESSIBLE',null));
        } catch (Exception failure) {
            Database.rollback(sp);
            results.clear();
            for (Id ignored : stepIds) results.add(new TF_ActionResult('TECHNICAL_FAILURE',null));
            Database.insert(new AgentAudit__c(ActionName__c='TF_ExecuteJourneyStep',Result__c='TECHNICAL_FAILURE',ReasonCode__c='JOURNEY_TRANSACTION_ROLLED_BACK',Actor__c=UserInfo.getUserId(),OccurredAt__c=System.now()),AccessLevel.SYSTEM_MODE);
        } finally {
            Database.releaseSavepoint(sp);
        }
        return results;
    }
    public class JourneyException extends Exception {}
}
