function Get-ServiceNowCatalogTasks {
    param(
        # Machine name of the field to order by
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [string]$OrderBy='opened_at',
        
        # Direction of ordering (Desc/Asc)
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [ValidateSet("Desc", "Asc")]
        [string]$OrderDirection='Desc',

        # Maximum number of records to return
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [int]$Limit=10,
        
        # Hashtable containing machine field names and values returned must match exactly (will be combined with AND)
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [hashtable]$MatchExact=@{},

        # Hashtable containing machine field names and values returned rows must contain (will be combined with AND)
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [hashtable]$MatchContains=@{},

        # Whether or not to show human readable display values instead of machine values
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [ValidateSet("true","false", "all")]
        [string]$DisplayValues='true',

        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $ServiceNowCredential, 

        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServiceNowURL, 

        [Parameter(ParameterSetName='UseConnectionObject', Mandatory=$True)] 
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Connection
    )
    
    $private:Query = New-ServiceNowQuery -OrderBy $private:OrderBy -OrderDirection $private:OrderDirection -MatchExact $private:MatchExact -MatchContains $private:MatchContains
    

    if ($Connection -ne $null) {
        $private:result = Get-ServiceNowTable -Table 'sc_task' -Query $private:Query -Limit $private:Limit -DisplayValues $private:DisplayValues -Connection $Connection
    }
    elseif ($ServiceNowCredential -ne $null -and $ServiceNowURL -ne $null) {
        $private:result = Get-ServiceNowTable -Table 'sc_task' -Query $private:Query -Limit $private:Limit -DisplayValues $private:DisplayValues -ServiceNowCredential $ServiceNowCredential -ServiceNowURL $ServiceNowURL 
    }
    else {
        $private:result = Get-ServiceNowTable -Table 'sc_task' -Query $private:Query -Limit $private:Limit -DisplayValues $private:DisplayValues 
    }

    # Add the custom type to the change request to enable a view
    $private:result | %{$_.psobject.TypeNames.Insert(0, "PSServiceNow.CatalogTask")}
    return $private:result
}

function Update-ServiceNowCatalogTask {
    Param(
        
        # sys_id of the entry we're modifying
        [parameter(mandatory=$true)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [string]$SysId,

        # custom fields as hashtable 
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [hashtable]$Values,

        # Credential used to authenticate to ServiceNow  
        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $ServiceNowCredential, 

        # The URL for the ServiceNow instance being used (eg: instancename.service-now.com)
        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServiceNowURL, 

        #Azure Automation Connection object containing username, password, and URL for the ServiceNow instance
        [Parameter(ParameterSetName='UseConnectionObject', Mandatory=$True)] 
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Connection
    )


    
    if ($Connection -ne $null)
    {
       Update-ServiceNowTableEntry -Table 'sc_task' -SysId $SysId -Values $Values -Connection $Connection
    }
    elseif ($ServiceNowCredential -ne $null -and $ServiceNowURL -ne $null) 
    {
       Update-ServiceNowTableEntry -Table 'sc_task' -SysId $SysId -Values $Values -ServiceNowCredential $ServiceNowCredential -ServiceNowURL $ServiceNowURL
    }
    else 
    {
       New-ServiceNowTableEntry -Table 'sc_task' -Values $Values   
    } 

}

