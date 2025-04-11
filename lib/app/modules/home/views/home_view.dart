import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD32F2F), // redAccent.shade700
              Color(0xFFFF5252), // redAccent.shade400
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(
                FontAwesomeIcons.bookOpen,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                ),
                cursorColor: Colors.white,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Enter a topic...",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final topic = _controller.text.trim();
                    if (topic.isNotEmpty) {
                      // Navigation or logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Continuing with topic: $topic"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a topic!"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(title: const Text("Stateless Text Input")),
    //   body: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       children: [
    //         TextField(
    //           controller: _controller,
    //           decoration: const InputDecoration(
    //             labelText: "Enter text",
    //             border: OutlineInputBorder(),
    //           ),
    //         ),
    //         SizedBox(height: 20),
    //         ElevatedButton(
    //           onPressed: () async {
    //             // Get.toNamed(Routes.SHOW_GRAPH);
    //             String inputText = _controller.text;
    //             String responce = await controller.generateContent(inputText);
    //             Get.toNamed(Routes.AI_RESPONCE, arguments: [responce]);
    //           },
    //           child: const Text("Generate"),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class HomeScreen extends StatelessWidget {
//   final TextEditingController topicController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
  
//   }
// }
