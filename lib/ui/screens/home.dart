import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:tem_apps_store/model/app_model.dart';
import 'package:tem_apps_store/ui/theme.dart';
import 'package:tem_apps_store/ui/widgets/app_card.dart';
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
    // get collection with all apps from Firestore
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('publicApps');
    Stream<QuerySnapshot> stream;
    stream = collectionReference.snapshots();

    // make card counts adaptive
    double width = MediaQuery.of(context).size.width;
    int widthCard = 170;
    int cardsCount = width ~/ widthCard;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Приложения'),
        actions: [
          // change site theme button
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
        padding: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: StreamBuilder(
          stream: stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // data still loading, show loading indicator
            if (!snapshot.hasData) return _buildLoadingIndicator();
            // got data, show apps in grid
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
      // Drawer with links to my social
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
                Icons.mail_outlined,
                color: Theme.of(context).accentColor,
              ),
              title: Text(
                'Написать в ВК',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () => _openUrl('https://vk.me/tembeon'),
            ),
            ListTile(
              leading: Icon(
                Icons.mail_outlined,
                color: Theme.of(context).accentColor,
              ),
              title: Text(
                'Написать в Telegram',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () => _openUrl('https://t.me/tembeon'),
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

  // Indicator for any loading content
  Center _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  // open url with logging to analytics
  // (I wanna know which one you like)
  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      analytics.logEvent(
        name: 'social_open',
        parameters: <String, dynamic>{'selected_social': url},
      );
      launch(url);
    }
  }
}
