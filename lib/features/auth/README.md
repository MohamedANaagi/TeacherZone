# Auth Feature - مثال Clean Architecture

هذا المجلد يحتوي على مثال كامل لتطبيق Clean Architecture في ميزة المصادقة.

## الهيكل

```
auth/
├── data/                          # طبقة البيانات
│   ├── datasources/              # مصادر البيانات
│   │   └── auth_remote_datasource.dart
│   ├── models/                   # نماذج البيانات
│   │   └── user_model.dart
│   └── repositories/            # تطبيقات المستودعات
│       └── auth_repository_impl.dart
│
├── domain/                       # طبقة الأعمال
│   ├── entities/                 # الكيانات
│   │   └── user.dart
│   ├── repositories/             # واجهات المستودعات
│   │   └── auth_repository.dart
│   └── usecases/                 # حالات الاستخدام
│       └── login_usecase.dart
│
└── presentation/                 # طبقة العرض
    └── screens/
        └── login_screen.dart
```

## تدفق البيانات

```
UI (LoginScreen)
    ↓
Use Case (LoginUseCase)
    ↓
Repository Interface (AuthRepository)
    ↓
Repository Implementation (AuthRepositoryImpl)
    ↓
Data Source (AuthRemoteDataSource)
    ↓
API / Database
```

## الاستخدام

```dart
// 1. إنشاء Data Source
final remoteDataSource = AuthRemoteDataSourceImpl();

// 2. إنشاء Repository
final repository = AuthRepositoryImpl(
  remoteDataSource: remoteDataSource,
);

// 3. إنشاء Use Case
final loginUseCase = LoginUseCase(repository);

// 4. استخدام Use Case في UI
final user = await loginUseCase('12345');
```

## ملاحظات

- **Domain Layer** لا يعتمد على أي طبقة أخرى
- **Data Layer** يعتمد على **Domain Layer** فقط
- **Presentation Layer** يعتمد على **Domain Layer** فقط

