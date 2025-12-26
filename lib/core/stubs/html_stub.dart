// Stub file for dart:html on non-web platforms
// This file is used when dart:html is not available (Android, iOS, etc.)
// DO NOT USE THIS FILE DIRECTLY - it's imported via conditional imports
library html_stub;

import 'dart:async';

/// Stub class for CssStyleDeclaration
class CssStyleDeclaration {
  String display = '';
}

/// Stub class for Node (for append)
class Node {}

/// Stub class for FileUploadInputElement
class FileUploadInputElement extends Node {
  String? accept;
  CssStyleDeclaration style = CssStyleDeclaration();

  void click() {}
  void remove() {}

  Stream<dynamic> onChange = const Stream.empty();
  dynamic files;

  FileUploadInputElement();
}

/// Stub class for File (dart:html File, not dart:io File)
/// Note: On mobile platforms, this stub is used and the code path using html.File
/// is not executed (only web code uses it). The conflict with dart:io File is resolved
/// by using the html prefix (html.File vs File from dart:io).
class File {
  final String name;
  final int size;

  File(this.name, this.size);
}

/// Stub class for FileReader
class FileReader {
  Stream<dynamic> onLoad = const Stream.empty();
  Stream<dynamic> onError = const Stream.empty();
  dynamic result;

  FileReader();

  void readAsArrayBuffer(dynamic file) {}
}

/// Stub class for BodyElement
class BodyElement {
  void append(dynamic node) {}
}

/// Stub class for Document
class Document {
  BodyElement? body;

  Document() {
    body = BodyElement();
  }
}

/// Top-level document getter (matches dart:html API)
Document get document => Document();
