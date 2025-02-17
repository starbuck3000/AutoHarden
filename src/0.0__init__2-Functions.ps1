###############################################################################
# FUNCTIONS - Global
$global:asks_cache = @{}

function ask( $query, $config )
{
	if( $global:asks_cache.ContainsKey($config) ){
		Write-Host ("# [${AutoHarden_AsksFolder}\${config}] In cache => {0}" -f $global:asks_cache[$config])
		return $global:asks_cache[$config];
	}
	if( [System.IO.File]::Exists("${AutoHarden_AsksFolder}\${config}") ){
		Write-Host "# [${AutoHarden_AsksFolder}\${config}] Exist => Using the new file location"
		$ret = _ask $query $config $AutoHarden_AsksFolder
		$global:asks_cache[$config] = $ret
		return $ret;
	}
	if( [System.IO.File]::Exists("${AutoHarden_Folder}\${config}") ){
		Write-Host "# [${AutoHarden_Folder}\${config}] The new 'ask' location doesn't exist but the old one exist => Using the old file location"
		$ret = _ask $query $config $AutoHarden_Folder
		[System.IO.File]::WriteAllLines("${AutoHarden_AsksFolder}\${config}", "$ret", (New-Object System.Text.UTF8Encoding $False));
		Remove-Item -Force "${AutoHarden_Folder}\${config}" -ErrorAction Ignore;
		$global:asks_cache[$config] = $ret
		return $ret;
	}
	if( $askMigration.Contains($config) ){
		if( [System.IO.File]::Exists("${AutoHarden_Folder}\$($askMigration[$config])") ){
			$ret=cat "${AutoHarden_Folder}\$($askMigration[$config])" -ErrorAction Ignore;
			if( $config -eq 'Hardening-DisableMimikatz__Mimikatz-DomainCredAdv.ask' ){
				if( $ret -eq 'Yes' ){
					$ret = 'No'
				}else{
					$ret = 'Yes'
				}
			}
			Write-Host ("# [${AutoHarden_AsksFolder}\${config}] Not found but the old configuration exist ${AutoHarden_Folder}\$($askMigration[$config]) with the value ${ret} => {0}" -f ($ret -eq 'Yes'))
			[System.IO.File]::WriteAllLines("${AutoHarden_AsksFolder}\${config}","$ret", (New-Object System.Text.UTF8Encoding $False));
			Remove-Item -Force $AutoHarden_Folder\$askMigration[$config] -ErrorAction Ignore;
			$global:asks_cache[$config] = $ret -eq 'Yes'
			return $global:asks_cache[$config];
		}
	}
	Write-Host "# [${AutoHarden_AsksFolder}\${config}] This parameter is new and doesn't exist at all"
	$ret = _ask $query $config $AutoHarden_AsksFolder
	$global:asks_cache[$config] = $ret
	return $ret;
}


function _ask( $query, $config, $folder )
{
	$ret=cat "${folder}\${config}" -ErrorAction Ignore;
	logInfo "[${folder}\${config}] Checking..."
	try{
		if( [string]::IsNullOrEmpty($ret) ){
			logInfo "[${folder}\${config}] Undefined... Asking"
			if( $AutoHarden_Asks ){
				$ret = 'No'
				if( -not [Environment]::UserInteractive ){
					throw 'UserNotInteractive'
				}
				Write-Host ""
				do{
					$ret = (Read-Host "${query}? (Y/n)").toupper()
					if( $ret.Length -gt 0 ){
						$ret = $ret.substring(0,1)
					}else{
						$ret = 'Y'
					}
				}while( $ret -ne 'Y' -and $ret -ne 'N' -and $ret -ne '' );
				if( $ret -eq 'Y' ){
					$ret = 'Yes'
				}else{
					$ret = 'No'
				}
				logInfo "[${folder}\${config}] Admin said >$ret<"
			}else{
				logInfo "[${folder}\${config}] AutoManagement ... NOASKING => YES"
				$ret = 'Yes'
			}
			[System.IO.File]::WriteAllLines("${AutoHarden_AsksFolder}\${config}","$ret", (New-Object System.Text.UTF8Encoding $False));
		}
		logSuccess ("[${folder}\${config}] is >$ret< => parsed={0}" -f ($ret -eq 'Yes' -Or $ret -eq 'True'))
		return $ret -eq 'Yes' -Or $ret -eq 'True';
	}catch{
		logError "[${folder}\${config}][WARN] An update of AutoHarden require an action from the administrator."
		if( $global:AutoHarden_boradcastMsg -And $AutoHarden_Asks ) {
			$global:AutoHarden_boradcastMsg=$false
			msg * "An update of AutoHarden require an action from the administrator.`r`n`r`n${query}?`r`nPlease run ${AutoHarden_Folder}\AutoHarden.ps1"
		}
		return $null;
	}
}


function createTempFile( $data, [Parameter(Mandatory=$false)][string]$ext='' )
{
	$tmpFileName = -join ((65..90) + (97..122) | Get-Random -Count 25 | % {[char]$_});
	$tmpFileName = "${AutoHarden_Folder}\${tmpFileName}${ext}"
	[System.IO.File]::WriteAllLines($tmpFileName, $data, (New-Object System.Text.UTF8Encoding $False));
	return $tmpFileName;
}


# reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /t REG_DWORD /v PublishUserActivities /d 0 /f
function reg()
{
	$action = $args[0].ToLower()
	$hk = $args[1].Replace('HKCU','HKCU:').Replace('HKEY_CURRENT_USER','HKCU:')

	$type = 'REG_DWORD'
	$key = ''
	$value = ''

	for( $i=2; $i -lt $args.Count; $i+=2 )
	{
		if( $args[$i] -eq '/t' ){
			$type=$args[$i+1]
		}elseif( $args[$i] -eq '/v' ){
			$key=$args[$i+1]
		}elseif( $args[$i] -eq '/d' ){
			$value=$args[$i+1]
		}elseif( $args[$i] -eq '/f' ){
			$i-=1
			# Pass
		}
	}

	if( $action -eq 'add' ){
		if( $hk.StartsWith('HKCU:') ){
			$path = $hk.Replace('HKCU:\','')
			Get-ChildItem REGISTRY::HKEY_USERS | select Name | foreach {
				$name = $_.Name.Trim('\')
				$name = ('{0}\{1}' -f $name,$path).Replace('\\','\')
				Write-host "reg.exe add $name /v $key /d $value /t $type /f"
				try{
					if( (Get-ItemPropertyValue "Registry::$name" -Name $key -ErrorAction SilentlyContinue) -ne $value ){
						throw "Invalid value"
					}
					logInfo "[${name}:$key] is OK ($value)"
				}catch{
					logSuccess "[${name}:$key] is now set to $value"
					reg.exe add "$name" /v "$key" /t $type /d "$value" /f
				}
			}
			return $null
		}
		try{
			Write-Host "reg.exe add $hk /v $key /d $value /t $type /f"
			if( (Get-ItemPropertyValue "Registry::$hk" -Name $key -ErrorAction Stop) -eq $value ){
				logInfo "[${hk}:$key] is OK ($value)"
			}else{
				logSuccess "[${hk}:$key] is now set to $value"
				reg.exe add "$hk" /v "$key" /d "$value" /t $type /f
			}
		}catch{
			logSuccess "[${hk}:$key] is now set to $value"
			reg.exe add "$hk" /v "$key" /d "$value" /t $type /f
		}
		return $null
	}elseif( $action -eq 'delete' ){
		if( $hk.StartsWith('HKCU:') ){
			$path = $hk.Replace('HKCU:\','')
			Get-ChildItem REGISTRY::HKEY_USERS | select Name | foreach {
				$name = $_.Name.Trim('\')
				$name = ('{0}\{1}' -f $name,$path).Replace('\\','\')
				try{
					Get-ItemPropertyValue "Registry::$name" -Name $key -ErrorAction Stop
					if( -not [string]::IsNullOrEmpty($key) ){
						logSuccess "[${name}:$key] is now DELETED"
						Write-Host "reg.exe delete $name /v $key /f"
						reg.exe delete "$name" /v "$key" /f
					}else{
						logSuccess "[$name] is now DELETED"
						Write-Host "reg.exe delete $name /f"
						reg.exe delete "$name" /f
					}
				}catch{
					logInfo "[${name}:$key] is NOT present"
				}
			}
			return $null
		}
		try{
			Get-ItemPropertyValue "Registry::$hk" -Name $key -ErrorAction Stop
			if( -not [string]::IsNullOrEmpty($key) ){
				logSuccess "[${hk}:$key] is now DELETED"
				Write-Information "reg.exe delete $hk /v $key /f"
				reg.exe delete "$hk" /v "$key" /f
			}else{
				logSuccess "[${hk}] is now DELETED"
				Write-Information "reg.exe delete $hk /f"
				reg.exe delete "$hk" /f
			}
		}catch{
			logInfo "[${hk}:$key] is NOT present"
		}
		return $null
	}
	Write-Error "Not implemented"
}

function mywget( $Uri, $OutFile=$null )
{
	$ret = $null
	Get-NetFirewallRule -DisplayName '*AutoHarden*Powershell*' -ErrorAction SilentlyContinue | Disable-NetFirewallRule
	try{
		if( $OutFile -eq $null ){
			$ret=Invoke-WebRequest -UseBasicParsing -Uri $Uri
		}else{
			Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $OutFile > $null
		}
	}catch{
		if( $OutFile -eq $null ){
			$ret=curl.exe $Uri
		}else{
			curl.exe $Uri --output $OutFile > $null
		}

	}
	Get-NetFirewallRule -DisplayName '*AutoHarden*Powershell*' -ErrorAction SilentlyContinue | Enable-NetFirewallRule
	return $ret;
}