# Clean Architecture Guide - دليل Clean Architecture

## نظرة عامة | Overview

هذا المشروع يستخدم **Clean Architecture** لتنظيم الكود بشكل احترافي وقابل للصيانة والتوسع.

This project uses **Clean Architecture** to organize code professionally, maintainably, and scalably.

---

## هيكل المشروع | Project Structure

```
lib/
├── core/                          # الكود المشترك | Shared Code
│   ├── router/                    # التوجيه | Routing
│   ├── styling/                   # التصميم | Styling
│   └── ...                        # Utilities, Constants, etc.
│
└── features/                      # الميزات | Features
    └── feature_name/              # اسم الميزة | Feature Name
        ├── data/                  # طبقة البيانات | Data Layer
        │   ├── datasources/       # مصادر البيانات | Data Sources
        │   │   ├── remote/        # API, Network
        │   │   └── local/         # Database, Cache
        │   ├── models/            # نماذج البيانات | Data Models
        │   └── repositories/     # تطبيقات المستودعات | Repository Implementations
        │
        ├── domain/                # طبقة الأعمال | Business Logic Layer
        │   ├── entities/          # الكيانات | Entities (Pure Dart Classes)
        │   ├── repositories/      # واجهات المستودعات | Repository Interfaces
        │   └── usecases/          # حالات الاستخدام | Use Cases
        │
        └── presentation/          # طبقة العرض | Presentation Layer
            ├── screens/           # الشاشات | Screens
            ├── widgets/            # الويدجت | Widgets
            └── providers/         # State Management (BLoC, Cubit, Provider, etc.)
```

---

## الطبقات | Layers

### 1. Presentation Layer (طبقة العرض)
**المسؤولية:** واجهة المستخدم والتفاعل مع المستخدم
**Responsibility:** UI and user interaction

**يحتوي على:**
- **Screens:** الشاشات الرئيسية
- **Widgets:** الويدجت القابلة لإعادة الاستخدام
- **State Management:** إدارة الحالة (BLoC, Cubit, Provider, etc.)

**مثال:**
```dart
// features/auth/presentation/screens/login_screen.dart
class LoginScreen extends StatelessWidget {
  // UI Code
}
```

---

### 2. Domain Layer (طبقة الأعمال)
**المسؤولية:** قواعد العمل والمنطق الأساسي (مستقل عن أي تقنية)
**Responsibility:** Business rules and core logic (technology-independent)

**يحتوي على:**
- **Entities:** الكيانات النقية (Pure Dart Classes)
- **Repository Interfaces:** واجهات المستودعات (Abstract Classes)
- **Use Cases:** حالات الاستخدام (Business Logic)

**مثال:**
```dart
// features/auth/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<User> login(String code);
  Future<void> logout();
}

// features/auth/domain/usecases/login_usecase.dart
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<User> call(String code) {
    return repository.login(code);
  }
}
```

---

### 3. Data Layer (طبقة البيانات)
**المسؤولية:** جلب وحفظ البيانات من مصادر مختلفة
**Responsibility:** Fetching and storing data from various sources

**يحتوي على:**
- **Data Sources:** مصادر البيانات (Remote API, Local Database)
- **Models:** نماذج البيانات (JSON Serialization)
- **Repository Implementations:** تطبيقات المستودعات

**مثال:**
```dart
// features/auth/data/models/user_model.dart
class UserModel extends User {
  UserModel({required super.id, required super.name, required super.email});
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// features/auth/data/datasources/remote/auth_remote_datasource.dart
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String code);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  
  AuthRemoteDataSourceImpl(this.client);
  
  @override
  Future<UserModel> login(String code) async {
    // API Call
    final response = await client.post(/* ... */);
    return UserModel.fromJson(response.data);
  }
}

// features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<User> login(String code) async {
    try {
      final userModel = await remoteDataSource.login(code);
      await localDataSource.cacheUser(userModel);
      return userModel;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
```

---

## قواعد Clean Architecture | Clean Architecture Rules

### 1. Dependency Rule (قاعدة التبعية)
- **Domain Layer** لا يعتمد على أي طبقة أخرى (Pure Dart)
- **Data Layer** يعتمد على **Domain Layer** فقط
- **Presentation Layer** يعتمد على **Domain Layer** فقط

```
Presentation → Domain ← Data
```

### 2. Data Flow (تدفق البيانات)
```
UI → Use Case → Repository → Data Source → API/Database
```

### 3. Naming Conventions (اتفاقيات التسمية)
- **Entities:** `User`, `Course`, `Exam`
- **Models:** `UserModel`, `CourseModel`, `ExamModel`
- **Repositories:** `AuthRepository`, `CourseRepository`
- **Use Cases:** `LoginUseCase`, `GetCoursesUseCase`
- **Data Sources:** `AuthRemoteDataSource`, `CourseLocalDataSource`

---

## كيفية إضافة ميزة جديدة | How to Add a New Feature

### الخطوة 1: إنشاء الهيكل
```bash
lib/features/new_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/
```

### الخطوة 2: ابدأ من Domain Layer
1. أنشئ **Entity** (Pure Dart Class)
2. أنشئ **Repository Interface** (Abstract Class)
3. أنشئ **Use Cases**

### الخطوة 3: نفذ Data Layer
1. أنشئ **Model** (extends Entity)
2. أنشئ **Data Sources** (Remote/Local)
3. أنشئ **Repository Implementation**

### الخطوة 4: أنشئ Presentation Layer
1. أنشئ **Screens**
2. أنشئ **Widgets**
3. استخدم **Use Cases** في State Management

---

## مثال كامل | Complete Example

### Domain Layer
```dart
// domain/entities/course.dart
class Course {
  final String id;
  final String title;
  final int lessonCount;
  
  Course({required this.id, required this.title, required this.lessonCount});
}

// domain/repositories/course_repository.dart
abstract class CourseRepository {
  Future<List<Course>> getCourses();
}

// domain/usecases/get_courses_usecase.dart
class GetCoursesUseCase {
  final CourseRepository repository;
  
  GetCoursesUseCase(this.repository);
  
  Future<List<Course>> call() {
    return repository.getCourses();
  }
}
```

### Data Layer
```dart
// data/models/course_model.dart
class CourseModel extends Course {
  CourseModel({
    required super.id,
    required super.title,
    required super.lessonCount,
  });
  
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      lessonCount: json['lesson_count'],
    );
  }
}

// data/datasources/remote/course_remote_datasource.dart
abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses();
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  // Implementation
}

// data/repositories/course_repository_impl.dart
class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;
  
  CourseRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<List<Course>> getCourses() async {
    return await remoteDataSource.getCourses();
  }
}
```

### Presentation Layer
```dart
// presentation/screens/courses_screen.dart
class CoursesScreen extends StatelessWidget {
  final GetCoursesUseCase getCoursesUseCase;
  
  const CoursesScreen({required this.getCoursesUseCase});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: getCoursesUseCase(),
      builder: (context, snapshot) {
        // UI Code
      },
    );
  }
}
```

---

## Dependency Injection (DI)

استخدم **get_it** أو **provider** لإدارة التبعيات:

```dart
// core/injection/injection_container.dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(http.Client()),
  );
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
}
```

---

## State Management

يمكنك استخدام أي طريقة لإدارة الحالة:
- **BLoC** (Recommended)
- **Cubit**
- **Provider**
- **Riverpod**

---

## نصائح مهمة | Important Tips

1. ✅ **ابدأ دائماً من Domain Layer** - إنه الأهم
2. ✅ **استخدم Entities في Domain** - لا تستخدم Models
3. ✅ **احفظ Business Logic في Use Cases** - ليس في UI
4. ✅ **استخدم Repository Pattern** - لفصل مصادر البيانات
5. ✅ **اختبر كل طبقة بشكل منفصل** - Unit Tests لكل طبقة
6. ✅ **استخدم Dependency Injection** - لتسهيل الاختبار والصيانة

---

## المراجع | References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)

---

## الدعم | Support

إذا كان لديك أي أسئلة حول Clean Architecture في هذا المشروع، راجع هذا الدليل أو اسأل الفريق.

If you have any questions about Clean Architecture in this project, refer to this guide or ask the team.

