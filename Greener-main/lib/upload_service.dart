import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class UploadService {
  final ImagePicker _picker = ImagePicker();

  Future<Map<String, dynamic>> pickAndUploadImageWithType(String type) async {
    try {
      // 🖼️ نختار صورة من المعرض
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return {'success': false};

      final File file = File(image.path);
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 📦 النقاط حسب النوع
      final validTypes = ['Metal', 'Organic', 'Paper', 'Plastic'];
      final points = validTypes.contains(type) ? 3 : 1;

      // 📁 اسم الصورة والمجلد
      final fileName = path.basename(image.path);
      final storageRef = FirebaseStorage.instance.ref().child(
        "$type/$fileName",
      );

      // ☁️ رفع الصورة
      await storageRef.putFile(file);
      final imageUrl = await storageRef.getDownloadURL();

      // 📝 Firestore: تخزين الصورة
      await FirebaseFirestore.instance
          .collection('user_waste')
          .doc(uid)
          .collection('images')
          .add({
            'imageUrl': imageUrl,
            'category': type,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // ⭐️ تحديث النقاط للمستخدم
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      await userRef.update({'points': FieldValue.increment(points)});

      print("✅ Image uploaded to $type. +$points points added.");
      return {'success': true, 'points': points, 'category': type};
    } catch (e) {
      print("❌ Upload failed: $e");
      return {'success': false};
    }
  }
}
