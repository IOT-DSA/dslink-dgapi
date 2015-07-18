import 'dart:async';
import 'package:dslink/dslink.dart';

import '../lib/dgapi.dart';

main(List<String> args) async {
  DgApiNodeProvider provider = new DgApiNodeProvider();
  SimpleNode root = provider.nodes["/"] = new SimpleNode("/");
  provider.nodes["/Add_Connection"] = new AddConnectionNode("/Add_Connection");
  root.addChild("Add_Connection", provider.nodes["/Add_Connection"]);
  link = new LinkProvider(args, "dgapi-", nodeProvider: provider, isResponder: true, autoInitialize: false);
  link.init();

  saveLink = () => link.save();

  int count = 0;

  while (true) {
    count++;
    if (provider.nx == 0 || count == 500 || (provider.nx != -1 && provider.ll == provider.nx)) {
      link.connect();
      break;
    } else {
      await new Future.delayed(new Duration(milliseconds: 5));
    }
  }
}

LinkProvider link;

class AddConnectionNode extends SimpleNode {
  AddConnectionNode(String path) : super(path) {
    load({
      r"$name": "Add Connection",
      r"$params": [
        {
          "name": "name",
          "type": "string",
          "description": "Connection Name",
          "placeholder": "OldServer"
        },
        {
          "name": "url",
          "type": "string",
          "placeholder": "http://dgbox.example.com/dglux5/"
        },
        {
          "name": "username",
          "type": "string",
          "description": "Username",
        },
        {
          "name": "password",
          "type": "string",
          "editor": "password"
        }
      ],
      r"$invokable": "write",
      r"$result": "values"
    });
  }

  @override
  onInvoke(Map<String, dynamic> params) async {
    var name = params["name"];
    var url = params["url"];
    var user = params["username"];
    var password = params["password"];

    if (!url.endsWith("/")) {
      url = "${url}/";
    }

    DgApiNodeProvider p = link.provider;
    p.addConnection(name, url, user, password);
  }
}
