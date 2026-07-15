import 'package:flutter/material.dart';

/// App-wide route observer. Screens that sit below a pushReplacement chain
/// (e.g. the round list under preview → quiz → result) never receive a pop
/// result at the right time, so they subscribe here and reload in didPopNext.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
