import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
                child: Image.asset("lib/images/w3slogo.png")
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/images/apple.png",
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Continue with Apple",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  )
                ),
                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/images/google.png",
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Continue with Google",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                        ),
                      ),
                    ],
                  )
                ),
                SizedBox(height: 16),

                // Sign up button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0
                  ),
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  )
                ),
                SizedBox(height: 16),

                // Log in button
                ElevatedButton(
                  onPressed: () {

                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Log in",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}