[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$RocketDrive = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.WebBrowser]$webBrowser1 = $null
[System.Windows.Forms.Button]$button1 = $null
function InitializeComponent
{
$webBrowser1 = (New-Object -TypeName System.Windows.Forms.WebBrowser)
$RocketDrive.SuspendLayout()
#
#webBrowser1
#
$webBrowser1.Dock = [System.Windows.Forms.DockStyle]::Fill
$webBrowser1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]0,[System.Int32]0))
$webBrowser1.MinimumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]20,[System.Int32]20))
$webBrowser1.Name = [System.String]'webBrowser1'
$webBrowser1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]284,[System.Int32]261))
$webBrowser1.TabIndex = [System.Int32]0
#
#RocketDrive
#
$RocketDrive.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]284,[System.Int32]261))
$RocketDrive.Controls.Add($webBrowser1)
$RocketDrive.Name = [System.String]'RocketDrive'
$RocketDrive.ResumeLayout($false)
Add-Member -InputObject $RocketDrive -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $RocketDrive -Name webBrowser1 -Value $webBrowser1 -MemberType NoteProperty
Add-Member -InputObject $RocketDrive -Name button1 -Value $button1 -MemberType NoteProperty
}
. InitializeComponent

$RocketDrive.ShowDialog()