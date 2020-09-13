import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:skip_ohoi/map_types.dart';
import 'package:skip_ohoi/secrets.dart';

class EncTokens {
  final String ticket;
  final String gkt;

  EncTokens(this.ticket, this.gkt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncTokens &&
          runtimeType == other.runtimeType &&
          ticket == other.ticket &&
          gkt == other.gkt;

  @override
  int get hashCode => ticket.hashCode ^ gkt.hashCode;
}

Stream<EncTokens> encTokensRefresher(MapType mapType) => mapType != MapType.ENC
    ? Stream.value(null)
    : Stream.periodic(Duration(seconds: 15))
        .startWith(null)
        .asyncMap(
          (_) => Future.wait([
            http.get(gateKeeperTicketUrl),
            http.get(gateKeeperTokenUrl),
          ]).then(
            (responses) {
              String value(String body) =>
                  RegExp(r'^"(.*)"\W$').firstMatch(body).group(1);
              return EncTokens(
                  value(responses[0].body), value(responses[1].body));
            },
          ),
        )
        .handleError((error) {
        developer.log('Failed to fetch ENC secrets', error: error);
      });
