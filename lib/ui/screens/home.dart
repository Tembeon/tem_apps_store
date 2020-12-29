import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:tem_apps_store/model/app_model.dart';
import 'package:tem_apps_store/ui/theme.dart';
import 'package:tem_apps_store/ui/widgets/app_card.dart';
import 'package:tem_apps_store/ui/widgets/rounded_modal_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('publicApps');
    Stream<QuerySnapshot> stream;
    stream = collectionReference.snapshots();

    double width = MediaQuery.of(context).size.width;
    int widthCard = 170;
    int cardsCount = width ~/ widthCard;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Приложения'),
        actions: [
          Tooltip(
            message: 'Сменить тему',
            child: IconButton(
              icon: Icon(Get.isDarkMode
                  ? Icons.brightness_5_outlined
                  : Icons.nights_stay_outlined),
              onPressed: () {
                var box = Hive.box('settings');
                if (Get.isDarkMode) {
                  box.put('selectedTheme', 'light');
                  Get.changeTheme(themeData(context));
                } else {
                  box.put('selectedTheme', 'dark');
                  Get.changeTheme(darkThemeData(context));
                }
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 20, top: 20),
        child: StreamBuilder(
          stream: stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return _buildLoadingIndicator();
            return GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cardsCount,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 1),
              children: snapshot.data.docs
                  .map((DocumentSnapshot document) => AppCard(
                      publicApp:
                          PublicApp.fromMap(document.data(), document.id)))
                  .toList(),
            );
          },
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
            child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12, left: 12),
              child: Text(
                'TemApps Store',
                style: TextStyle(fontSize: 22),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Theme.of(context).accentColor,
              ),
              title: Text(
                'Посетить группу ВК',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () => _openUrl('https://vk.com/tem_apps'),
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Theme.of(context).accentColor,
              ),
              title: Text(
                'Посетить канал Telegram',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () => _openUrl('https://t.me/tem_apps'),
            ),
          ],
        )),
      ),
    );
  }

  Center _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      analytics.logEvent(
          name: 'social_open',
          parameters: <String, dynamic>{'selected_social': url});
      launch(url);
    }
  }

  void _accountInfo() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      _openAccountInfo();
    } else {
      _loginAccount();
    }
  }

  void _loginAccount() {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    roundedModalSheet(
      context,
      'Вход в аккаунт',
      Column(
        children: [
          TextFormField(
            controller: emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                labelText: 'Введите email',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  labelText: 'Введите пароль',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Stack(
              children: [
                ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () => _registerAccount(
                            emailController.text, passwordController.text),
                        child: Text(
                          'Зарегистрироваться',
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                        highlightColor:
                            Theme.of(context).accentColor.withOpacity(0.20),
                      ),
                    ]),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Отмена',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      highlightColor:
                          Theme.of(context).accentColor.withOpacity(0.20),
                    ),
                    OutlineButton(
                      child: Text(
                        'Войти',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      onPressed: () => _accountMakeLogin(
                          emailController.text, passwordController.text),
                      highlightedBorderColor: Theme.of(context).accentColor,
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerAccount(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.rawSnackbar(
              title: 'Ошибка', message: 'Используемый пароль слишком простой');

          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          Get.rawSnackbar(
              title: 'Ошибка', message: 'Данный email уже используется');
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    } else {
      Get.rawSnackbar(
          title: 'Ошибка',
          message: 'Введите все данные для регистрации аккаунта');
    }
  }

  void _accountMakeLogin(String email, String password) {}

  void _openAccountInfo() {}
}
