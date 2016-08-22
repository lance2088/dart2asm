#!/usr/bin/env dart
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/error.dart';
import 'package:analyzer/src/generated/parser.dart';
import "package:dart2asm/src/asm/all_imports.dart" as asm;
import "package:dart2asm/src/visitor.dart";
import "package:dart2asm/src/codegen/all_imports.dart";

main(List<String> args) {

  for (var arg in args) {
    CompilationUnit compilationUnit = _parse(new File(arg));

    if (compilationUnit != null) {
      AssemblyCodegen assemblyCodegen = new NasmAssemblyCodegen();
      var visitor = new Dart2AsmVisitor();
      compilationUnit.accept(visitor);
      print(assemblyCodegen.generate(visitor.assembly));
    }
  }
}

CompilationUnit _parse(File file) {
  var src = file.readAsStringSync();
  var errorListener = new _ErrorCollector();
  var reader = new CharSequenceReader(src);
  var scanner = new Scanner(null, reader, errorListener);
  var token = scanner.tokenize();
  var parser = new Parser(null, errorListener);
  var unit = parser.parseCompilationUnit(token);

  if (errorListener.errors.isNotEmpty) {
    for (var error in errorListener.errors) {
      stderr.writeln(error);
    }

    return null;
  } else return unit;
}

class _ASTVisitor extends GeneralizingAstVisitor {
  @override
  visitNode(AstNode node) {
    return super.visitNode(node);
  }
}

class _ErrorCollector extends AnalysisErrorListener {
  List<AnalysisError> errors;
  _ErrorCollector() : errors = new List<AnalysisError>();
  @override
  onError(error) => errors.add(error);
}
