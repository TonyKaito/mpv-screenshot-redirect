$file = Get-Content -Path .\result.log | ForEach-Object { [Int64]$_ } # takes AnkiConnect only takes int64 for some reason

$request = @{
	Method = "POST"
	URI = "http://127.0.0.1:8765" # assuming integration with AnkiConnect
	ContentType = "application/json"
	Body = @{
		"action" = "notesInfo"
		"version" = 6
		"params" = @{
			"notes" = $file
		}
	} | ConvertTo-Json
}
$result = Invoke-RestMethod @request
$features = $result.result | ForEach-Object {"{0}|{1}|{2}|{3}" -f $_.noteId, $_.fields.SentAudio.value, $_.fields.Image.value, $_.fields.Notes.value}
Write-Output $features