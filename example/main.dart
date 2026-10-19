// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_amadeus/otel_amadeus.dart';

/// Traces Amadeus calls with OpenTelemetry.
///
/// `otel_amadeus` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Amadeus call in
/// [tracedAmadeus]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'amadeus-example');

  // Wraps an Amadeus API call in a CLIENT span.
  final amadeusId = await tracedAmadeus<String>(
    operation: 'seatmap.list',
    invoke: () async {
      // Make the Amadeus call here, then report what it returned.
      const id = 'amadeus_8f3a2c';
      return const AmadeusCallResult(
          value: id,
          result: AmadeusResult(
              environment: 'test',
              product: 'flights',
              endpoint: '/v2/shopping/flight-offers',
              origin: 'example',
              destination: 'example',
              departureDate: 'example',
              returnDate: 'example',
              travelers: 1,
              cabin: 'ECONOMY',
              currency: 'usd',
              offerCount: 3,
              lowestPriceMicros: 1,
              cityCode: 'PAR',
              hotelId: 'hotel_8f3a2c',
              checkInDate: 'example',
              checkOutDate: 'example',
              roomQuantity: 1,
              pnr: 'example',
              bookingId: 'booking_8f3a2c',
              bookingStatus: 'CONFIRMED',
              ticketingTime: 'example',
              errorCode: 'example',
              errorTitle: 'example',
              statusCode: 200));
    },
  );
  OTelLog.info('tracedAmadeus seatmap.list returned $amadeusId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAmadeusInstrumentationAsync.
  await runWithoutAmadeusInstrumentationAsync(
    () => tracedAmadeus<String>(
      operation: 'seatmap.list',
      invoke: () async {
        const id = 'amadeus_8f3a2c';
        return const AmadeusCallResult(
            value: id,
            result: AmadeusResult(
                environment: 'test',
                product: 'flights',
                endpoint: '/v2/shopping/flight-offers',
                origin: 'example',
                destination: 'example',
                departureDate: 'example',
                returnDate: 'example',
                travelers: 1,
                cabin: 'ECONOMY',
                currency: 'usd',
                offerCount: 3,
                lowestPriceMicros: 1,
                cityCode: 'PAR',
                hotelId: 'hotel_8f3a2c',
                checkInDate: 'example',
                checkOutDate: 'example',
                roomQuantity: 1,
                pnr: 'example',
                bookingId: 'booking_8f3a2c',
                bookingStatus: 'CONFIRMED',
                ticketingTime: 'example',
                errorCode: 'example',
                errorTitle: 'example',
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
