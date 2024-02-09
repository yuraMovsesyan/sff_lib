import 'dart:io';
import 'package:async/async.dart' show StreamGroup;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show AccumulatorSink;

/// comparing two files for identity by content
Future<bool> compareFilesEquality(File file1, File file2) async {

  if (file1.statSync().size != file2.statSync().size) {
    return false;
  }

  // An auxiliary function for comparing 
  // two lists for identity
  listEqual(List<int> l1, List<int> l2) {
    if (l1.length != l2.length) {
      return false;
    }

    for (int i = 0; i < l1.length; i++){
      if (l1[i] != l2[i]){
        return false;
      }
    }

    return true;
  }

  var a = false;
  List<int> buff = const[];

  await for(final val in StreamGroup.merge([file1.openRead(), file2.openRead()])) {
    if (a = !a) {
      buff = val;
      continue;
    }

    if (!listEqual(buff, val)) {
      return false;
    }
  }

  return true;
}

/// Stream the channel that transmits ([File], [File]) the original file and its duplicate
/// 
/// For find in several directories, the [Directory] list is passed in the parameters.
/// 
/// it is possible to filter the content, which in turn increases the crawl
Stream<(File, File)>
findDuplicates(List<Directory> dirs, {File? file, bool recursive = true, bool Function(String)? filter}) async* {
  if (dirs.isEmpty) return;
  Map<Digest, File> files = {}; 
  try {
    if (file != null) {
      files[await generateHashFile(file)] = file;
    }
    await for (final entitie in StreamGroup.merge([for (final dir in dirs) dir.list(recursive: recursive)])) {
      if (entitie.statSync().type == FileSystemEntityType.file) {
        if (file != null && file.path == entitie.path) continue;
        if (filter != null && !filter(entitie.path)) continue;
        final entitieFile = File(entitie.path);
        var hash = await generateHashFile(entitieFile);

        if (files[hash] != null) {
          yield (files[hash]!, entitieFile);
        } else {
          if (file == null) {
            files[hash] = entitieFile;
          }
        }      
      }
    }
  } on PathAccessException {
    print("Insufficient permissions to read subdirectories :(");
  }
}

/// recursively traverses contents of the directory, and returns the [File] type
Stream<File>
recListFile (Directory dir) async* {
  try {
    await for (final entitie in dir.list()) {
      switch (entitie.statSync().type){
        case FileSystemEntityType.file:
          yield File(entitie.path); 
        break;
        case FileSystemEntityType.directory:
          yield* recListFile(Directory(entitie.path));
        break;
        default: break;
      }
    }
  } on PathAccessException {
    print("Insufficient permissions to read subdirectories :( (${dir.path})");
  }
}

/// Method that generates a hash code from the contents of a file
Future<Digest> generateHashFile(File file, [Hash hashMethod = sha1]) async {
    var output = AccumulatorSink<Digest>();
    var input = hashMethod.startChunkedConversion(output);

    await for(final val in file.openRead()) {
      input.add(val);
    }

    input.close();
    return output.events.single;
}