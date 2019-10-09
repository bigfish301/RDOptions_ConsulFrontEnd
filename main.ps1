[CmdletBinding()]
param (
    [Parameter()]
    [int]$port = 1025,
    [Parameter()]
    [string]$consul_host = "http://1.1.1.1:8500/v1/kv/"
)
function return-response($responsecontent="$(get-date)",$responseobj)
{
    try {
        $responsecontent | ConvertTo-Json -ErrorAction Stop | out-null
        $responseobj.ContentType = "application/json"
    }
    catch {
        $responseobj.ContentType = "text/plain"
    }
    $BUFFER = [Text.Encoding]::UTF8.GetBytes($responsecontent)
    $responseobj.ContentLength64 = $BUFFER.Length
    $responseobj.AddHeader("Last-Modified", [DATETIME]::Now.ToString('r'))
    $responseobj.AddHeader("Server", "Powershell")
    $responseobj.OutputStream.Write($BUFFER, 0, $BUFFER.Length)
    $responseobj.Close()
}

function start-webserver ($BINDING = 'http://127.0.0.1:85/')
{
    $LISTENER = New-Object System.Net.HttpListener
    $LISTENER.Prefixes.Add($BINDING)
    $LISTENER.Start()
    $Error.Clear()
    try
    {
        while ($LISTENER.IsListening)
        {
	        # analyze incoming request
	        $CONTEXT = $LISTENER.GetContext()
            $REQUEST = $CONTEXT.Request
            if($($REQUEST.Url) -notlike "*favicon.ico")
            {
                Write-Host "$($REQUEST.RemoteEndPoint.Address.IPAddressToString) requested $($REQUEST.Url)"
            }
            switch ($REQUEST.Url.Segments[1]) {
                "consul/" {
                    # $REQUEST.Url
                    $ConsulReq = ""
                    for ($i = 2; $i -lt $REQUEST.Url.Segments.Count; $i++) {
                        $ConsulReq = "$ConsulReq$($REQUEST.Url.Segments[$i])"
                    }
                    # write-host "$consul_host$ConsulReq`?raw"
                    try {
                        $ConsulData = Invoke-WebRequest "$consul_host$ConsulReq`?raw"
                        $Response = $ConsulData.Content
                    }
                    catch {
                        $Response = "['failure']"
                    }
                    return-response -responseobj $CONTEXT.Response -responsecontent $Response
                 }
                Default {
                    return-response -responseobj $CONTEXT.Response
                }
            }
            if ($REQUEST.Url.LocalPath -eq '/exit' -or $REQUEST.Url.LocalPath -eq '/quit')
	        {
		        "$(Get-Date -Format s) Closing"
		        break;
            }
        }
    }
    finally
    {
	    # Stop powershell webserver
	    $LISTENER.Stop()
	    $LISTENER.Close()
        $LISTENER.Dispose()
	    "$(Get-Date -Format s) Powershell webserver stopped."
    }
}
start-webserver -BINDING "http://+:$port/"
