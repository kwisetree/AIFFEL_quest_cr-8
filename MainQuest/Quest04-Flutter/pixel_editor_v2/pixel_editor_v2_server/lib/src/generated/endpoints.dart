/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/pixelparty_endpoint.dart' as _i2;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'pixelParty': _i2.PixelPartyEndpoint()
        ..initialize(
          server,
          'pixelParty',
          null,
        )
    };
    connectors['pixelParty'] = _i1.EndpointConnector(
      name: 'pixelParty',
      endpoint: endpoints['pixelParty']!,
      methodConnectors: {
        'setPixel': _i1.MethodConnector(
          name: 'setPixel',
          params: {
            'colorIndex': _i1.ParameterDescription(
              name: 'colorIndex',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'pixelIndex': _i1.ParameterDescription(
              name: 'pixelIndex',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['pixelParty'] as _i2.PixelPartyEndpoint).setPixel(
            session,
            colorIndex: params['colorIndex'],
            pixelIndex: params['pixelIndex'],
          ),
        ),
        'imageUpdates': _i1.MethodStreamConnector(
          name: 'imageUpdates',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
            Map<String, Stream> streamParams,
          ) =>
              (endpoints['pixelParty'] as _i2.PixelPartyEndpoint)
                  .imageUpdates(session),
        ),
      },
    );
  }
}
