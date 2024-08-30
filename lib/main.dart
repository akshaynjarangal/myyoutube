import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MaterialApp(home: WebViewExample()));

class WebViewExample extends StatelessWidget {
  const WebViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('WebView example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                  onPressed: () {
                    openUrl('https://www.youtube.com/embed/A3s07JYA48o',
                        'Youtube Video');
                  },
                  child: const Text('Open Native Android WebView')),
            ],
          ),
        ));
  }
}

Future<void> openUrl(String url, String title) async {
  try {
    const channel = MethodChannel('com.akshay');
    await channel.invokeMethod('loadUrl', {'url': url, 'title': title});
  } catch (e) {
    debugPrint('Error opening url: $e');
  }
}
