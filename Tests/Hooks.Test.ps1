Describe "HooksTest" {
	BeforeAll {
		$Parent = Split-Path (Split-Path $PSCommandPath -Parent)
		Import-Module (Join-Path $Parent "PoshInternals.psd1") -Force
	}

	Context "LocalHookTest" {
		Set-Hook -Dll "Kernel32.dll" -ReturnType "bool" -EntryPoint "Beep" -Verbose -ScriptBlock {
			param([int]$Freq, [int]$Duration)
			Write-Host "Frequency was ($Freq) and duration was ($Duration)"
			return $true
		}

		[Console]::Beep(1000, 1000)

		Get-Hook | Remove-Hook
	}

	Context "RemoteHookTest" {
		$Posh = Start-Process PowerShell -ArgumentList " '& [Console]::Beep()'" -PassThru

		Set-Hook -ProcessId $Posh.ProcessId -Dll "Kernel32.dll" -ReturnType "bool" -EntryPoint "Beep" -ScriptBlock {
			param([int]$Freq, [int]$Duration)
			"Frequency was ($Freq) and duration was ($Duration)" | Out-File C:\users\adriscoll\desktop\test.txt
			return $true
		}
	}
}
