<span style="font-size:2em">Python - Virtual Environments</span>

- [Useful Links](#useful-links)
- [Getting Setup](#getting-setup)
- [Checking if using the correct virtual environment (source)](#checking-if-using-the-correct-virtual-environment-source)

# Useful Links
* [Main Docs of venv](https://docs.python.org/3/library/venv.html)

# Getting Setup

* Install vanilla python
  * https://www.python.org/downloads/
* Either add python to PATH or cd into directory where you installed python so you can use it to spawn a virtual environment
  * `> python -m venv [dir]`
* Go look at [dir] and see what you have done (should have some stuff there)
    * `> cd [dir]`
* Go activate your environment
    * `> cd Scripts`
    * Run appropriate script for platform
        * `> activate.bat`
        * `> Activate.ps1`
        * `...`

# Checking if using the correct virtual environment ([source](https://stackoverflow.com/questions/1871549/determine-if-python-is-running-inside-virtualenv))

This seems to be the agreed answer 
```
    import sys
    sys.base_prefix != sys.prefix
 ```
    
These have edge cases where they don’t work
```
    import sys 
    sys.executable
```
```
    import os 
    os.getenv("VIRTUAL_ENV")
    > pip -V
``` 