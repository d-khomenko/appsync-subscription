import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Subscription {
  String _endpoint;
  String _apiKey;
  int _port;

  Subscription(this._endpoint, this._apiKey, this._port);


  subscripeToSubscription(Map<String, String> query, Function callBackFunc) async {

    try {    
      var data = await http.post(
        '$_endpoint',
        headers: {
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(query),
        );
              
      Map<String, dynamic> response =
          jsonDecode(data.body) as Map<String, dynamic>;

      var server;
      var clientIdentifier;
      var topic;
      topic= response['extensions']['subscription']['mqttConnections'][0]
                          ['topics'][0];


      for (var m in response['extensions']['subscription']['mqttConnections']) {
        if ((m['topics'] as List<dynamic>).contains(topic)) {
          server=m['url'];  
          clientIdentifier=m['client'];
          break;
        }
      }

      final client = MqttServerClient(server.toString(),  clientIdentifier.toString());
      client.port = _port;
      client.logging(on: false);
      client.keepAlivePeriod = 30;
      client.useWebSocket = true;

      client.onDisconnected = onDisconnected;
      client.onConnected = onConnected;

      try {
        await client.connect();
        client.subscribe(topic.toString(), MqttQos.atMostOnce);

        client.updates
            .listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage recMess =
              c[0].payload as MqttPublishMessage;
          final String results = MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message);

          client.disconnect();
   
          return callBackFunc(results);
        });

      } on NoConnectionException catch (e) {
        print('client exception: $e');
        client.disconnect();
      } on SocketException catch (e) {
        print('socket exception: $e');
        client.disconnect();
      }

    } catch (e) {
      print(e);
    }
  }

}


void onConnected() {
  print('Client connection was sucessful');
}

void onDisconnected() {
  print('Client disconnection was sucessful');
}