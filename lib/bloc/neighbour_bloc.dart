import 'dart:async';

import 'package:beacon/bloc/bloc.dart';
import 'package:beacon/utils/neighbour.dart';
import 'package:flutter/material.dart';

class NeighbourBloc implements Bloc {
  final _neighbourController = StreamController<NeighbourMqtt>();
  NeighbourMqtt _neighbour;
  Color color = Colors.black;
  NeighbourMqtt get currentNeighbour => _neighbour;

  Stream<NeighbourMqtt> get neighbourStream => _neighbourController.stream;

  void setNeighbour(NeighbourMqtt neighbour) {
    _neighbour = neighbour;
    _neighbourController.sink.add(neighbour);
  }

  @override
  void dispose() {
    this._neighbourController.close();
  }

}