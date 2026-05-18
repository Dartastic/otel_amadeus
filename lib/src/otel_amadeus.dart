// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_amadeus_suppression.dart';

const _tracerName = 'dartastic_otel_libs_amadeus';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class AmadeusResult {
  const AmadeusResult({
    this.environment,
    this.product,
    this.endpoint,
    this.origin,
    this.destination,
    this.departureDate,
    this.returnDate,
    this.travelers,
    this.cabin,
    this.currency,
    this.offerCount,
    this.lowestPriceMicros,
    this.cityCode,
    this.hotelId,
    this.checkInDate,
    this.checkOutDate,
    this.roomQuantity,
    this.pnr,
    this.bookingId,
    this.bookingStatus,
    this.ticketingTime,
    this.errorCode,
    this.errorTitle,
    this.statusCode,
  });

  /// `test` (test.api.amadeus.com) / `production` (api.amadeus.com).
  final String? environment;

  /// `flights`, `hotels`, `cars`, `transfers`, `activities`,
  /// `airport`, `airline`, `location`, `trip_purpose`, `trip_parser`,
  /// `flight_delay`, `branded_fares`, `seatmap`, `booking`.
  final String? product;

  /// REST endpoint suffix (e.g. `/v2/shopping/flight-offers`).
  final String? endpoint;

  final String? origin;
  final String? destination;

  /// ISO yyyy-MM-dd.
  final String? departureDate;
  final String? returnDate;

  final int? travelers;

  /// `ECONOMY`, `PREMIUM_ECONOMY`, `BUSINESS`, `FIRST`.
  final String? cabin;

  /// ISO 4217.
  final String? currency;

  /// Result set sizes.
  final int? offerCount;

  /// Lowest fare in millionths (currency-agnostic).
  final int? lowestPriceMicros;

  // ── Hotels ─────────────────────────────────────────────────────
  /// IATA city code (`PAR`, `NYC`, `LON`, ...).
  final String? cityCode;
  final String? hotelId;
  final String? checkInDate;
  final String? checkOutDate;
  final int? roomQuantity;

  // ── Booking ────────────────────────────────────────────────────
  /// 6-char airline PNR locator.
  final String? pnr;
  final String? bookingId;

  /// `CONFIRMED`, `IN_PROGRESS`, `CANCELLED`, `EXPIRED`, `ON_HOLD`,
  /// `TICKETED`, `REFUNDED`.
  final String? bookingStatus;

  /// Time-limit ISO timestamp by which ticketing must occur.
  final String? ticketingTime;

  /// Amadeus error code (numeric).
  final String? errorCode;
  final String? errorTitle;
  final int? statusCode;
}

class AmadeusCallResult<T> {
  const AmadeusCallResult({required this.value, this.result});
  final T value;
  final AmadeusResult? result;
}

/// Wraps an Amadeus API call in a CLIENT span. [operation] is one of
/// `flightOffers.search`, `flightOffers.price`,
/// `flightOffersPrediction.choice`, `flightAvailabilities.search`,
/// `flightOrders.create`, `flightOrders.retrieve`, `flightOrders.cancel`,
/// `flightDelay.predict`, `seatmap.list`, `brandedFares.upsell`,
/// `hotelOffers.search`, `hotelOffer.get`, `hotelBookings.create`,
/// `hotelRatings.sentiments`, `hotelNameAutocomplete.list`,
/// `cars.search`, `cars.book`, `transfers.search`, `transfers.book`,
/// `activities.search`, `activities.detail`, `airport.daily`,
/// `airport.transfers`, `airline.codeLookup`,
/// `location.search`, `location.cityNearest`,
/// `tripPurpose.predict`, `tripParser.parseEmail`,
/// `auth.token`.
Future<T> tracedAmadeus<T>({
  required String operation,
  required Future<AmadeusCallResult<T>> Function() invoke,
}) async {
  if (amadeusInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'amadeus',
    'rpc.method': operation,
    'amadeus.operation': operation,
  };

  final span = _tracer().startSpan(
    'amadeus $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.environment != null) {
        extras.add(OTel.attributeString(
          'amadeus.environment',
          res.environment!,
        ));
      }
      if (res.product != null) {
        extras.add(OTel.attributeString('amadeus.product', res.product!));
      }
      if (res.endpoint != null) {
        extras.add(OTel.attributeString('amadeus.endpoint', res.endpoint!));
      }
      if (res.origin != null) {
        extras.add(OTel.attributeString('amadeus.origin', res.origin!));
      }
      if (res.destination != null) {
        extras.add(OTel.attributeString(
          'amadeus.destination',
          res.destination!,
        ));
      }
      if (res.departureDate != null) {
        extras.add(OTel.attributeString(
          'amadeus.departure_date',
          res.departureDate!,
        ));
      }
      if (res.returnDate != null) {
        extras.add(OTel.attributeString(
          'amadeus.return_date',
          res.returnDate!,
        ));
      }
      if (res.travelers != null) {
        extras.add(OTel.attributeInt(
          'amadeus.travelers',
          res.travelers!,
        ));
      }
      if (res.cabin != null) {
        extras.add(OTel.attributeString('amadeus.cabin', res.cabin!));
      }
      if (res.currency != null) {
        extras.add(OTel.attributeString('amadeus.currency', res.currency!));
      }
      if (res.offerCount != null) {
        extras.add(OTel.attributeInt(
          'amadeus.offer.count',
          res.offerCount!,
        ));
      }
      if (res.lowestPriceMicros != null) {
        extras.add(OTel.attributeInt(
          'amadeus.lowest_price.micros',
          res.lowestPriceMicros!,
        ));
      }
      if (res.cityCode != null) {
        extras.add(OTel.attributeString(
          'amadeus.city_code',
          res.cityCode!,
        ));
      }
      if (res.hotelId != null) {
        extras.add(OTel.attributeString(
          'amadeus.hotel.id',
          res.hotelId!,
        ));
      }
      if (res.checkInDate != null) {
        extras.add(OTel.attributeString(
          'amadeus.check_in_date',
          res.checkInDate!,
        ));
      }
      if (res.checkOutDate != null) {
        extras.add(OTel.attributeString(
          'amadeus.check_out_date',
          res.checkOutDate!,
        ));
      }
      if (res.roomQuantity != null) {
        extras.add(OTel.attributeInt(
          'amadeus.room_quantity',
          res.roomQuantity!,
        ));
      }
      if (res.pnr != null) {
        extras.add(OTel.attributeString('amadeus.pnr', res.pnr!));
      }
      if (res.bookingId != null) {
        extras.add(OTel.attributeString(
          'amadeus.booking.id',
          res.bookingId!,
        ));
      }
      if (res.bookingStatus != null) {
        extras.add(OTel.attributeString(
          'amadeus.booking.status',
          res.bookingStatus!,
        ));
        if (res.bookingStatus == 'CANCELLED' ||
            res.bookingStatus == 'EXPIRED') {
          span.setStatus(
            SpanStatusCode.Error,
            'Amadeus booking ${res.bookingStatus}',
          );
        }
      }
      if (res.ticketingTime != null) {
        extras.add(OTel.attributeString(
          'amadeus.ticketing.time',
          res.ticketingTime!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'amadeus.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Amadeus ${res.errorCode}');
      }
      if (res.errorTitle != null) {
        extras.add(OTel.attributeString(
          'amadeus.error.title',
          res.errorTitle!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Amadeus HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
