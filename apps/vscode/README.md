# 'fixing' home and end keys

[extended-cursormove](https://marketplace.visualstudio.com/items?itemName=BillStewart.extended-cursormove) extension

keybindings (from documentation):

```
[
  { "key": "home",       "command": "extension.extendedCursorMove.cursorHome",       "when": "editorTextFocus" },
  { "key": "end",        "command": "extension.extendedCursorMove.cursorEnd",        "when": "editorTextFocus" },
  { "key": "shift+home", "command": "extension.extendedCursorMove.cursorHomeSelect", "when": "editorTextFocus" },
  { "key": "shift+end",  "command": "extension.extendedCursorMove.cursorEndSelect",  "when": "editorTextFocus" }
]
```