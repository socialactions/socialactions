// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function()
		{
			$("#select_all_sites").click(function()				
			{
             	//alert("got here " + this.checked)
				var checked_status = this.checked;
				$("input[@id=sites]").each(function()
				{
					//alert("got here " + this.value)
					this.checked = checked_status;
				});
			});					
		});
		
