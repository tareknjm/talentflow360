public with sharing class TF_ProfileGuard {
    public static void enforce(List<TalentProfile__c> profiles, Map<Id, TalentProfile__c> previous) {
        for (TalentProfile__c profile : profiles) {
            TalentProfile__c old = previous == null ? null : previous.get(profile.Id);
            Boolean changed = old == null
                ? profile.HumanApproved__c || profile.ApprovedBy__c != null || profile.ApprovedAt__c != null || profile.OnboardingCycle__c != null || profile.Status__c == 'Hired'
                : profile.HumanApproved__c != old.HumanApproved__c || profile.ApprovedBy__c != old.ApprovedBy__c || profile.ApprovedAt__c != old.ApprovedAt__c || profile.OnboardingCycle__c != old.OnboardingCycle__c || (profile.Status__c != old.Status__c && (profile.Status__c == 'Hired' || old.Status__c == 'Hired'));
            if (changed && (profile.Id == null || TF_HiringService.approvingId != profile.Id)) {
                profile.addError('Utiliser le parcours distinct de validation RH. Les champs d’approbation ne sont pas modifiables directement.');
            }
        }
    }
}
