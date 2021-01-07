import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:tem_apps_store/model/app_model.dart';
import 'package:tem_apps_store/ui/screens/home.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewApp extends StatefulWidget {
  static const routeName = '/app';
  final String publicAppName;

  const ViewApp({Key key, this.publicAppName}) : super(key: key);

  @override
  _ViewAppState createState() => _ViewAppState();
}

class _ViewAppState extends State<ViewApp> {
  PublicApp app = PublicApp(
    name: 'Загрузка...',
    shortDesc: 'Загрузка...',
    description: 'Загрузка...',
    downloadUrl: '',
    iconUrl: '',
    id: '',
    version: 'Загрузка...',
    images: [],
  );

  @override
  void initState() {
    _getData(widget.publicAppName);
    super.initState();
  }

  Future<void> _getData(String appId) async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection('publicApps')
        .doc(appId)
        .get();

    setState(() {
      if (data.exists) {
        app = PublicApp.fromMap(data.data(), data.id);
      } else {
        Navigator.popAndPushNamed(context, HomeScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (app == null) {
      Navigator.pushNamed(context, HomeScreen.routeName, arguments: app);
    }

    double mediaWidth = MediaQuery.of(context).size.width;

    double cardPadding = mediaWidth / 60;
    double insideCardPadding = mediaWidth / 30;
    double fontSmallSize = mediaWidth >= 1000 ? 20 : 18;
    double fontBigSize = mediaWidth >= 1000 ? 32 : 22;

    return Scaffold(
      appBar: AppBar(
        title: Text('Страница приложения'),
        actions: [
          TextButton(
            onPressed: () async {
              if (await canLaunch(app.downloadUrl)) {
                launch(app.downloadUrl);
              }
            },
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  'Скачать',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(Icons.download_outlined),
              )
            ]),
            style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Theme.of(context).accentColor.withOpacity(0.1)),
                foregroundColor: MaterialStateColor.resolveWith(
                    (states) => Theme.of(context).accentColor)),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(cardPadding, 8, cardPadding, 8),
        child: SingleChildScrollView(
          child: Card(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(insideCardPadding),
                    child: Row(
                      children: [
                        Hero(
                          tag: app.id,
                          child: CachedNetworkImage(
                            width: 100,
                            height: 100,
                            imageUrl: app.iconUrl,
                            placeholder: (context, url) => Container(
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                              padding: EdgeInsets.only(left: insideCardPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app.name + " ",
                                      style: TextStyle(fontSize: fontBigSize)),
                                  Text(app.shortDesc + " ",
                                      style:
                                          TextStyle(fontSize: fontSmallSize)),
                                  Text('Версия: ${app.version}' + ' ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(fontSize: fontSmallSize)),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8.0,
                        left: insideCardPadding,
                        right: insideCardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Описание' + ' ',
                          style: TextStyle(fontSize: fontBigSize),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Linkify(
                            text: app.description.replaceAll("\\n", "\n") + " ",
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                launch(link.url);
                              }
                            },
                            style: TextStyle(fontSize: fontSmallSize),
                          ),
                        ),
                        Text(
                          'Скриншоты' + ' ',
                          style: TextStyle(fontSize: fontBigSize),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Container(
                            height: 600,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: app.images.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.allScroll,
                                    child: app.images.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: app.images[index],
                                            errorWidget: (context, error, _) =>
                                                Text(
                                                    'Не удалось загрузить скриншот:\n$error'),
                                          )
                                        : Container(
                                            width: 0,
                                            height: 0,
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Text(
                          'Список изменений' + ' ',
                          style: TextStyle(fontSize: fontBigSize),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 8, bottom: insideCardPadding),
                          child: app.changelog != null
                              ? ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  reverse: true,
                                  shrinkWrap: true,
                                  itemCount: app.changelog.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Linkify(
                                      onOpen: (link) async {
                                        if (await canLaunch(link.url)) {
                                          launch(link.url);
                                        }
                                      },
                                      text: app.changelog[index]
                                              .toString()
                                              .replaceAll('\\n', '\n') +
                                          " ",
                                      style: TextStyle(fontSize: fontSmallSize),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      thickness: 2,
                                    );
                                  },
                                )
                              : Text(
                                  'Кажется, тут ничего нет ',
                                  style: TextStyle(fontSize: fontSmallSize),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
