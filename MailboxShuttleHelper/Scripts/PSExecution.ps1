#create window

$xamlFile = "C:\Users\nick.carpenter\source\repos\MailboxShuttleHelper\MailboxShuttleHelper\MainWindow.xaml"

$inputXML = Get-Content $xamlFile -Raw

Function Connect-Tenant {

    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

    Import-PSSession $Session
}


Function Check-MoveRequest {
    Param($Mailbox)

    Get-MoveRequest $Mailbox | Get-MoveRequestStatistics

}

Function Check-Mailbox {
    Param($Mailbox)

    Get-Mailbox $Mailbox | fl

}