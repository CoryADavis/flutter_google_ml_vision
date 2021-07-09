// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$GoogleVision', () {
    final List<MethodCall> log = <MethodCall>[];
    dynamic returnValue;

    setUp(() {
      GoogleVision.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);

        switch (methodCall.method) {
          case 'BarcodeDetector#detectInImage':
            return returnValue;
          case 'FaceDetector#processImage':
            return returnValue;
          case 'TextRecognizer#processImage':
            return returnValue;
          default:
            return null;
        }
      });
      log.clear();
      GoogleVision.nextHandle = 0;
    });

    group('$BarcodeDetector', () {
      late BarcodeDetector detector;
      late GoogleVisionImage image;
      List<dynamic>? returnBarcodes;

      setUp(() {
        detector = GoogleVision.instance.barcodeDetector();
        image = GoogleVisionImage.fromFilePath('empty');
        returnBarcodes = <dynamic>[
          <dynamic, dynamic>{
            'rawValue': 'hello:raw',
            'displayValue': 'hello:display',
            'format': 0,
            'left': 1.0,
            'top': 2.0,
            'width': 3.0,
            'height': 4.0,
            'points': <dynamic>[
              <dynamic>[5.0, 6.0],
              <dynamic>[7.0, 8.0],
            ],
          },
        ];
      });

      test('detectInImage unknown', () async {
        returnBarcodes![0]['valueType'] = BarcodeValueType.unknown.index;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'BarcodeDetector#detectInImage',
            arguments: <String, dynamic>{
              'handle': 0,
              'type': 'file',
              'path': 'empty',
              'bytes': null,
              'metadata': null,
              'options': <String, dynamic>{
                'barcodeFormats': 0xFFFF,
              },
            },
          ),
        ]);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.unknown);
        // TODO(jackson): Use const Rect when available in minimum Flutter SDK
        // ignore: prefer_const_constructors
        expect(barcode.boundingBox, Rect.fromLTWH(1, 2, 3, 4));
        expect(barcode.rawValue, 'hello:raw');
        expect(barcode.displayValue, 'hello:display');
        expect(barcode.cornerPoints, const <Offset>[
          Offset(5, 6),
          Offset(7, 8),
        ]);
      });

      test('detectInImage email', () async {
        final Map<dynamic, dynamic> email = <dynamic, dynamic>{
          'address': 'a',
          'body': 'b',
          'subject': 's',
          'type': BarcodeEmailType.home.index,
        };

        returnBarcodes![0]['valueType'] = BarcodeValueType.email.index;
        returnBarcodes![0]['email'] = email;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.email);
        expect(barcode.email!.address, 'a');
        expect(barcode.email!.body, 'b');
        expect(barcode.email!.subject, 's');
        expect(barcode.email!.type, BarcodeEmailType.home);
      });

      test('detectInImage phone', () async {
        final Map<dynamic, dynamic> phone = <dynamic, dynamic>{
          'number': '000',
          'type': BarcodePhoneType.fax.index,
        };

        returnBarcodes![0]['valueType'] = BarcodeValueType.phone.index;
        returnBarcodes![0]['phone'] = phone;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.phone);
        expect(barcode.phone!.number, '000');
        expect(barcode.phone!.type, BarcodePhoneType.fax);
      });

      test('detectInImage sms', () async {
        final Map<dynamic, dynamic> sms = <dynamic, dynamic>{'phoneNumber': '000', 'message': 'm'};

        returnBarcodes![0]['valueType'] = BarcodeValueType.sms.index;
        returnBarcodes![0]['sms'] = sms;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.sms);
        expect(barcode.sms!.phoneNumber, '000');
        expect(barcode.sms!.message, 'm');
      });

      test('detectInImage url', () async {
        final Map<dynamic, dynamic> url = <dynamic, dynamic>{'title': 't', 'url': 'u'};

        returnBarcodes![0]['valueType'] = BarcodeValueType.url.index;
        returnBarcodes![0]['url'] = url;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.url);
        expect(barcode.url!.title, 't');
        expect(barcode.url!.url, 'u');
      });

      test('detectInImage wifi', () async {
        final Map<dynamic, dynamic> wifi = <dynamic, dynamic>{
          'ssid': 's',
          'password': 'p',
          'encryptionType': BarcodeWiFiEncryptionType.wep.index,
        };

        returnBarcodes![0]['valueType'] = BarcodeValueType.wifi.index;
        returnBarcodes![0]['wifi'] = wifi;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.wifi);
        expect(barcode.wifi!.ssid, 's');
        expect(barcode.wifi!.password, 'p');
        expect(barcode.wifi!.encryptionType, BarcodeWiFiEncryptionType.wep);
      });

      test('detectInImage geoPoint', () async {
        final Map<dynamic, dynamic> geoPoint = <dynamic, dynamic>{
          'latitude': 0.2,
          'longitude': 0.3,
        };

        returnBarcodes![0]['valueType'] = BarcodeValueType.geographicCoordinates.index;
        returnBarcodes![0]['geoPoint'] = geoPoint;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.geographicCoordinates);
        expect(barcode.geoPoint!.latitude, 0.2);
        expect(barcode.geoPoint!.longitude, 0.3);
      });

      test('detectInImage contactInfo', () async {
        final Map<dynamic, dynamic> contact = <dynamic, dynamic>{
          'addresses': <dynamic>[
            <dynamic, dynamic>{
              'addressLines': <String>['al'],
              'type': BarcodeAddressType.work.index,
            }
          ],
          'emails': <dynamic>[
            <dynamic, dynamic>{'type': BarcodeEmailType.home.index, 'address': 'a', 'body': 'b', 'subject': 's'},
          ],
          'name': <dynamic, dynamic>{
            'formattedName': 'fn',
            'first': 'f',
            'last': 'l',
            'middle': 'm',
            'prefix': 'p',
            'pronunciation': 'pn',
            'suffix': 's',
          },
          'phones': <dynamic>[
            <dynamic, dynamic>{
              'number': '012',
              'type': BarcodePhoneType.mobile.index,
            }
          ],
          'urls': <String>['url'],
          'jobTitle': 'j',
          'organization': 'o'
        };

        returnBarcodes![0]['valueType'] = BarcodeValueType.contactInfo.index;
        returnBarcodes![0]['contactInfo'] = contact;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.contactInfo);
        expect(barcode.contactInfo!.addresses![0].type, BarcodeAddressType.work);
        expect(barcode.contactInfo!.addresses![0].addressLines[0], 'al');
        expect(barcode.contactInfo!.emails![0].type, BarcodeEmailType.home);
        expect(barcode.contactInfo!.emails![0].address, 'a');
        expect(barcode.contactInfo!.emails![0].body, 'b');
        expect(barcode.contactInfo!.emails![0].subject, 's');
        expect(barcode.contactInfo!.name!.first, 'f');
        expect(barcode.contactInfo!.name!.last, 'l');
        expect(barcode.contactInfo!.name!.middle, 'm');
        expect(barcode.contactInfo!.name!.formattedName, 'fn');
        expect(barcode.contactInfo!.name!.prefix, 'p');
        expect(barcode.contactInfo!.name!.suffix, 's');
        expect(barcode.contactInfo!.name!.pronunciation, 'pn');
        expect(barcode.contactInfo!.phones![0].type, BarcodePhoneType.mobile);
        expect(barcode.contactInfo!.phones![0].number, '012');
        expect(barcode.contactInfo!.urls![0], 'url');
        expect(barcode.contactInfo!.jobTitle, 'j');
        expect(barcode.contactInfo!.organization, 'o');
      });

      test('detectInImage calendarEvent', () async {
        final Map<dynamic, dynamic> calendar = <dynamic, dynamic>{
          'eventDescription': 'e',
          'location': 'l',
          'organizer': 'o',
          'status': 'st',
          'summary': 'sm',
          'start': '2017-07-04 12:34:56.123',
          'end': '2018-08-05 01:23:45.456',
        };

        returnBarcodes![0]['valueType'] = BarcodeValueType.calendarEvent.index;
        returnBarcodes![0]['calendarEvent'] = calendar;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.calendarEvent);
        expect(barcode.calendarEvent!.eventDescription, 'e');
        expect(barcode.calendarEvent!.location, 'l');
        expect(barcode.calendarEvent!.organizer, 'o');
        expect(barcode.calendarEvent!.status, 'st');
        expect(barcode.calendarEvent!.summary, 'sm');
        expect(barcode.calendarEvent!.start, DateTime(2017, 7, 4, 12, 34, 56, 123));
        expect(barcode.calendarEvent!.end, DateTime(2018, 8, 5, 1, 23, 45, 456));
      });

      test('detectInImage driversLicense', () async {
        final Map<dynamic, dynamic> driver = <dynamic, dynamic>{
          'firstName': 'fn',
          'middleName': 'mn',
          'lastName': 'ln',
          'gender': 'g',
          'addressCity': 'ac',
          'addressState': 'a',
          'addressStreet': 'st',
          'addressZip': 'az',
          'birthDate': 'bd',
          'documentType': 'dt',
          'licenseNumber': 'l',
          'expiryDate': 'ed',
          'issuingDate': 'id',
          'issuingCountry': 'ic'
        };

        returnBarcodes![0]['valueType'] = BarcodeValueType.driverLicense.index;
        returnBarcodes![0]['driverLicense'] = driver;
        returnValue = returnBarcodes;

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.valueType, BarcodeValueType.driverLicense);
        expect(barcode.driverLicense!.firstName, 'fn');
        expect(barcode.driverLicense!.middleName, 'mn');
        expect(barcode.driverLicense!.lastName, 'ln');
        expect(barcode.driverLicense!.gender, 'g');
        expect(barcode.driverLicense!.addressCity, 'ac');
        expect(barcode.driverLicense!.addressState, 'a');
        expect(barcode.driverLicense!.addressStreet, 'st');
        expect(barcode.driverLicense!.addressZip, 'az');
        expect(barcode.driverLicense!.birthDate, 'bd');
        expect(barcode.driverLicense!.documentType, 'dt');
        expect(barcode.driverLicense!.licenseNumber, 'l');
        expect(barcode.driverLicense!.expiryDate, 'ed');
        expect(barcode.driverLicense!.issuingDate, 'id');
        expect(barcode.driverLicense!.issuingCountry, 'ic');
      });

      test('detectInImage no blocks', () async {
        returnValue = <dynamic>[];

        final List<Barcode> blocks = await detector.detectInImage(image);
        expect(blocks, isEmpty);
      });

      test('detectInImage no bounding box', () async {
        returnValue = <dynamic>[
          <dynamic, dynamic>{
            'rawValue': 'potato:raw',
            'displayValue': 'potato:display',
            'valueType': 0,
            'format': 0,
            'points': <dynamic>[
              <dynamic>[17.0, 18.0],
              <dynamic>[19.0, 20.0],
            ],
          },
        ];

        final List<Barcode> barcodes = await detector.detectInImage(image);

        final Barcode barcode = barcodes[0];
        expect(barcode.boundingBox, null);
        expect(barcode.rawValue, 'potato:raw');
        expect(barcode.displayValue, 'potato:display');
        expect(barcode.cornerPoints, const <Offset>[
          Offset(17, 18),
          Offset(19, 20),
        ]);
      });

      test('enums match device APIs', () {
        expect(BarcodeValueType.values.length, 13);
        expect(BarcodeValueType.unknown.index, 0);
        expect(BarcodeValueType.contactInfo.index, 1);
        expect(BarcodeValueType.email.index, 2);
        expect(BarcodeValueType.isbn.index, 3);
        expect(BarcodeValueType.phone.index, 4);
        expect(BarcodeValueType.product.index, 5);
        expect(BarcodeValueType.sms.index, 6);
        expect(BarcodeValueType.text.index, 7);
        expect(BarcodeValueType.url.index, 8);
        expect(BarcodeValueType.wifi.index, 9);
        expect(BarcodeValueType.geographicCoordinates.index, 10);
        expect(BarcodeValueType.calendarEvent.index, 11);
        expect(BarcodeValueType.driverLicense.index, 12);

        expect(BarcodeEmailType.values.length, 3);
        expect(BarcodeEmailType.unknown.index, 0);
        expect(BarcodeEmailType.work.index, 1);
        expect(BarcodeEmailType.home.index, 2);

        expect(BarcodePhoneType.values.length, 5);
        expect(BarcodePhoneType.unknown.index, 0);
        expect(BarcodePhoneType.work.index, 1);
        expect(BarcodePhoneType.home.index, 2);
        expect(BarcodePhoneType.fax.index, 3);
        expect(BarcodePhoneType.mobile.index, 4);

        expect(BarcodeWiFiEncryptionType.values.length, 4);
        expect(BarcodeWiFiEncryptionType.unknown.index, 0);
        expect(BarcodeWiFiEncryptionType.open.index, 1);
        expect(BarcodeWiFiEncryptionType.wpa.index, 2);
        expect(BarcodeWiFiEncryptionType.wep.index, 3);

        expect(BarcodeAddressType.values.length, 3);
        expect(BarcodeAddressType.unknown.index, 0);
        expect(BarcodeAddressType.work.index, 1);
        expect(BarcodeAddressType.home.index, 2);
      });

      group('$BarcodeDetectorOptions', () {
        test('barcodeFormats', () async {
          // The constructor for `BarcodeDetectorOptions` can't be `const`
          // without triggering a `CONST_EVAL_TYPE_BOOL_INT` error.
          // ignore: prefer_const_constructors
          final BarcodeDetectorOptions options = BarcodeDetectorOptions(
            barcodeFormats: BarcodeFormat.code128 | BarcodeFormat.dataMatrix | BarcodeFormat.ean8,
          );

          final BarcodeDetector detector = GoogleVision.instance.barcodeDetector(options);
          await detector.detectInImage(image);

          expect(
            log[0].arguments['options']['barcodeFormats'],
            0x0001 | 0x0010 | 0x0040,
          );
        });
      });
    });
  });
}
