import 'package:assignment_quad/homeview.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState()
  {
    super.initState();
    redirect();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
      child:Image.asset('assets/netflix.png',
      height:100,
      width:100,
      fit:BoxFit.cover,),
      ),
    );
  }

  Future<void> redirect() async{
  await Future.delayed(const Duration(seconds:2));
  Navigator.pushReplacement(context,MaterialPageRoute(builder:(BuildContext context)=> ShowList()));
  }
}