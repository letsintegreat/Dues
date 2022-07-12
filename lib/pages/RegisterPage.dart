import 'package:dues/models/DuesUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String _nameError = "";
  String _usernameError = "";
  String _passwordError = "";
  String _confirmError = "";

  Future<void> submit() async {
    String name = _nameController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;
    String confirm = _confirmController.text;

    if (name.isEmpty) {
      setState(() {
        _nameError = "Name is required.";
      });
      return;
    }
    if (username.isEmpty) {
      setState(() {
        _usernameError = "Username is required.";
      });
      return;
    }
    if (!RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(username)) {
      setState(() {
        _usernameError =
            "Only alphanumerics and underscores.";
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _confirmError = "Passwords don't match.";
      });
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: "$username@dues.com", password: password);
      User firebaseUser = FirebaseAuth.instance.currentUser!;
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection("users");
      DuesUser duesUser = DuesUser(
          firebaseUid: firebaseUser.uid, name: name, username: username);
      usersCollection.doc(duesUser.firebaseUid).set(duesUser.toJson());
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        setState(() {
          _passwordError = "Password too weak.";
        });
      } else if (e.code == "email-already-in-use") {
        setState(() {
          _usernameError = "Username already registered.";
        });
      }
    } catch (e) {
      print(e);
    }
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
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFF3F3D56),
            image: DecorationImage(
              image: AssetImage("assets/signup_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100.0, bottom: 60.0),
                child: Center(
                    child: SvgPicture.asset(
                  "assets/register.svg",
                  color: Colors.white,
                  height: 80.0,
                )),
              ),
              Center(
                child: Text(
                  "Register yourself",
                  style: GoogleFonts.comfortaa(
                    fontSize: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Create an account to create track of your dues.",
                    style: GoogleFonts.comfortaa(
                      fontSize: 13.0,
                      color: Color(0x99FFFFFF),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 80.0, left: 32.0, right: 32.0),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Center(
                          child: Container(
                            width: 32.0,
                            child: SvgPicture.asset(
                              "assets/UserFocus.svg",
                              color: Color(0xFF3F3D56),
                              width: 20.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: TextField(
                              controller: _nameController,
                              onChanged: (v) {
                                setState(() {
                                  _nameError = "";
                                });
                              },
                              cursorColor: Color(0xFF3F3D56),
                              style: GoogleFonts.comfortaa(
                                color: Color(0xFF3F3D56),
                                fontWeight: FontWeight.w900,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelText: "Name",
                                labelStyle: GoogleFonts.comfortaa(
                                  color: Color(0xEE3F3D56),
                                  fontWeight: FontWeight.normal,
                                ),
                                errorText: _nameError == "" ? null : _nameError,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Hero(
                tag: "usernameHero",
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 32.0, right: 32.0),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Center(
                              child: Container(
                                width: 32.0,
                                child: SvgPicture.asset(
                                  "assets/At.svg",
                                  color: Color(0xFF3F3D56),
                                  width: 20.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: TextField(
                                  controller: _usernameController,
                                  onChanged: (v) {
                                    setState(() {
                                      _usernameError = "";
                                    });
                                  },
                                  cursorColor: Color(0xFF3F3D56),
                                  style: GoogleFonts.comfortaa(
                                    color: Color(0xFF3F3D56),
                                    fontWeight: FontWeight.w900,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    labelText: "Username",
                                    labelStyle: GoogleFonts.comfortaa(
                                      color: Color(0xEE3F3D56),
                                      fontWeight: FontWeight.normal,
                                    ),
                                    errorText: _usernameError == ""
                                        ? null
                                        : _usernameError,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Hero(
                tag: "passwordHero",
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 32.0, right: 32.0),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Center(
                              child: Container(
                                width: 32.0,
                                child: SvgPicture.asset(
                                  "assets/Keyhole.svg",
                                  color: Color(0xFF3F3D56),
                                  width: 20.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: TextField(
                                  controller: _passwordController,
                                  onChanged: (v) {
                                    setState(() {
                                      _passwordError = "";
                                    });
                                  },
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  cursorColor: Color(0xFF3F3D56),
                                  style: GoogleFonts.comfortaa(
                                    color: Color(0xFF3F3D56),
                                    fontWeight: FontWeight.w900,
                                  ),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      labelText: "Password",
                                      labelStyle: GoogleFonts.comfortaa(
                                        color: Color(0xEE3F3D56),
                                        fontWeight: FontWeight.normal,
                                      ),
                                      errorText: _passwordError == ""
                                          ? null
                                          : _passwordError),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Center(
                          child: Container(
                            width: 32.0,
                            child: SvgPicture.asset(
                              "assets/Keyhole.svg",
                              color: Color(0xFF3F3D56),
                              width: 20.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: TextField(
                              controller: _confirmController,
                              onChanged: (v) {
                                setState(() {
                                  _confirmError = "";
                                });
                              },
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              cursorColor: Color(0xFF3F3D56),
                              style: GoogleFonts.comfortaa(
                                color: Color(0xFF3F3D56),
                                fontWeight: FontWeight.w900,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelText: "Confirm password",
                                labelStyle: GoogleFonts.comfortaa(
                                  color: Color(0xEE3F3D56),
                                  fontWeight: FontWeight.normal,
                                ),
                                errorText:
                                    _confirmError == "" ? null : _confirmError,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Hero(
                tag: "registerHero",
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 32.0, right: 32.0, bottom: 32.0),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          submit();
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
                              "Register",
                              style: GoogleFonts.comfortaa(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: FaIcon(
                                FontAwesomeIcons.arrowRight,
                                size: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color = Colors.white})
      : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 3.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
