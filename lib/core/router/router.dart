

import 'package:go_router/go_router.dart';

import '../../features/auth/LoginScreen.dart';
import '../../features/auth/on_boarding_screen.dart';
import '../../features/start_screen.dart';
import '../../main_screen.dart';
import 'app_routers.dart';


class RouterGenerator {

  static final GoRouter router = GoRouter(
    initialLocation: AppRouters.startScreen,
    routes: <GoRoute>[
      GoRoute(
        path: AppRouters.startScreen,
        name:AppRouters.startScreen ,
        builder: ( context,  state) {
          return  StartScreen();
        },
      ),
      GoRoute( path: AppRouters.OnBoardingScreen,
              name:  AppRouters.OnBoardingScreen,
              builder: (context, state) {
                return const OnBoardingScreen();
              },),
      GoRoute( path: AppRouters.codeInputScreen,
              name:  AppRouters.codeInputScreen,
              builder: (context, state) {
                return const CodeInputScreen  ();}),
      GoRoute( path: AppRouters.mainScreen,
              name:  AppRouters.mainScreen,
              builder: (context, state) { return const MainScreen  ();}),




    ],

  );
}


