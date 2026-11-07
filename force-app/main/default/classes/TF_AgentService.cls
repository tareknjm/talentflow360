public with sharing class TF_AgentService {
    public class Request {
        public String candidateCode;
        public Datetime periodStart;
        public Datetime periodEnd;
        public Id slotId;
        public String requestKey;
        public Boolean confirmed;
    }

    public static List<TF_ActionResult> execute(String action, List<Request> requests) {
        List<TF_ActionResult> results = new List<TF_ActionResult>();
        if (requests == null) return results;
        if (requests.size() > 10) {
            for (Request ignored : requests) results.add(new TF_ActionResult('INVALID_INPUT', null));
            return results;
        }
        for (Request request : requests) {
            Savepoint sp = Database.setSavepoint();
            TF_ActionResult result;
            try {
                result = executeOne(action, request);
                AgentAudit__c audit = new AgentAudit__c(
                    ProfileCode__c=validCode(request) ? request.candidateCode : null,
                    ActionName__c=action, Result__c=result.resultCode, ReasonCode__c=result.resultCode,
                    CorrelationId__c=EncodingUtil.convertToHex(Crypto.generateAesKey(128)),
                    Actor__c=UserInfo.getUserId(), OccurredAt__c=System.now()
                );
                // Only fixed, non-personal fields; no general system-mode data access is exposed.
                Database.insert(audit, AccessLevel.SYSTEM_MODE);
            } catch (Exception failure) {
                Database.rollback(sp);
                result = new TF_ActionResult('TECHNICAL_FAILURE', null);
            } finally {
                Database.releaseSavepoint(sp);
            }
            results.add(result);
        }
        return results;
    }

    private static Boolean validCode(Request request) {
        return request != null && request.candidateCode != null && Pattern.matches('[A-Za-z0-9_-]{1,30}', request.candidateCode);
    }

    private static TF_ActionResult executeOne(String action, Request request) {
        if (!validCode(request)) return new TF_ActionResult('INVALID_INPUT', null);
        List<TalentProfile__c> profiles;
        try {
            if (action == 'TF_ReserveInterview') {
                profiles = [SELECT Id, CandidateCode__c, Status__c FROM TalentProfile__c WHERE CandidateCode__c=:request.candidateCode WITH USER_MODE FOR UPDATE];
            } else {
                profiles = [SELECT Id, CandidateCode__c, Role__c, JavaEvidence__c, SpringEvidence__c, Availability__c FROM TalentProfile__c WHERE CandidateCode__c=:request.candidateCode WITH USER_MODE];
            }
        } catch (QueryException inaccessible) {
            return new TF_ActionResult('NOT_AVAILABLE_OR_NOT_ACCESSIBLE', null);
        }
        if (profiles.isEmpty()) return new TF_ActionResult('NOT_AVAILABLE_OR_NOT_ACCESSIBLE', null);
        TalentProfile__c profile = profiles[0];
        if (action == 'TF_GetCandidateBrief') {
            List<String> missing = new List<String>();
            if (profile.JavaEvidence__c == 'NotProvided') missing.add('JavaEvidence');
            if (profile.SpringEvidence__c == 'NotProvided') missing.add('SpringEvidence');
            if (profile.Availability__c == null) missing.add('Availability');
            return new TF_ActionResult('SUCCESS', new Map<String,Object>{
                'candidateCode'=>profile.CandidateCode__c, 'role'=>profile.Role__c,
                'javaEvidence'=>profile.JavaEvidence__c, 'springEvidence'=>profile.SpringEvidence__c,
                'availability'=>profile.Availability__c, 'missingInformation'=>missing
            });
        }
        if (action == 'TF_ListInterviewSlots') {
            if (request.periodStart == null || request.periodEnd == null || request.periodStart >= request.periodEnd || request.periodEnd > request.periodStart.addDays(31)) return new TF_ActionResult('INVALID_INPUT', null);
            List<Object> slots = new List<Object>();
            Datetime now = System.now();
            for (InterviewSlot__c slot : [SELECT Id, Start__c, End__c FROM InterviewSlot__c WHERE Status__c='Available' AND Start__c >= :request.periodStart AND Start__c > :now AND End__c <= :request.periodEnd WITH USER_MODE ORDER BY Start__c, Id LIMIT 20]) slots.add(slotPayload(slot));
            return new TF_ActionResult('SUCCESS', new Map<String,Object>{'slots'=>slots});
        }
        if (action == 'TF_ReserveInterview') return reserve(profile, request);
        if (action == 'TF_GetOnboardingStatus') {
            List<Object> steps = new List<Object>();
            List<Object> nextTasks = new List<Object>();
            for (JourneyStep__c step : [SELECT Stage__c, DueDate__c, Status__c, ExecutionMode__c FROM JourneyStep__c WHERE TalentProfile__c=:profile.Id WITH USER_MODE ORDER BY DueDate__c, Id LIMIT 100]) {
                steps.add(new Map<String,Object>{'stage'=>step.Stage__c,'dueDate'=>step.DueDate__c,'status'=>step.Status__c,'executionMode'=>step.ExecutionMode__c});
                if (step.Status__c=='Pending' && nextTasks.size()<6) nextTasks.add(new Map<String,Object>{'stage'=>step.Stage__c,'dueDate'=>step.DueDate__c});
            }
            return new TF_ActionResult('SUCCESS', new Map<String,Object>{'steps'=>steps,'nextTasks'=>nextTasks});
        }
        return new TF_ActionResult('INVALID_INPUT', null);
    }

    private static TF_ActionResult reserve(TalentProfile__c profile, Request request) {
        if (request.slotId == null || request.slotId.getSObjectType()!=InterviewSlot__c.SObjectType || String.isBlank(request.requestKey) || request.requestKey.length()>80 || request.confirmed!=true) return new TF_ActionResult('INVALID_INPUT',null);
        if (profile.Status__c=='Hired' || profile.Status__c=='Draft') return new TF_ActionResult('INVALID_INPUT',null);
        List<InterviewSlot__c> existing = [SELECT Id, Start__c, End__c FROM InterviewSlot__c WHERE TalentProfile__c=:profile.Id AND Status__c='Reserved' WITH USER_MODE ORDER BY Start__c, Id LIMIT 1];
        if (!existing.isEmpty()) return new TF_ActionResult('ALREADY_RESERVED',slotPayload(existing[0]));
        List<InterviewSlot__c> slots = [SELECT Id, Start__c, End__c, Status__c, TalentProfile__c, ReservationKey__c FROM InterviewSlot__c WHERE Id=:request.slotId WITH USER_MODE FOR UPDATE];
        if (slots.isEmpty()) return new TF_ActionResult('SLOT_UNAVAILABLE',null);
        InterviewSlot__c slot = slots[0];
        if (slot.Status__c!='Available' || slot.Start__c<=System.now() || slot.End__c<=slot.Start__c) return new TF_ActionResult('SLOT_UNAVAILABLE',null);
        slot.Status__c='Reserved';
        slot.TalentProfile__c=profile.Id;
        slot.ReservationKey__c=EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(profile.Id)+'|'+request.requestKey)));
        Database.update(slot, AccessLevel.USER_MODE);
        Database.update(new TalentProfile__c(Id=profile.Id, Status__c='InterviewScheduled'), AccessLevel.USER_MODE);
        return new TF_ActionResult('SUCCESS',slotPayload(slot));
    }

    private static Map<String,Object> slotPayload(InterviewSlot__c slot) {
        return new Map<String,Object>{'slotId'=>slot.Id,'start'=>slot.Start__c,'end'=>slot.End__c};
    }
}
