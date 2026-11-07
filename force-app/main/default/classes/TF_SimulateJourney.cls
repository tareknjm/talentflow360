public with sharing class TF_SimulateJourney {
    public class Request { @InvocableVariable(required=true) public Id stepId; }
    @InvocableMethod(label='TF — Simulation J+30/J+60/J+90 (démonstration)' description='Données synthétiques uniquement, permission TF_DemoTools obligatoire. Ne jamais exposer à Agentforce.')
    public static List<TF_ActionResult> run(List<Request> requests) {
        List<Id> ids=new List<Id>();
        if (requests!=null) for (Request request : requests) ids.add(request==null ? null : request.stepId);
        if (!FeatureManagement.checkPermission('TF_DemoTools')) {
            List<TF_ActionResult> denied=new List<TF_ActionResult>();
            for (Id ignored : ids) denied.add(new TF_ActionResult('NOT_AVAILABLE_OR_NOT_ACCESSIBLE',null));
            return denied;
        }
        // Even the demo operator must have user-mode read access to these steps.
        Set<Id> visible=new Map<Id,JourneyStep__c>([SELECT Id FROM JourneyStep__c WHERE Id IN :ids WITH USER_MODE]).keySet();
        for (Integer index=0;index<ids.size();index++) if (!visible.contains(ids[index])) ids[index]=null;
        return TF_JourneyService.execute(ids,true);
    }
}
