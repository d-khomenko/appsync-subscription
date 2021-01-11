# Flutter AppSync subscription Plugin

[![pub package](https://img.shields.io/pub/v/appsync_subscription.svg)](https://pub.dev/packages/appsync_subscription)

This plugin for [Flutter](https://flutter.io)
handles subscripe to AWS AppSync subscription.

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  appsync_subscription: ^1.0.0
```

## Usage

Import the package with

```dart
import 'package:appsync_subscription/appsync_subscription.dart';
```

```dart

final endPoint = "https://yourappsync.appsync-api.region.amazonaws.com/graphql";
final apiKey = "you-api-key";
final port = 443;

class _MyHomePageState extends State<MyHomePage> {
  final _appsyncSubscription = new Subscription(endPoint, apiKey, port);

 @override
  Widget build(BuildContext context) {
    final query = {
      'query': '''subscription {
          onPublishResult(id: "12345") {
            id
          }
        }
        '''
    };
    _appsyncSubscription.subscripeToSubscription(query, _callBackFunc);
  }
    void _callBackFunc(data) {
    print('Data received from subscription $data');
    // update widget with new data
    setState(() {
    });
  }
}

```
