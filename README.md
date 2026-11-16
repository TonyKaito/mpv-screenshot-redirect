# mpv-screenshot-redirect
Redirect screenshots into it's own folder structure. 

## Extra Settings
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