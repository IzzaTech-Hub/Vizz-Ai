import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Show feedback dialog when flag is clicked
  Future<void> showFeedbackDialog(BuildContext context, String message) async {
    // First ask if they like or dislike
    final likeDislike = await _showLikeDislikeDialog(context);
    if (likeDislike == null) return; // User cancelled

    if (likeDislike) {
      // User liked - submit directly
      await _submitFeedback(context, message, true);
    } else {
      // User disliked - ask for reason
      await _showReasonDialog(context, message);
    }
  }

  // Step 1: Like/Dislike dialog
  Future<bool?> _showLikeDislikeDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Provide Feedback"),
          content: const Text("Did you find this helpful?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Dislike"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Like"),
            ),
          ],
        );
      },
    );
  }

  // Step 2: Reason dialog (only for dislikes)
  Future<void> _showReasonDialog(BuildContext context, String message) async {
    final TextEditingController customReasonController =
        TextEditingController();
    List<String> reasons = [
      "Harmful/Unsafe",
      "Sexual Explicit Content",
      'Repetitive',
      'Hate and harassment',
      'Misinformation',
      'Frauds and scam',
      "Spam",
      "Other"
    ];
    RxString selectedReason = "".obs;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Report Inappropriate Message"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Please select a reason:"),
                ...reasons.map((reason) {
                  return Obx(() => RadioListTile(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason.value,
                        onChanged: (value) {
                          selectedReason.value = value!;
                          if (selectedReason != "Other") {
                            customReasonController.clear();
                          }
                        },
                      ));
                }).toList(),
                Obx(() => selectedReason.value == "Other"
                    ? TextField(
                        controller: customReasonController,
                        decoration: const InputDecoration(
                          labelText: "Enter custom reason",
                        ),
                      )
                    : Container()),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Submit"),
              onPressed: () async {
                String reportReason = selectedReason.value == "Other"
                    ? customReasonController.text
                    : selectedReason.value;

                if (reportReason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please select or enter a reason.")),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _submitFeedback(
                    context, '$message (Reason: $reportReason)', false);
              },
            ),
          ],
        );
      },
    );
  }

  // Submit feedback to Firebase
  Future<void> _submitFeedback(
      BuildContext context, String message, bool isLiked) async {
    print('trying');
    try {
      // EasyLoading.show(status: "Submitting...");

      await _firestore.collection('feedback').add({
        'message': message,
        'isLiked': isLiked,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // EasyLoading.dismiss();
      _showSuccessMessage(context);
    } catch (e) {
      // EasyLoading.dismiss();
      print(e);
      _showErrorMessage(context, e.toString());
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted successfully!")),
    );
  }

  void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to submit feedback")),
    );
  }
}
