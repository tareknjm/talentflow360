"""Stage only the UI increment, including two relationship display labels."""
from pathlib import Path
import shutil

root=Path(__file__).resolve().parents[2]
source=root/'force-app/main/default'
target=root/'test-results/ui-workspace-deploy'
files=[
    'applications/TalentFlow360.app-meta.xml',
    'flexipages/TF_TalentWorkspace.flexipage-meta.xml',
    'layouts/TalentProfile__c-TalentFlow.layout-meta.xml',
    'objects/TalentProfile__c/TalentProfile__c.object-meta.xml',
    'objects/TalentProfile__c/compactLayouts/TF_TalentSummary.compactLayout-meta.xml',
    'objects/InterviewSlot__c/fields/TalentProfile__c.field-meta.xml',
    'objects/JourneyStep__c/fields/TalentProfile__c.field-meta.xml',
    'objects/InterviewSlot__c/listViews/TF_ReservedSlots.listView-meta.xml',
]
expected=set(files)
existing={p.relative_to(target).as_posix() for p in target.rglob('*') if p.is_file()} if target.exists() else set()
if not existing<=expected: raise RuntimeError('Unexpected staging file; inspect before deploying.')
for name in files:
    dest=target/name; dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(source/name,dest)
print('UI staging prepared: '+str(len(files))+' files; two lookup display labels only, no permission, Flow or Apex included.')
