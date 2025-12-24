import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/bunny_storage_service.dart';
import '../models/question_model.dart';
import '../models/test_model.dart';
import '../models/test_result_model.dart';

/// مصدر البيانات البعيدة للاختبارات - Data Layer
abstract class TestRemoteDataSource {
  // Tests
  Future<void> addTest(TestModel test);
  Future<List<TestModel>> getTests({String? adminCode});
  Future<TestModel?> getTestById(String testId);
  Future<void> deleteTest(String testId);
  Future<void> updateTest(TestModel test);

  // Questions
  Future<void> addQuestion(QuestionModel question);
  Future<List<QuestionModel>> getQuestionsByTestId(String testId);
  Future<void> deleteQuestion(String questionId);
  Future<void> updateQuestion(QuestionModel question);
  Future<void> updateQuestionsCountForTest(String testId);

  // Test Results
  Future<void> saveTestResult(TestResultModel result);
  Future<List<TestResultModel>> getTestResultsByStudentCode(String studentCode);
  Future<List<TestResultModel>> getTestResultsByTestId(String testId);
  Future<TestResultModel?> getTestResult(String resultId);
}

class TestRemoteDataSourceImpl implements TestRemoteDataSource {
  final FirebaseFirestore firestore;

  TestRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== Tests ====================

  @override
  Future<void> addTest(TestModel test) async {
    try {
      await firestore.collection('tests').doc(test.id).set(test.toFirestore());
    } catch (e) {
      throw ServerException('فشل إضافة الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<List<TestModel>> getTests({String? adminCode}) async {
    try {
      // إذا لم يتم تمرير adminCode، إرجاع قائمة فارغة
      // (الطلاب يجب أن يروا فقط الاختبارات المرتبطة بـ adminCode الخاص بهم)
      if (adminCode == null || adminCode.isEmpty) {
        return [];
      }

      Query query = firestore.collection('tests')
          .where('adminCode', isEqualTo: adminCode);

      final snapshot = await query.get(const GetOptions(source: Source.server));

      final tests = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return TestModel.fromFirestore(
                doc.id, data as Map<String, dynamic>);
          })
          .toList();

      // ترتيب محلي حسب التاريخ (الأحدث أولاً)
      tests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return tests;
    } catch (e) {
      throw ServerException('فشل جلب الاختبارات: ${e.toString()}');
    }
  }

  @override
  Future<TestModel?> getTestById(String testId) async {
    try {
      final doc = await firestore
          .collection('tests')
          .doc(testId)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) {
        return null;
      }

      return TestModel.fromFirestore(doc.id, doc.data() ?? {});
    } catch (e) {
      throw ServerException('فشل جلب الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTest(String testId) async {
    try {
      // جلب جميع الأسئلة المرتبطة بالاختبار قبل الحذف
      final questionsSnapshot = await firestore
          .collection('questions')
          .where('testId', isEqualTo: testId)
          .get();

      // حذف الصور من Bunny Storage لكل سؤال يحتوي على imageUrl
      debugPrint('🔍 عدد الأسئلة المرتبطة بالاختبار: ${questionsSnapshot.docs.length}');
      for (var doc in questionsSnapshot.docs) {
        final questionData = doc.data();
        final imageUrl = questionData['imageUrl'] as String?;
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            debugPrint('🔍 محاولة حذف صورة السؤال من Bunny Storage: $imageUrl');
            final fileName = BunnyStorageService.getFileNameFromUrl(imageUrl);
            debugPrint('📝 اسم الملف المستخرج: $fileName');
            if (fileName.isNotEmpty) {
              await BunnyStorageService.deleteImage(fileName);
              debugPrint('✅ تم حذف صورة السؤال بنجاح من Bunny Storage');
            } else {
              debugPrint('⚠️ لم يتم استخراج اسم الملف من URL');
            }
          } catch (e) {
            // لا نوقف العملية إذا فشل حذف الصورة من Bunny Storage
            // فقط نطبع الخطأ ونكمل
            debugPrint('⚠️ فشل حذف صورة السؤال من Bunny Storage: $e');
          }
        } else {
          debugPrint('ℹ️ السؤال ${doc.id} لا يحتوي على imageUrl');
        }
      }

      // حذف الاختبار
      await firestore.collection('tests').doc(testId).delete();

      // حذف جميع الأسئلة المرتبطة بالاختبار
      final batch = firestore.batch();
      for (var doc in questionsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('فشل حذف الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTest(TestModel test) async {
    try {
      await firestore.collection('tests').doc(test.id).update(test.toFirestore());
    } catch (e) {
      throw ServerException('فشل تحديث الاختبار: ${e.toString()}');
    }
  }

  // ==================== Questions ====================

  @override
  Future<void> addQuestion(QuestionModel question) async {
    try {
      await firestore
          .collection('questions')
          .doc(question.id)
          .set(question.toFirestore());

      // تحديث عدد الأسئلة في الاختبار
      await updateQuestionsCountForTest(question.testId);
    } catch (e) {
      throw ServerException('فشل إضافة السؤال: ${e.toString()}');
    }
  }

  @override
  Future<List<QuestionModel>> getQuestionsByTestId(String testId) async {
    try {
      final snapshot = await firestore
          .collection('questions')
          .where('testId', isEqualTo: testId)
          .get(const GetOptions(source: Source.server));

      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(
              doc.id, doc.data()))
          .toList();

      // ترتيب حسب order
      questions.sort((a, b) => a.order.compareTo(b.order));

      return questions;
    } catch (e) {
      throw ServerException('فشل جلب الأسئلة: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    try {
      // جلب معلومات السؤال لمعرفة الاختبار المرتبط
      final questionDoc =
          await firestore.collection('questions').doc(questionId).get();
      if (!questionDoc.exists) {
        throw ServerException('السؤال غير موجود');
      }

      final questionData = questionDoc.data();
      final testId = questionData?['testId'] as String?;
      final imageUrl = questionData?['imageUrl'] as String?;

      // حذف الصورة من Bunny Storage إذا كانت موجودة
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          debugPrint('🔍 محاولة حذف صورة السؤال من Bunny Storage: $imageUrl');
          final fileName = BunnyStorageService.getFileNameFromUrl(imageUrl);
          debugPrint('📝 اسم الملف المستخرج: $fileName');
          if (fileName.isNotEmpty) {
            await BunnyStorageService.deleteImage(fileName);
            debugPrint('✅ تم حذف صورة السؤال بنجاح من Bunny Storage');
          } else {
            debugPrint('⚠️ لم يتم استخراج اسم الملف من URL');
          }
        } catch (e) {
          // لا نوقف العملية إذا فشل حذف الصورة من Bunny Storage
          // فقط نطبع الخطأ ونكمل
          debugPrint('⚠️ فشل حذف صورة السؤال من Bunny Storage: $e');
        }
      } else {
        debugPrint('ℹ️ السؤال لا يحتوي على imageUrl');
      }

      // حذف السؤال
      await firestore.collection('questions').doc(questionId).delete();

      // تحديث عدد الأسئلة في الاختبار
      if (testId != null) {
        await updateQuestionsCountForTest(testId);
      }
    } catch (e) {
      throw ServerException('فشل حذف السؤال: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuestion(QuestionModel question) async {
    try {
      await firestore
          .collection('questions')
          .doc(question.id)
          .update(question.toFirestore());
    } catch (e) {
      throw ServerException('فشل تحديث السؤال: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuestionsCountForTest(String testId) async {
    try {
      final questionsCount = await firestore
          .collection('questions')
          .where('testId', isEqualTo: testId)
          .count()
          .get();

      await firestore.collection('tests').doc(testId).update({
        'questionsCount': questionsCount.count,
      });
    } catch (e) {
      // لا نرمي exception هنا لأنها عملية مساعدة
    }
  }

  // ==================== Test Results ====================

  @override
  Future<void> saveTestResult(TestResultModel result) async {
    try {
      await firestore
          .collection('testResults')
          .doc(result.id)
          .set(result.toFirestore());
    } catch (e) {
      throw ServerException('فشل حفظ نتيجة الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<List<TestResultModel>> getTestResultsByStudentCode(
      String studentCode) async {
    try {
      final snapshot = await firestore
          .collection('testResults')
          .where('studentCode', isEqualTo: studentCode)
          .get(const GetOptions(source: Source.server));

      final results = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return TestResultModel.fromFirestore(
                doc.id, data as Map<String, dynamic>);
          })
          .toList();

      // ترتيب حسب التاريخ (الأحدث أولاً)
      results.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return results;
    } catch (e) {
      throw ServerException('فشل جلب نتائج الاختبارات: ${e.toString()}');
    }
  }

  @override
  Future<List<TestResultModel>> getTestResultsByTestId(String testId) async {
    try {
      final snapshot = await firestore
          .collection('testResults')
          .where('testId', isEqualTo: testId)
          .get(const GetOptions(source: Source.server));

      final results = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return TestResultModel.fromFirestore(
                doc.id, data as Map<String, dynamic>);
          })
          .toList();

      // ترتيب حسب التاريخ (الأحدث أولاً)
      results.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return results;
    } catch (e) {
      throw ServerException('فشل جلب نتائج الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<TestResultModel?> getTestResult(String resultId) async {
    try {
      final doc = await firestore
          .collection('testResults')
          .doc(resultId)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      return TestResultModel.fromFirestore(
          doc.id, data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('فشل جلب نتيجة الاختبار: ${e.toString()}');
    }
  }
}

