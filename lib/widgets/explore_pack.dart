import 'package:flutter/material.dart';
import 'package:packnary/models/pack.dart';
import 'package:packnary/screen/pack_screen.dart';
import 'package:packnary/services/pack_service.dart';
import 'package:provider/provider.dart';

class ExplorePack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<PackService>(context).explorePack(),
      builder: (ctx, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (dataSnapshot.error != null) {
            print(dataSnapshot.error);
            return Center(child: Text('An error Ocurred'));
          } else {
            return ListView.builder(
              itemCount: dataSnapshot.data.length,
              itemBuilder: (ctx, i) {
                Pack pack = dataSnapshot.data[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    PackScreen.routeName,
                    arguments: pack.packId,
                  ),
                  child: ListTile(
                    title: Text(pack.packName),
                    subtitle: Text(pack.admin.name),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}
