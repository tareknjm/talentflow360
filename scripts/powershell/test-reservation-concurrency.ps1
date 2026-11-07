param([string]$TargetOrg = 'TFDev')
$ErrorActionPreference = 'Stop'
if ($TargetOrg -ne 'TFDev') { throw 'Test borné à TFDev.' }
$env:SHELL = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $taskRoot
function Query-Safe([string]$Soql) {
    $response = sf.cmd data query --query $Soql --target-org $TargetOrg --json | ConvertFrom-Json
    if ($response.status -ne 0) { throw 'Lecture Salesforce impossible ; test annulé.' }
    return $response.result
}
$org = Query-Safe 'SELECT OrganizationType, InstanceName FROM Organization LIMIT 1'
if ($org.records[0].OrganizationType -ne 'Developer Edition' -or $org.records[0].InstanceName -ne 'CAN96') { throw 'Cible de développement attendue non confirmée.' }
$profiles = @( (Query-Safe "SELECT Id, CandidateCode__c, DemoBatch__c FROM TalentProfile__c WHERE CandidateCode__c IN ('TF-DEMO-001','TF-DEMO-002') AND Status__c = 'ReadyForReview' ORDER BY CandidateCode__c").records )
if ($profiles.Count -ne 2 -or @($profiles | Where-Object { $_.DemoBatch__c -ne 'TF360-DEMO-V1' }).Count -ne 0) { throw 'Deux dossiers synthétiques initiaux sont requis ; aucun reset automatique.' }
$slots = @( (Query-Safe "SELECT Id, DemoBatch__c FROM InterviewSlot__c WHERE DemoKey__c = 'TF360-DEMO-V1-SLOT-1' AND Status__c = 'Available'").records )
if ($slots.Count -ne 1 -or $slots[0].DemoBatch__c -ne 'TF360-DEMO-V1') { throw 'Créneau synthétique libre initial requis.' }
$taskOut = Join-Path $taskRoot 'test-results/concurrency'
New-Item -ItemType Directory -Force -Path $taskOut | Out-Null
$taskSlot = $slots[0].Id
$taskLaunch = [DateTime]::UtcNow.AddSeconds(20).ToString('o')
$jobs = @()
foreach ($profile in $profiles) {
    $code = $profile.CandidateCode__c
    $file = Join-Path $taskOut ($code + '.apex')
    $apex = @"
TF_ReserveInterview.Request request = new TF_ReserveInterview.Request();
request.candidateCode = '$code'; request.slotId = '$taskSlot';
request.requestKey = 'CONCURRENT-$code'; request.confirmed = true;
System.debug(LoggingLevel.INFO, 'TF_RACE_START=' + System.now().getTime());
TF_ActionResult result = TF_ReserveInterview.run(new List<TF_ReserveInterview.Request>{request})[0];
// Hold the real transaction locks for two seconds to exercise contention.
Long releaseAt = System.now().getTime() + 2000;
while (System.now().getTime() < releaseAt) { }
System.debug(LoggingLevel.INFO, 'TF_RACE_RESULT=' + result.resultCode);
System.debug(LoggingLevel.INFO, 'TF_RACE_END=' + System.now().getTime());
"@
    [IO.File]::WriteAllText($file, $apex, (New-Object Text.UTF8Encoding($false)))
    $jobs += Start-Job -ArgumentList $taskRoot,$file,$taskLaunch,$code -ScriptBlock {
        param($root,$file,$launch,$code)
        Set-Location -LiteralPath $root
        $env:SHELL = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
        $when = [DateTime]::Parse($launch).ToUniversalTime()
        while ([DateTime]::UtcNow -lt $when) { Start-Sleep -Milliseconds 50 }
        $run = sf.cmd apex run --file $file --target-org TFDev --json | ConvertFrom-Json
        $logs = [string]$run.result.logs
        [pscustomobject]@{
            code=$code; success=($run.status -eq 0 -and $run.result.success)
            result=[regex]::Match($logs,'TF_RACE_RESULT=([A-Z_]+)').Groups[1].Value
            started=[regex]::Match($logs,'TF_RACE_START=([0-9]+)').Groups[1].Value
            ended=[regex]::Match($logs,'TF_RACE_END=([0-9]+)').Groups[1].Value
        }
    }
}
$jobs | Wait-Job -Timeout 45 | Out-Null
if (@($jobs | Where-Object State -ne 'Completed').Count -ne 0) {
    $jobs | Stop-Job
    throw 'Exécution concurrente incomplète ; vérifier les réservations avant toute relance.'
}
$results = @($jobs | Receive-Job | Select-Object code,success,result,started,ended)
$jobs | Remove-Job
if ($results.Count -ne 2 -or @($results | Where-Object { -not $_.success }).Count -ne 0) { throw 'Appel Apex non réussi ; vérifier les journaux restreints.' }
$overlap = [long]$results[0].started -lt [long]$results[1].ended -and [long]$results[1].started -lt [long]$results[0].ended
$ids = ($profiles | ForEach-Object { "'" + $_.Id + "'" }) -join ','
$count = (Query-Safe "SELECT COUNT() FROM InterviewSlot__c WHERE TalentProfile__c IN ($ids) AND Status__c = 'Reserved'").totalSize
$passed = $overlap -and @($results | Where-Object result -eq 'SUCCESS').Count -eq 1 -and @($results | Where-Object result -eq 'SLOT_UNAVAILABLE').Count -eq 1 -and $count -eq 1
$proof = [pscustomobject]@{dateUtc=[DateTime]::UtcNow.ToString('o');target='TFDev Developer Edition CAN96';overlappingServerIntervals=$overlap;reservedSlots=$count;status= $(if ($passed) {'Passed'} else {'Failed'});calls=$results}
$proof | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskOut 'result.json') -Encoding UTF8
$proof | ConvertTo-Json -Depth 5
if (-not $passed) { throw 'Concurrence non prouvée ou invariant de réservation non satisfait.' }
