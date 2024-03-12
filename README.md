# ElgrocerShopperSDK-SPM

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

ElgrocerShopperSDK-SPM is available through [SPM](https://www.swift.org/package-manager/). Once you have your Swift package set up, adding ElgrocerShopperSDK-SPM
as a dependency is as easy as adding it to the dependencies value of your Package.swift or the Package list in Xcode.

```ruby
    dependencies: [
        .package(url: "https://<TOKEN>@github.com/elgrocer/SDKGrocerySPM", .upToNextMajor(from: "0.0.1"))
    ]
```

```ruby
Token = Token needs to update with provided token. (i.e register users token on elgrocer git account) 
```


## Author

elgrocer, abubaker@elgrocer.com, rashidkhan@elgrocer.com

## License

ElgrocerShopperSDK-SPM linked with consent with Elgrocer / Smiles useage permission. 

