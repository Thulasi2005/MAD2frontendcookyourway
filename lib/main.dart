import 'package:flutter/material.dart';
import 'customer/customer_sign_up_page.dart';
import 'foodmaker/food_maker_sign_up_page.dart';
import 'foodmaker/foodmaker_signin_page.dart';
import 'customer/customer_signin_page.dart' as customer;
import 'intro_page.dart';
import 'register_user_selection_page.dart';
import 'customer/customer_sign_up_page.dart';
import 'customer/customer_home_page.dart';
import 'foodmaker/foodmaker_homepage.dart';
import 'foodmaker/foodmaker_menuhandling_page.dart';
import 'customer/customer_browsemenu_page.dart';
import 'customer/customer_cart_page.dart';
import 'customer/customer_customizedfood_request_page.dart';
import 'foodmaker/foodmaker_response_customizedrequests_page.dart';
import 'customer/customer_customizedrequests_response_page.dart';
import 'foodmaker/foodmaker_paymentreceival_page.dart';
import 'customer/customer_profile_page.dart';
import 'sign_in_page.dart';
import 'foodmaker/food_maker_profile_page.dart';
import 'customer/customer_payment_page.dart';
import 'help_page.dart';


void main()  {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bridge of Hope',
        theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto', // Set the default font family to Roboto
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => IntroPage(),
      '/loginselection':(context)=> SignInPage(),
      '/foodmakersignIn': (context) =>FoodMakerLoginPage(),
      '/customersignIn' : (context) => customer.LoginPage(),
      '/registerselection' : (context) => RegistrationSelectionPage(),
      '/customersignUp' : (context) => CustomerSignUpPage(),
      '/foodmakersignUp': (context) => FoodMakerSignUpPage(),
      '/customercustomizedrequests': (context) => CustomizeFoodPage(),
      '/customerhomepage': (context) => CustomerHomePage(),
      '/helppage': (context) => ContactServicePage(),
      '/foodmakerpaymentreceival': (context) => FoodMakerPaymentsPage(identifier: '', token: '',),
      '/customercart': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        print("Arguments received: $args"); // Log the arguments to see what is received
        return CartPage(token: args['token']); // Pass the token here
      },
      '/customerbrowsemenu': (context) => BrowseMenuPage(),
      '/customercustomizedresponse': (context)=> OrdersPage(),
      '/foodmakerprofile':(context){ final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return FoodMakerProfilePage(identifier: args['identifier']!, token: args['token']!);
    },
      '/customerprofile': (context)  {final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return CustomerProfilePage(identifier: args['identifier']!, token: args['token']!);
    },
      '/foodmakerresponsetocustomized': (context)=> CustomizedRequestsPage(),
      '/foodmakermenu': (context) {
        // Retrieve the arguments passed from FoodMakerHomePage
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        return MenuPage(identifier: args['identifier']!, token: args['token']!);
      },
      '/foodmakerhomepage': (context){ final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        return FoodMakerHomePage(
        identifier: args['identifier'] as String,
        token: args['token'] as String,
         );






    }});}}

