//
//  AWPickerList.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 04/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import UIKit

class AWPickerList: CustomCollectionView {
    
    
    var collectionData : [DeliverySlot] = [DeliverySlot]()
    var filterData : [DeliverySlot] = [DeliverySlot]()
    var selectedIndex = -1
    var selectedSlotID = UserDefaults.getCurrentSelectedDeliverySlotId()
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsAndSetDelegateAndDataSource()
    }
    

    func registerCellsAndSetDelegateAndDataSource () {
        
        self.addCollectionViewWithDirection(.vertical)
        let cell = UINib(nibName: "AWPicketCollectionViewCell", bundle: Bundle.resource)
        self.collectionView?.register(cell, forCellWithReuseIdentifier: "AWPicketCollectionViewCell")
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
       
                
    }
    
    func configureData(_ dataA : [DeliverySlot]) {
        filterData = dataA
        selectedSlotID = UserDefaults.getCurrentSelectedDeliverySlotId()
        self.collectionView?.reloadDataOnMainThread()
        if let i = filterData.firstIndex(where: {$0.dbID == selectedSlotID }) {
            self.selectedIndex = i
            ElGrocerUtility.sharedInstance.delay(0.05) {
                self.collectionView?.scrollToItem(at: IndexPath.init(row: self.selectedIndex , section: 0), at: .centeredVertically, animated: true)
            }
        }
       
    }
 
}
extension AWPickerList : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AWPicketCollectionViewCell" , for: indexPath) as! AWPicketCollectionViewCell
        let slot = filterData[indexPath.row]
        if slot.isInstant.boolValue {
            cell.lblSlotName.text = localizedString("today_title", comment: "") + " "   +  localizedString("60_min", comment: "")
        } else {
            let timeSlot = self.getSlotTimeInSlotSelection(slot: slot , ElGrocerUtility.sharedInstance.isDeliveryMode)
            cell.lblSlotName.text = timeSlot
        }
        cell.setState(self.selectedIndex == indexPath.row)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let slot = filterData[indexPath.row]
        self.selectedIndex = indexPath.row
        self.selectedSlotID = slot.getdbID()
        self.collectionView?.reloadData()
    }
    
    //MARK: Date Helper
    
    func getSlotTimeInSlotSelection( slot : DeliverySlot , _ isDeliveryMode : Bool = true ) -> String {
        guard slot.start_time != nil && slot.end_time != nil else { return "" }
        let startDate =  slot.start_time!
        let endDate =  slot.end_time!
        return ( isDeliveryMode ?  startDate.formatDateForDeliveryHAFormateString() : startDate.formatDateForCandCFormateString() ) + " - " + ( isDeliveryMode ?  endDate.formatDateForDeliveryHAFormateString() : endDate.formatDateForCandCFormateString())
    }
  
}
extension AWPickerList : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize:CGSize = CGSize(width: collectionView.frame.size.width * 0.44 , height: 38)
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0 , left: 16 , bottom: 0 , right: 16)
    }
    
}
