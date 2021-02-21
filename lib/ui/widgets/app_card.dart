import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tem_apps_store/model/app_model.dart';
import 'package:tem_apps_store/ui/screens/view_app.dart';

class AppCard extends StatelessWidget {
  // require appID to get data from Firestore
  final PublicApp publicApp;

  const AppCard({Key key, this.publicApp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.height;
    final double imagePadding = width / 32;

    // simple Card with icon and app name
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openApp(context, publicApp.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(imagePadding),
              child: Hero(
                tag: publicApp.id,
                child: CachedNetworkImage(
                  imageUrl: publicApp.iconUrl,
                  placeholder: (context, url) => Container(),
                ),
              ),
            ),
            Text(publicApp.name + ' ', style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }

  // when card clicked, open app viewer with app ID
  void _openApp(BuildContext context, String app) {
    Navigator.pushNamed(context, ViewApp.routeName + '/' + app,);
  }
}
