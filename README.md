Small package designed to simplify working with files/directories

## Features

- File comparison for identity
- Recursive copying/moving of a directory
- Move/Delete/Copy files according to the rules

## Getting started

Add a dependency to `pubspec.yaml`

```yaml
dependencies:
    sff_lib:
```

## Usage

Look in `/example` folder.

```dart
copyDirRec(
    Directory('/home/yura/Images'),
    Directory('/media/yura/Elements/Images')
).listen((event) {
    print("${event.$1} -> ${event.$2}");
});
```

## Additional information

This library is under development. With each new version, a new feature will be added.

Also, do not forget to look at the [documentation](https://rawcdn.githack.com/yuraMovsesyan/sff_lib/c2dabd8027bb70d7a9a4ffbc4d787c30e74f24e5/doc/api/index.html).