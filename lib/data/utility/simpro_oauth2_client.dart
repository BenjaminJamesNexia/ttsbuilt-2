import 'package:oauth2_client/oauth2_client.dart';

class SimproOAuth2Client extends OAuth2Client {
  SimproOAuth2Client({required String redirectUri, required String customUriScheme}): super(
      authorizeUrl: 'https://territorytrade.simprosuite.com/oauth2/login?client_id=216db2b119c178035694d36ee1b90b', //Your service's authorization url
      tokenUrl: 'https://territorytrade.simprosuite.com/oauth2/token', //Your service access token url
      redirectUri: redirectUri,
      customUriScheme: customUriScheme
  );
}