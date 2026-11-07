"""Create the agreed declarative orchestration and standard internal screens once."""
from create_model import write


def action(name, apex, inputs, output=None, connector=None):
    body=f'<actionCalls><name>{name}</name><label>{name}</label><locationX>50</locationX><locationY>200</locationY><actionName>{apex}</actionName><actionType>apex</actionType>'
    if connector: body+=f'<connector><targetReference>{connector}</targetReference></connector>'
    body+='<flowTransactionModel>CurrentTransaction</flowTransactionModel>'
    for key,ref in inputs.items(): body+=f'<inputParameters><name>{key}</name><value><elementReference>{ref}</elementReference></value></inputParameters>'
    if output:
        for key,ref in output.items(): body+=f'<outputParameters><assignToReference>{ref}</assignToReference><name>{key}</name></outputParameters>'
    return body+'</actionCalls>'


def variable(name,kind='String',input=False):
    return f'<variables><name>{name}</name><dataType>{kind}</dataType><isCollection>false</isCollection><isInput>{str(input).lower()}</isInput><isOutput>false</isOutput></variables>'


def screen(name,label,fields,connector=None):
    return f'<screens><name>{name}</name><label>{label}</label><locationX>50</locationX><locationY>300</locationY><allowBack>false</allowBack><allowFinish>true</allowFinish><allowPause>false</allowPause>'+ (f'<connector><targetReference>{connector}</targetReference></connector>' if connector else '')+fields+'<showFooter>true</showFooter><showHeader>true</showHeader></screens>'


def text(name,value):
    return f'<fields><name>{name}</name><fieldText>&lt;p&gt;{value}&lt;/p&gt;</fieldText><fieldType>DisplayText</fieldType></fields>'


def permission_gate(permission,yes,no):
    return f'<decisions><name>Check_Authorization</name><label>Vérifier l’autorisation</label><locationX>50</locationX><locationY>100</locationY><defaultConnector><targetReference>{no}</targetReference></defaultConnector><defaultConnectorLabel>Non autorisé</defaultConnectorLabel><rules><name>Authorized</name><conditionLogic>and</conditionLogic><conditions><leftValueReference>$Permission.{permission}</leftValueReference><operator>EqualTo</operator><rightValue><booleanValue>true</booleanValue></rightValue></conditions><connector><targetReference>{yes}</targetReference></connector><label>Autorisé</label></rules></decisions>'


def screen_flow(api,label,actions,screens,variables,decisions='',lookups='',start='Input_Screen',choices=''):
    content=actions+'<apiVersion>68.0</apiVersion>'+choices+decisions+f'<description>Parcours interne distinct, jamais exposé à Agentforce.</description><interviewLabel>{label} {{!$Flow.CurrentDateTime}}</interviewLabel><label>{label}</label><processMetadataValues><name>BuilderType</name><value><stringValue>LightningFlowBuilder</stringValue></value></processMetadataValues><processType>Flow</processType>'+lookups+screens+f'<start><locationX>50</locationX><locationY>0</locationY><connector><targetReference>{start}</targetReference></connector></start><status>Active</status>'+variables
    write(f'flows/{api}.flow-meta.xml','Flow',content)


def record_flow(api,label,obj,apex,param,filters):
    content=action('Run_Service',apex,{param:'$Record.Id'})+f'<apiVersion>68.0</apiVersion><description>Orchestration interne après sauvegarde ; service transactionnel.</description><interviewLabel>{label} {{!$Flow.CurrentDateTime}}</interviewLabel><label>{label}</label><processType>AutoLaunchedFlow</processType><start><locationX>50</locationX><locationY>0</locationY><connector><targetReference>Run_Service</targetReference></connector><filterLogic>and</filterLogic>{filters}<object>{obj}</object><recordTriggerType>CreateAndUpdate</recordTriggerType><triggerType>RecordAfterSave</triggerType></start><status>Active</status>'
    write(f'flows/{api}.flow-meta.xml','Flow',content)


record_flow('TF_Onboarding','TF — Synchroniser le parcours RH','TalentProfile__c','TF_JourneySync','profileId','<filters><field>Status__c</field><operator>EqualTo</operator><value><stringValue>Hired</stringValue></value></filters><filters><field>HumanApproved__c</field><operator>EqualTo</operator><value><booleanValue>true</booleanValue></value></filters>')
record_flow('TF_PulseAlert','TF — Alerte de satisfaction','PulseResponse__c','TF_PulseAlert','responseId','<filters><field>Score__c</field><operator>LessThanOrEqualTo</operator><value><numberValue>2</numberValue></value></filters><filters><field>AlertTaskId__c</field><operator>IsNull</operator><value><booleanValue>true</booleanValue></value></filters>')

# RH confirmation: server permission remains mandatory, even when the flow is opened directly.
lookups='<recordLookups><name>Get_Profile</name><label>Lire le dossier autorisé</label><locationX>50</locationX><locationY>150</locationY><assignNullValuesIfNoRecordsFound>false</assignNullValuesIfNoRecordsFound><connector><targetReference>Input_Screen</targetReference></connector><filterLogic>and</filterLogic><filters><field>Id</field><operator>EqualTo</operator><value><elementReference>recordId</elementReference></value></filters><getFirstRecordOnly>true</getFirstRecordOnly><object>TalentProfile__c</object><storeOutputAutomatically>true</storeOutputAutomatically></recordLookups>'
fields=text('Summary','Dossier : {!Get_Profile.CandidateCode__c}. Confirmer la décision RH et la date d’arrivée. Cette action est réservée à une personne autorisée.')+'<fields><name>ArrivalDate</name><dataType>Date</dataType><fieldText>Date d’arrivée</fieldText><fieldType>InputField</fieldType><isRequired>true</isRequired></fields><fields><name>Confirmed</name><dataType>Boolean</dataType><defaultValue><booleanValue>false</booleanValue></defaultValue><fieldText>Je confirme personnellement la validation de cette embauche</fieldText><fieldType>InputField</fieldType><isRequired>true</isRequired></fields>'
screens=screen('Input_Screen','Validation RH',fields,'Approve_Hiring')+screen('Result_Screen','Résultat de la validation',text('Result_Message','{!approvalMessage}'))+screen('Denied_Screen','Accès réservé aux RH',text('Denied_Message','Vous ne disposez pas de l’autorisation de validation RH.'))
screen_flow('TF_ApproveHiring','TF — Validation humaine de l’embauche',action('Approve_Hiring','TF_HiringService',{'profileId':'recordId','startDate':'ArrivalDate','confirmed':'Confirmed'},{'message':'approvalMessage'},'Result_Screen'),screens,variable('recordId',input=True)+variable('approvalMessage'),permission_gate('TF_ApproveHiring','Get_Profile','Denied_Screen'),lookups,'Check_Authorization')

choices=''.join(f'<choices><name>Score{score}</name><choiceText>{score} / 5</choiceText><dataType>Number</dataType><value><numberValue>{score}</numberValue></value></choices>' for score in range(1,6))
fields=text('Pulse_Explanation','Réponse confidentielle de suivi d’intégration. Une satisfaction de 1 ou 2 déclenche une tâche de prise de contact RH.')+'<fields><name>SelectedScore</name>'+''.join(f'<choiceReferences>Score{score}</choiceReferences>' for score in range(1,6))+'<dataType>Number</dataType><fieldText>Satisfaction</fieldText><fieldType>DropdownBox</fieldType><isRequired>true</isRequired></fields>'
result_decision='<decisions><name>Check_Result</name><label>Vérifier l’enregistrement</label><locationX>50</locationX><locationY>250</locationY><defaultConnector><targetReference>Failure_Screen</targetReference></defaultConnector><defaultConnectorLabel>Non enregistré</defaultConnectorLabel><rules><name>Saved</name><conditionLogic>and</conditionLogic><conditions><leftValueReference>resultCode</leftValueReference><operator>EqualTo</operator><rightValue><stringValue>SUCCESS</stringValue></rightValue></conditions><connector><targetReference>Success_Screen</targetReference></connector><label>Enregistré</label></rules></decisions>'
screens=screen('Input_Screen','Satisfaction',fields,'Submit_Response')+screen('Success_Screen','Réponse enregistrée',text('Saved_Message','Votre réponse a été enregistrée. Une note de 1 ou 2 crée une tâche confidentielle de prise de contact.'))+screen('Failure_Screen','Réponse non enregistrée',text('Failed_Message','La réponse n’a pas été enregistrée. Vérifiez le dossier et vos accès, puis réessayez.'))
screen_flow('TF_CapturePulse','TF — Saisir la satisfaction',action('Submit_Response','TF_SubmitPulse',{'profileId':'recordId','score':'SelectedScore'},{'resultCode':'resultCode'},'Check_Result'),screens,variable('recordId',input=True)+variable('resultCode'),result_decision,choices=choices)

fields=text('Simulation_Warning','SIMULATION J+30 / J+60 / J+90 — uniquement sur les données de démonstration. Les tâches seront réellement créées ; ceci ne prouve pas l’exécution à une échéance future.')
screens=screen('Input_Screen','Simulation du parcours',fields,'Simulate_Step')+screen('Result_Screen','Simulation — résultat',text('Simulation_Result','Résultat : {!resultCode}. SUCCESS signifie que les tâches de démonstration ont été créées ; ALREADY_COMPLETED indique une étape déjà exécutée.'))+screen('Denied_Screen','Simulation non autorisée',text('Simulation_Denied','Les outils de démonstration sont réservés aux opérateurs autorisés.'))
screen_flow('TF_SimulateJourney','TF — Simulation J+30 / J+60 / J+90',action('Simulate_Step','TF_SimulateJourney',{'stepId':'recordId'},{'resultCode':'resultCode'},'Result_Screen'),screens,variable('recordId',input=True)+variable('resultCode'),permission_gate('TF_DemoTools','Input_Screen','Denied_Screen'),start='Check_Authorization')

for obj,api,label in [('TalentProfile__c','TF_ApproveHiring','Valider l’embauche'),('TalentProfile__c','TF_CapturePulse','Saisir la satisfaction'),('JourneyStep__c','TF_SimulateJourney','Simulation J+30 / J+60 / J+90')]:
    write(f'quickActions/{obj}.{api}.quickAction-meta.xml','QuickAction',f'<flowDefinition>{api}</flowDefinition><label>{label}</label><optionsCreateFeedItem>false</optionsCreateFeedItem><type>Flow</type>')
print('Five active Flow sources and three quick actions prepared; not deployed or UI-tested.')
