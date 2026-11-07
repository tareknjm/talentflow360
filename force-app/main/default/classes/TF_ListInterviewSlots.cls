public with sharing class TF_ListInterviewSlots {
    public class Request {
        @InvocableVariable(required=true label='Code candidat') public String candidateCode;
        @InvocableVariable(required=true label='Début de période') public Datetime periodStart;
        @InvocableVariable(required=true label='Fin de période') public Datetime periodEnd;
    }
    @InvocableMethod(label='TF_ListInterviewSlots' description='Liste au plus vingt créneaux internes futurs accessibles sur une période de trente et un jours maximum.')
    public static List<TF_ActionResult> run(List<Request> requests) {
        List<TF_AgentService.Request> inputs = new List<TF_AgentService.Request>();
        if (requests != null) for (Request request : requests) {
            TF_AgentService.Request input = new TF_AgentService.Request();
            if (request!=null) { input.candidateCode=request.candidateCode; input.periodStart=request.periodStart; input.periodEnd=request.periodEnd; }
            inputs.add(input);
        }
        return TF_AgentService.execute('TF_ListInterviewSlots',inputs);
    }
}
