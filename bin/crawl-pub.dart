import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:collection/equality.dart';

final eq = new IterableEquality();

main() {
  final datasPath = '../web/datas.json';
  final datasFile = new File(datasPath);
  final Map datas = datasFile.existsSync() ? readJson(datasFile) : {};

  g(int page) => getPackages(page: page).then((json) {
    int pages = json['pages'];
    List<String> packages = json['packages'].toList();
    void f() {
      if (packages.isEmpty) {
        if (page < pages) {
          g(page + 1);
        } else {
          writeJson(datasFile, datas);
        }
        return;
      }
      final package = packages.removeAt(0);
      getJson(package).then((json) {
        final String name = json['name'];
        print("package: $name");
        final List<String> uploaders = json['uploaders'];
        final List<String> versions = json['versions'];
        final knowPackage = datas[name];
        if (knowPackage == null || !eq.equals(knowPackage['uploaders'],
            uploaders) || !eq.equals(knowPackage['versions'], versions)) {
          datas[name] = json;
          f();
        } else {
          writeJson(datasFile, datas);
        }
      });
    }
    f();
  });

  g(1);
}

readJson(File f) => JSON.decode(f.readAsStringSync());
void writeJson(File f, json) => f.writeAsStringSync(JSON.encode(json));

Future getPackages({int page: 1}) => getJson(
    'http://pub.dartlang.org/packages.json?page=$page');

Future getJson(String uri) => new HttpClient().getUrl(Uri.parse(uri)).then((r)
    => r.close()).then((r) => r.map(UTF8.decode).join()).then((s) => JSON.decode(s)
    );
