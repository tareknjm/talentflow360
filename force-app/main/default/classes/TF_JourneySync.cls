public without sharing class TF_JourneySync {
    public class Request { @InvocableVariable(required=true) public Id profileId; }
    @InvocableMethod(label='TF — Synchroniser le parcours (automatisation interne)' description='Appelé par le Flow après embauche humaine ; ne jamais exposer à Agentforce.')
    public static void run(List<Request> requests) {
        Set<Id> ids=new Set<Id>();
        if (requests!=null) for (Request request : requests) if (request!=null && request.profileId!=null) ids.add(request.profileId);
        TF_JourneyService.sync(ids);
    }
}
