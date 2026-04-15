import 'package:flutter/material.dart';
import 'package:umrahapp/final_project_application.dart';
import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferancesService.init();
  ApiService.init();
  runApp(const FinalProjectApplication());
}



