import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'studentClassScreen.dart';

class StudentHomepageInfo extends StatefulWidget{
  const StudentHomepageInfo({super.key});

  State<StudentHomepageInfo> createState() => StudentHomepageInfoState();
}

class StudentHomepageInfoState extends State<StudentHomepageInfo> {

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    Future<Map> studentInfo = FirebaseService().getStudentData(uid: FirebaseService().auth.currentUser!.uid);
    return Center(child: Column(
      children: [
        FutureBuilder(future: studentInfo, builder: (BuildContext context, AsyncSnapshot snapshot){
          List<Widget> containers;
          List<Widget> classeslist = [];
          String? name;
          if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasData){
            List<Widget> widglist = [];
            name = snapshot.data!["name"];
            for (var i in snapshot.data!["schools"]){
              widglist.add(Container(
                padding: const EdgeInsets.all(7.5),
                color: const Color(0xFFb2d8f7),
                child: Column(
                  children: [
                    const Icon(Icons.school),
                    Text(i, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),)
                  ],
                ),
              ));
            }
            containers = widglist;
            List<Widget> classeslist2 = [];
            for (var i in snapshot.data!["classes"]){
              classeslist2.add(
                  ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text(i["className"]),
                    subtitle: Text(i["teacher"]),
                    onTap: () async{
                      Map classinfo = await FirebaseService().getClassInfo(path: i["accessEvents"]);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClassDetailScreen(classInfo: classinfo)));},
                  )
              );
            }
            classeslist = classeslist2;
          } else if (snapshot.hasError){
            containers = [const Icon(Icons.error, color: Colors.red)];
          } else {containers = [IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, "/addSchools");
          }
          )];}
          } else {
            containers = [const CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.only(top: deviceHeight*0.05),
                child: const Text('Awaiting result...'),
              ),];
          }
          containers.insert(0, Padding(
              padding: EdgeInsets.symmetric(horizontal:10.0, vertical: deviceHeight*0.05),
              child: Text("Your Schools:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))));
          classeslist.insert(0, const ListTile(title: Text("Your classes", textAlign: TextAlign.center,)));
          return Expanded(child: Column(children: [
          Row(children: containers), Expanded(child: Align(alignment: Alignment.centerLeft, child:
            SizedBox(
                height: 0.4*deviceHeight,
                child: Row(children: [ListView(children: classeslist), const UpcomingView()])))),
          ]));
        }),
      ],
    ),);
  }
}

class StudentHomepage extends StatelessWidget {
  const StudentHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        toolbarHeight: deviceHeight*0.1,
        title: const Image(image: AssetImage("assets/images/squarelogo-removebg-preview.png")),
        actions: [IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/messages");
            },
            icon: Icon(Icons.message_outlined)),
        PopupMenuButton(itemBuilder: (BuildContext context) =>
        <PopupMenuEntry>[
          PopupMenuItem(
              child: Center(child: TextButton(
    child: const Text("Report a bug", style: TextStyle(color: Colors.black)),
    onPressed: () {Navigator.pushNamed(context, "/bugreporting");}
    )),
            onTap: () => Navigator.pushNamed(context, "/bugreporting"),
          ),
          PopupMenuItem(
            child: Center(child: TextButton(
                child: const Text("Help", style: TextStyle(color: Colors.black)),
                onPressed: () {Navigator.pushNamed(context, "/tutorial");}
            )),
            onTap: () => Navigator.pushNamed(context, "/tutorial"),
          )
        ])],
        centerTitle: true,
      ),
      drawer: const StudentNavDrawer(highlightIndex: 0),
      body: const StudentHomepageInfo(),
    ));
  }
}

class StudentNavDrawer extends StatefulWidget {
  final int? highlightIndex;
  const StudentNavDrawer({super.key, this.highlightIndex});

  @override
  State<StudentNavDrawer> createState() => StudentNavState(selectedIndex: highlightIndex);
}

class StudentNavState extends State<StudentNavDrawer> {
  int? selectedIndex;
  StudentNavState({this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Image.asset("assets/images/togetherwide.png"),
            ),
            ListTile(
              leading: selectedIndex == 0
                  ? const Icon(Icons.home_filled)
                  : const Icon(Icons.home_outlined),
              title: const Text("Home"),
              onTap: () {
                if (selectedIndex != 0){
                  Navigator.popAndPushNamed(context, "/studenthome");
                }
                  setState(() {
                    selectedIndex = 0;
                  }
                  );},
            ),
            ListTile(
              leading: selectedIndex == 2 ? const Icon(
                  Icons.help_center_rounded) : const Icon(
                  Icons.help_center_outlined),
              title: const Text("Support"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 2;
                  }
                  ),
            ),
            ListTile(
              leading: selectedIndex == 3 ? const Icon(Icons.book) : const Icon(
                  Icons.book_outlined),
              title: const Text("Classes"),
              onTap: () {
                  setState(() {
                    selectedIndex = 3;
                  });
              Navigator.pushNamed(context, "/studentClasses");}
                  ),
            ListTile(
              leading: selectedIndex == 4
                  ? const Icon(Icons.people_alt)
                  : const Icon(Icons.people_alt_outlined),
              title: const Text("Connect"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 4;
                  }
                  ),
            ),
            ListTile(
              leading: selectedIndex == 5
                  ? const Icon(Icons.shopping_cart)
                  : const Icon(Icons.shopping_cart_outlined),
              title: const Text("School Store"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 5;
                  }
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseService().auth.signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                } else {}
                Navigator.popAndPushNamed(context, "/");
              },
            )
          ],
        ));
  }
}

class UpcomingView extends StatefulWidget {
  const UpcomingView({super.key});

  @override
  State<UpcomingView> createState() => UpcomingViewState();
}

class UpcomingViewState extends State<UpcomingView> {
  bool eventsorassignments = true;

  @override
  Widget build(BuildContext context){
    return FutureBuilder(future: FirebaseService().getStudentEvents(uid: FirebaseService().auth.currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
        int numberOfTiles = 0;
        print(snapshot.data);
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasData){
          if(snapshot.data![0].length >= snapshot.data![1].length) {
            int numberOfTiles = snapshot.data![0].length;
          } else if (snapshot.data![1].length > snapshot.data![0].length){
            int numberOfTiles = snapshot.data![1].length;
          } else {
            int numberOfTiles = 0;
          }
          int tilesBuiltCounter = 0;
          List<Widget> tiles = [];
          while(tilesBuiltCounter < numberOfTiles){
            tiles.add(
              ExpansionTile(title: eventsorassignments ?
              Text(snapshot.data![1][tilesBuiltCounter]["name"])
                  : Text(snapshot.data![0][tilesBuiltCounter]["name"])
                ,
              subtitle: eventsorassignments ?
              Text(snapshot.data![1][tilesBuiltCounter]["time"])
                  : Text(snapshot.data![0][tilesBuiltCounter]["deadline"]),
              controlAffinity: eventsorassignments ?
              ListTileControlAffinity.trailing :
                  null,
              children: eventsorassignments ?
              [Text(snapshot.data![1][tilesBuiltCounter]["description"])]
                  : []
              )
            );
          }

          tiles.add(ListTile(leading: eventsorassignments ? IconButton(
              icon: const Icon(Icons.assignment_outlined),
              onPressed: (){setState(() {
                eventsorassignments = false;
              });}
          ) : const Icon(Icons.assignment),
              title: Text("Upcoming"),
              trailing: eventsorassignments ? const Icon(Icons.event) :
              IconButton(
                  onPressed: (){setState(() {
                    eventsorassignments = true;
                  });},
                  icon: const Icon(Icons.event_outlined))
          ));

        return ListView(children: tiles);} else {return const ListTile(
          title: Text("Nothing to show"),
        );}} else {
          return const ListTile(leading: CircularProgressIndicator(),
              title: Text("Awaiting result..."));
        }
    }
    );
  }
}
