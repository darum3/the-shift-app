import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io' as io;

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final String startUrl;

  MyApp({this.startUrl});

  @override
  Widget build(BuildContext context) {
    // return SafeArea(child: null)
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.cyan,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
          title: 'Theシフト[開発版]',
          url: 'http://dev.the-shift.tk/home',
          permitUrl: 'http://dev.the-shift.tk/',
          loginPost: 'http://dev.the-shift.tk/login'), // todo 環境でURL変える
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => new MyHomePage(),
        '/login': (BuildContext context) => new LoginPage(),
        // '/home': (BuildContext context) => new MyHomePage(url: ,)
      },
    );
  }
}

class LoginData {
  LoginData({this.email, this.password});

  String email;
  String password;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.url, this.permitUrl, this.loginPost})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String url;
  final String permitUrl;
  final String loginPost;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = "";
  String csrfToken = "";
  bool inLoginProc = false;
  SharedPreferences prefs;

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((_prefs) => this.prefs = _prefs);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            Expanded(
              child: Container(
                child: InAppWebView(
                    initialUrl: widget.url,
                    onLoadStart:
                        (InAppWebViewController controller, String url) {
                      setState(() {
                        this.url = url;
                      });
                      // TODO 許可URLのみ
                      // if (Uri.parse(url).origin != widget.permitUrl) {
                      //   controller.stopLoading();
                      //   controller.loadUrl(url: widget.url);
                      // }
                    },
                    onLoadStop:
                        (InAppWebViewController controller, String url) async {
                      setState(() {
                        this.url = url;
                      });
                      debugPrint(url);
                      List<String> storeCookies =
                          this.prefs.getStringList('cookies') ?? new List();
                      if (this.url.endsWith('/login')) {
                        if (storeCookies.isEmpty) {
                          controller.getMetaTags().then((value) {
                            int index = value.indexWhere(
                                (element) => element.name == 'csrf-token');
                            if (index >= 0) {
                              this.csrfToken = value[index].content;
                            }
                          });

                          // var input =
                          //     await Navigator.pushNamed(context, '/login');
                          // LoginData value = input;
//
                          // String formBody = 'token=' + this.csrfToken;
                          // formBody += '&email=' + value.email;
                          // formBody += '&password=' + value.password;
                          // formBody += '&remember="ok"';
                          // List<int> bodyBytes = utf8.encode(formBody);
                          // controller
                          //     .postUrl(
                          //         url: widget.loginPost, postData: bodyBytes)
                          //     .then((result) {
                          //   CookieManager cookieManager =
                          //       CookieManager.instance();
                          //   cookieManager
                          //       .getCookies(
                          //           url: Uri.parse(widget.loginPost).origin)
                          //       .then((cookies) {
                          //     List<String> store = new List();
                          //     for (Cookie cookie in cookies) {
                          //       store.add(json.encode(cookie.toJson()));
                          //     }
                          //     this.prefs.setStringList('cookies', store);
                          //   });
                          // });

                          http.Response response;
                          do {
                            var input =
                                await Navigator.pushNamed(context, '/login');
                            LoginData value = input;

                            Map<String, String> headers = {
                              'Content-type':
                                  'application/x-www-form-urlencoded',
                            };
                            Map<String, String> body = {
                              '_token': this.csrfToken,
                              'email': value.email,
                              'password': value.password,
                              "remember": "on",
                            };
                            response = await http.post(widget.loginPost,
                                headers: headers, body: body);
                          } while (response.statusCode != 302);

                          String setCookies = response.headers['set-cookie'];
                          var cookies = setCookies.split(',');
                          for (int i = 0; i < cookies.length; i += 2) {
                            io.Cookie cookie = io.Cookie.fromSetCookieValue(
                                cookies[i] + cookies[i + 1]);
                            CookieManager cookieManager =
                                CookieManager.instance();
                            cookieManager.setCookie(
                                url: Uri.parse(widget.loginPost).origin +
                                    cookie.path,
                                name: cookie.name,
                                value: cookie.value);
                          }
                          debugPrint(response.headers.toString());
                          controller.loadUrl(url: response.headers['location']);
                        } else {
                          CookieManager cookieManager =
                              CookieManager.instance();
                          for (String storeCookie in storeCookies) {
                            var decodeCookie = json.decode(storeCookie);
                            // debugPrint(decodeCookie.toString());
                            cookieManager.setCookie(
                              url: Uri.parse(widget.loginPost).origin,
                              name: decodeCookie['name'],
                              value: decodeCookie['value'],
                            );
                          }
                        }
                      }
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _userController = TextEditingController();
  var _passwordController = TextEditingController();

  FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('ログイン'),
          ),
          body: Container(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Text('情報を入��'),
                  Text('メールアドレス:'),
                  TextField(
                    controller: _userController,
                    autofocus: true,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 24.0, 0, 0),
                    child: Text('パスワード'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    focusNode: focusNode,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 32.0, 0, 0),
                    child: Center(
                        child: RaisedButton(
                      child: Text('ログイン'),
                      onPressed: () => setState(() {
                        Navigator.pop(
                            context,
                            new LoginData(
                                email: _userController.text,
                                password: _passwordController.text));
                      }),
                      color: Colors.cyan,
                      focusNode: focusNode,
                    )),
                  ),
                ],
              ))),
    );
  }
}
