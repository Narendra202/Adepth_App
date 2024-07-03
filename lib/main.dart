import 'package:expedition_poc/screens/application/expeditions/areas/area_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/areas.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/dive_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/dives.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/records/record_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/samples/analysis/analysis.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/samples/analysis/analysis_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/samples/sample_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/samples/samples.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/location_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/locations.dart';
import 'package:expedition_poc/screens/application/expeditions/data/data.dart';
import 'package:expedition_poc/screens/application/expeditions/data/data_form.dart';
import 'package:expedition_poc/screens/application/expeditions/expedition_form.dart';
// import 'package:expedition_poc/screens/application/expeditions/expedition_form.dart';

import 'package:expedition_poc/screens/application/expeditions/expeditions.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platform_form.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platforms.dart';
import 'package:expedition_poc/screens/application/expeditions/tools/tool_form.dart';
import 'package:expedition_poc/screens/application/expeditions/tools/tools.dart';
import 'package:expedition_poc/screens/auth/authGuard.dart';
import 'package:expedition_poc/screens/auth/components/LoginForm.dart';
import 'package:expedition_poc/screens/auth/login_page.dart';
import 'package:expedition_poc/screens/home_page.dart';
import 'package:expedition_poc/screens/validator_page.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(
  //     debug: true // Set debug to true for verbose logs
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Adepth",
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: ColorUtils.primaryColor,
        primarySwatch:
            MaterialColor(ColorUtils.primaryColor.value, <int, Color>{
          50: ColorUtils.primaryColor.withOpacity(0.1),
          100: ColorUtils.primaryColor.withOpacity(0.2),
          200: ColorUtils.primaryColor.withOpacity(0.3),
          300: ColorUtils.primaryColor.withOpacity(0.4),
          400: ColorUtils.primaryColor.withOpacity(0.5),
          500: ColorUtils.primaryColor.withOpacity(0.6),
          600: ColorUtils.primaryColor.withOpacity(0.7),
          700: ColorUtils.primaryColor.withOpacity(0.8),
          800: ColorUtils.primaryColor.withOpacity(0.9),
          900: ColorUtils.primaryColor,
        }),
      ),
      debugShowCheckedModeBanner: false,
      // home: HomePage(),
      initialRoute: "/",
      onGenerateRoute: AuthGuard.generateRoute,
      onUnknownRoute: (settings) {
        // Handle unknown routes and redirect to the home page
        return MaterialPageRoute(builder: (_) => const ValidatorPage());
      },
      routes: {
        "/": (context) => const ValidatorPage(),
        AppPaths.home: (context) => HomePage(),
        AppPaths.login: (context) => const AppSignIn(),
        AppPaths.expedition: (context) => const Expeditions(),
        AppPaths.expeditionForm: (context) => const ExpeditionForm(),
        AppPaths.area: (context) => const Areas(),
        AppPaths.areaForm: (context) => const AreaForm(),
        AppPaths.platform: (context) => Platforms(),
        AppPaths.platformForm: (context) => PlatformForm(),
        AppPaths.tool: (context) => const Tools(),
        AppPaths.toolForm: (context) => ToolForm(),
        AppPaths.data: (context) => const Data(),
        AppPaths.dataForm: (context) => DataForm(),
        AppPaths.location: (context) => const Locations(),
        AppPaths.locationForm: (context) => const LocationForm(),
        AppPaths.dive: (context) => const Dives(),
        AppPaths.diveForm: (context) => const DiveForm(),
        AppPaths.recordForm: (context) => const RecordForm(),
        AppPaths.sample: (context) => const Samples(),
        AppPaths.sampleForm: (context) => const SampleForm(),
        AppPaths.analysis: (context) => const Analysis(),
        AppPaths.analysisForm: (context) => const AnalysisForm(),
      },
    );
  }
}
