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
pod ‘el-grocer-shopper-sdk-iOS’,   :git => ‘https://token@github.com/elgrocer/el-grocer-shopper-sdk-iOS.git’, :tag => 1.0.0
```

```ruby
Token = Token needs to update with provided token. (i.e register users token on elgrocer git account) 
```


## Author

elgrocer, abubaker@elgrocer.com

## License

el-grocer-shopper-sdk-iOS is available under the MIT license. See the LICENSE file for more info.

