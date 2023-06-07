# playit-auto-installer
A auto installer for playit.gg<br>
Automatically install playit agent and create a service to start it at boot.<br>
It tries to use apt but if it's not installed it falls back to manually downloading it.<br>
This should work on most Linux systems. (Such as a raspberry pi.)
# Usage
Run this to start the install:
```sh
curl -SsL https://raw.githubusercontent.com/westhecool/playit-auto-installer/main/playit.sh | bash
```