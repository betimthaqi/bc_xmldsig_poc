
# Albanian Fiscalization - AL Signing POC

## Overview

Proof of concept for implementing **Albanian fiscalization signing directly in Microsoft Dynamics 365 Business Central using AL**.

The goal of this project was to verify whether Business Central can generate and cryptographically sign Albanian fiscalization requests using a fiscal certificate **without requiring an external .NET service, Azure Function, or signing middleware**.

> **POC scope:** Fiscalization data is hardcoded intentionally. All company identifiers, fiscal codes, certificate references, invoice data, and other identifying values included in this public repository are **dummy/sample values**.
>
> The focus of this repository is the cryptographic signing flow, not Business Central document mapping or a production-ready fiscalization implementation.

## Goal

The main objective was to prove that AL can perform the following flow:

```text
Hardcoded Dummy Fiscalization Data
        ↓
Generate Fiscalization XML
        ↓
Build IIC Input
        ↓
Fiscal Certificate + Private Key
        ↓
Generate IIC / IICSignature
        ↓
Generate XML Digital Signature
        ↓
Create SOAP Request
        ↓
Send to Fiscalization API
```

## What Was Implemented

- Build `RegisterInvoiceRequest` XML in AL.
- Build `RegisterTCRRequest` XML in AL.
- Generate fiscalization UUID and date/time values.
- Construct the source input used for IIC generation.
- Read the fiscal certificate from Business Central certificate storage.
- Access the certificate private key through AL.
- Sign IIC data using **SHA-256 / RSA**.
- Generate `IIC` and `IICSignature`.
- Sign the fiscalization XML using **XMLDSig**.
- Reference the request using `URI="#Request"`.
- Apply:
  - Enveloped Signature Transform
  - Exclusive XML Canonicalization
  - RSA-SHA256
- Include the X.509 certificate in the XML signature.
- Wrap the signed request in SOAP.
- Send the request using AL `HttpClient`.

## IIC Signing Flow

```text
IIC Source Data
      ↓
SHA-256 + RSA Private Key
      ↓
Signature
      ↓
HEX
      ├──→ IICSignature
      ↓
Hash
      ↓
IIC
```

The generated values are added to the invoice:

```xml
<Invoice
    IIC="..."
    IICSignature="..."
/>
```

## XML Digital Signature

After the fiscalization request is generated, the complete request is signed using XMLDSig.

Simplified structure:

```xml
<RegisterInvoiceRequest Id="Request">
    <Header />

    <Invoice
        IIC="..."
        IICSignature="..."
        ...
    />

    <Signature>
        <SignedInfo>
            <Reference URI="#Request">
                ...
            </Reference>
        </SignedInfo>

        <SignatureValue>...</SignatureValue>

        <KeyInfo>
            <X509Data>
                <X509Certificate>...</X509Certificate>
            </X509Data>
        </KeyInfo>
    </Signature>
</RegisterInvoiceRequest>
```

The signing implementation uses the certificate and private key available through Business Central certificate management.

## Sample Data

The repository contains hardcoded values because the purpose of the POC is to demonstrate the signing process independently from Business Central document mapping.

All identifying values in the public source code have been replaced with dummy/sample values, including:

```text
Issuer NUIS:        L00000000A
Business Unit Code: aa000aa000
TCR Code:           bb000bb000
Software Code:      cc000cc000
Operator Code:      dd000dd000
Maintainer Code:    ee000ee000
Certificate Code:   TEST_CERTIFICATE
```

These values are **not valid production fiscalization credentials** and are intended only to illustrate the structure of the implementation.

## POC Status

This repository contains an **experimental technical signing proof of concept**.

The scope is intentionally limited to:

- IIC and IICSignature generation
- Fiscal certificate and private key handling
- XML Digital Signature (XMLDSig)
- XML canonicalization and hashing
- X.509 certificate inclusion
- SOAP request generation
- Direct communication with the fiscalization service

Business Central document mapping and the complete fiscalization business process are outside the scope of this repository.

The technical validation targeted the following flow:

```text
AL Generated XML
        ↓
AL Generated IIC / IICSignature
        ↓
AL Generated XMLDSig
        ↓
Albanian Fiscalization TEST API
        ↓
Signature Validation
```

This repository should therefore be treated specifically as a **technical signing proof of concept**, rather than as a complete or production-ready Albanian fiscalization implementation.

## Intended Architecture

A complete implementation could build on the validated signing approach using the following architecture:

```text
Business Central Document
        ↓
Fiscalization Mapping
        ↓
XML Generation
        ↓
IIC Generation
        ↓
Certificate / Private Key
        ↓
XML Digital Signature
        ↓
SOAP / HttpClient
        ↓
Albanian Fiscalization Service
```

The architectural objective is to keep **XML generation, certificate handling, cryptographic signing, and API communication entirely inside Business Central AL**.