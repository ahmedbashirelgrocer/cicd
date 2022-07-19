# el-grocer-shopper-sdk-iOS

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To start ios sdk, start engine with following code

```ruby
 let launchOptions = LaunchOptions(
            accountNumber: txtAccountNumber.text,
            latitude: ((txtLat.text ?? "0") as NSString).doubleValue,
            longitude: ((txtLong.text ?? "0") as NSString).doubleValue,
            address: txtAddress.text,
            loyaltyID: txtLoyalityID.text,
            email: txtEmail.text,
            pushNotificationPayload: ["data" : txtPushPayload.text],
            deepLinkPayload:  txtDLPayload.text,
            language: txtLanguage.text, isSmileSDK: true
        )
        ElGrocer.startEngine(with: launchOptions)
```

## Requirements

## Installation

el-grocer-shopper-sdk-iOS is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'el-grocer-shopper-sdk-iOS'
```

## Author

elgrocer, abubaker@elgrocer.com

## License

el-grocer-shopper-sdk-iOS is available under the MIT license. See the LICENSE file for more info.

