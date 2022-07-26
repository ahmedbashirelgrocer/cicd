//
//  MyBasketCandCDataHandler.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 23/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation


protocol MyBasketCandCDataHandlerDelegate : class {
   
    func collectorDataLoaded() -> Void
    func carDataLoaded() -> Void
    func pickUpLocationLoaded() -> Void
    
    
}

extension MyBasketCandCDataHandlerDelegate {
    
    func collectorDataLoaded(){}
    func carDataLoaded(){}
    func pickUpLocationLoaded(){}
}


struct collector {
    var name  : String = ""
    var phonenNumber  : String = ""
    var dbID  : Int = -1
}
extension collector {
    init( collectorData : NSDictionary ){
        self.dbID = collectorData["id"] as? Int ?? -1
        self.name = collectorData["name"] as? String ?? ""
        self.phonenNumber = collectorData["phone_number"] as? String ?? ""
    }
}


struct vehicleColors {
    var color_code : String = ""
    var name : String = ""
    var dbId : Int = -1
}


struct vehicleModels {
    var name : String = ""
    var dbId : Int = -1
}


struct Car {
    var company : String = ""
    var dbId : Int = -1
    var plateNumber : String = ""
    var color : vehicleColors?
    var model : vehicleModels?
}


struct PickUpLocation {
    var details : String = ""
    var dbId : Int = -1
    var latitude : String = ""
    var longitude : String = ""
    var photo_url : String = ""
    var retailer_id : Int = -1
}



class MyBasketCandCDataHandler {
    
    weak var delegate : MyBasketCandCDataHandlerDelegate?
    var collectorList : [collector] = []
    var carList : [Car] = [] {
        didSet{
            elDebugPrint(carList.count)
        }
    }
    var selectedCollector : collector?
    var selectedCar : Car?
    var pickUpLocation : PickUpLocation?
    
    func loadInitailData() {
        getCardetails()
        getCollectordetails()
    }
   
    func getCardetails() {
        
        ElGrocerApi.sharedInstance.getCarDetail { (result) in
            switch result {
                case .success(let response):
                    elDebugPrint(response)
                    if let data = response["data"] as? [NSDictionary] {
                        self.carList = []
                        for carDict in data {
                            var currentModel : vehicleModels?
                            if let vehicleDict = carDict["vehicle_model"] as? NSDictionary {
                                currentModel =  vehicleModels.init(name: vehicleDict["name"] as? String ?? "", dbId: vehicleDict["id"] as? Int ?? -1)
                            }
                            var currentColor : vehicleColors?
                            if let vehicleDict = carDict["vehicle_color"] as? NSDictionary {
                                currentColor =  vehicleColors.init(color_code: vehicleDict["color_code"] as? String ?? "" , name: vehicleDict["name"] as? String ?? "" , dbId: vehicleDict["id"] as? Int ?? -1)
                            }
                            let car = Car.init(company: (carDict["company"] as? String) ?? "", dbId: carDict["id"] as! Int, plateNumber: (carDict["plate_number"] as? String) ?? "", color: currentColor, model: currentModel)
                            self.carList.append(car)
                        }
                        self.makeSelectedCar()
                        self.delegate?.carDataLoaded()
                    }
                case .failure(let error):
                    error.showErrorAlert()
                   // self.reloadTableData()
            }
        }
        
    }
    
    func getCollectordetails() {
        ElGrocerApi.sharedInstance.getcollectorDetail  { (result) in
            switch result {
                case .success(let response):
                    if let data = response["data"] as? NSArray {
                        self.collectorList = []
                        for obj in data {
                            if obj is NSDictionary {
                                let dataObj = collector.init(collectorData: obj as! NSDictionary)
                                self.collectorList.append(dataObj)
                            }
                        }
                    }
                    self.makeSelectedCollector()
                    self.delegate?.collectorDataLoaded()
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
        
    }
    
    
    func getPickUpLocation(_ retailId : String ) {
        
        ElGrocerApi.sharedInstance.getPickUpLocations(retailId: retailId) { (result) in
            switch result {
                case .success(let response):
                    elDebugPrint(response)
                    if let data = response["data"] as? [NSDictionary] {
                        for dict in data {
                            self.pickUpLocation = PickUpLocation.init(details: (dict["details"] as? String) ?? "", dbId: (dict["id"] as? Int) ?? -1, latitude: (dict["latitude"] as? String) ?? "", longitude: (dict["longitude"] as? String) ?? "", photo_url: (dict["photo_url"] as? String) ?? "", retailer_id: (dict["retailer_id"] as? Int) ?? -1)
                        }
                    }
                    self.delegate?.pickUpLocationLoaded()
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
        
        
    }
    
    func makeSelectedCollector() {
        if  self.collectorList.count > 0 {
            self.selectedCollector = self.collectorList[0]
            let dbId = UserDefaults.getCurrentSelectedCollector()
            if dbId != nil && dbId != -1 {
                let currentCollector = self.collectorList.filter { (type) -> Bool in
                    return type.dbID == dbId
                }
                if currentCollector.count > 0 {
                    self.selectedCollector = currentCollector[0]
                }
            }
        }
    }
    
    func makeDefaultCar(car : Car) {
        if  car.dbId != -1 {
            self.selectedCar = car
            UserDefaults.setCurrentSelectedCar(car.dbId)
        }
    }

    
    func makeSelectedCar() {
        if  self.carList.count > 0 {
            self.selectedCar = self.carList[0]
            let dbId = UserDefaults.getCurrentSelectedCar()
            if dbId != nil && dbId != -1 {
                let currentCar = self.carList.filter { (type) -> Bool in
                    return type.dbId == dbId
                }
                if currentCar.count > 0 {
                    self.selectedCar = currentCar[0]
                }
            }
        }
    }



}
