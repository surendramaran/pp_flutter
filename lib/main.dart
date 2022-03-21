import 'package:flutter/material.dart';
import 'package:packnary/services/create.dart';
import 'package:provider/provider.dart';

import './screen/demo_page.dart';

import 'models/user.dart';
import './services/auth.dart';
import 'screen/createScreen.dart';
import 'screen/home.dart';
import 'screen/login.dart';
import 'screen/pack_screen.dart';
import 'screen/search_results_screen.dart';
import 'screen/signup.dart';
import 'screen/user_profile.dart';
import 'services/pack_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => User()),
        ChangeNotifierProvider(create: (ctx) => AuthService()),
        ChangeNotifierProvider(create: (ctx) => CreateService()),
        ChangeNotifierProvider(create: (ctx) => PackService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Home(),
        routes: {
          Signup.routeName: (ctx) => Signup(),
          Demo.routeName: (ctx) => Demo(),
          Login.routeName: (ctx) => Login(),
          UserProfile.routeName: (ctx) => UserProfile(),
          CreateScreen.routeName: (ctx) => CreateScreen(),
          PackScreen.routeName: (ctx) => PackScreen(),
          SearchResultsScreen.routeName: (ctx) => SearchResultsScreen(),
        },
      ),
    );
  }
}

Map<int, Color> whiteColor = {
  50: Color.fromRGBO(255, 255, 255, .1),
  100: Color.fromRGBO(255, 255, 255, .2),
  200: Color.fromRGBO(255, 255, 255, .3),
  300: Color.fromRGBO(255, 255, 255, .4),
  400: Color.fromRGBO(255, 255, 255, .5),
  500: Color.fromRGBO(255, 255, 255, .6),
  600: Color.fromRGBO(255, 255, 255, .7),
  700: Color.fromRGBO(255, 255, 255, .8),
  800: Color.fromRGBO(255, 255, 255, .9),
  900: Color.fromRGBO(255, 255, 255, 1),
};
MaterialColor whiteColorCustom = MaterialColor(0xFFFFFFFF, whiteColor);


// class DataSearch extends SearchDelegate<String> {
//   final data = ['a', 'ab', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'];
//   final recent = ['b', 'c', 'd', 'e'];

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//         icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // Return type should be a Widget
//     return null;
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final suggestionList = query.isEmpty
//         ? recent
//         : data.where((element) => element.startsWith(query)).toList();
//     return ListView.builder(
//       itemBuilder: (context, index) => ListTile(

//         onTap: () {
//           // On tap on any ListTile I can easily go to another screen
//           Navigator.of(context).pushNamed('/rro', arguments: query);
//         },
  
//         title: Text(suggestionList[index]),
//       ),
//       itemCount: suggestionList.length,
//     );
//   }
// }