The provided configuration files need certain lxops properties and files.
To initalize these, run:
```
cd demo
./setup.sh
```

The properties are saved in ~/.config/lxops/

To list them, run
```
lxops property list
```
Feel free to customize them.

Pay special attention to the fs* properties, as these specify
zfs filesystems that will be used by the examples.

