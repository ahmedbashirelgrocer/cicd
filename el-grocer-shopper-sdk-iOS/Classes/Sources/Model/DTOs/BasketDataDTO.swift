//
//  BasketDataDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 13/07/2023.
//

import Foundation

// MARK: - BasketDataResponse
struct BasketDataResponse: Codable {
    let status: String
    let data: BasketDataClass
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case data = "data"
    }
}

    // MARK: - BasketDataClass
struct BasketDataClass: Codable {
    
    var primaryPaymentTypeID: Int?
    let finalAmount, totalValue: Double?
    let promoCodes: Bool?
    let smilesBalance: Double?
    let elWalletBalance, productsTotal, serviceFee, productsSaving: Double?
    let promoCode: PromoCode?
    let smilesRedeem, elWalletRedeem: Double?
    let smilesPoints: Int?
    //let deliverySlots: [DeliverySlotDTO]?
    let selectedDeliverySlot: Int?
    let paymentTypes: [PaymentType]?
   // let retailerDeliveryZoneId: Int?
    let quantity: Int?
    let totalDiscount: Double?
    let extraBalanceMessage: String?
    let extraBalance: Double?
    let smilesEarn: Int?
    let priceVariance: Double?
    var smilesSubscriber: Bool?
    var tabbyWebUrl: String?
    var tabbyRedeem: Double?
    var tabbyThresholdMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case finalAmount = "final_amount"
        case totalValue = "total"
        case promoCodes = "promo_codes"
        case primaryPaymentTypeID = "primary_payment_type_id"
        case serviceFee = "service_fee"
        case smilesBalance = "smiles_balance"
        case elWalletBalance = "el_wallet_balance"
        case productsSaving = "products_saving"
        case promoCode = "promo_code"
        case smilesRedeem = "smiles_redeem"
        case elWalletRedeem = "el_wallet_redeem"
        //case deliverySlots = "delivery_slots"
        case paymentTypes = "retailer_payment_methods"
        case selectedDeliverySlot = "selected_delivery_slot"
        case productsTotal = "products_total"
        case smilesPoints = "smiles_points"
       // case retailerDeliveryZoneId = "retailer_delivery_zone_id"
        case quantity
        case totalDiscount = "total_discount"
        case extraBalanceMessage = "balance_message"
        case smilesEarn = "smiles_earn"
        case priceVariance = "Price_variance"
        case extraBalance = "balance"
        case smilesSubscriber = "food_subscription_status"
        case tabbyWebUrl = "tabby_web_url"
        case tabbyRedeem = "tabby_redeem"
        case tabbyThresholdMessage = "tabby_threshold_message"
        
    }
    
    init(from decoder: Decoder) throws {
       
    
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        finalAmount = (try? values.decode(Double.self, forKey: .finalAmount))
        totalValue = (try? values.decode(Double.self, forKey: .totalValue))
        promoCodes  = (try? values.decode(Bool.self, forKey: .promoCodes))
        primaryPaymentTypeID = (try? values.decode(Int.self, forKey: .primaryPaymentTypeID))
        smilesBalance = (try? values.decode(Double.self, forKey: .smilesBalance))
        elWalletBalance = (try? values.decode(Double.self, forKey: .elWalletBalance))
        productsTotal = (try? values.decode(Double.self, forKey: .productsTotal))
        serviceFee = (try? values.decode(Double.self, forKey: .serviceFee))
        productsSaving = (try? values.decode(Double.self, forKey: .productsSaving))
        promoCode = (try? values.decode(PromoCode.self, forKey: .promoCode))
        smilesRedeem = (try? values.decode(Double.self, forKey: .smilesRedeem))
        elWalletRedeem = (try? values.decode(Double.self, forKey: .elWalletRedeem))
        smilesPoints = (try? values.decode(Int.self, forKey: .smilesPoints))
       // deliverySlots = deliverySlots
       // deliverySlots = (try? values.decode([DeliverySlotDTO].self, forKey: .deliverySlots))
        selectedDeliverySlot = (try? values.decode(Int.self, forKey: .selectedDeliverySlot))
        paymentTypes = (try? values.decode([PaymentType].self, forKey: .paymentTypes))
      //  retailerDeliveryZoneId = (try? values.decode(Int.self, forKey: .retailerDeliveryZoneId))
        quantity = (try? values.decode(Int.self, forKey: .quantity))
        totalDiscount = (try? values.decode(Double.self, forKey: .totalDiscount))
        extraBalanceMessage = (try? values.decode(String.self, forKey: .extraBalanceMessage))
        smilesEarn = (try? values.decode(Int.self, forKey: .smilesEarn))
        priceVariance = (try? values.decode(Double.self, forKey: .smilesEarn))
        extraBalance = (try? values.decode(Double.self, forKey: .extraBalance))
        smilesSubscriber = (try? values.decode(Bool.self, forKey: .smilesSubscriber)) //?? false
        tabbyWebUrl = (try? values.decode(String.self, forKey: .tabbyWebUrl))
        tabbyRedeem = (try? values.decode(Double.self, forKey: .tabbyRedeem))
        tabbyThresholdMessage = (try? values.decode(String.self, forKey: .tabbyThresholdMessage))

    }
}

    // MARK: - DeliverySlot
struct DeliverySlotDTO: Codable {
    let id: Int
    let timeMilli, usid: Int?
    let startTime, endTime, estimatedDeliveryAt: String?
    
    var isToday: Bool {
        return self.startTime?.toDate()?.date.isToday ?? false
    }
    
    var isTomorrow: Bool {
        return self.startTime?.toDate()?.date.isTomorrow ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case timeMilli = "time_milli"
        case usid
        case startTime = "start_time"
        case endTime = "end_time"
        case estimatedDeliveryAt = "estimated_delivery_at"
    }
    
    func getInstantText() -> String {
        return localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "") + "⚡️"
    }
}

    // MARK: - PaymentType
struct PaymentType: Codable {
    let id: Int
    let name: String?
    let accountType: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case accountType = "account_type"
    }
    
    func getLocalPaymentOption() -> PaymentOption {
        
        if self.id == 1 {
            return PaymentOption.cash
        }else if self.id == 2 {
            return PaymentOption.card
        }else if self.id == 3 {
            return PaymentOption.creditCard
        } else if self.id == 7 {
            return PaymentOption.tabby
        } else if self.id == PaymentOption.applePay.rawValue {
            return PaymentOption.applePay
        }else {
            return PaymentOption.none
        }
    }
    func getLocalizedName() -> String {
        
        if self.id == 1 {
            return localizedString("txt_pay_cash", comment: "")
        }else if self.id == 2 {
            return localizedString("pay_via_card", comment: "")
        }else if self.id == 3 {
            return localizedString("pay_via_CreditCard", comment: "")
        }else if self.id == PaymentOption.applePay.rawValue {
            return localizedString("pay_via_Apple_pay", comment: "")
        }else {
            return self.name ?? ""
        }
    }
}
    // MARK: - PromoCode
struct PromoCode: Codable {
    let code: String?
    let promotionCodeRealizationID: Int?
    let value: Double?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case promotionCodeRealizationID = "realization_id"
        case value
        case errorMessage = "error_message"
    }
}



struct DeliverySlotsResponse: Codable {
    let status: String
    let data: DeliverySlotsData
}

struct DeliverySlotsData: Codable {
    let retailer: Retailer
    let deliverySlots: [DeliverySlotDTO]?
    
    enum CodingKeys: String, CodingKey {
        case retailer
        case deliverySlots = "delivery_slots"
    }
}

struct Retailer: Codable {
    let id: String?
    let isOpened: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isOpened = "is_opened"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try? values.decode(String.self, forKey: .id))
        isOpened = (try? values.decode(Bool.self, forKey: .isOpened))
    }
}
