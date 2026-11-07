public with sharing class TF_ReserveInterview {
    public class Request {
        @InvocableVariable(required=true label='Code candidat') public String candidateCode;
        @InvocableVariable(required=true label='Créneau confirmé') public Id slotId;
        @InvocableVariable(required=true label='Clé de répétition') public String requestKey;
        @InvocableVariable(required=true label='Confirmation explicite reçue') public Boolean confirmed;
    }
    @InvocableMethod(label='TF_ReserveInterview' description='Réserve un créneau après confirmation explicite, avec contrôle des droits et de la concurrence. Ne confirme un succès qu’après SUCCESS.')
    public static List<TF_ActionResult> run(List<Request> requests) {
        List<TF_AgentService.Request> inputs = new List<TF_AgentService.Request>();
        if (requests != null) for (Request request : requests) {
            TF_AgentService.Request input = new TF_AgentService.Request();
            if (request!=null) { input.candidateCode=request.candidateCode; input.slotId=request.slotId; input.requestKey=request.requestKey; input.confirmed=request.confirmed; }
            inputs.add(input);
        }
        return TF_AgentService.execute('TF_ReserveInterview',inputs);
    }
}
