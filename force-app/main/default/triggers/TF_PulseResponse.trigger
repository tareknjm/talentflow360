trigger TF_PulseResponse on PulseResponse__c (before insert,before update) {
    TF_PulseGuard.enforce(Trigger.new,Trigger.isInsert ? null : Trigger.oldMap);
}
