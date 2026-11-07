$ErrorActionPreference='Stop'
$env:SHELL='C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $taskRoot
function Read-TF([string]$Query) {
    $r=sf.cmd data query --query $Query --target-org TFDev --json | ConvertFrom-Json
    if ($r.status -ne 0) { throw 'Lecture TFDev impossible.' }
    return $r.result
}
$org=Read-TF 'SELECT OrganizationType, InstanceName, TimeZoneSidKey FROM Organization LIMIT 1'
if ($org.records[0].OrganizationType -ne 'Developer Edition' -or $org.records[0].InstanceName -ne 'CAN96' -or $org.records[0].TimeZoneSidKey -ne 'America/Los_Angeles') { throw 'Cible ou fuseau inattendu ; probe annulée.' }
$r=sf.cmd apex run --file scripts/apex/prepareScheduledProbe.apex --target-org TFDev --json | ConvertFrom-Json
if ($r.status -ne 0 -or -not $r.result.success) { throw 'Fixture synthétique non préparée.' }
$step=(Read-TF "SELECT Id FROM JourneyStep__c WHERE TalentProfile__r.CandidateCode__c='TF-DEMO-001' AND DemoBatch__c='TF360-DEMO-V1' AND Stage__c='Day1' AND Status__c='Pending'").records
if (@($step).Count -ne 1) { throw 'Une seule étape de test est attendue.' }
$taskOutput=Join-Path $taskRoot 'test-results/scheduled-probe'
New-Item -ItemType Directory -Force -Path (Join-Path $taskOutput 'flows') | Out-Null
$taskFireUtc=[DateTime]::UtcNow.AddMinutes(4)
$taskFireLocal=[TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($taskFireUtc,'Pacific Standard Time')
[xml]$flow=Get-Content -Raw -Encoding UTF8 -LiteralPath 'force-app/main/default/flows/TF_JourneyDaily.flow-meta.xml'
$flow.Flow.label='TF Schedule Probe - synthetic only'
$flow.Flow.description='One-time real schedule test on one marked synthetic Day1 step. Uses the actual daily execution action, without simulation.'
$flow.Flow.interviewLabel='TF Schedule Probe {!$Flow.CurrentDateTime}'
$flow.Flow.start.schedule.frequency='Once'
$flow.Flow.start.schedule.startDate=$taskFireLocal.ToString('yyyy-MM-dd')
$flow.Flow.start.schedule.startTime=$taskFireLocal.ToString('HH:mm:ss')+'.000Z'
foreach ($pair in @(@('Id',[string]$step.Id),@('DemoBatch__c','TF360-DEMO-V1'))) {
    $filter=$flow.CreateElement('filters',$flow.DocumentElement.NamespaceURI)
    $field=$flow.CreateElement('field',$flow.DocumentElement.NamespaceURI);$field.InnerText=$pair[0];[void]$filter.AppendChild($field)
    $operator=$flow.CreateElement('operator',$flow.DocumentElement.NamespaceURI);$operator.InnerText='EqualTo';[void]$filter.AppendChild($operator)
    $value=$flow.CreateElement('value',$flow.DocumentElement.NamespaceURI)
    $literal=$flow.CreateElement('stringValue',$flow.DocumentElement.NamespaceURI);$literal.InnerText=$pair[1];[void]$value.AppendChild($literal);[void]$filter.AppendChild($value)
    [void]$flow.Flow.start.InsertBefore($filter,$flow.Flow.start.SelectSingleNode('*[local-name()="object"]'))
}
$taskFile=Join-Path $taskOutput 'flows/TF_JourneyScheduleProbe.flow-meta.xml'
$flow.Save($taskFile)
$configuration=[pscustomobject]@{target='TFDev';stepId=[string]$step.Id;plannedUtc=$taskFireUtc.ToString('o');timezone='America/Los_Angeles';localDate=$taskFireLocal.ToString('yyyy-MM-dd');localTime=$taskFireLocal.ToString('HH:mm:ss')}
$configuration | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskOutput 'configuration.json') -Encoding UTF8
$deploy=sf.cmd project deploy start --source-dir $taskFile --target-org TFDev --test-level NoTestRun --wait 1 --json | ConvertFrom-Json
[pscustomobject]@{status=$deploy.status;message=$deploy.message;job=$deploy.result.id;deploymentStatus=$deploy.result.status;plannedUtc=$configuration.plannedUtc;failures=@($deploy.result.details.componentFailures | Select-Object fullName,problem)} | ConvertTo-Json -Depth 5
if ($deploy.status -ne 0 -or $deploy.result.status -ne 'Succeeded') { throw 'Probe non déployée ; aucune preuve de déclenchement.' }
