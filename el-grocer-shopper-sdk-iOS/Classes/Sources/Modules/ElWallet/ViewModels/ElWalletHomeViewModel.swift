//
//  ElWalletHomeViewModel.swift
//  ElGrocerShopper
//
//  Created by Salman on 16/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

public class ElWalletHomeViewModel {
    
    //TODO: add the code for cards management
    
    let walletBalance : AppBinder<Double?> = AppBinder(nil)

    let transactionInfo : AppBinder<TransactionRecord?> = AppBinder(nil)
    let allTransactions : AppBinder<[Transaction]> = AppBinder([])
    
    let voucherInfo : AppBinder<VoucherRecord?> = AppBinder(nil)
    let allVouchers : AppBinder<[Voucher]> = AppBinder([])
    
    var showAlertClosure: (()->Void)?
    
    init() {}

    func fetchVoucherData() {
        self.getVoucherInfo()
    }
    
    func fetchTransactionData() {
        self.getTransactionInfo()
    }
    
    func fetchCards() {
        self.getDebitCreditCards()
    }
    
    private func getDebitCreditCards() {
        
    }
    
    
    
    private func getTransactionInfo() {
        self.getAllWalletTransaction()
        /*
        let dataString = "{\"balance\": 12.21,\"transaction_history\": [{\"transaction_type\": \"debit\",\"created_at\": \"2022-04-27T09:30:35Z\",\"balance\": 12.21,\"amount\": 5.5,\"owner_type\": \"Order\",\"owner_detail\": \"1234567\"},{\"transaction_type\": \"credit\",\"created_at\": \"2022-04-27T09:30:35Z\",\"balance\": 12.21,\"amount\": 5,\"owner_type\": \"Voucher\",\"owner_detail\": \"el5ED\"},{\"transaction_type\": \"credit\",\"created_at\": \"2022-04-27T09:30:35Z\",\"balance\": 12.21,\"amount\": 5,\"owner_type\": \"Voucher\",\"owner_detail\": \"SP50AED\"}]}"
        
        let data = dataString.data(using: .utf8)!

        do {
            let transactionData = try TransactionRecord.init(data: data)
            print(transactionData)
            self.transactionInfo.value = transactionData
            self.allTransactions.value = transactionData.transactionHistory
        } catch {
            print(error)
            if let showAlertClosure = showAlertClosure {
                showAlertClosure()
            }
        }
        */
    }
    func getAdyenPaymentMethods(isApplePayAvailbe: Bool = false, shouldAddVoucher: Bool = false, completion: @escaping paymentFetcherCompletion) {
        PaymentMethodFetcher.getAdyenPaymentMethods(isApplePayAvailbe: true, shouldAddVoucher: shouldAddVoucher) { (paymentMethodA, creditCardA, applePayPaymentMethod, error) in
            
            completion(paymentMethodA,creditCardA,applePayPaymentMethod,error)
            
        }
    }
    
    private func getVoucherInfo() {
        self.getAllWalletVouchers()
        /*
        let dataString = "{\"vouchers\": [{\"code\": \"el5AED\",\"is_smiles\": false,\"title\": \"This is el voucher.\",\"description\": \"This is el voucher which will give 5 AED amount.\",\"amount\": 5.5},{\"code\": \"SP50\",\"is_smiles\": true,\"title\": \"This is smiles voucher.\",\"description\": \"This is smiles voucher which will give 50 AED of amount.\",\"amount\": 50}]}"
        
        let data = dataString.data(using: .utf8)!

        do {
            let voucherData = try VoucherRecord.init(data: data)
            print(voucherData)
            self.voucherInfo.value = voucherData
            self.allVouchers.value = voucherData.vouchers
        } catch {
            print(error)
            if let showAlertClosure = self.showAlertClosure {
                showAlertClosure()
            }
        }
        */
    }
    
    func getWalletAvailableBalance() {
        
        ElWalletNetworkManager.sharedInstance().getWalletBalance { result in
            SpinnerView.hideSpinnerView()
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                    let dataDict = response["data"]
                    //WalletBalance
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
                        let balance = try WalletBalance.init(data: jsonData)
                        // print(balance)
                        self.walletBalance.value = balance.balance
                    } catch {
                        //   print(error)
                        if let showAlertClosure = self.showAlertClosure {
                            showAlertClosure()
                        }
                    }

                case .failure(let error):
                    debugPrint(error.localizedMessage)
            }
            
        }
    }
    
    func redeemVoucherWith(code: String, completionHandler: @escaping ((_ error: ElGrocerError?, _ response: NSDictionary? )-> Void)) {
        
        ElWalletNetworkManager.sharedInstance().redeemVoucher(params: ["voucher_code":code]) { result in
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                    completionHandler(nil, response)

                case .failure(let error):
                    debugPrint(error.localizedMessage)
                    completionHandler(error, nil)
            }
        }
        
    }
    
    func getAllWalletTransaction () {
        
        ElWalletNetworkManager.sharedInstance().getTransactions { result in
            SpinnerView.hideSpinnerView()
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                if response["data"] != nil {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        let transactionData = try TransactionRecord.init(data: jsonData)
                        print(transactionData)
                        self.transactionInfo.value = transactionData
                        self.allTransactions.value = transactionData.transactionHistory
                    } catch (let error){
                        //    print(error)
                        if let showAlertClosure = self.showAlertClosure {
                            showAlertClosure()
                        }
                    }
                }
                case .failure(let error):
                    debugPrint(error.localizedMessage)
            }
            
        }
    }
    
    func getAllWalletVouchers () {
        
        ElWalletNetworkManager.sharedInstance().getVouchers { result in
            switch (result) {
                case .success(let response):
                    debugPrint(response)
                if let data = response["data"] as? NSDictionary {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let voucherData = try VoucherRecord.init(data: jsonData)
                        //  print(voucherData)
                        self.voucherInfo.value = voucherData
                        self.allVouchers.value = voucherData.vouchers
                    } catch {
                        //    print(error)
                        if let showAlertClosure = self.showAlertClosure {
                            showAlertClosure()
                        }
                    }
                }
                case .failure(let error):
                    debugPrint(error.localizedMessage)
            }
            
        }
    }
    
    
    
    
    
}
