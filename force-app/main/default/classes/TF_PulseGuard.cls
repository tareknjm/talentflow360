public with sharing class TF_PulseGuard {
    public static void enforce(List<PulseResponse__c> responses,Map<Id,PulseResponse__c> previous) {
        for (PulseResponse__c response : responses) {
            PulseResponse__c old=previous==null ? null : previous.get(response.Id);
            if (old==null) {
                response.SubmittedAt__c=System.now();
                if (response.AlertTaskId__c!=null) response.addError('La référence d’alerte est gérée par l’automatisation.');
            } else {
                if (response.Score__c!=old.Score__c || response.TalentProfile__c!=old.TalentProfile__c || response.SubmittedAt__c!=old.SubmittedAt__c || response.DemoBatch__c!=old.DemoBatch__c) response.addError('Une réponse enregistrée ne peut pas être réécrite.');
                if (response.AlertTaskId__c!=old.AlertTaskId__c && (TF_PulseService.updatingIds==null || !TF_PulseService.updatingIds.contains(response.Id))) response.addError('La référence d’alerte est gérée par l’automatisation.');
            }
        }
    }
}
