//
//  TransactionsCell.swift
//  ElGrocerShopper
//
//  Created by Salman on 06/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import SwiftDate

class TransactionsCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: AWView!{
        didSet {
            innerContainerView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet var lineView: UIView!
    
    
    static let reuseId: String = "TransactionsCell"
    static var nib: UINib {
        return UINib(nibName: "TransactionsCell", bundle: .resource)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpInitialAppearance()
    }
    
    private func setUpInitialAppearance() {
        nameLabel.setBody3SemiBoldDarkStyle()
        valueLabel.setBody3RegDarkStyle()
        dateLabel.setBody3RegDarkStyle()
        sourceLabel.setBody3RegDarkStyle()
        balanceLabel.setBody3RegDarkStyle()
        self.setAppearanceForArabic()
    }
    private func setAppearanceForArabic() {
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            nameLabel.textAlignment = .right
            dateLabel.textAlignment = .right
            balanceLabel.textAlignment = .left
            sourceLabel.textAlignment = .right
            valueLabel.textAlignment = .right
        }else {
            nameLabel.textAlignment = .left
            dateLabel.textAlignment = .left
            balanceLabel.textAlignment = .right
            sourceLabel.textAlignment = .left
            valueLabel.textAlignment = .left
        }
    }

    func configure(_ transaction:Transaction) {
        
        nameLabel.text = transaction.transactionType
        let initalString = (transaction.isCredited ?? false) ? "+" : "-"
        let amount: String = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: (transaction.amount ?? 0.0).formateDisplayString())
        valueLabel.text = initalString + amount + localizedString("aed", comment: "")
        dateLabel.text = self.parseDate(date: transaction.createdAt ?? "")
        if (transaction.ownerDetail ?? "").elementsEqual("apple_pay") {
            sourceLabel.text = (transaction.ownerType ?? "")
        }else {
            sourceLabel.text = (transaction.ownerType ?? "") + " : " + (transaction.ownerDetail ?? "")
        }
        let balance: String = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: (transaction.balance ?? 0.0).formateDisplayString())
        balanceLabel.text = localizedString("txt_elwallet_balance", comment: "") + " " + balance + localizedString("aed", comment: "")
    }
    
    private func parseDate(date: String)-> String {
        var dateString = ""
        if let date = date.convertStringToCurrentTimeZoneDate() {
            dateString = date.toString(DateToStringStyles.custom("dd MMM yyyy"))
        }
        return dateString
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
