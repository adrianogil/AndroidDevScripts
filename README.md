# AndroidDevScripts
Few random scripts for Android development

# Command line options

Save logcat in current directory
```
dlog [<log_sufix_name>]
```

Search for a string in last saved logcat in current directory
```
logtext <string>
```

Show logs from an Unity application
```
logunity
```

Show exceptions from an Unity application
```
logunityexception
```

Get process id of an Unity application
```
logunitypid
```

Alias to open files

## Planned features
- List logs generated in a specific date in current log directory
```
dlog-tool -l <search-string>
dlog-tool -l --today
```
- Smarter log tools

## Installation

Add the following lines to your bashrc:
```
export ANDROID_DEV_SCRIPTS_DIR=/<path-to>/AndroidDevScripts/
source ${ANDROID_DEV_SCRIPTS_DIR}/bashrc.sh
```
(WIP I am going to create a better setup)

## Contributing

Feel free to submit PRs. I will do my best to review and merge them if I consider them essential.

## Development status

This is a very alpha software. The code was written with no consideration of coding standards and architecture. A refactoring would do it good...

## Interesting Android development resources:
* https://github.com/mzlogin/awesome-adb/blob/master/README.en.md#device-connection-management
