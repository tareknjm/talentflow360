public with sharing class TF_ActionResult {
    @InvocableVariable(label='Code de résultat') public String resultCode;
    @InvocableVariable(label='Données autorisées JSON') public String payloadJson;

    public TF_ActionResult() {}
    public TF_ActionResult(String code, Object payload) {
        resultCode=code;
        payloadJson=payload == null ? null : JSON.serialize(payload);
    }
}
