---
title: Encoding issue when calling API via powershell
date: 2020-08-04 13:40:00
tags:
- Powershell
- Encoding
- Json
---
Recently we need to fetch a big dataset from an API via powershell, then import to Azure Data Explorer (ADX).

## Problem
```bash
#Used Measure-Command for measuring performance
Measure-Command {curl 'THE_API_END_POINT' | select -expand Content > data.json}
```
The data.json file looks perfectly fine, but during import to ADX, it reported error "invalid json format".

## Troubleshooting
1. Using online validation tool such as https://jsonlint.com/, copy & paste the content from data.json. The json objects are valid.

2. Using local tool [jsonlint](https://www.npmjs.com/package/jsonlint), reports error. It shows the data.json file has encoding issue.
```
PS C:\Users\lufeng\Desktop> jsonlint .\data.json
Error: Parse error on line 1:
��[ { " _ i d " : {
^
Expecting 'STRING', 'NUMBER', 'NULL', 'TRUE', 'FALSE', '{', '[', got 'undefined'
    at Object.parseError (C:\Users\lufeng\AppData\Roaming\npm\node_modules\jsonlint\lib\jsonlint.js:55:11)  
    at Object.parse (C:\Users\lufeng\AppData\Roaming\npm\node_modules\jsonlint\lib\jsonlint.js:132:22)      
    at parse (C:\Users\lufeng\AppData\Roaming\npm\node_modules\jsonlint\lib\cli.js:82:14)
    at main (C:\Users\lufeng\AppData\Roaming\npm\node_modules\jsonlint\lib\cli.js:135:14)
    at Object.<anonymous> (C:\Users\lufeng\AppData\Roaming\npm\node_modules\jsonlint\lib\cli.js:179:1)      
    at Module._compile (internal/modules/cjs/loader.js:955:30)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:991:10)
    at Module.load (internal/modules/cjs/loader.js:811:32)
    at Function.Module._load (internal/modules/cjs/loader.js:723:14)
    at Function.Module.runMain (internal/modules/cjs/loader.js:1043:10)
```
## Solution
Switch to a different powershell command solved the problem
```
Invoke-WebRequest -Uri 'THE_API_END_POINT' -OutFile data.json

```

EOF