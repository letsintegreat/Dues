import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dues/models/DuesTransaction.dart';
import 'package:dues/models/DuesUser.dart';
import 'package:dues/pages/DetailsPage.dart';
import 'package:dues/pages/NewCustomerPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  Map<DuesUser, int>? filteredData;
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  final Stream<QuerySnapshot> _userStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  DuesUser? duesUser;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  int _getIndex(List<DuesUser> list, String id) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].firebaseUid == id) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dues",
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF3F3D56),
        primaryColor: Color(0xFF3F3D56),
      ),
      home: StreamBuilder<QuerySnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 50,
                ),
              ),
            );
          }
          List<DuesUser> duesUsers = [];
          for (var document in snapshot.data!.docs) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            DuesUser newUser = DuesUser.fromJson(data);
            if (newUser.firebaseUid != firebaseUser.uid) {
              duesUsers.add(DuesUser.fromJson(data));
            } else {
              duesUser = DuesUser.fromJson(data);
            }
          }
          Stream<QuerySnapshot> _transactionStream =
              FirebaseFirestore.instance.collection('transactions').snapshots();

          return Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            floatingActionButton: (duesUser == null)
                ? null
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 32.0),
                    child: Builder(builder: (context) {
                      return FloatingActionButton(
                        backgroundColor: Color(0xFF3F3D56),
                        onPressed: () {
                          if (filteredData == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Loading")));
                            return;
                          }
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NewCustomerPage(
                                    duesUser: duesUser!,
                                    alreadyHere: filteredData!.keys.toList(),
                                  )));
                        },
                        child: SvgPicture.asset(
                          "assets/register.svg",
                          color: Colors.white,
                          height: 30.0,
                        ),
                      );
                    }),
                  ),
            body: StreamBuilder<QuerySnapshot>(
              stream: _transactionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                }
                Map<String, List<DuesTransaction>> sanitizedData = {};
                filteredData = {};
                int netGivenAmount = 0;
                int netGotAmount = 0;
                for (var document in snapshot.data!.docs) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  DuesTransaction thisTransaction =
                      DuesTransaction.fromJson(data);

                  if (thisTransaction.fromUid == duesUser!.firebaseUid) {
                    int i = _getIndex(duesUsers, thisTransaction.toUid);
                    if (sanitizedData[thisTransaction.toUid] == null) {
                      sanitizedData[thisTransaction.toUid] = [];
                      sanitizedData[thisTransaction.toUid]!
                          .add(thisTransaction);
                      filteredData![duesUsers[i]] = -1 * thisTransaction.amount;
                    } else {
                      sanitizedData[thisTransaction.toUid]!
                          .add(thisTransaction);
                      filteredData![duesUsers[i]] =
                          filteredData![duesUsers[i]]! - thisTransaction.amount;
                    }
                  } else if (thisTransaction.toUid == duesUser!.firebaseUid) {
                    int i = _getIndex(duesUsers, thisTransaction.fromUid);
                    if (sanitizedData[thisTransaction.fromUid] == null) {
                      sanitizedData[thisTransaction.fromUid] = [];
                      sanitizedData[thisTransaction.fromUid]!
                          .add(thisTransaction);
                      filteredData![duesUsers[i]] = thisTransaction.amount;
                    } else {
                      sanitizedData[thisTransaction.fromUid]!
                          .add(thisTransaction);
                      filteredData![duesUsers[i]] =
                          filteredData![duesUsers[i]]! + thisTransaction.amount;
                    }
                  }
                }
                filteredData!.forEach((key, value) {
                  if (value < 0) {
                    netGivenAmount += value.abs();
                  } else {
                    netGotAmount += value;
                  }
                });
                filteredData!.removeWhere((key, value) {
                  return !key.name.toLowerCase().contains(searchQuery);
                });
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300.0,
                      decoration: BoxDecoration(
                          color: Color(0xFF3F3D56),
                          image: DecorationImage(
                            image: AssetImage("assets/home_head_bg.png"),
                            fit: BoxFit.fill,
                          )),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
                            child: Container(
                              height: 70,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: SvgPicture.asset(
                                            "assets/At.svg",
                                            color: Colors.white,
                                            width: 20.0,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            duesUser!.username.length < 15
                                                ? duesUser!.username
                                                : "${duesUser!.username.substring(0, 15)}...",
                                            style: GoogleFonts.comfortaa(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 32.0),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(32.0),
                                                child: Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 16.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              "Are you sure?",
                                                              style: GoogleFonts
                                                                  .comfortaa(
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          16.0,
                                                                      right:
                                                                          8.0,
                                                                      top:
                                                                          32.0),
                                                                  child:
                                                                      Container(
                                                                    height: 50,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        primary:
                                                                            Color(0xFFFCB495),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(30),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        "Cancel",
                                                                        style: GoogleFonts
                                                                            .comfortaa(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          16.0,
                                                                      left: 8.0,
                                                                      top:
                                                                          32.0),
                                                                  child:
                                                                      Container(
                                                                    height: 50,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        FirebaseAuth
                                                                            .instance
                                                                            .signOut();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        primary:
                                                                            Color(0xFF3F3D56),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(30),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        "Log out",
                                                                        style: GoogleFonts
                                                                            .comfortaa(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: SvgPicture.asset(
                                        "assets/SignOut.svg",
                                        color: Colors.white,
                                        width: 30.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 32.0, right: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 16.0),
                                          child: SvgPicture.asset(
                                            "assets/SmileySad.svg",
                                            color: Color(0xFF3F3D56),
                                            width: 32.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: SvgPicture.asset(
                                                        "assets/CurrencyInr.svg",
                                                        color:
                                                            Color(0xFF3F3D56),
                                                        width: 20.0,
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        "$netGotAmount",
                                                        style: GoogleFonts.lato(
                                                          color:
                                                              Color(0xFF3F3D56),
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "You will give",
                                                  style: GoogleFonts.comfortaa(
                                                    color: Color(0xFF3F3D56),
                                                    fontSize: 10,
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
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 32.0, left: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 16.0),
                                          child: SvgPicture.asset(
                                            "assets/Smiley.svg",
                                            color: Color(0xFF3F3D56),
                                            width: 32.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: SvgPicture.asset(
                                                        "assets/CurrencyInr.svg",
                                                        color:
                                                            Color(0xFF3F3D56),
                                                        width: 20.0,
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        "$netGivenAmount",
                                                        style: GoogleFonts.lato(
                                                          color:
                                                              Color(0xFF3F3D56),
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "You will get",
                                                  style: GoogleFonts.comfortaa(
                                                    color: Color(0xFF3F3D56),
                                                    fontSize: 10,
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
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, left: 32.0, right: 32.0),
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(0xFF555274),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: TextField(
                                          controller: _searchController,
                                          onSubmitted: (v) {
                                            if (searchQuery !=
                                                _searchController.text
                                                    .trim()
                                                    .toLowerCase()) {
                                              setState(() {
                                                searchQuery = _searchController
                                                    .text
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
                                              searchQuery = _searchController
                                                  .text
                                                  .trim()
                                                  .toLowerCase();
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
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
                        child: (filteredData!.keys.isEmpty)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/waiting.png",
                                    height: 150.0,
                                  ),
                                  Text(
                                    "No transactions.",
                                    style: GoogleFonts.comfortaa(),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: filteredData!.keys.length,
                                  itemBuilder: (context, index) {
                                    DuesUser listUser =
                                        filteredData!.keys.toList()[index];
                                    int amount = filteredData![listUser]!;
                                    return Builder(builder: (context) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) => DetailsPage(
                                                      currentUser: duesUser!,
                                                      targetUser: listUser,
                                                      index: index,
                                                      transactions:
                                                          sanitizedData[listUser
                                                              .firebaseUid]!)));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                          ),
                                          child: Container(
                                            height: 80.0,
                                            child: Card(
                                              elevation: 2.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0),
                                                    child: Hero(
                                                      tag:
                                                          "userIconHero${index}",
                                                      child: Container(
                                                        width: 48.0,
                                                        height: 48.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFFCB495),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      24.0),
                                                        ),
                                                        child: Center(
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: Text(
                                                              listUser.name[0],
                                                              style: GoogleFonts
                                                                  .comfortaa(
                                                                fontSize: 20.0,
                                                                color: Color(
                                                                    0xFF3F3D56),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Hero(
                                                        tag:
                                                            "userNameHero${index}",
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: Text(
                                                            listUser.name,
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
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16.0),
                                                    child: Hero(
                                                      tag:
                                                          "userDueHero${index}",
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: Container(
                                                          height: 80.0,
                                                          child: Column(
                                                            children: [
                                                              Spacer(),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Center(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      "assets/CurrencyInr.svg",
                                                                      color: Color(
                                                                          0xFF3F3D56),
                                                                      width:
                                                                          20.0,
                                                                    ),
                                                                  ),
                                                                  Center(
                                                                    child: Text(
                                                                      "${amount.abs()}",
                                                                      style: GoogleFonts
                                                                          .lato(
                                                                        color: Color(
                                                                            0xFF3F3D56),
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                (amount < 0)
                                                                    ? "You will get"
                                                                    : (amount >
                                                                            0)
                                                                        ? "You will give"
                                                                        : "Settled up",
                                                                style: GoogleFonts
                                                                    .comfortaa(
                                                                  color: Color(
                                                                      0xFF3F3D56),
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                            ],
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
                                      );
                                    });
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
