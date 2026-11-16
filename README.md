# mpv-screenshot-redirect
Redirect screenshots into it's own folder structure. 

## Extra Settings
Currently tested on Windows platform only, using PowerShell 5.1

Make sure you have in your subs2srs.conf:
```
note_tag=subs2srs imageonfront path_in_note
```

and:
```
miscinfo_enable=yes
miscinfo_field=Notes
miscinfo_format=%n EP%d (%t) </br> %f
```