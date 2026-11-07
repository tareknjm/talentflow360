public without sharing class TF_ExecuteJourneyStep {
    public class Request { @InvocableVariable(required=true) public Id stepId; }
    @InvocableMethod(label='TF — Exécuter une échéance (automatisation interne)' description='Réservé au Flow planifié, refuse les échéances futures ; ne jamais exposer à Agentforce.')
    public static List<TF_ActionResult> run(List<Request> requests) {
        List<Id> ids=new List<Id>();
        if (requests!=null) for (Request request : requests) ids.add(request==null ? null : request.stepId);
        return TF_JourneyService.execute(ids,false);
    }
}
