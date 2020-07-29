// import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/app_user.dart';
import 'package:nonce/nonce.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:corsac_jwt/corsac_jwt.dart';

class Login extends ChangeNotifier {
  static const dev_AUTH0_CLIENT_ID = 'ZavYd2LZRm8iF1TH3iE4Hu76XYeh7OH2';
  static const dev_AUTH0_DOMAIN = 'https://drumscore-dev.eu.auth0.com';

  static const publicKey = '''-----BEGIN CERTIFICATE-----
MIIDDzCCAfegAwIBAgIJNawtRWipewWLMA0GCSqGSIb3DQEBCwUAMCUxIzAhBgNV
BAMTGmRydW1zY29yZS1kZXYuZXUuYXV0aDAuY29tMB4XDTE3MDMyNTE4MzUwMloX
DTMwMTIwMjE4MzUwMlowJTEjMCEGA1UEAxMaZHJ1bXNjb3JlLWRldi5ldS5hdXRo
MC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmvcIAT23az7B1
19LTXUeVjNumi2yIqXksrIw+DuZcamxelsAOgp7XVWt5/qjWSD0yMtnFDdDvq+Dk
eu8E50sDdVvFWkEL4QbnqtM6KV8fCa14nEoo/S2zUzTRJcqi6bnh6JrCY2vcujW8
yhoIqAgw83ouf8KngB9zippxaPcZgzsxYmTiz0DXHfIf0H/eL804UDtIHCuKOgkA
l7DIJz4lp4mP13Pag1+DPKscB7QqWcub+K0mp+l3WYWFK31ZjjsV+S44XAMFaGmq
zMCckIO8v0JxDY/bFfMGeXC70en9EVInj3zJf13IkSI7tJFCca0ei4X2K0OdNa5r
KQ1aQ2ytAgMBAAGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFAx9jRnz
JJYaBleKm4gJrzoqDMOhMA4GA1UdDwEB/wQEAwIChDANBgkqhkiG9w0BAQsFAAOC
AQEA3GALLn+0QDR+5BQtqRxMBrp+F3iMoiGXz6Izaol0DK9PXzJ/Y9j6i3HQBgaO
ewRXii80gEPs/xN2173PWUxIPvHJH58VJvIkdKp0dUELz6CaUdvCkIxxsJuJTCjH
4Q/Ewyv1bzPpJrgdj5o1r1cbyyZCw7sjl45B7FquI4bfEkgzLF5ksKOA/5mu2HqR
KQyAH0dmRt5jUylSKdr/+kHRupa+d3+RKsdK2k1rjrZsNwR64UgeN1U9C3cyeaj7
I//WF9mIzqeLSXQ6o+hmffh8ICEhHpF3cvN+TFORSkBPRNTbG5mqP/Rtr4U2ZTCC
M2C3sR5hbDD/VZCp54/WqE57Lg==
-----END CERTIFICATE-----''';

  AppUser _user = AppUser();

  bool get isLoggedIn => _user.accessToken != '';
  String get accessToken => _user.accessToken;
  LoginStatus get loginStatus => _user.loginStatus;

  Login(Uri uri) {
    print('Login');
    // we check to see if there was anything in the URI to suggest
    // we're a callback from auth
    // if there isn't we should check for a stored jwt??

    var uri = Uri.tryParse(js.context['location']['href']);
    if (uri != null) {
      print(uri.fragment);
      var bits = Uri.splitQueryString(uri.fragment);
      if (bits != null) {
        var at = bits['access_token'];
        if (at != null) {
          Set<String> errors = {};
          var decodedToken;

          var storedState = html.window.localStorage['stored_state'];
          var tokenState = bits['state'];
          if (storedState != null &&
              tokenState != null &&
              storedState == tokenState) {
            // funky stuff
            decodedToken = new JWT.parse(bits['id_token']);

            var signer = JWTRsaSha256Signer(publicKey: publicKey);

            // Validate claims, signature, expiry etc:
            var validator = new JWTValidator()
              ..issuer = dev_AUTH0_DOMAIN + '/'
              ..audience = dev_AUTH0_CLIENT_ID;

            errors.addAll(validator.validate(decodedToken, signer: signer));

            var storedNonce = html.window.localStorage['stored_nonce'];
            var tokenNonce = decodedToken.getClaim('nonce');

            if (storedNonce == null ||
                tokenNonce == null ||
                storedNonce != tokenNonce) {
              errors.add('nonce failure');
            }
          } else {
            errors.add('state error in callback');
          }

          if (errors.isNotEmpty) {
            print('unable to validate JWT');
            print(errors);
            _setUnauthenticated();
          } else {
            print('successfully validated JWT');
            _user.accessToken = at;

            html.window.localStorage['id_token'] = bits['id_token'];
            html.window.localStorage['access_token'] = at;

            _printJWT(decodedToken);
          }
        }
      }
    }
  }

  void _printJWT(JWT jwt) {
    print(jwt.algorithm);
    print(jwt.audience);
    print(jwt.claims);
    print(jwt.id);
    print(jwt.issuer);
    print(jwt.subject);
    var iss = jwt.issuedAt * 1000;
    var exp = jwt.expiresAt * 1000;
    print('Issued at ${DateTime.fromMillisecondsSinceEpoch(iss)}');
    print('Expires at ${DateTime.fromMillisecondsSinceEpoch(exp)}');
  }

  void _setUnauthenticated() {
    _user.accessToken = '';
    _user.refreshToken = '';

    _user.loginStatus = LoginStatus.Unauthenticated;
  }

  void logout() {
    // redirect to the logout URL
    var lgtUrl = dev_AUTH0_DOMAIN +
        '/v2/logout?client_id=' +
        dev_AUTH0_CLIENT_ID +
        '&returnTo=' +
        Uri.encodeComponent(
            Uri.tryParse(js.context['location']['href']).toString());

    // not doing this as UX isn't great seeing sign in, then page refreshes
    // _setUnauthenticated();
    // notifyListeners();

    html.window.location.assign(lgtUrl);
  }

  void authenticate() {
    var nonce = Nonce.generate();
    var state = Nonce.generate();

    html.window.localStorage['stored_nonce'] = nonce;
    html.window.localStorage['stored_state'] = state;

    var authUrl = dev_AUTH0_DOMAIN +
        '/authorize?client_id=' +
        dev_AUTH0_CLIENT_ID +
        '&state=' +
        state +
        '&scope=openid+profile+email' +
        '&nonce=' +
        nonce +
        '&redirect_uri=' +
        Uri.encodeComponent(
            Uri.tryParse(js.context['location']['href']).toString()) +
        '&response_type=id_token token';

    // in case we want to update something before the screen is wiped!
    _user.loginStatus = LoginStatus.Authenticating;
    notifyListeners();

    // send this whole browser window to authUrl
    html.window.location.assign(authUrl);
  }
}
