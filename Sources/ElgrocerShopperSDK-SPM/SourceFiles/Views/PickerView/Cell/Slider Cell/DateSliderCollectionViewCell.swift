//
//  DateSliderCollectionViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 23/11/2023.
//

import UIKit
import RxSwift
import RxCocoa

class DateSliderCollectionViewCell: RxUICollectionViewCell {
    @IBOutlet weak var viewBG: AWView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    
    override var isSelected: Bool {
        set {
            super.isSelected = newValue
            
            self.viewBG.backgroundColor = isSelected ? ApplicationTheme.currentTheme.themeBasePrimaryColor : UIColor.colorWithHexString(hexString: "f5f5f5")
            self.lblDate.textColor = isSelected ? UIColor.white : .newBlackColor()
            self.lblDay.textColor = isSelected ? UIColor.white : .newBlackColor()
        }
        get {
            super.isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.selectedBackgroundView = {
//            let selectedBGView = UIView()
//            selectedBGView.backgroundColor = .clear
//            return selectedBGView
//        }()
//        
//        self.bringSubviewToFront(selectedBackgroundView!)
    }
    
    func configure(date: Date) {
        self.lblDate.text = date.formateDate(dateFormate: "dd MMM")
        self.lblDay.text = self.dayString(date: date)
    }
    
    private func dayString(date: Date) -> String {
        if date.isToday {
            return localizedString("today_title", comment: "")
        } else if date.isTomorrow {
            return localizedString("tomorrow_title", comment: "")
        } else {
            return date.getDayNameFull() ?? ""
        }
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? DateSliderCollectionViewCellViewModelType else { return }
        
        viewModel.outputs.dateString
            .bind(to: self.lblDate.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.dayString
            .bind(to: self.lblDay.rx.text)
            .disposed(by: disposeBag)
    }
}
