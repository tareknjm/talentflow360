"""Create missing API-68 descriptors only; never replace an existing descriptor."""
from pathlib import Path
root=Path(__file__).resolve().parents[2] / 'force-app/main/default'
for directory,suffix,kind in [('classes','.cls','ApexClass'),('triggers','.trigger','ApexTrigger')]:
    for path in (root/directory).glob('*'+suffix):
        descriptor=path.with_name(path.name+'-meta.xml')
        if not descriptor.exists():
            descriptor.write_text(f'<?xml version="1.0" encoding="UTF-8"?>\n<{kind} xmlns="http://soap.sforce.com/2006/04/metadata"><apiVersion>68.0</apiVersion><status>Active</status></{kind}>\n',encoding='utf-8')
            print(descriptor.relative_to(root))
