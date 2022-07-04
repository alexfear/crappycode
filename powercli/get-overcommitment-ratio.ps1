param ($vcenter,$username,$password)
Connect-VIServer -Server $vcenter -Username $username -Password $password
Set-Content -Path overcommitment.csv -Encoding unicode -Value "Host,vCPUs,pCPUs,vRAM,pRAM,RatioCPU,RatioRAM"; ForEach ($esx in Get-VMHost) {$esxview = Get-View $esx.Id; $pcpus = $esxview.hardware.cpuinfo.numcputhreads; $pram = [math]::round(($esxview.hardware.memorysize/1024/1024/1024)); $vcpus = 0; $vram = 0; Get-VM -Location $esx | ForEach-Object { $vcpus = $vcpus + $_.numcpu; $vram = $vram + $_.memorygb}; $cpu_ratio = [math]::round(($vcpus/$pcpus),2); $ram_ratio = [math]::round(($vram/$pram),2); Write-Output "$esx,$vcpus,$pcpus,$vram,$pram,$cpu_ratio,$ram_ratio" |  Out-File overcommitment.csv -Append }
Disconnect-VIServer -Server $vcenter -force -confirm:$false