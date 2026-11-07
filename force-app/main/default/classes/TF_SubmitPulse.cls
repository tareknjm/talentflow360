public with sharing class TF_SubmitPulse {
    public class Request {
        @InvocableVariable(required=true) public Id profileId;
        @InvocableVariable(required=true) public Decimal score;
    }
    @InvocableMethod(label='TF — Enregistrer la satisfaction (écran interne)' description='Réservé au Screen Flow de satisfaction ; ne jamais exposer à Agentforce.')
    public static List<TF_ActionResult> run(List<Request> requests) {
        List<TF_ActionResult> results=new List<TF_ActionResult>();
        if (requests==null) return results;
        if (requests.size()!=1) {
            for (Request ignored : requests) results.add(new TF_ActionResult('INVALID_INPUT',null));
            return results;
        }
        Request request=requests[0];
        if (request==null || request.profileId==null || request.score==null || request.score<1 || request.score>5 || request.score!=request.score.setScale(0)) return new List<TF_ActionResult>{new TF_ActionResult('INVALID_INPUT',null)};
        Savepoint sp=Database.setSavepoint();
        try {
            if (!Schema.sObjectType.PulseResponse__c.isCreateable()) return new List<TF_ActionResult>{new TF_ActionResult('NOT_AVAILABLE_OR_NOT_ACCESSIBLE',null)};
            List<TalentProfile__c> profiles=[SELECT Id,Status__c,DemoBatch__c FROM TalentProfile__c WHERE Id=:request.profileId WITH USER_MODE];
            if (profiles.isEmpty()) return new List<TF_ActionResult>{new TF_ActionResult('NOT_AVAILABLE_OR_NOT_ACCESSIBLE',null)};
            if (profiles[0].Status__c!='Hired') return new List<TF_ActionResult>{new TF_ActionResult('INVALID_INPUT',null)};
            PulseResponse__c response=new PulseResponse__c(TalentProfile__c=profiles[0].Id,Score__c=request.score,SubmittedAt__c=System.now(),DemoBatch__c=profiles[0].DemoBatch__c);
            Database.insert(response,AccessLevel.USER_MODE);
            if (request.score<=2 && [SELECT AlertTaskId__c FROM PulseResponse__c WHERE Id=:response.Id WITH SYSTEM_MODE].AlertTaskId__c==null) throw new PulseException('Alert automation did not run.');
            results.add(new TF_ActionResult('SUCCESS',null));
        } catch (Exception failure) {
            Database.rollback(sp);
            results.add(new TF_ActionResult('TECHNICAL_FAILURE',null));
        } finally { Database.releaseSavepoint(sp); }
        return results;
    }
    public class PulseException extends Exception {}
}
