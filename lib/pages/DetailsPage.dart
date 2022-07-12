import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dues/models/DuesTransaction.dart';
import 'package:dues/models/DuesUser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailsPage extends StatefulWidget {
  DuesUser currentUser;
  DuesUser targetUser;
  int index;
  List<DuesTransaction> transactions;
  DetailsPage(
      {Key? key,
      required this.currentUser,
      required this.targetUser,
      required this.index,
      required this.transactions})
      : super(key: key);

  @override
  _DetailsPage createState() => _DetailsPage();
}

class _DetailsPage extends State<DetailsPage> {
  final TextEditingController _amountGivenController = TextEditingController();
  final TextEditingController _amountGotController = TextEditingController();
  String _amountGivenError = "";
  String _amountGotError = "";

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    int amount = 0;
    widget.transactions.sort((a, b) {
      return b.dateTime.compareTo(a.dateTime);
    });
    widget.transactions.forEach((transaction) {
      if (transaction.toUid == widget.currentUser.firebaseUid) {
        amount += transaction.amount;
      } else {
        amount -= transaction.amount;
      }
    });
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 130.0,
            decoration: BoxDecoration(
              color: Color(0xFF3F3D56),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 8.0, bottom: 16.0, top: 25.0),
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
                          child: Hero(
                            tag: "userIconHero${widget.index}",
                            child: Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFFCB495),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    widget.targetUser.name[0],
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 20.0,
                                      color: Color(0xFF3F3D56),
                                      fontWeight: FontWeight.w900,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 20),
                                  child: Hero(
                                    tag: "userNameHero${widget.index}",
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        widget.targetUser.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.comfortaa(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, left: 8.0),
                                  child: Hero(
                                    tag: "usernameHero${widget.index}",
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Row(
                                        children: [
                                          Center(
                                            child: SvgPicture.asset(
                                              "assets/At.svg",
                                              color: Colors.white,
                                              width: 15.0,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 4.0),
                                            child: Text(
                                              widget.targetUser.username.length <
                                                      10
                                                  ? widget.targetUser.username
                                                  : "${widget.targetUser.username.substring(0, 10)}...",
                                              style: GoogleFonts.comfortaa(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.0),
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
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, top: 20),
                          child: Hero(
                            tag: "userDueHero${widget.index}",
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                height: 80.0,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/CurrencyInr.svg",
                                          color: Colors.white,
                                          width: 20.0,
                                        ),
                                        Text(
                                          "${amount.abs()}",
                                          style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      (amount > 0)
                                          ? "You will give"
                                          : (amount < 0)
                                              ? "You will get"
                                              : "Settled up",
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
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
              child: Column(
                children: [
                  Expanded(
                    child: (widget.transactions.isEmpty)
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
                              itemCount: widget.transactions.length,
                              itemBuilder: (context, index) {
                                final aDate = DateTime(
                                    widget.transactions[index].dateTime.year,
                                    widget.transactions[index].dateTime.month,
                                    widget.transactions[index].dateTime.day);
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0),
                                  child: Container(
                                    height: 80.0,
                                    child: Card(
                                      elevation: 2.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16.0),
                                            child: Container(
                                              width: 48.0,
                                              height: 48.0,
                                              decoration: BoxDecoration(
                                                color: widget.transactions[index]
                                                            .toUid ==
                                                        widget.currentUser
                                                            .firebaseUid
                                                    ? Colors.green
                                                    : Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  widget.transactions[index]
                                                              .toUid ==
                                                          widget.currentUser
                                                              .firebaseUid
                                                      ? "+"
                                                      : "-",
                                                  style: GoogleFonts.comfortaa(
                                                    fontSize: 25.0,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8.0),
                                            child: Container(
                                              height: 80.0,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0, top: 20),
                                                    child: Text(
                                                      DateFormat("h:mma").format(
                                                          widget
                                                              .transactions[index]
                                                              .dateTime),
                                                      style: GoogleFonts.lato(
                                                        color: Color(0xFF3F3D56),
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0, top: 4.0),
                                                    child: Text(
                                                      (aDate == today)
                                                          ? "Today"
                                                          : (aDate == yesterday)
                                                              ? "Yesterday"
                                                              : DateFormat
                                                                      .yMMMMd()
                                                                  .format(aDate),
                                                      style:
                                                          GoogleFonts.comfortaa(
                                                              color: Color(
                                                                  0xFF3F3D56),
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 13.0),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: Container(
                                              height: 80.0,
                                              child: Column(
                                                children: [
                                                  Spacer(),
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
                                                          "${widget.transactions[index].amount}",
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
                                                    widget.transactions[index]
                                                                .toUid ==
                                                            widget.currentUser
                                                                .firebaseUid
                                                        ? "You got"
                                                        : "You gave",
                                                    style: GoogleFonts.comfortaa(
                                                      color: Color(0xFF3F3D56),
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ),
                  ),
                  Container(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 8.0, bottom: 16.0),
                            child: Container(
                              height: 70,
                              child: Builder(builder: (context) {
                                return ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(32.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8),
                                                    child: Row(
                                                      children: [
                                                        Center(
                                                          child: Container(
                                                            width: 32.0,
                                                            child: SvgPicture
                                                                .asset(
                                                              "assets/CurrencyInr.svg",
                                                              color: Color(
                                                                  0xFF3F3D56),
                                                              width: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      0.0),
                                                              child: TextField(
                                                                controller:
                                                                    _amountGivenController,
                                                                onChanged: (v) {
                                                                  setState(() {
                                                                    _amountGivenError =
                                                                        "";
                                                                  });
                                                                },
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                cursorColor: Color(
                                                                    0xFF3F3D56),
                                                                style: GoogleFonts
                                                                    .comfortaa(
                                                                  color: Color(
                                                                      0xFF3F3D56),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                                decoration:
                                                                    InputDecoration(
                                                                        border: InputBorder
                                                                            .none,
                                                                        focusedBorder:
                                                                            InputBorder
                                                                                .none,
                                                                        enabledBorder:
                                                                            InputBorder
                                                                                .none,
                                                                        errorBorder:
                                                                            InputBorder
                                                                                .none,
                                                                        disabledBorder:
                                                                            InputBorder
                                                                                .none,
                                                                        labelText:
                                                                            "Amount you gave",
                                                                        labelStyle:
                                                                            GoogleFonts
                                                                                .comfortaa(
                                                                          color:
                                                                              Color(0xEE3F3D56),
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                        ),
                                                                        errorText: _amountGivenError ==
                                                                                ""
                                                                            ? null
                                                                            : _amountGivenError),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Container(
                                                    height: 60,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        String amountEntered =
                                                            _amountGivenController
                                                                .text;
                                                        if (!RegExp(r"^[0-9]+$")
                                                                .hasMatch(
                                                                    amountEntered) ||
                                                            amountEntered
                                                                .isEmpty ||
                                                            RegExp(r"^[0]+$")
                                                                .hasMatch(
                                                                    amountEntered)) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      "Invalid amount")));
                                                          Navigator.of(context)
                                                              .pop();
                                                          return;
                                                        }
                                                        DuesTransaction
                                                            newTransaction =
                                                            DuesTransaction(
                                                                fromUid: widget
                                                                    .currentUser
                                                                    .firebaseUid,
                                                                toUid: widget
                                                                    .targetUser
                                                                    .firebaseUid,
                                                                amount: int.parse(
                                                                    amountEntered),
                                                                dateTime:
                                                                    DateTime
                                                                        .now());
                                                        CollectionReference
                                                            transactionCollection =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "transactions");
                                                        transactionCollection
                                                            .add(newTransaction
                                                                .toJson());
                                                        widget.transactions.add(
                                                            newTransaction);
                                                        setState(() {
                                                          _amountGivenError =
                                                              "";
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                            Color(0xFF3F3D56),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "Submit",
                                                            style: GoogleFonts
                                                                .comfortaa(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8.0),
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .arrowRight,
                                                              size: 15.0,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFFFCB495),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "You gave",
                                        style: GoogleFonts.comfortaa(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: SvgPicture.asset(
                                          "assets/CurrencyInr.svg",
                                          color: Colors.white,
                                          width: 20.0,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 16.0, left: 8.0, bottom: 16.0),
                            child: Container(
                              height: 70,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(32.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Row(
                                                    children: [
                                                      Center(
                                                        child: Container(
                                                          width: 32.0,
                                                          child:
                                                              SvgPicture.asset(
                                                            "assets/CurrencyInr.svg",
                                                            color: Color(
                                                                0xFF3F3D56),
                                                            width: 20.0,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        0.0),
                                                            child: TextField(
                                                              controller:
                                                                  _amountGotController,
                                                              onChanged: (v) {
                                                                setState(() {
                                                                  _amountGotError =
                                                                      "";
                                                                });
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              cursorColor: Color(
                                                                  0xFF3F3D56),
                                                              style: GoogleFonts
                                                                  .comfortaa(
                                                                color: Color(
                                                                    0xFF3F3D56),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                      border: InputBorder
                                                                          .none,
                                                                      focusedBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      enabledBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      errorBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      disabledBorder:
                                                                          InputBorder
                                                                              .none,
                                                                      labelText:
                                                                          "Amount you received",
                                                                      labelStyle:
                                                                          GoogleFonts
                                                                              .comfortaa(
                                                                        color: Color(
                                                                            0xEE3F3D56),
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                      ),
                                                                      errorText: _amountGotError ==
                                                                              ""
                                                                          ? null
                                                                          : _amountGotError),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Container(
                                                  height: 60,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      String amountEntered =
                                                          _amountGotController
                                                              .text;
                                                      if (!RegExp(r"^[0-9]+$")
                                                              .hasMatch(
                                                                  amountEntered) ||
                                                          amountEntered
                                                              .isEmpty ||
                                                          RegExp(r"^[0]+$")
                                                              .hasMatch(
                                                                  amountEntered)) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    "Invalid amount")));
                                                        Navigator.of(context)
                                                            .pop();
                                                        return;
                                                      }
                                                      DuesTransaction
                                                          newTransaction =
                                                          DuesTransaction(
                                                              fromUid: widget
                                                                  .targetUser
                                                                  .firebaseUid,
                                                              toUid: widget
                                                                  .currentUser
                                                                  .firebaseUid,
                                                              amount: int.parse(
                                                                  amountEntered),
                                                              dateTime: DateTime
                                                                  .now());
                                                      CollectionReference
                                                          transactionCollection =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "transactions");
                                                      transactionCollection.add(
                                                          newTransaction
                                                              .toJson());
                                                      widget.transactions
                                                          .add(newTransaction);
                                                      setState(() {
                                                        _amountGotError = "";
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary:
                                                          Color(0xFF3F3D56),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Submit",
                                                          style: GoogleFonts
                                                              .comfortaa(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 8.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .arrowRight,
                                                            size: 15.0,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF3F3D56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "You got",
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: SvgPicture.asset(
                                        "assets/CurrencyInr.svg",
                                        color: Colors.white,
                                        width: 20.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
