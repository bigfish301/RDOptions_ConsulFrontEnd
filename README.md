# RDOptions_ConsulFrontEnd
This is a simple posh script to front end consul kv store and use it as an options remote url

# Usage

1. Setup a consul server
2. Create a rundeck job with an execute inline script task.
3. Copy the main.ps1 contents into the code
4. Set Invocation String as powershell.exe (windows) or pwsh (linux)
5. Set file extension to .ps1
6. Save and start the job

To test:
1. Create a kv on consul test1 with the data ["testoption1","testoption2"]
2. In a web browsers go to http://<rundeck ip>:1025/consul/test1
3. This should return ["testoption1","testoption2"]
  
Usage:
Once configured you can add the root link with the KV name for the option in the remote url section of the option. 
http://<rundeck ip>:1025/consul/<consul kv option path>
  
This isnt a fully baked solution but it quickly allows you to use consul as option storage for rundeck.
