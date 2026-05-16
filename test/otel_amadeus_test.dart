// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_amadeus/otel_amadeus.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_amadeus-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('flightOffers.search records origin/dest + offer count', () async {
    await tracedAmadeus<String>(
      operation: 'flightOffers.search',
      invoke: () async => const AmadeusCallResult(
        value: 'ok',
        result: AmadeusResult(
          environment: 'production',
          product: 'flights',
          origin: 'SFO',
          destination: 'JFK',
          departureDate: '2026-06-01',
          travelers: 2,
          cabin: 'ECONOMY',
          currency: 'USD',
          offerCount: 48,
          lowestPriceMicros: 18900000,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('amadeus flightOffers.search')!);
    expect(a['amadeus.offer.count'], 48);
    expect(a['amadeus.cabin'], 'ECONOMY');
  });

  test('CANCELLED booking sets span error', () async {
    await tracedAmadeus<String>(
      operation: 'flightOrders.retrieve',
      invoke: () async => const AmadeusCallResult(
        value: 'ok',
        result: AmadeusResult(
          pnr: 'ABC123',
          bookingId: 'b_1',
          bookingStatus: 'CANCELLED',
        ),
      ),
    );
    expect(
      spans.findSpanByName('amadeus flightOrders.retrieve')!.status,
      SpanStatusCode.Error,
    );
  });

  test('hotelOffers.search records city + dates', () async {
    await tracedAmadeus<String>(
      operation: 'hotelOffers.search',
      invoke: () async => const AmadeusCallResult(
        value: 'ok',
        result: AmadeusResult(
          product: 'hotels',
          cityCode: 'PAR',
          checkInDate: '2026-07-01',
          checkOutDate: '2026-07-05',
          roomQuantity: 1,
          offerCount: 120,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('amadeus hotelOffers.search')!);
    expect(a['amadeus.city_code'], 'PAR');
    expect(a['amadeus.room_quantity'], 1);
  });

  test('suppression skips spans', () async {
    await runWithoutAmadeusInstrumentationAsync(() async {
      await tracedAmadeus<String>(
        operation: 'auth.token',
        invoke: () async => const AmadeusCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('amadeus '), isEmpty);
  });
}
