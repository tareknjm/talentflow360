"""Bootstrap native guided actions and an app-scoped workspace from org backups.

The generated metadata is the maintained source. Does not change business data.
"""
from pathlib import Path
import xml.etree.ElementTree as E

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'force-app/main/default'
BACKUP=ROOT/'test-results/ux-guided-baseline'
URI='http://soap.sforce.com/2006/04/metadata'
E.register_namespace('',URI)
q=lambda name:'{'+URI+'}'+name
def add(parent,name,value=None):
    node=E.SubElement(parent,q(name))
    if value is not None: node.text=str(value)
    return node
def write(path,node):
    path.parent.mkdir(parents=True,exist_ok=True); E.indent(node,space='    ')
    E.ElementTree(node).write(path,encoding='UTF-8',xml_declaration=True)
def component(region,name,identifier,**props):
    node=add(add(region,'itemInstances'),'componentInstance')
    for key,value in props.items():
        prop=add(node,'componentInstanceProperties'); add(prop,'name',key); add(prop,'value',value)
    add(node,'componentName',name); add(node,'identifier',identifier)
    return node
def visibility(node,criteria):
    rule=add(node,'visibilityRule')
    if len(criteria)>1: add(rule,'booleanFilter',' AND '.join(str(i+1) for i in range(len(criteria))))
    for left,operator,right in criteria:
        c=add(rule,'criteria'); add(c,'leftValue',left); add(c,'operator',operator); add(c,'rightValue',right)
def region(page,name,kind='Facet'):
    node=add(page,'flexiPageRegions')
    return node,name,kind
def finish(data):
    node,name,kind=data; add(node,'name',name); add(node,'type',kind)

home_path=BASE/'flexipages/TF_MyWorkspace.flexipage-meta.xml'
if home_path.exists(): raise RuntimeError('Workspace exists: inspect before replacing.')
record=E.parse(BACKUP/'flexipages/TF_TalentWorkspace.flexipage-meta.xml').getroot()
header=next(c for c in record.iter(q('componentInstance')) if c.findtext(q('identifier'))=='talentHighlights')
assert not any(p.findtext(q('name'))=='actionNames' for p in header.findall(q('componentInstanceProperties')))
for prop in header.findall(q('componentInstanceProperties')):
    if prop.findtext(q('name'))=='enableActionsConfiguration': prop.find(q('value')).text='true'
names=E.Element(q('componentInstanceProperties')); add(names,'name','actionNames'); values=add(names,'valueList')
for action,criteria in [
    ('TalentProfile__c.TF_ApproveHiring',[('{!Record.Status__c}','EQUAL','InterviewScheduled'),('{!$Permission.CustomPermission.TF_ApproveHiring}','EQUAL','true')]),
    ('TalentProfile__c.TF_CapturePulse',[('{!Record.Status__c}','EQUAL','Hired')]),
    ('Edit',[]),
]:
    value=add(values,'valueListItems'); add(value,'value',action)
    if criteria: visibility(value,criteria)
header.insert(0,names)
for comp in record.iter(q('componentInstance')):
    if comp.findtext(q('componentName'))=='force:relatedListSingleContainer':
        for prop in comp.findall(q('componentInstanceProperties')):
            if prop.findtext(q('name'))=='relatedListComponentOverride': prop.find(q('value')).text='ADVGRID'
            if prop.findtext(q('name'))=='showActionBar': prop.find(q('value')).text='false'
sidebar=next(r for r in record.findall(q('flexiPageRegions')) if r.findtext(q('name'))=='sidebar')
# Insert state guidance before the existing, non-private assistant help.
states=[
    ('Draft','Compléter le dossier','Renseignez le rôle, les preuves disponibles et la disponibilité. Une information inconnue reste à vérifier.'),
    ('ReadyForReview','Préparer l’entretien','Consultez les preuves dans Préparation. Ouvrez TalentFlow Assistant avec le code candidat pour préparer les questions et rechercher un créneau.'),
    ('InterviewRequested','Choisir un créneau','Consultez les créneaux réels avec TalentFlow Assistant. Confirmez le code candidat et l’horaire avant toute réservation.'),
    ('InterviewScheduled','Consulter la réservation','L’entretien est planifié. Ouvrez Entretiens pour vérifier la réservation. La décision RH appartient au parcours humain autorisé.'),
    ('Hired','Suivre l’intégration','L’embauche est validée. Ouvrez Intégration pour consulter les étapes et leurs échéances. Les tâches générées restent à accomplir par les personnes concernées.'),
]
for index,(state,title,text) in enumerate(states):
    temporary=E.Element('temporary')
    node=component(temporary,'flexipage:richText','nextAction'+state,richTextValue='<h2>Prochaine action : '+title+'</h2><p>'+text+'</p>')
    visibility(node,[('{!Record.Status__c}','EQUAL',state)])
    sidebar.insert(index,temporary[0])
write(BASE/'flexipages/TF_TalentWorkspace.flexipage-meta.xml',record)

home=E.Element(q('FlexiPage'))
panels=[]
for identifier,title,entity,view in [
    ('review','Dossiers à examiner','TalentProfile__c','TF_AwaitingReview'),
    ('reservations','Réservations','InterviewSlot__c','TF_ReservedSlots'),
    ('onboarding','Étapes à exécuter','JourneyStep__c','TF_OpenSteps'),
]:
    content=region(home,identifier+'Content')
    component(content[0],'flexipage:filterListCard',identifier+'List',entityName=entity,filterName=view,pageSize='8')
    finish(content); panels.append((identifier,title,content[1]))
tabs=region(home,'workspaceTabs')
for index,(identifier,title,content) in enumerate(panels):
    props={'body':content,'title':title}
    if index==0: props['active']='true'
    component(tabs[0],'flexipage:tab',identifier+'Tab',**props)
finish(tabs)
main=region(home,'main','Region')
component(main[0],'flexipage:richText','workspaceWelcome',richTextValue='<h1>Mon espace TalentFlow</h1><p>Préparez les dossiers, consultez les réservations et suivez les prochaines étapes, depuis un seul espace.</p><p><strong>Parcours :</strong> compléter le dossier → préparer l’entretien → réserver après confirmation → décision RH humaine → intégration.</p><p>Les listes respectent votre accès aux données. Elles couvrent les dossiers accessibles, pas uniquement ceux dont vous êtes propriétaire. Les réservations affichées peuvent inclure des dates passées ; vérifiez les horaires et votre fuseau.</p>')
component(main[0],'flexipage:tabset','workspaceTabset',tabs=tabs[1])
component(main[0],'flexipage:richText','workspaceHelp',richTextValue='<p>Ouvrez un dossier depuis sa référence pour accéder à sa préparation, ses entretiens et son intégration. Une liste vide signifie qu’aucun élément n’est disponible dans cette vue et votre périmètre d’accès.</p><p><strong>Simulation</strong> et exécution planifiée restent distinctes. Les validations RH et la satisfaction ne sont jamais des actions de l’assistant.</p>')
finish(main); add(home,'masterLabel','TalentFlow — Mon espace'); add(add(home,'template'),'name','flexipage:defaultAppHomeTemplate'); add(home,'type','AppPage')
write(home_path,home)

tab=E.Element(q('CustomTab')); add(tab,'flexiPage','TF_MyWorkspace'); add(tab,'label','Mon espace'); add(tab,'motif','Custom57: Building Block')
write(BASE/'tabs/TF_MyWorkspace.tab-meta.xml',tab)
app=E.parse(BACKUP/'applications/TalentFlow360.app-meta.xml').getroot()
tabs_nodes=app.findall(q('tabs')); position=list(app).index(tabs_nodes[0]); tab_node=E.Element(q('tabs')); tab_node.text='TF_MyWorkspace'; app.insert(position,tab_node)
write(BASE/'applications/TalentFlow360.app-meta.xml',app)
permission=E.Element(q('PermissionSet')); add(permission,'hasActivationRequired','false'); add(permission,'label','TalentFlow — Accès à Mon espace')
setting=add(permission,'tabSettings'); add(setting,'tab','TF_MyWorkspace'); add(setting,'visibility','Visible')
write(BASE/'permissionsets/TF_WorkspaceAccess.permissionset-meta.xml',permission)
print('Guided actions and native workspace prepared. No business state, Flow, Apex or existing permission modified.')
