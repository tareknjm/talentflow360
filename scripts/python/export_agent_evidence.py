"""Export action-only evidence from a CLI preview. Never export prompts or context.

Usage: python scripts/python/export_agent_evidence.py RESPONSE_JSON OUTPUT_JSON [--published-runtime]
Reads the selected live session from test-results/agent-preview/session.json.
"""
import hashlib
import json
import sys
from datetime import datetime,timezone
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
def read(path): return json.loads(path.read_text(encoding='utf-8-sig'))
session=read(ROOT/'test-results/agent-preview/session.json')
response=read(ROOT/sys.argv[1])
folder=ROOT/'.sfdx/agents/TalentFlow_Assistant/sessions'/session['sessionId']
if not (folder/'metadata.json').exists():
    # Published runtime sessions use the agent's Salesforce ID as directory name.
    matches=list((ROOT/'.sfdx/agents').glob('*/sessions/'+session['sessionId']+'/metadata.json'))
    if len(matches)!=1: raise RuntimeError('Expected exactly one selected session metadata file.')
    folder=matches[0].parent
metadata=read(folder/'metadata.json')
published=len(sys.argv)>3 and sys.argv[3]=='--published-runtime'
if published:
    if metadata.get('mockMode') is not None or not metadata.get('agentId') or folder.parents[1].name!=metadata['agentId']:
        raise RuntimeError('Expected a published agent runtime session, not an authoring preview.')
    if response.get('agentApiName')!='TalentFlow_Assistant': raise RuntimeError('Unexpected published agent.')
    mode='Published Runtime (no mockMode field)'
elif metadata.get('mockMode')=='Live Test':
    mode='Live Test'
else:
    raise RuntimeError('Live Test required; simulated evidence refused.')
allowed_names={'connection_probe','get_brief','list_slots','reserve_interview','get_onboarding'}
allowed_inputs={'candidateCode','periodStart','periodEnd','slotId','requestKey','confirmed'}
allowed_payload={'candidateCode','role','javaEvidence','springEvidence','availability','missingInformation','slots','slotId','start','end','steps','stage','dueDate','status','nextTasks','executionMode'}
def validate_payload(value):
    if isinstance(value,dict):
        if not set(value)<=allowed_payload: raise RuntimeError('Unexpected output field; evidence not exported.')
        for item in value.values(): validate_payload(item)
    elif isinstance(value,list):
        for item in value: validate_payload(item)
invocations=[]
for message in response.get('messages',[]):
    plan_id=message.get('planId')
    if not plan_id: continue
    trace=read(folder/'traces'/(plan_id+'.json'))
    for step in trace.get('plan',[]):
        if step.get('type')!='FunctionStep': continue
        function=step['function']
        if function.get('name') not in allowed_names: raise RuntimeError('Unexpected action; evidence not exported.')
        inputs=function.get('input',{})
        if not set(inputs)<=allowed_inputs: raise RuntimeError('Unexpected input field; evidence not exported.')
        output=function.get('output',{})
        safe={key:output[key] for key in ('safeSummary','resultCode','payloadJson') if key in output}
        if 'payloadJson' in safe and safe['payloadJson'] is not None:
            payload=json.loads(safe['payloadJson']);validate_payload(payload);safe['payload']=payload;del safe['payloadJson']
        invocations.append({'action':function['name'],'inputs':inputs,'executionStatus':output.get('__action_execution_status__'),'outputs':safe})
script=ROOT/'force-app/main/default/aiAuthoringBundles/TalentFlow_Assistant/TalentFlow_Assistant.agent'
evidence={'observedAtUtc':datetime.now(timezone.utc).isoformat(),'target':'TFDev Developer Edition CAN96','apiVersion':'68.0','agentType':'AgentforceEmployeeAgent','mode':mode,'sessionStartedAtUtc':metadata.get('startTime'),'configurationSha256':hashlib.sha256(script.read_bytes()).hexdigest(),'invocations':invocations}
path=ROOT/sys.argv[2];path.parent.mkdir(parents=True,exist_ok=True)
path.write_text(json.dumps(evidence,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'{len(invocations)} actual action(s) exported without prompts or identity.')
