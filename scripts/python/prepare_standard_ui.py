"""Apply French labels and native views without piping non-ASCII code through PowerShell."""
from pathlib import Path
import xml.etree.ElementTree as E
from create_model import BASE, write

NS='http://soap.sforce.com/2006/04/metadata'
E.register_namespace('',NS)
def tag(value): return '{'+NS+'}'+value
def save(path,root):
    E.indent(root,space='    ')
    path.write_bytes(E.tostring(root,encoding='UTF-8',xml_declaration=True))

labels={'JavaBackendDeveloper':'Développement Java backend','QAEngineer':'Ingénierie qualité','NotProvided':'Non fournie','DeclaredProject':'Projet déclaré','RecordedAssessment':'Évaluation consignée','Draft':'Brouillon','ReadyForReview':'À examiner','InterviewRequested':'Entretien demandé','InterviewScheduled':'Entretien planifié','Hired':'Embauche validée','Available':'Libre','Reserved':'Réservé','Cancelled':'Annulée','PreArrival':'J−7','Arrival':'J0','Day1':'J+1','Day30':'J+30','Day60':'J+60','Day90':'J+90','Pending':'À exécuter','Completed':'Exécutée','Failed':'En erreur','NotApplicable':'Sans objet','Prepared':'Préparé','Sent':'Envoyé'}
for path in (BASE/'objects').glob('*/fields/*.xml'):
    root=E.parse(path).getroot()
    values=root.findall('.//'+tag('valueSetDefinition')+'/'+tag('value'))
    if not values: continue
    for value in values:
        name=value.findtext(tag('fullName'))
        if name in labels: value.find(tag('label')).text=labels[name]
    save(path,root)

for name in ('TF_ApproveHiring','TF_CapturePulse','TF_SimulateJourney'):
    path=BASE/'flows'/(name+'.flow-meta.xml');root=E.parse(path).getroot()
    for screen in root.findall(tag('screens')):
        for field in screen.findall(tag('fields')):
            if field.findtext(tag('name'))=='Failure_Message':
                field.find(tag('fieldText')).text='<p>Le traitement a été interrompu. Aucun succès ne peut être confirmé ; vérifiez le dossier avant de réessayer.</p>'
            if field.findtext(tag('name'))=='Simulation_Result':
                field.find(tag('fieldText')).text='<p>Simulation terminée ou étape déjà traitée. Consultez les tâches et le mode d’exécution sur l’étape. Ceci ne prouve pas une échéance future.</p>'
    for decision in root.findall(tag('decisions')):
        if name=='TF_SimulateJourney' and decision.findtext(tag('name'))=='Check_Result':
            decision.find(tag('label')).text='Vérifier la simulation'
            decision.find(tag('defaultConnectorLabel')).text='Non exécutée'
            decision.find(tag('rules')).find(tag('label')).text='Exécutée ou déjà traitée'
    save(path,root)

views=[
 ('TalentProfile__c','TF_AwaitingReview','Dossiers à examiner',['NAME','CandidateCode__c','Role__c','Status__c'],'Status__c','ReadyForReview'),
 ('TalentProfile__c','TF_InterviewScheduled','Entretiens planifiés',['NAME','CandidateCode__c','Role__c','Status__c'],'Status__c','InterviewScheduled'),
 ('InterviewSlot__c','TF_ReservedSlots','Créneaux réservés',['NAME','Start__c','End__c','Status__c'],'Status__c','Reserved'),
 ('JourneyStep__c','TF_OpenSteps','Étapes à exécuter',['NAME','TalentProfile__c','Stage__c','DueDate__c','Status__c'],'Status__c','Pending'),
 ('JourneyStep__c','TF_CompletedSteps','Étapes exécutées',['NAME','TalentProfile__c','Stage__c','ExecutionMode__c','ExecutedAt__c'],'Status__c','Completed'),
]
for obj,name,label,columns,field,value in views:
    relative=f'objects/{obj}/listViews/{name}.listView-meta.xml'
    if (BASE/relative).exists(): continue
    body=f'<fullName>{name}</fullName>'+''.join(f'<columns>{column}</columns>' for column in columns)+f'<filterScope>Everything</filterScope><filters><field>{field}</field><operation>equals</operation><value>{value}</value></filters><label>{label}</label>'
    write(relative,'ListView',body)

path=BASE/'layouts/JourneyStep__c-TalentFlow.layout-meta.xml';root=E.parse(path).getroot()
column=root.find(tag('layoutSections')).find(tag('layoutColumns'))
present={item.findtext(tag('field')) for item in column.findall(tag('layoutItems'))}
for name in ('ExecutedAt__c','ExecutionMode__c','TaskIds__c','IsDue__c'):
    if name not in present:
        item=E.SubElement(column,tag('layoutItems'));E.SubElement(item,tag('behavior')).text='Readonly';E.SubElement(item,tag('field')).text=name
save(path,root)
for name in ('TF_Recruiter','TF_HiringApprover','TF_DemoAdmin'):
    path=BASE/'permissionsets'/(name+'.permissionset-meta.xml');root=E.parse(path).getroot()
    if not any(field.findtext(tag('field'))=='JourneyStep__c.IsDue__c' for field in root.findall(tag('fieldPermissions'))):
        field=E.Element(tag('fieldPermissions'));E.SubElement(field,tag('editable')).text='false';E.SubElement(field,tag('field')).text='JourneyStep__c.IsDue__c';E.SubElement(field,tag('readable')).text='true'
        index=next(i for i,element in enumerate(root) if element.tag in {tag('flowAccesses'),tag('hasActivationRequired')});root.insert(index,field)
    save(path,root)
for path in BASE.rglob('*.xml'):
    root=E.parse(path).getroot()
    for element in root.iter():
        if element.tag in {tag('label'),tag('fieldText'),tag('defaultConnectorLabel')} and element.text and '?' in element.text:
            raise RuntimeError(f'Corrupted visible text in {path}')
print('French text verified, five native views prepared, execution fields visible read-only.')
