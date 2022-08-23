$Date = Get-Date -Format "dd-MM-yyyy" #Get current the date
$PCFilter = '*computer*' # PC Names, you might use * for selection of PC

#If File doesn't exist then creat it or delete
if (Test-Path -Path ".\$Date.csv") {
    Remove-Item ".\$Date.csv" -Recurse
} else {New-Item ".\$Date.csv" -ItemType File | Out-Null}


# Getting computers from AD using selection
$PCNames = Get-ADComputer -Filter "Name -like '$PCFilter'" | Select-Object -ExpandProperty Name

# Getting INFO and add it to CSV-file
foreach ($PCName in $PCNames) {
    try{
        $output = @{
            ComputerName = $PCName # Computer Name
            IsOnline = $false # Check Computer
            PCModel = $Null # Get PC Model
            SerialNumber = $Null # Get computer serial number
        }

        if (Test-Connection -ComputerName $PCName -Count 1 -Quiet) {
            $output.IsOnline = $true
            $output.PCModel = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $PCName).Model
            $output.SerialNumber = (Get-WmiObject -Class Win32_BIOS -ComputerName $PCName).SerialNumber
            }
    } catch {
        Write-Host "Something Wrong!"
    } finally {
        [pscustomobject]$output | Select ComputerName,IsOnline,PCModel,SerialNumber | Export-Csv -Path ".\$Date.csv" -Append -NoTypeInformation
        [pscustomobject]$output
    }
}