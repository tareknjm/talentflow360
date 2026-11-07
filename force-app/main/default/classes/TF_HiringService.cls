public with sharing class TF_HiringService {
    // Only this class can open the approval gate, only for the locked record.
    public static Id approvingId { get; private set; }

    public class Request {
        @InvocableVariable(required=true label='Dossier')
        public Id profileId;
        @InvocableVariable(required=true label='Date d’arrivée')
        public Date startDate;
        @InvocableVariable(required=true label='Confirmation humaine')
        public Boolean confirmed;
    }
    public class Result {
        @InvocableVariable public String resultCode;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='TF — Valider une embauche (RH uniquement)' description='Réservé au Screen Flow RH. Ne jamais exposer comme action Agentforce.')
    public static List<Result> approve(List<Request> requests) {
        List<Result> results = new List<Result>();
        if (requests == null) return results;
        if (requests.size() > 1) {
            for (Request ignored : requests) {
                Result rejected = new Result();
                rejected.resultCode = 'INVALID_INPUT';
                rejected.message = 'Une validation humaine à la fois.';
                results.add(rejected);
            }
            return results;
        }
        for (Request request : requests) {
            Result result = new Result();
            result.resultCode = 'INVALID_INPUT';
            result.message = 'Vérifier le dossier, la date et la confirmation.';
            if (!FeatureManagement.checkPermission('TF_ApproveHiring')) {
                result.resultCode = 'NOT_AVAILABLE_OR_NOT_ACCESSIBLE';
                result.message = 'Validation RH non autorisée.';
            } else if (request != null && request.profileId != null && request.startDate != null && request.confirmed == true) {
                Savepoint sp = Database.setSavepoint();
                try {
                    if (!Schema.sObjectType.TalentProfile__c.isUpdateable() || !Schema.sObjectType.TalentProfile__c.fields.StartDate__c.isUpdateable()) {
                        throw new HiringException('Access denied');
                    }
                    List<TalentProfile__c> profiles = [SELECT Id, Status__c FROM TalentProfile__c WHERE Id = :request.profileId WITH USER_MODE FOR UPDATE];
                    if (profiles.isEmpty()) {
                        result.resultCode = 'NOT_AVAILABLE_OR_NOT_ACCESSIBLE';
                        result.message = 'Dossier indisponible.';
                    } else if (profiles[0].Status__c != 'InterviewScheduled') {
                        result.message = 'La validation exige un entretien planifié et un dossier non encore embauché.';
                    } else {
                        approvingId = profiles[0].Id;
                        TalentProfile__c profile = new TalentProfile__c(
                            Id=approvingId, Status__c='Hired', HumanApproved__c=true,
                            ApprovedBy__c=UserInfo.getUserId(), ApprovedAt__c=System.now(),
                            StartDate__c=request.startDate,
                            OnboardingCycle__c=EncodingUtil.convertToHex(Crypto.generateAesKey(128))
                        );
                        // Narrow, deliberate elevation: approval fields are read-only to users.
                        // Sharing/read access and custom permission were checked above.
                        Database.update(profile, AccessLevel.SYSTEM_MODE);
                        result.resultCode = 'SUCCESS';
                        result.message = 'Validation RH enregistrée.';
                    }
                } catch (Exception error) {
                    Database.rollback(sp);
                    result.resultCode = 'TECHNICAL_FAILURE';
                    result.message = 'Validation non enregistrée. Consulter le support technique.';
                } finally {
                    approvingId = null;
                }
            }
            results.add(result);
        }
        return results;
    }

    public class HiringException extends Exception {}
}
