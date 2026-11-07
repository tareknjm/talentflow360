trigger TF_TalentProfile on TalentProfile__c (before insert, before update) {
    TF_ProfileGuard.enforce(Trigger.new, Trigger.isInsert ? null : Trigger.oldMap);
}
