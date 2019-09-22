Add-Type -AssemblyName PresentationFramework

Function Connect-Tenant {

    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

    Import-PSSession $Session
}


Function Check-MoveRequest {
    Param($Mailbox)

    Get-MoveRequest $Mailbox | Get-MoveRequestStatistics | fl DisplayName, Status, StatusDetail, PercentComplete | Out-String
}

Function Check-Mailbox {
    Param($Mailbox)

    Get-Mailbox $Mailbox | fl Name, Archive*, Database | Out-String
}


#create window

$xamlFile = "C:\Users\nick.carpenter\source\repos\MailboxShuttleHelper\MailboxShuttleHelper\MainWindow.xaml"

$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}

Get-Variable var_*

$var_connectTenant.Add_Click( {
    Connect-Tenant
})

$var_mvReqButton.Add_Click( {
    #Clear Output
    $var_txtResults.Text = ""

    if ($result = Check-MoveRequest -Mailbox $var_mbxInput.Text) {
        $var_txtResults.Text = "$($result)`n"
    } else {
        $var_txtResults.Text = "The operation couldn't be performed because object couldn't be found!"
    }
})

$var_mbxButton.Add_Click( {
    #Clear Output
    $var_txtResults.Text = ""

    if ($result = Check-Mailbox -Mailbox $var_mbxInput.Text) {
        $var_txtResults.Text = "$($result)`n"
    } else {
        $var_txtResults.Text = "The operation couldn't be performed because object couldn't be found!"
    }
})


$Null = $window.ShowDialog()