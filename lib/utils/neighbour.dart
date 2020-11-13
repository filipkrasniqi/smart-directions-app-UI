import 'dart:ui';

import 'package:flutter/material.dart';

import 'MapOriginColor.dart';

class NeighbourMqtt {
  String _mac;
  String _origin;
  bool _close;

  NeighbourMqtt(String origin, String mac, bool close) {
    _mac = mac;
    _close = close;
    _origin = origin;
  }

  update(NeighbourMqtt neighbour) {
    _mac = neighbour.mac;
    _close = neighbour.close;
    _origin = neighbour.origin;
  }

  toInner() {
    return InnerNeighbour(_origin, _close);
  }

  toNeighbour() {
    return Neighbour(mac, [InnerNeighbour(_origin, _close)]);
  }

  toUI(MapOriginColor colors, String mac) {
    return NeighbourUI(close ? colors.get(origin) : Colors.black, mac);
  }

  String get mac => _mac;
  String get origin => _origin;
  bool get close => _close;
}

class InnerNeighbour {
  String _origin;
  bool _close;

  InnerNeighbour(this._origin, this._close);

  update(InnerNeighbour other) {
    _close = other.close;
    _origin = other.origin;
  }

  bool get close => _close;
  String get origin => _origin;

  toUI(MapOriginColor colors, String mac) {
    return NeighbourUI(close ? colors.get(origin) : Colors.black, mac);
  }
}

class Neighbour {
  String _mac;
  List<InnerNeighbour> _neighbours;

  Neighbour(String mac, List<InnerNeighbour> neighbours) {
    _mac = mac;
    _neighbours = neighbours;
  }

  String get mac => _mac;
  List<InnerNeighbour> get neighbours => _neighbours;
}

class NeighbourUI {
  Color color;
  String toShow;

  NeighbourUI(this.color, this.toShow);
}