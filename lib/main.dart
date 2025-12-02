import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pixcraft/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}



// apikey 
// AIzaSyCg-4Fo6_gfoRrXkMD8deidQf2uixR-RNw


// curl -X POST \
//   "https://us-central1-aiplatform.googleapis.com/v1/projects/pixcraft-4841b/locations/us-central1/publishers/google/models/imagen-4.0-fast-generate-001:predict?key=AIzaSyCg-4Fo6_gfoRrXkMD8deidQf2uixR-RNw" \
//   -H "Content-Type: application/json" \
//   -d '{
//     "contents": [{
//       "parts": [{
//         "text": "Say hello in one sentence"
//       }]
//     }]
//   }'


//   POST 