import 'dart:convert';
import 'dart:html';

void main() {
  HttpRequest.getString('datas.json').then((jsonAsString) => JSON.decode(
      jsonAsString)).then(displayDatas);
}


displayDatas(Map datas) {
  final m = {};
  datas.forEach((k, v) {
    v['uploaders'].forEach((e) => m.putIfAbsent(e, () => []).add(k));
  });
  final dl = new DListElement();
  (m.keys.toList()..sort((String e1, String e2) => e1.toLowerCase().compareTo(
      e2.toLowerCase()))).forEach((k) {
    dl.append(new Element.tag('dt')..text = k);
    m[k].forEach((e) => dl.append(new Element.tag('dd')..text = e));
  });
  document.documentElement.append(dl);
}
