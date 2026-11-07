public without sharing class TF_PulseAlert {
    public class Request { @InvocableVariable(required=true) public Id responseId; }
    @InvocableMethod(label='TF — Créer l’alerte satisfaction (automatisation interne)' description='Appelé par le Flow de satisfaction ; ne jamais exposer à Agentforce.')
    public static void run(List<Request> requests) {
        Set<Id> ids=new Set<Id>();
        if (requests!=null) for (Request request : requests) if (request!=null && request.responseId!=null) ids.add(request.responseId);
        TF_PulseService.alert(ids);
    }
}
