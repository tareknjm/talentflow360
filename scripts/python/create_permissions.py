"""Generate initial additive permission sets without overwriting existing files."""
from create_model import BASE, write
import xml.etree.ElementTree as ET

NS = {'m': 'http://soap.sforce.com/2006/04/metadata'}
SAFE = {'CandidateCode__c','Role__c','JavaEvidence__c','SpringEvidence__c','Availability__c'}
PROTECTED = {'HumanApproved__c','ApprovedBy__c','ApprovedAt__c','OnboardingCycle__c','AlertTaskId__c'}
SETS = {
    'TF_Recruiter': ('Recrutement TalentFlow', {'TalentProfile__c': 'CE', 'InterviewSlot__c': 'CE', 'JourneyStep__c': '', 'PulseResponse__c': 'C'}, []),
    'TF_AgentAccess': ('Actions minimisées TalentFlow', {'TalentProfile__c': 'E', 'InterviewSlot__c': 'E', 'JourneyStep__c': ''}, []),
    'TF_HiringApprover': ('Validation RH TalentFlow', {'CandidateIdentity__c': 'CE', 'TalentProfile__c': 'E', 'PulseResponse__c': '', 'JourneyStep__c': ''}, ['TF_ApproveHiring']),
    'TF_DemoAdmin': ('Démonstration TalentFlow', {p.name: 'CED' for p in (BASE / 'objects').iterdir()}, ['TF_DemoTools']),
}

for name, (label, objects, permissions) in SETS.items():
    body = ''
    if name != 'TF_AgentAccess':
        body += '    <applicationVisibilities><application>TalentFlow360</application><visible>true</visible></applicationVisibilities>\n'
    if name == 'TF_HiringApprover':
        body += '    <classAccesses><apexClass>TF_HiringService</apexClass><enabled>true</enabled></classAccesses>\n'
    for permission in permissions:
        body += f'    <customPermissions><enabled>true</enabled><name>{permission}</name></customPermissions>\n'
    for obj, access in sorted(objects.items()):
        for path in sorted((BASE / f'objects/{obj}/fields').glob('*.xml')):
            root = ET.parse(path).getroot()
            field = root.find('m:fullName', NS).text
            if root.findtext('m:required', namespaces=NS) == 'true':
                continue  # Salesforce does not support FLS entries on universally required fields.
            if name == 'TF_AgentAccess':
                allowed = (obj == 'TalentProfile__c' and field in SAFE | {'Status__c'}) or (obj == 'InterviewSlot__c' and field in {'TalentProfile__c','ReservationKey__c'}) or (obj == 'JourneyStep__c' and field == 'AssignedTo__c')
                if not allowed:
                    continue
            editable = bool('C' in access or 'E' in access) and field not in PROTECTED
            if name == 'TF_AgentAccess' and obj == 'TalentProfile__c':
                editable = field == 'Status__c'
            body += f'    <fieldPermissions><editable>{str(editable).lower()}</editable><field>{obj}.{field}</field><readable>true</readable></fieldPermissions>\n'
    body += f'    <hasActivationRequired>false</hasActivationRequired>\n    <label>{label}</label>\n'
    for obj, access in sorted(objects.items()):
        body += f'    <objectPermissions><allowCreate>{str("C" in access).lower()}</allowCreate><allowDelete>{str("D" in access).lower()}</allowDelete><allowEdit>{str("E" in access).lower()}</allowEdit><allowRead>true</allowRead><modifyAllRecords>false</modifyAllRecords><object>{obj}</object><viewAllRecords>false</viewAllRecords></objectPermissions>\n'
    if name != 'TF_AgentAccess':
        for obj in sorted(objects):
            body += f'    <tabSettings><tab>{obj}</tab><visibility>Visible</visibility></tabSettings>\n'
    write(f'permissionsets/{name}.permissionset-meta.xml', 'PermissionSet', body)
print('Four permission sets generated; not assigned to any user.')
