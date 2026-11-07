public with sharing class TF_GetCandidateBrief {
    public class Request {
        @InvocableVariable(required=true label='Code candidat') public String candidateCode;
    }
    @InvocableMethod(label='TF_GetCandidateBrief' description='Retourne les seules preuves autorisées et informations manquantes, sans identité ni décision.')
    public static List<TF_ActionResult> run(List<Request> requests) {
        List<TF_AgentService.Request> inputs = new List<TF_AgentService.Request>();
        if (requests != null) for (Request request : requests) {
            TF_AgentService.Request input = new TF_AgentService.Request();
            input.candidateCode=request==null ? null : request.candidateCode;
            inputs.add(input);
        }
        return TF_AgentService.execute('TF_GetCandidateBrief',inputs);
    }
}
