<#
.NOTES
    Author:  Andrew Huddleston
    Website: github.com/adrwh

.SYNOPSIS
This function gets time when you want it!.

.DESCRIPTION
USAGE
    whatsTheTime <command>

COMMANDS
    -utc                                get current UTC time
    -utcOffset [-]1-11                  get the time in utc10 (AEST), or utc-5 (EST)
    -in Sydney                          get the time in Sydney
    -in Sydney -when 7pm -for Orlando   get the time in Sydney when it's 7pm in Orlando
    -showTableFor Sydney -and Orlando   show me a table of times between Sydney and Orlando
    -help, -?                            show this help message

.EXAMPLE
# Get the time in Sydney when its 9am in Orlando
whatsTheTime -in Sydney -when 9am -in Orlando

.EXAMPLE
# Show a table of times between Sydney and Orlando
whatsTheTime -showTableWith orlando -and sydney
#>

class CitiesDic {
  [pscustomobject]cities() {
    return @{
      sydney     = "Australia/Sydney"
      orlando    = "America/New_York"
      newyork    = "America/New_York"
      losangeles = "America/Los_Angeles"
      london     = "Europe/London"
      paris      = "Europe/Paris"
      germany    = "Europe/Germany"
    }
  }
}

class Cities : System.Management.Automation.IValidateSetValuesGenerator {
  [String[]] GetValidValues() {
    return [Citiesdic]::new().cities().keys
  }
}

function getTimeZoneInfo {
  param ([String]$city)
  $cities = [Citiesdic]::new().cities()
  return [System.TimeZoneInfo]::FindSystemTimeZoneById($cities[$city])
}

function showTable {

  param($sourceCity, $targetCity)
  
  $sourceCityTz = getTimeZoneInfo -city $sourceCity
  $targetCityTz = getTimeZoneInfo -city $targetCity
  
  $shortSourceCity = $sourceCity.Substring(0, 3).ToUpper()
  $shortTargetCity = $targetCity.Substring(0, 3).ToUpper()
  
  for ($i = 0; $i -lt 24; $i++) {
        
    [PSCustomObject]@{
      # "$shortSourceCity $($sourceCityTz.BaseUtcOffset.Hours)" = ([System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now.AddHours($i), $timeZoneDic[$sourceCity])).ToString("hh")
      $shortSourceCity = ([System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now.AddHours($i), $sourceCityTz.Id)).ToString("hh tt")
      UTC              = [DateTime]::UtcNow.AddHours($i).ToString("hh tt")
      # "$shortTargetCity $($targetCityTz.BaseUtcOffset.Hours)" = ([System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now.AddHours($i), $timeZoneDic[$targetCity])).ToString("hh")
      $shortTargetCity = ([System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now.AddHours($i), $targetCityTz.id)).ToString("hh tt")
        
    }
  }
}

function displayTime {
  param ([DateTime]$dateTime, [TimeZoneInfo]$timeZone)
  if (-not $timeZone) {
    $timeZone = [System.TimeZoneInfo]::Local
  }
  Write-Output ("[{0}] {1}" -f $dateTime.ToString("hh:mm tt"), $timeZone.DisplayName)
}

function whatsTheTime {

  param(
    [CmdletBinding()]
    [Parameter(Mandatory = $false)]
    [ValidateRange(-11, 11)]
    [Int]$utcOffset,

    [Parameter(Mandatory = $false)]
    [Switch]$utc,

    [Parameter(Mandatory = $false)]
    [ValidateSet([Cities])]
    [String]$in,

    [Parameter(Mandatory = $false)]
    [ValidateSet([Cities])]
    [String]$showTableWith,

    [Parameter(Mandatory = $false)]
    [Switch]$help
  )

  DynamicParam {

    $ParamOptions = @{
      in            = @(
        [pscustomobject]@{
          ParamName            = "when"
          ParamMandatory       = $false
          ParamPosition        = 0
          ParamType            = [String]
          ParamValidatePattern = "(1|2|3|4|5|6|7|8|9|10|11|12)(am|pm)"
          ParamHelpMessage     = "Choose when to compare time with."
        }
        [pscustomobject]@{
          ParamName        = "for"
          ParamMandatory   = $false
          ParamPosition    = 0
          ParamType        = [String]
          ParamValidateSet = [Cities]
          ParamHelpMessage = "Choose the city to compare time with."
        }
      )

      showTableWith = 
      [pscustomobject]@{
        ParamName        = "and"
        ParamMandatory   = $true
        ParamPosition    = 0
        ParamType        = [String]
        ParamValidateSet = [Cities]
        ParamHelpMessage = "Choose the city to compare time with."
      }
    
    } 
  
    $RuntimeDefinedParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
    function AddDynamicParams {

      param (
        $ParamName, 
        $ParamType,
        $ParamMandatory, 
        $ParamPosition,
        $ParamValidatePattern,
        $ParamValidateSet
      )

      $ParameterAttribute = [System.Management.Automation.ParameterAttribute]@{
        Mandatory = $ParamMandatory
        Position  = $ParamPosition
      }
    
      $Collection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
      $Collection.Add($ParameterAttribute)
    
      if ($ParamValidateRange) {
        $ValidateRangeAttribute = New-Object System.Management.Automation.ValidateRangeAttribute($ParamValidateRange)
        $Collection.Add($ValidateRangeAttribute)
      }

      if ($ParamValidateSet) {
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ParamValidateSet)
        $Collection.Add($ValidateSetAttribute)
      }

      if ($ParamValidatePattern) {
        $ValidatePatternAttribute = New-Object System.Management.Automation.ValidatePatternAttribute($ParamValidatePattern)
        $Collection.Add($ValidatePatternAttribute)
      }

      $RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::new($ParamName, $ParamType, $Collection)
      $RuntimeDefinedParameterDictionary.Add($ParamName, $RuntimeDefinedParameter)
    }

    if ($PSBoundParameters.in) {
      $ParamOptions.in.foreach{
        AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType -ParamValidatePattern $_.ParamValidatePattern -ParamValidateSet $_.ParamValidateSet
      }
    }

    if ($PSBoundParameters.showTableWith) {
      $ParamOptions.showTableWith.foreach{
        AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType -ParamMandatory $_.ParamMandatory -ParamPosition $_.ParamPosition -ParamValidatePattern $_.ParamValidatePattern -ParamValidateSet $_.ParamValidateSet
      }
    }
  
    return $RuntimeDefinedParameterDictionary
  }

  begin {

    if ($PSBoundParameters.Count -eq 0) { displayTime -dateTime ([System.DateTime]::Now) -timeZone ([System.TimeZoneInfo]::Local); break; }
    if ($PSBoundParameters.utc) { displayTime -dateTime ([System.DateTime]::UtcNow) -timeZone ([System.TimeZoneInfo]::Utc); break; }  
    if ($PSBoundParameters.utcOffset -in -12..14) { 
      Write-Output ("[{0}]" -f ([System.DateTime]::UtcNow.AddHours($PSBoundParameters.utcOffset)).ToString("hh:mm tt"))
      break;
    }
    
    if ($PSboundParameters.help -or $PSBoundParameters."?") {
      Get-Help $PSCommandPath -Full
    }
  
    if ($PSBoundParameters.in -and $PSBoundParameters.Count -eq 1) {
      $sourceCityTz = getTimeZoneInfo -city $PSBoundParameters.in

      $dateTime = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((get-date), $sourceCityTz.Id)
      displayTime -dateTime $dateTime -timeZone $sourceCityTz
      break;
    }

    if ($PSBoundParameters.in -and $PSBoundParameters.when -and $PSBoundParameters.for) {
      $sourceCity = $PSBoundParameters.in
      $when = $PSBoundParameters.when
      $targetCity = $PSBoundParameters.for

      $sourceCityTz = getTimeZoneInfo -city $sourceCity
      $targetCityTz = getTimeZoneInfo -city $targetCity

      $dateTime = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date $when), $targetCityTz.Id, $sourceCityTz.Id)
      displayTime -dateTime $dateTime -timeZone $sourceCityTz
      break;
    }

    if ($PSBoundParameters.showTableWith) {
      $sourceCity = $PSBoundParameters.showTableWith
      $targetCity = $PSBoundParameters.and
      showTable -sourceCity $sourceCity -targetCity $targetCity
    }

  }
}