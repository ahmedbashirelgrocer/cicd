//
//  SmilesLoginViewModel.swift
//  ElGrocerShopper
//
//  Created by Salman on 08/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import RxSwift

public class SmilesLoginViewModel {
    
    let user : AppBinder<SmileUser?> = AppBinder(nil)
    
    let smilePoints : AppBinder<Int64?> = AppBinder(0)
    let userName = AppBinder("")
    let userPhoneNumber = AppBinder("")
    let userToken = AppBinder("")
    let userOtp = AppBinder("")
    
    let currentOtp: String = ""
    let currentUserPhoneNum: String = ""
    
    var userLoggedinSuccessfull: (()->Void)?
    var showAlertClosure: ((_ errString:String)->Void)?
    var isBlockOtp: ((_ isBlocked:Bool)->Void)?
    
    var isTimerRunning: AppBinder<Bool> = AppBinder(false)
    var timeLeft: AppBinder<Int> = AppBinder(0)
    private var retryTime: Int = 0
    private var retryCounts: Int = 0
    private var countDownTimer: Timer?

    init() {}
    
    func otpVerifcation(code: String, completionHandler: @escaping ((_ isSuccess:Bool)-> Void)) {
        if code == (userOtp.value as String) {
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
    
    func startTimer() {
        
        //Setting the countdown time
        let smilesConfig = ElGrocerUtility.sharedInstance.appConfigData.smilesData

        guard smilesConfig.allowRetry > retryCounts else {
            return
        }
        
        let timeInterval = Int(smilesConfig.retryInterval) ?? 10
        let retryMultiplyer = smilesConfig.retryIntervalDelayMultiplier * retryCounts
        timeLeft.value = timeInterval*(retryMultiplyer==0 ? 1:retryMultiplyer)//30
        
        retryCounts += 1
        countDownTimer?.invalidate()
        //countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        countDownTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        //Adding Timer to the current loop
        RunLoop.current.add(countDownTimer!, forMode: .common)
    }
    
    @objc func countDown() {
        
        var secondsLeft = timeLeft.value
        if secondsLeft > 0 {
            //print(secondsLeft)
            secondsLeft -= 1
            timeLeft.value = secondsLeft
            isTimerRunning.value = true
        } else {
            // Timer stopping
            countDownTimer?.invalidate()
            isTimerRunning.value = false
        }
     }
    
    /*
    // no longer being used
    //
    func smilesLoginWithPhone( _ phoneNum: String ) {
        /*
        let data = "{\"Sent_OTP\": \"123123\",\"UserToken\": \"xxx-xxx-xxx\"}".data(using: .utf8)!
        do {
            
            let smileAuthObj = try JSONDecoder().decode(SmileAuth.self, from: data)
            print(smileAuthObj)
            
            if let smileOtp = smileAuthObj.sentOTP {
                self.userOtp.value = smileOtp
            }
            if let token = smileAuthObj.userToken {
                self.userToken.value = token
            }
            
        } catch {
            print(error)
            if let showAlertClosure = showAlertClosure {
                showAlertClosure()
            }
        }
        */
        
        SmilesNetworkManager.sharedInstance().loginUserWithSmile(params: [:]) { result in
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                    let dataDict = response["data"]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict as Any, options: .prettyPrinted)

                        let smileAuthObj = try JSONDecoder().decode(SmileAuth.self, from: jsonData)
                        print(smileAuthObj)
                        
                        if let smileOtp = smileAuthObj.sentOTP {
                            self.userOtp.value = smileOtp
                        }
                        if let token = smileAuthObj.userToken {
                            self.userToken.value = token
                        }
                        
                    } catch {
                        print(error)
                        if let showAlertClosure = self.showAlertClosure {
                            showAlertClosure()
                        }
                    }

                case .failure(let error):
                    debugPrint(error.localizedMessage)
            }
        }
    }*/
    
    /*
    func retryOtp () {
        // api call
        
        SmilesNetworkManager.sharedInstance().retrySmileOtp(params: [:]) { result in
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                    let dataDict = response["data"]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict as Any, options: .prettyPrinted)

                        let smileAuthObj = try JSONDecoder().decode(SmileAuth.self, from: jsonData)
                        print(smileAuthObj)
                        if let smileOtp = smileAuthObj.sentOTP {
                            self.userOtp.value = smileOtp
                        }
                        
                    } catch {
                        print(error)
                        if let showAlertClosure = self.showAlertClosure {
                            showAlertClosure()
                        }
                    }

                case .failure(let error):
                    debugPrint(error.localizedMessage)
            }
        }
        /*
        let data = "{\"Sent_OTP\": \"123123\"}".data(using: .utf8)!
        do {
            let smileAuthObj = try JSONDecoder().decode(SmileAuth.self, from: data)
            print(smileAuthObj)
            if let smileOtp = smileAuthObj.sentOTP {
                self.userOtp.value = smileOtp
            }
        } catch {
            print(error)
        }*/
    }*/
    
    /*
    func otpAuthenticate (completionHandler: @escaping (()->Void) ) {
        // api call
        
        SmilesNetworkManager.sharedInstance().ConfirmSmileOtp(params: [:]) { result in
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                    let dataDict = response["data"]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict as Any, options: .prettyPrinted)

                        let smileAuthObj = try JSONDecoder().decode(SmileAuth.self, from: jsonData)
                        print(smileAuthObj)
                        completionHandler()
                        
                    } catch {
                        print(error)
                        if let showAlertClosure = self.showAlertClosure {
                            showAlertClosure()
                        }
                    }

                case .failure(let error):
                    debugPrint(error.localizedMessage)
            }
        }

    }*/
    
    
    
    func generateSmilesOtp () {
        
        SmilesNetworkManager.sharedInstance().createSmilesOtp { [weak self] result in
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                    /*
                    let dataDict = response["data"]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict as Any, options: .prettyPrinted)

                        let smileAuthObj = try JSONDecoder().decode(SmileAuth.self, from: jsonData)
                        print(smileAuthObj)
                        completionHandler()
                        
                    } catch {
                        print(error)
                        if let showAlertClosure = self.showAlertClosure {
                            showAlertClosure()
                        }
                    }*/

                case .failure(let error):
                    debugPrint(error.localizedMessage)
                    if let showAlertClosure = self?.showAlertClosure {
                        showAlertClosure(error.localizedMessage)
                    }
                    
                    if let blockClosuer = self?.isBlockOtp {
                        if error.code == SmilesNetworkManager.sharedInstance().blockedErrorCode {
                            self?.countDownTimer?.invalidate()
                            self?.isTimerRunning.value = false
                            blockClosuer(true)
                        }
                    }
                
            }
        }

    }
    
    
    func smilesLoginWithOtp (code: String, completionHandler: @escaping ((_ isSuccess:Bool, _ message:String )-> Void)) {
        
        SmilesNetworkManager.sharedInstance().loginUserWithSmile(params: ["pin":code]) { result in
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                    let dataDict = response["data"]
                    completionHandler(true, "")
                    /*
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict as Any, options: .prettyPrinted)

                        let smileAuthObj = try JSONDecoder().decode(SmileAuth.self, from: jsonData)
                        print(smileAuthObj)
                        
                        if let smileOtp = smileAuthObj.sentOTP {
                            self.userOtp.value = smileOtp
                        }
                        if let token = smileAuthObj.userToken {
                            self.userToken.value = token
                        }
                        
                    } catch {
                        print(error)
                        if let showAlertClosure = self.showAlertClosure {
                            showAlertClosure()
                        }
                    }*/

                case .failure(let error):
                    debugPrint(error.localizedMessage)
                    completionHandler(false, error.localizedMessage)
            }
        }
        
        
        
    }
}
