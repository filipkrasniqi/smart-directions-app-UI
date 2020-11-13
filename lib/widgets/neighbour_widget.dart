import 'package:beacon/bloc/neighbour_bloc.dart';
import 'package:beacon/utils/MapOriginColor.dart';
import 'package:beacon/utils/neighbour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class NeighbourWidget extends StatefulWidget {

  Color color = Colors.brown;
  NeighbourBloc neighbourBloc;

  NeighbourWidget({ Key key,
      @required this.color
    }) : assert(color != null),
    super(key: key) {

    neighbourBloc = NeighbourBloc();

    // beacon.start();
    connect().then((connection) => {
      connection.subscribe("ble/neighbours", MqttQos.atMostOnce)
    });
  }

  Future<MqttServerClient> connect() async {
    String clientIdentifier = "smartphone";
    MqttServerClient client =
    MqttServerClient.withPort('54.164.129.181', clientIdentifier, 1883);
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    String username = "test", password = "password123";

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .authenticateAs(username, password)
        .keepAliveFor(60)
        // .withWillTopic('ble/disconnect')
        // .withWillMessage('Will message')
        .startClean()
    //.withWillQos(MqttQos.atLeastOnce);
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;
    try {
      // await client.connect();
      await client.connect(username, password);
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
      MqttPublishPayload.bytesToStringAsString(message.payload.message);
      final topic = c[0].topic;

      if(topic == "ble/neighbours") {
        // message is: MAC$close, being close 1 if we are close to that, 0 otherwise
        var splits = payload.split("\$");
        String origin = splits[0];
        String mac = splits[1];
        bool close = splits[2] == "1";
        if(mac.contains("ED:CA")) {
          print("LALA");
        }
        neighbourBloc.setNeighbour(NeighbourMqtt(origin, mac, close));
      }

      print('Received message:$payload from topic: ${c[0].topic}>');
    });

    return client;
  }

  void onConnected() {
    print('Connected');
  }

// unconnected
  void onDisconnected() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  @override
  _NeighbourWidgetState createState() => _NeighbourWidgetState(neighbourBloc);
}

class _NeighbourWidgetState extends State<NeighbourWidget> {

  MapOriginColor colors = new MapOriginColor();
  NeighbourBloc neighbourBloc;
  List<NeighbourMqtt> _neighbours = List();

  _NeighbourWidgetState(this.neighbourBloc);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StreamBuilder<NeighbourMqtt>(
            stream: neighbourBloc.neighbourStream,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                var neighbour = snapshot.data;
                var mac = neighbour.mac;
                var origin = neighbour.origin;

                // TODO update or add
                var index = _neighbours.indexWhere((element) => origin == element.origin && mac == element.mac);
                if(index > 0) {
                  _neighbours.elementAt(index).update(neighbour);
                } else {
                  _neighbours.add(neighbour);
                }
                var listOfAll = List<NeighbourUI>();
                var distinctDevices = _neighbours.map((neighbour) => neighbour.mac).toSet().toList();
                for(var device in distinctDevices) {
                  var closeNeighbours = _neighbours.where((element) => element.mac == device && element.close);
                  if(closeNeighbours != null && closeNeighbours.length > 0) {
                    listOfAll.add(closeNeighbours.elementAt(0).toUI(colors, device));
                  } else {
                    listOfAll.add(NeighbourUI(Colors.grey, device));
                  }
                }
                List<Container> containers = listOfAll.map((neighbour) => Container(height: 50, color: neighbour.color, child: Center(child: Text(neighbour.toShow)))).toList();
                /*
                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: <Widget> children: containers
                );*/
                return Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: containers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return containers.elementAt(index);
                      }
                  )
                );
              } else {

                return Text(
                    'Nothing happened',
                    style: TextStyle(color: Colors.black)
                );
              }
            }),
      ],
    );
  }
}