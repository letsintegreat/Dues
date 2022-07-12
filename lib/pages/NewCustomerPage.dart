import 'package:dues/models/DuesUser.dart';
import 'package:dues/pages/DetailsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NewCustomerPage extends StatefulWidget {
  DuesUser duesUser;
  List<DuesUser> alreadyHere;
  NewCustomerPage({Key? key, required this.duesUser, required this.alreadyHere})
      : super(key: key);
  @override
  _NewCustomerPage createState() => _NewCustomerPage();
}

class _NewCustomerPage extends State<NewCustomerPage> {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200.0,
            decoration: BoxDecoration(
              color: Color(0xFF3F3D56),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 8.0, bottom: 0.0, top: 25.0),
                  child: Container(
                    height: 80.0,
                    child: Row(
                      children: [
                        Builder(builder: (context) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: FaIcon(
                              FontAwesomeIcons.arrowLeft,
                              color: Colors.white,
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: Text(
                            "Add a new friend",
                            style: GoogleFonts.comfortaa(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 32.0, right: 32.0),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF555274),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: (v) {
                                  if (searchQuery !=
                                      _searchController.text
                                          .trim()
                                          .toLowerCase()) {
                                    setState(() {
                                      searchQuery = _searchController.text
                                          .trim()
                                          .toLowerCase();
                                    });
                                  }
                                },
                                cursorColor: Colors.white,
                                style: GoogleFonts.comfortaa(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    labelText: "Search...",
                                    labelStyle: GoogleFonts.comfortaa(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    )),
                              ),
                            ),
                          ),
                          Center(
                            child: InkWell(
                              onTap: () {
                                if (searchQuery !=
                                    _searchController.text
                                        .trim()
                                        .toLowerCase()) {
                                  setState(() {
                                    searchQuery = _searchController.text
                                        .trim()
                                        .toLowerCase();
                                  });
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  width: 32.0,
                                  child: SvgPicture.asset(
                                    "assets/MagnifyingGlass.svg",
                                    color: Colors.white,
                                    width: 25.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF3F3D56),
                image: DecorationImage(
                  image: AssetImage("assets/home_list_bg.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                  stream: _usersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 50,
                        ),
                      );
                    }

                    List<DuesUser> duesUsers = [];
                    for (var document in snapshot.data!.docs) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      DuesUser newUser = DuesUser.fromJson(data);
                      if (newUser.firebaseUid != firebaseUser.uid) {
                        bool contains = false;
                        for (var u in widget.alreadyHere) {
                          if (u.isEqual(newUser)) {
                            contains = true;
                            false;
                          }
                        }
                        if (!contains) {
                          duesUsers.add(newUser);
                        }
                      }
                      duesUsers.removeWhere((element) {
                        return !element.name
                                .toLowerCase()
                                .contains(searchQuery) &&
                            !element.username
                                .toLowerCase()
                                .contains(searchQuery);
                      });
                    }
                    return (duesUsers.isEmpty)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/waiting.png",
                                height: 150.0,
                              ),
                              Text(
                                "No users available.",
                                style: GoogleFonts.comfortaa(),
                              ),
                            ],
                          )
                        : Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: duesUsers.length,
                              itemBuilder: (context, index) {
                                return Builder(builder: (context) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (context) => DetailsPage(
                                                    currentUser: widget.duesUser,
                                                    targetUser: duesUsers[index],
                                                    index: index,
                                                    transactions: [],
                                                  )));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        bottom: 8.0,
                                      ),
                                      child: Container(
                                        height: 80.0,
                                        child: Card(
                                          elevation: 2.0,
                                          color: Color(0xFFFCB495),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0),
                                                child: Hero(
                                                  tag: "userIconHero$index",
                                                  child: Container(
                                                    width: 48.0,
                                                    height: 48.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF3F3D56),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                    ),
                                                    child: Center(
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: Text(
                                                          duesUsers[index]
                                                              .name[0],
                                                          style: GoogleFonts
                                                              .comfortaa(
                                                            fontSize: 20.0,
                                                            color:
                                                                Color(0xFFFCB495),
                                                            fontWeight:
                                                                FontWeight.w900,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: 80.0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                left: 8.0,
                                                                top: 20),
                                                        child: Hero(
                                                          tag:
                                                              "userNameHero$index",
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: Text(
                                                              duesUsers[index]
                                                                  .name,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .comfortaa(
                                                                color: Color(
                                                                    0xFF3F3D56),
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                top: 4.0,
                                                                left: 8.0),
                                                        child: Hero(
                                                          tag:
                                                              "usernameHero$index",
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: Row(
                                                              children: [
                                                                Center(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/At.svg",
                                                                    color: Color(
                                                                        0xFF3F3D56),
                                                                    width: 15.0,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              4.0),
                                                                  child: Text(
                                                                    duesUsers[index]
                                                                                .username
                                                                                .length <
                                                                            15
                                                                        ? duesUsers[
                                                                                index]
                                                                            .username
                                                                        : "${duesUsers[index].username.substring(0, 15)}...",
                                                                    style: GoogleFonts.comfortaa(
                                                                        color: Color(
                                                                            0xFF3F3D56),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              },
                            ),
                        );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
