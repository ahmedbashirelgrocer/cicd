//
//  DownloadPDFCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 23/06/2023.
//

import UIKit

class DownloadPDFCell: UITableViewCell {

    @IBOutlet weak var btnDownload: UIButton! {
        didSet {
            btnDownload.setBody3BoldSecondaryDarkGreenColorStyle()
        }
    }
    
    var url: URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }()
        btnDownload.addTarget(self, action: #selector(downloadFile), for: .touchUpInside)
    }
    
    @objc func downloadFile() {
        UIApplication.shared.open(url)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(url: URL) {
        self.url = url
    }
    
}
