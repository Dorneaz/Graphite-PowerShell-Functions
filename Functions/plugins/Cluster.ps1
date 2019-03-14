New-Module `
-AsCustomObject `
-name Cluster `
-ScriptBlock { 

	function Init 
	{
		$plugin = [PSCustomObject]@{
			PluginName = "Cluster"
			Enabled = $false
			Config = $null
			MetricPath = ""
			NodeHostName = ""
			ConfigSectionName = "Cluster"
		}
	
		$getMetricsBlock = 
		{
			if (!($this.Enabled)) {return}
			$clusterName = (Get-Cluster).name
			Get-ClusterGroup | select GroupType, OwnerNode, Name, State | ? GroupType -ne 'AvailableStorage' | ? GroupType -ne 'VirtualMachine' | %{ [pscustomobject]@{ Path="\\$($clusterName)\$($env:COMPUTERNAME)\ClusterGroupState\$($_.GroupType)\$($_.Name.Replace('(','').Replace(')',''))"; Value=[int]$_.State } }
		}
	
		$memberParam = @{
			MemberType = "ScriptMethod"
			InputObject = $plugin
			Name = "GetMetrics"
			Value = $getMetricsBlock
		}
		Add-Member @memberParam
		return $plugin
	}
} 





