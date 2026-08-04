$request = @{
	Method = "POST"
	URI = "http://127.0.0.1:8765" # assuming integration with AnkiConnect
	ContentType = "application/json"
	Body = @{
		"action" = "findNotes"
		"version" = 6
		"params" = @{
			"query" = "tag:subs2srs" # assuming integration with subs2srs
		}
	} | ConvertTo-Json
}
$thing = Invoke-RestMethod @request
Write-Output $thing.result