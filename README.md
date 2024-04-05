# GoogleCloudKit

GoogleCloudKit is a Swift package that provides utilities for interacting with Google services such as Google Sheets and Firebase Cloud Storage. This package is designed to simplify tasks such as creating Google Sheets, uploading data to Google Sheets, uploading images to Firebase Cloud Storage, and more.

## Features

- Upload data to Google Sheets.
- Create new sheet tabs.
- Upload images to Google Cloud Storage.
- Check if a Google Sheet with a certain name exists.
- Retrieve download URLs for uploaded images.

## Installation

You can integrate GoogleCloudKit into your Swift projects using Swift Package Manager (SPM). Simply add the package URL to your project's dependencies in the `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/TaifAldehbash/GoogleCloudKit.git", from: "1.0.0")
]
