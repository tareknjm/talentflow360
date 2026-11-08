"""Stage only native guided UI components. Source metadata remains authoritative."""
from pathlib import Path
import shutil
root=Path(__file__).resolve().parents[2]
source=root/'force-app/main/default'; target=root/'test-results/ux-guided-deploy'
files=[
    'flexipages/TF_TalentWorkspace.flexipage-meta.xml',
    'flexipages/TF_MyWorkspace.flexipage-meta.xml',
    'applications/TalentFlow360.app-meta.xml',
    'tabs/TF_MyWorkspace.tab-meta.xml',
    'permissionsets/TF_WorkspaceAccess.permissionset-meta.xml',
]
existing={p.relative_to(target).as_posix() for p in target.rglob('*') if p.is_file()} if target.exists() else set()
if not existing<=set(files): raise RuntimeError('Unexpected staging component; inspect before deployment.')
for name in files:
    dest=target/name; dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(source/name,dest)
print('Five guided UI components staged; no object, business field, Apex or Flow.')
