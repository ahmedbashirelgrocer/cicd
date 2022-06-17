//
//  CustomTableView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 21/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

class CustomTableView: UITableView {


    lazy var customTableBGView : UIView = {
        let spinnerView = Bundle.resource.loadNibNamed("SpinnerView", owner: nil, options: nil)![0] as! SpinnerView
        spinnerView.tag = kSpinnerViewTag
        spinnerView.alpha = 1
        return spinnerView
    }()

    private let cutomRefreshControl = UIRefreshControl()
    var refreshCalled: (()->Void)? {
        
        didSet {
            
            if #available(iOS 10.0, *) {
                self.refreshControl = cutomRefreshControl
                customTableBGView.frame = refreshControl!.bounds
                refreshControl!.addSubview(customTableBGView)
            } else {
                // Fallback on earlier versions
                cutomRefreshControl.backgroundColor = UIColor.clear
                cutomRefreshControl.tintColor = UIColor.clear
                self.addSubview(cutomRefreshControl)
                customTableBGView.frame = cutomRefreshControl.bounds
                cutomRefreshControl.addSubview(customTableBGView)
            }
            cutomRefreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
            
        }
    
        
    }
    //var LoadMoreCalled: (()->Void)?
    //private var endRefreshingTimer: Timer!
    //gameTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
    //gameTimer.invalidate()

    override func awakeFromNib() {
       
    }
    @objc func refreshData(_ sender: Any) {
        if self.refreshCalled != nil {
            self.refreshCalled!()
        }
    }
    func stopRefreshing() {
        cutomRefreshControl.endRefreshing()
    }



}
extension CustomTableView {

    func setEmptyView(title: String, message: String) {

        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.SFProDisplaySemiBoldFont(15)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont.SFProDisplayNormalFont(13)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        self.backgroundView = emptyView
        self.separatorStyle = .none
    }

    func setLoader(){
        customTableBGView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.backgroundView = customTableBGView
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
    }

}

