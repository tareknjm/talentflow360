"""Build an explicit backend manifest from existing source components.

Agentforce authoring/publication is intentionally a separate workflow.
"""
from pathlib import Path
from xml.sax.saxutils import escape

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'force-app/main/default'
manifest=ROOT/'manifest/package.xml'
probe=ROOT/'manifest/probe.xml'
if not probe.exists(): probe.write_bytes(manifest.read_bytes())
types={
    'ApexClass':('classes','*.cls-meta.xml','.cls-meta.xml'),
    'ApexTrigger':('triggers','*.trigger-meta.xml','.trigger-meta.xml'),
    'CustomApplication':('applications','*.app-meta.xml','.app-meta.xml'),
    'CustomObject':('objects','*/*.object-meta.xml','.object-meta.xml'),
    'CustomPermission':('customPermissions','*.customPermission-meta.xml','.customPermission-meta.xml'),
    'CustomTab':('tabs','*.tab-meta.xml','.tab-meta.xml'),
    'Flow':('flows','*.flow-meta.xml','.flow-meta.xml'),
    'Layout':('layouts','*.layout-meta.xml','.layout-meta.xml'),
    'PermissionSet':('permissionsets','*.permissionset-meta.xml','.permissionset-meta.xml'),
    'Profile':('profiles','*.profile-meta.xml','.profile-meta.xml'),
    'QuickAction':('quickActions','*.quickAction-meta.xml','.quickAction-meta.xml'),
}
body='<?xml version="1.0" encoding="UTF-8"?>\n<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n'
for kind,(directory,pattern,suffix) in types.items():
    members=sorted(path.name.removesuffix(suffix) for path in (BASE/directory).glob(pattern))
    if kind=='PermissionSet':
        # Requires the published agent; deploy after publication with agent-access.xml.
        members=[name for name in members if name!='TF_AssistantAccess']
    if not members: continue
    body+='    <types>\n'+''.join(f'        <members>{escape(name)}</members>\n' for name in members)+f'        <name>{kind}</name>\n    </types>\n'
body+='    <version>68.0</version>\n</Package>\n'
manifest.write_text(body,encoding='utf-8')
print('Backend manifest generated; original probe manifest preserved. No remote mutation.')
