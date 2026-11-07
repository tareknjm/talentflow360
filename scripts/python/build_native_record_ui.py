"""Build the first native UI increment from the reviewed, isolated org backup.

Bootstrap only: refuses an existing TF_TalentWorkspace page. Not a data migration.
"""
from pathlib import Path
from copy import deepcopy
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'force-app/main/default'
BACKUP = ROOT / 'test-results/ui-baseline'
URI = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', URI)
Q = lambda name: '{'+URI+'}'+name

def el(parent, tag, text=None):
    node = ET.SubElement(parent, Q(tag))
    if text is not None: node.text = str(text)
    return node

def write(path, root):
    path.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space='    ')
    ET.ElementTree(root).write(path, encoding='UTF-8', xml_declaration=True)

page_path = BASE/'flexipages/TF_TalentWorkspace.flexipage-meta.xml'
if page_path.exists(): raise RuntimeError('Existing page: inspect instead of regenerating.')
page = ET.Element(Q('FlexiPage'))

def region(name, kind='Facet'):
    node = el(page, 'flexiPageRegions')
    return node, name, kind

def finish(region_data):
    node, name, kind = region_data
    el(node, 'name', name); el(node, 'type', kind)

def component(region_data, name, identifier, **props):
    node = el(el(region_data[0], 'itemInstances'), 'componentInstance')
    for key, value in props.items():
        p = el(node, 'componentInstanceProperties'); el(p, 'name', key); el(p, 'value', value)
    el(node, 'componentName', name); el(node, 'identifier', identifier)
    return node

def rich(region_data, identifier, html):
    return component(region_data, 'flexipage:richText', identifier, richTextValue=html)

def field_section(name, label, columns):
    column_names=[]
    for index, fields in enumerate(columns):
        field_region=region(name+'_fields_'+str(index)); column_names.append(field_region[1])
        for field in fields:
            node=el(el(field_region[0], 'itemInstances'), 'fieldInstance')
            prop=el(node, 'fieldInstanceProperties'); el(prop,'name','uiBehavior'); el(prop,'value','readonly')
            el(node,'fieldItem','Record.'+field); el(node,'identifier',name+'_'+field)
        finish(field_region)
    columns_region=region(name+'_columns')
    for index, field_region_name in enumerate(column_names):
        component(columns_region,'flexipage:column',name+'_column_'+str(index),body=field_region_name)
    finish(columns_region)
    content=region(name+'_content')
    component(content,'flexipage:fieldSection',name+'_section',columns=columns_region[1],horizontalAlignment='false',label=label)
    finish(content)
    return content[1]

header=region('header','Region')
component(header,'force:highlightsPanel','talentHighlights',collapsed='false',enableActionsConfiguration='false',hideChatterActions='true',numVisibleActions='3')
finish(header)
overview=field_section('overview','Informations du dossier',[
    ['CandidateCode__c','Role__c','Status__c'],['Availability__c','StartDate__c']])
preparation=field_section('preparation','Preuves disponibles',[
    ['JavaEvidence__c'],['SpringEvidence__c']])
interviews=region('interviews_content')
rich(interviews,'interviewTimezone','<h2>Réservations du dossier</h2><p>Les horaires suivent le fuseau de votre utilisateur Salesforce. Vérifiez ce fuseau avant de confirmer un créneau avec l’assistant.</p>')
component(interviews,'force:relatedListSingleContainer','interviewList',parentFieldApiName='TalentProfile__c.Id',relatedListApiName='InterviewSlots__r',relatedListComponentOverride='NONE',rowsToDisplay='5',showActionBar='false')
finish(interviews)
journey=region('journey_content')
rich(journey,'journeyMeaning','<h2>Votre parcours d’intégration</h2><p>Le parcours est généré après validation RH. Si la liste est vide, vérifiez l’état du dossier.</p><p><strong>Exécutée / Completed</strong> signifie que les tâches ont été générées, pas que le travail humain est terminé. <strong>Simulation</strong> identifie un traitement de démonstration créant des tâches synthétiques.</p>')
component(journey,'force:relatedListSingleContainer','journeyList',parentFieldApiName='TalentProfile__c.Id',relatedListApiName='JourneySteps__r',relatedListComponentOverride='NONE',rowsToDisplay='10',showActionBar='false')
finish(journey)
tabs=region('talent_tabs')
for identifier,title,body in [('overviewTab','Vue d’ensemble',overview),('preparationTab','Préparation',preparation),('interviewsTab','Entretiens',interviews[1]),('journeyTab','Intégration',journey[1])]:
    props={'body':body,'title':title}
    if identifier=='overviewTab': props['active']='true'
    component(tabs,'flexipage:tab',identifier,**props)
finish(tabs)
main=region('main','Region'); component(main,'flexipage:tabset','talentTabset',tabs=tabs[1]); finish(main)
sidebar=region('sidebar','Region')
rich(sidebar,'assistantGuide','<h2>Préparer la prochaine action</h2><p>Ouvrez le panneau <strong>TalentFlow Assistant</strong> avec le code candidat de ce dossier.</p><ul><li>Lire le brief et préparer trois questions.</li><li>Consulter les créneaux et réserver après confirmation.</li><li>Lire les étapes du parcours.</li></ul><p>Les preuves restent déclarées ou enregistrées selon leur provenance. L’assistant ne classe pas les candidats et ne décide pas de l’embauche.</p>')
rich(sidebar,'humanDecisionGuide','<h2>Une décision humaine séparée</h2><p>Les RH autorisés utilisent <strong>Valider l’embauche</strong>, puis le formulaire dédié. La satisfaction est saisie après validation.</p><p>Fermez ces formulaires avant de reprendre la conversation. Aucune identité, satisfaction ou validation RH ne doit être transmise au chat.</p>')
finish(sidebar)
el(page,'masterLabel','TalentFlow — Espace candidat')
el(page,'sobjectType','TalentProfile__c')
el(el(page,'template'),'name','flexipage:recordHomeTemplateDesktop')
el(page,'type','RecordPage')
write(page_path,page)

# Preserve all retrieved application properties; change navigation/branding and one app-scoped assignment.
app=ET.parse(BACKUP/'applications/TalentFlow360.app-meta.xml').getroot()
assert not app.findall(Q('actionOverrides')) and not app.findall(Q('profileActionOverrides')), 'Unexpected org assignment; inspect manually.'
for node in app.findall(Q('tabs')): app.remove(node)
index=list(app).index(app.find(Q('uiType')))
for offset,tab in enumerate(['TalentProfile__c','InterviewSlot__c','JourneyStep__c','standard-Task']):
    node=ET.Element(Q('tabs')); node.text=tab; app.insert(index+offset,node)
override=ET.Element(Q('actionOverrides'))
for tag,value in [('actionName','View'),('content','TF_TalentWorkspace'),('formFactor','Large'),('skipRecordTypeSelect','false'),('type','Flexipage'),('pageOrSobjectType','TalentProfile__c')]: el(override,tag,value)
app.insert(0,override)
brand=ET.Element(Q('brand')); el(brand,'headerColor','#102D50'); el(brand,'shouldOverrideOrgTheme','true'); app.insert(1,brand)
write(BASE/'applications/TalentFlow360.app-meta.xml',app)

# Reorder the existing layout, preserving action configuration and its other settings.
layout=ET.parse(BACKUP/'layouts/TalentProfile__c-TalentFlow.layout-meta.xml').getroot()
old_items={item.findtext(Q('field')):deepcopy(item) for section in layout.findall(Q('layoutSections')) for col in section.findall(Q('layoutColumns')) for item in col.findall(Q('layoutItems')) if item.find(Q('field')) is not None}
for section in list(layout.findall(Q('layoutSections'))):
    if section.findtext(Q('style'))!='CustomLinks': layout.remove(section)
groups=[('Dossier et disponibilité',[['CandidateCode__c','Role__c','Status__c'],['Availability__c','StartDate__c','Name']]),('Préparation de l’entretien',[['JavaEvidence__c'],['SpringEvidence__c']]),('Validation RH — lecture seule',[['HumanApproved__c','ApprovedBy__c'],['ApprovedAt__c']])]
for index,(label,columns) in enumerate(groups):
    section=ET.Element(Q('layoutSections'))
    for tag,value in [('customLabel','true'),('detailHeading','true'),('editHeading','true'),('label',label)]: el(section,tag,value)
    for fields in columns:
        col=el(section,'layoutColumns')
        for field in fields: col.append(old_items[field])
    el(section,'style','TwoColumnsTopToBottom'); layout.insert(index,section)
related_specs=[('InterviewSlot__c.TalentProfile__c',['NAME','Start__c','End__c','Status__c']),('JourneyStep__c.TalentProfile__c',['NAME','Stage__c','DueDate__c','Status__c','ExecutionMode__c'])]
for related_name,fields in related_specs:
    assert not any(n.findtext(Q('relatedList'))==related_name for n in layout.findall(Q('relatedLists')))
    item=ET.Element(Q('relatedLists'))
    for field in fields: el(item,'fields',field)
    el(item,'relatedList',related_name)
    position=next((i for i,n in enumerate(layout) if n.tag==Q('showEmailCheckbox')),len(layout))
    layout.insert(position,item)
write(BASE/'layouts/TalentProfile__c-TalentFlow.layout-meta.xml',layout)

compact=ET.Element(Q('CompactLayout')); el(compact,'fullName','TF_TalentSummary')
for field in ['CandidateCode__c','Role__c','Status__c','Availability__c','StartDate__c']: el(compact,'fields',field)
el(compact,'label','TalentFlow — Synthèse du dossier')
write(BASE/'objects/TalentProfile__c/compactLayouts/TF_TalentSummary.compactLayout-meta.xml',compact)
obj=ET.parse(BACKUP/'objects/TalentProfile__c/TalentProfile__c.object-meta.xml').getroot()
obj.find(Q('compactLayoutAssignment')).text='TF_TalentSummary'
write(BASE/'objects/TalentProfile__c/TalentProfile__c.object-meta.xml',obj)
print('Native UI generated from reviewed org backup. No data, permission, Apex or Flow mutation.')
