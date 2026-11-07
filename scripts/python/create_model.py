"""Scaffold the agreed Salesforce MVP model. Refuses to overwrite existing files.

Run from the project root with Python 3. No Salesforce access or external messages.
The generated metadata remains the source of truth after generation.
"""
from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'force-app/main/default'
NS = 'http://soap.sforce.com/2006/04/metadata'


def write(relative, root, body):
    path = BASE / relative
    if path.exists():
        raise RuntimeError(f'Refusing to overwrite {path.relative_to(ROOT)}')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f'<?xml version="1.0" encoding="UTF-8"?>\n<{root} xmlns="{NS}">\n{body}\n</{root}>\n', encoding='utf-8')


def field(obj, name, label, kind='Text', required=False, **kw):
    body = f'    <fullName>{name}</fullName>\n'
    if kind == 'Text':
        body += f'    <externalId>{str(kw.get("external", False)).lower()}</externalId>\n'
    body += f'    <label>{escape(label)}</label>\n'
    if kind in ('Text', 'LongTextArea'):
        body += f'    <length>{kw.get("length", 40)}</length>\n'
    if kind == 'Lookup':
        if kw['target'] != 'User':
            body += '    <deleteConstraint>Restrict</deleteConstraint>\n'
        body += f'    <referenceTo>{kw["target"]}</referenceTo>\n    <relationshipLabel>{escape(kw["relation"])}</relationshipLabel>\n    <relationshipName>{kw["relation"]}</relationshipName>\n'
    if kind == 'Number':
        body += '    <precision>2</precision>\n    <scale>1</scale>\n'
    if kind == 'Checkbox':
        body += '    <defaultValue>false</defaultValue>\n'
    elif kind != 'LongTextArea':
        body += f'    <required>{str(required).lower()}</required>\n'
    body += f'    <type>{kind}</type>\n'
    if kind == 'Text':
        body += f'    <unique>{str(kw.get("unique", False)).lower()}</unique>\n'
    if kind == 'LongTextArea':
        body += '    <visibleLines>5</visibleLines>\n'
    if kind == 'Picklist':
        body += '    <valueSet><restricted>true</restricted><valueSetDefinition><sorted>false</sorted>\n'
        for index, value in enumerate(kw['values']):
            body += f'        <value><fullName>{value}</fullName><default>{str(index == 0).lower()}</default><label>{value}</label></value>\n'
        body += '    </valueSetDefinition></valueSet>\n'
    write(f'objects/{obj}/fields/{name}.field-meta.xml', 'CustomField', body)


OBJECTS = {
    'CandidateIdentity__c': ('Identité candidat', 'Identités candidats', 'CID'),
    'TalentProfile__c': ('Dossier talent', 'Dossiers talents', 'TP'),
    'InterviewSlot__c': ("Créneau d’entretien", "Créneaux d’entretien", 'IS'),
    'JourneyStep__c': ('Étape de parcours', 'Étapes de parcours', 'JS'),
    'PulseResponse__c': ('Réponse de satisfaction', 'Réponses de satisfaction', 'PR'),
    'AgentAudit__c': ("Trace d’action", "Traces d’actions", 'AA'),
}


def build():
    for obj, (label, plural, prefix) in OBJECTS.items():
        write(f'objects/{obj}/{obj}.object-meta.xml', 'CustomObject', f'''    <deploymentStatus>Deployed</deploymentStatus>
    <enableActivities>{str(obj == 'TalentProfile__c').lower()}</enableActivities>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
    <externalSharingModel>Private</externalSharingModel>
    <label>{label}</label>
    <nameField><displayFormat>{prefix}-{{0000}}</displayFormat><label>Référence</label><type>AutoNumber</type></nameField>
    <pluralLabel>{plural}</pluralLabel>
    <sharingModel>Private</sharingModel>''')
        field(obj, 'DemoBatch__c', 'Lot synthétique', length=40)
        write(f'tabs/{obj}.tab-meta.xml', 'CustomTab', '    <customObject>true</customObject>\n    <motif>Custom57: Building Block</motif>')

    for obj in ('CandidateIdentity__c', 'TalentProfile__c'):
        field(obj, 'CandidateCode__c', 'Code candidat', required=True, length=30, external=True, unique=True)
    field('CandidateIdentity__c', 'FullName__c', 'Nom fictif', required=True, length=120)
    field('CandidateIdentity__c', 'Email__c', 'Email fictif', 'Email', required=True)

    obj = 'TalentProfile__c'
    field(obj, 'Role__c', 'Rôle', 'Picklist', True, values=['JavaBackendDeveloper', 'QAEngineer'])
    for name, label in [('JavaEvidence__c', 'Preuve Java'), ('SpringEvidence__c', 'Preuve Spring')]:
        field(obj, name, label, 'Picklist', True, values=['NotProvided', 'DeclaredProject', 'RecordedAssessment'])
    field(obj, 'Availability__c', 'Disponibilité', 'Date')
    field(obj, 'Status__c', 'État du dossier', 'Picklist', True, values=['Draft', 'ReadyForReview', 'InterviewRequested', 'InterviewScheduled', 'Hired'])
    field(obj, 'HumanApproved__c', 'Approbation humaine', 'Checkbox')
    field(obj, 'ApprovedBy__c', 'Validé par', 'Lookup', target='User', relation='ApprovedTalents')
    field(obj, 'ApprovedAt__c', 'Date de validation', 'DateTime')
    field(obj, 'StartDate__c', "Date d’arrivée", 'Date')
    field(obj, 'OnboardingCycle__c', "Cycle d’intégration", length=40)

    obj = 'InterviewSlot__c'
    field(obj, 'Start__c', 'Début', 'DateTime', True)
    field(obj, 'End__c', 'Fin', 'DateTime', True)
    field(obj, 'Recruiter__c', 'Recruteur', 'Lookup', target='User', relation='RecruiterSlots')
    field(obj, 'Status__c', 'État du créneau', 'Picklist', True, values=['Available', 'Reserved', 'Cancelled'])
    field(obj, 'TalentProfile__c', 'Dossier talent', 'Lookup', target='TalentProfile__c', relation='InterviewSlots')
    field(obj, 'ReservationKey__c', 'Clé de réservation', length=80, unique=True)
    field(obj, 'DemoKey__c', 'Clé synthétique', length=80, unique=True, external=True)

    obj = 'JourneyStep__c'
    field(obj, 'TalentProfile__c', 'Dossier talent', 'Lookup', True, target='TalentProfile__c', relation='JourneySteps')
    field(obj, 'Stage__c', 'Jalon', 'Picklist', True, values=['PreArrival', 'Arrival', 'Day1', 'Day30', 'Day60', 'Day90'])
    field(obj, 'Status__c', 'État de l’étape', 'Picklist', True, values=['Pending', 'Completed', 'Cancelled', 'Failed'])
    field(obj, 'DispatchStatus__c', 'État du message', 'Picklist', True, values=['NotApplicable', 'Prepared', 'Sent', 'Failed'])
    field(obj, 'DueDate__c', 'Échéance', 'Date', True)
    field(obj, 'AssignedTo__c', 'Responsable', 'Lookup', target='User', relation='AssignedJourneySteps')
    field(obj, 'StepKey__c', 'Clé d’étape', 'Text', True, length=100, unique=True, external=True)
    field(obj, 'MessagePreview__c', 'Aperçu du message', 'LongTextArea', length=4000)

    obj = 'PulseResponse__c'
    field(obj, 'TalentProfile__c', 'Dossier talent', 'Lookup', True, target='TalentProfile__c', relation='PulseResponses')
    field(obj, 'Score__c', 'Satisfaction de 1 à 5', 'Number', True)
    field(obj, 'SubmittedAt__c', 'Date de réponse', 'DateTime', True)
    field(obj, 'AlertTaskId__c', 'Référence de l’alerte', length=18)

    obj = 'AgentAudit__c'
    for name, label, length, required in [('ProfileCode__c', 'Code dossier', 30, False), ('ActionName__c', 'Action', 80, True), ('Result__c', 'Résultat', 40, False), ('ReasonCode__c', 'Motif', 80, False), ('CorrelationId__c', 'Corrélation', 80, False)]:
        field(obj, name, label, length=length, required=required)
    field(obj, 'Actor__c', 'Acteur effectif', 'Lookup', target='User', relation='AgentActionAudits')
    field(obj, 'OccurredAt__c', 'Horodatage', 'DateTime', True)

    rules = [
        ('InterviewSlot__c', 'RecruiterRequired', 'ISBLANK(Recruiter__c)', 'Un recruteur est obligatoire pour chaque créneau.'),
        ('InterviewSlot__c', 'EndAfterStart', 'End__c <= Start__c', 'La fin doit être strictement après le début.'),
        ('InterviewSlot__c', 'ReservationConsistency', 'OR(AND(ISPICKVAL(Status__c, "Reserved"), OR(ISBLANK(TalentProfile__c), ISBLANK(ReservationKey__c))), AND(ISPICKVAL(Status__c, "Available"), OR(NOT(ISBLANK(TalentProfile__c)), NOT(ISBLANK(ReservationKey__c)))))', 'Un créneau réservé exige un dossier et une clé ; un créneau libre ne les conserve pas.'),
        ('PulseResponse__c', 'ScoreRange', 'OR(Score__c < 1, Score__c > 5, MOD(Score__c, 1) <> 0)', 'La satisfaction doit être un entier compris entre 1 et 5.'),
        ('TalentProfile__c', 'HiringRequiresApproval', 'AND(ISPICKVAL(Status__c, "Hired"), OR(NOT(HumanApproved__c), ISBLANK(ApprovedBy__c), ISBLANK(ApprovedAt__c), ISBLANK(StartDate__c)))', 'L’embauche exige la validation RH et une date d’arrivée.'),
    ]
    for obj, name, formula, message in rules:
        write(f'objects/{obj}/validationRules/{name}.validationRule-meta.xml', 'ValidationRule', f'    <fullName>{name}</fullName>\n    <active>true</active>\n    <errorConditionFormula>{escape(formula)}</errorConditionFormula>\n    <errorMessage>{escape(message)}</errorMessage>')

    for permission, label in [('TF_ApproveHiring', 'Valider une embauche TalentFlow'), ('TF_DemoTools', 'Utiliser les outils de démonstration TalentFlow')]:
        write(f'customPermissions/{permission}.customPermission-meta.xml', 'CustomPermission', f'    <label>{label}</label>')

    tabs = ''.join(f'    <tabs>{obj}</tabs>\n' for obj in OBJECTS)
    write('applications/TalentFlow360.app-meta.xml', 'CustomApplication', f'''    <description>Démonstrateur RH sur données synthétiques.</description>
    <formFactors>Large</formFactors>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <label>TalentFlow 360</label>
    <navType>Standard</navType>
{tabs}    <uiType>Lightning</uiType>''')

    for obj in OBJECTS:
        all_fields = [p.name.removesuffix('.field-meta.xml') for p in sorted((BASE / f'objects/{obj}/fields').glob('*.xml'))]
        required = {p.name.removesuffix('.field-meta.xml') for p in (BASE / f'objects/{obj}/fields').glob('*.xml') if '<required>true</required>' in p.read_text(encoding='utf-8')}
        items = '<layoutItems><behavior>Readonly</behavior><field>Name</field></layoutItems>'
        for name in all_fields:
            readonly = name in {'HumanApproved__c','ApprovedBy__c','ApprovedAt__c','OnboardingCycle__c','AlertTaskId__c'}
            behavior = 'Readonly' if readonly else 'Required' if name in required else 'Edit'
            items += f'<layoutItems><behavior>{behavior}</behavior><field>{name}</field></layoutItems>'
        write(f'layouts/{obj}-TalentFlow.layout-meta.xml', 'Layout', f'    <layoutSections><customLabel>true</customLabel><detailHeading>true</detailHeading><editHeading>true</editHeading><label>Informations</label><layoutColumns>{items}</layoutColumns><style>OneColumn</style></layoutSections>\n    <showEmailCheckbox>false</showEmailCheckbox>\n    <showHighlightsPanel>false</showHighlightsPanel>\n    <showInteractionLogPanel>false</showInteractionLogPanel>\n    <showRunAssignmentRulesCheckbox>false</showRunAssignmentRulesCheckbox>\n    <showSubmitAndAttachButton>false</showSubmitAndAttachButton>')

    print('Six objects and standard navigation generated. Not deployed or tested.')


if __name__ == '__main__':
    build()
