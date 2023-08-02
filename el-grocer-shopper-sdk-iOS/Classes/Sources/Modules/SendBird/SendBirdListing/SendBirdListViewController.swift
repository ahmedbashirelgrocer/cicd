//
//  SendBirdListViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 20/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SendBirdDesk
import SendbirdChatSDK
import SendbirdUIKit
import RxCocoa
class SendBirdListViewController: UIViewController, NavigationBarProtocol, UIScrollViewDelegate, NoStoreViewDelegate {
    var openOffset: Int = 0
    var closeOffset: Int = 0
    var ticketList : [SBDSKTicket]? = []
    var closedTicketList : [SBDSKTicket]? = []
    var orderId: String = "0"
    var isApiCalling : Bool = false
    var closeIsApiCalling : Bool = false
    var nextValue : Bool = true
    var closedNextValue : Bool = true
    private let refreshControl = UIRefreshControl()
    private let SBDMainDelegateIdentifier = "UNIQUE_DELEGATE_ID_List"
    var showCloseTickets: Bool = false
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoTicket()
        return noStoreView!
    }()
    func noDataButtonDelegateClick(_ state: actionState) {
        self.createSupportTicket()
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentControl: UISegmentedControl!{
        didSet {
            segmentControl.layer.cornerRadius = segmentControl.layer.frame.height / 2
            segmentControl.layer.masksToBounds = true
        }
    }
    
    func getCurrentUser() -> UserProfile? {
        
        if UserDefaults.isUserLoggedIn(){
            let user = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            return user
        }else{
            return nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localizedString("ios.ZDKRequests.requestList.title", comment: "")
        self.setSendbirdDelegate()
            // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        refreshControl.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        self.setSegmentApperance()
        self.handleArabicMode()
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        
        // Do any additional setup after loading the view.
    }
    func handleArabicMode() {
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.tableView.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        
        refreshTicketData()
    }
    
    func refreshTicketData() {
        if self.showCloseTickets {
            self.closeIsApiCalling = true
            self.closeOffset = 0
            self.closedNextValue = true
            self.getCloseTickets()
        }else {
            self.isApiCalling = true
            self.openOffset = 0
            self.nextValue = true
            self.getOpenTickets()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        
        Thread.OnMainThread {
            
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            sdkManager.isShopperApp ? self.addWhiteBackButton() : self.addBackButton(isGreen: false)
            self.addCreateTicketButton()
            self.refreshTicketData()
            self.tableView.reloadData()
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard !isApiCalling else {return}
        self.isApiCalling = true
        self.closeIsApiCalling = true
        self.getOpenTickets()
        self.getCloseTickets()
    }
    
    func setSegmentApperance() {
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15) ]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        
        let titleTextAttributesUnselected = [NSAttributedString.Key.foregroundColor: UIColor.newBlackColor() , NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14)]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesUnselected, for: .normal)
        
        segmentControl.setTitle(localizedString("lbl_open_ticket", comment: ""), forSegmentAt: 0)
        segmentControl.setTitle(localizedString("lbl_close_ticket", comment: ""), forSegmentAt: 1)
        
    }
    
    @objc override func backButtonClick() {
        
        self.removeSendBirdDelegates()
        self.dismiss(animated: true)
    }
    
    func backButtonClickedHandler() {
        self.removeSendBirdDelegates()
        self.dismiss(animated: true)
    }
    
    func removeSendBirdDelegates() {
        SendbirdChat.removeChannelDelegate(forIdentifier: SBDMainDelegateIdentifier)
        SendbirdChat.removeUserEventDelegate(forIdentifier: SBDMainDelegateIdentifier)
        SendbirdChat.removeConnectionDelegate(forIdentifier: SBDMainDelegateIdentifier)
        sdkManager.setSendbirdDelegate()
    }
    
    func setSendbirdDelegate () {
        
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(SBUGroupChannelCell.self, forCellReuseIdentifier: "SBUGroupChannelCell")
        
        
        SendbirdChat.addChannelDelegate(self, identifier: SBDMainDelegateIdentifier)
        SendbirdChat.addConnectionDelegate(self, identifier: SBDMainDelegateIdentifier)
        SendbirdChat.addUserEventDelegate(self, identifier: SBDMainDelegateIdentifier)
    }
    
    @IBAction func segmentControlActionHandler(_ sender: Any) {
        
        self.showCloseTickets = (self.segmentControl.selectedSegmentIndex == 1)
        self.checkNoDataView()
//        self.tableView.reloadDataOnMain()
    }
    
    func getOpenTickets() {
        
        guard self.nextValue else {return}
        
        if self.openOffset == 0 {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        
        SBDSKTicket.getOpenedList(withOffset: self.openOffset, customFieldFilter: [:]) { (tickets, hasNext, error) in
            
            
            Thread.OnMainThread {
                self.refreshControl.endRefreshing()
                SpinnerView.hideSpinnerView()
            }
            
          
            guard error == nil else {
                Thread.OnMainThread {
                    error?.showSBDErrorAlert()
                }
                self.isApiCalling  = false
                return
            }
            
            
            
            if self.openOffset == 0 {
                self.ticketList = []
//                self.tableView.reloadDataOnMain()
                self.checkNoDataView()
            }
            
           
            self.nextValue = hasNext
             
            if let list = tickets {
                for tic in list {
                    self.ticketList?.append(tic)
                }
            }
            
            self.ticketList =  self.ticketList?.uniqued()
            
            if hasNext {
                self.openOffset += self.ticketList?.count ?? 0
            }
            
//            self.tableView.reloadDataOnMain()
            self.checkNoDataView()
            self.isApiCalling  = false
        }
        
        
    }
    func getCloseTickets(){
        
        guard self.closedNextValue else {return}
        
        if self.closeOffset == 0 {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        
        var customFieldFilter = [String: String]()
        
        if let shopperUser = self.getCurrentUser(){
            customFieldFilter = ["shopperid": shopperUser.dbID.stringValue]
//            customFieldFilter["orderid"] = "0"
        }
        
        SBDSKTicket.getClosedList(withOffset: self.closeOffset, customFieldFilter: customFieldFilter) { (tickets, hasNext, error) in
            
            
            Thread.OnMainThread {
                self.refreshControl.endRefreshing()
                SpinnerView.hideSpinnerView()
            }
            
            guard error == nil else {
                Thread.OnMainThread {
                    error?.showSBDErrorAlert()
                }
                self.closeIsApiCalling  = false
                return
            }
            if self.closeOffset == 0 {
                self.closedTicketList = []
                self.tableView.reloadDataOnMain()
            }
            self.closedNextValue = hasNext
             
            if let list = tickets {
                for tic in list {
                    self.closedTicketList?.append(tic)
                }
            }
            
           elDebugPrint("closed Tickets: \(tickets?.count)")
            self.closedTicketList =  self.closedTicketList?.uniqued()
            
            if hasNext {
                self.closeOffset += self.closedTicketList?.count ?? 0
            }
            self.tableView.reloadDataOnMain()
            self.closeIsApiCalling  = false
        }
    }
    
    func openChannelFromTicket(ticket: SBDSKTicket) {
        
        guard let urlData = ticket.channel?.channelURL else {
            return
        }
        let title = ticket.title
        if title?.contains("Order:") ?? false {
            let data : [String] = title?.components(separatedBy: "Order:") ?? []
            if (data.count) > 1 {
                let orderData = data[1] as NSString
                self.orderId = orderData.replacingOccurrences(of: "_shopper", with: "")
                self.orderId = self.orderId.replacingOccurrences(of: " ", with: "")
            }
        }else {
            self.orderId = "0"
        }
        
        Thread.OnMainThread { let _ = SpinnerView.showSpinnerViewInView(self.view) }
       
        GroupChannel.getChannel(url: urlData) { channel, error in
            SpinnerView.hideSpinnerView()
            guard let channel = channel , error == nil else{
                error?.showSBDErrorAlert()
                return
            }
            Thread.OnMainThread {
                let params = MessageListParams()
                params.includeMetaArray = true
                params.includeReactions = true
                params.includeThreadInfo = true
                params.includeParentMessageInfo = SendbirdUI.config.groupChannel.channel.replyType != .none
                params.replyType = SendbirdUI.config.groupChannel.channel.replyType.filterValue
                params.messageTypeFilter = .user
                let channelController = ElgrocerChannelController(channel: channel, messageListParams: params)
                channelController.headerComponent?.rightBarButton = UIBarButtonItem()
                self.navigationController?.pushViewController(channelController, animated: true)
            }
        }
    }
    
    func checkNoDataView() {
        Thread.OnMainThread {
            if self.showCloseTickets {
                if self.closedTicketList?.count ?? 0 == 0 {
                    self.tableView.backgroundView = self.NoDataView
                }else {
                    self.tableView.backgroundView = UIView()
                }
            }else {
                if self.ticketList?.count ?? 0 == 0 {
                    self.tableView.backgroundView = self.NoDataView
                }else {
                    self.tableView.backgroundView = UIView()
                }
            }
        }
        
        self.tableView.reloadDataOnMain()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}
extension SendBirdListViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showCloseTickets {
            return closedTicketList?.count ?? 0
        }else {
            return ticketList?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SBUGroupChannelCell", for: indexPath) as! SBUGroupChannelCell
        
        if showCloseTickets {
            if let channel = closedTicketList?[indexPath.row].channel {
                cell.configure(channel: channel)
//                let profileUrl = closedTicketList?[indexPath.row].agent?.profileUrl ?? ""
//                cell.coverImage.setImage(withCoverURL: profileUrl)
                var title = channel.name
                title = title.replacingOccurrences(of: "_shopper", with: "")
                cell.titleLabel.text = title
                var image = UIImage(name: "logo-bg")!
                if #available(iOS 13.0, *) {
                    image = image.withTintColor(ApplicationTheme.currentTheme.themeBasePrimaryColor)
                }
                cell.coverImage.setImage(withImage: image)
            }
        }else {
            if let channel = ticketList?[indexPath.row].channel {
                cell.configure(channel: channel)
                var title = channel.name
                title = title.replacingOccurrences(of: "_shopper", with: "")
                cell.titleLabel.text = title
                var image = UIImage(name: "logo-bg")!
                if #available(iOS 13.0, *) {
                    image = image.withTintColor(ApplicationTheme.currentTheme.themeBasePrimaryColor)
                }
                cell.coverImage.setImage(withImage: image)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.showCloseTickets {
            if indexPath.row < closedTicketList?.count ?? 0 {
                let ticket = closedTicketList![indexPath.row]
                self.openChannelFromTicket(ticket: ticket)
            }
        }else {
            if indexPath.row < ticketList?.count ?? 0 {
                let ticket = ticketList![indexPath.row]
                self.openChannelFromTicket(ticket: ticket)
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    
        if maximumOffset - currentOffset <= 70.0 {
            if self.showCloseTickets {
                guard !closeIsApiCalling else {return}
                self.closeIsApiCalling = true
                self.getCloseTickets()
            }else {
                guard !isApiCalling else {return}
                self.isApiCalling = true
                self.getOpenTickets()
            }
            
        }
    }
    
    
}
extension SendBirdListViewController {
    func addCreateTicketButton() {
        
        var image: UIImage! = UIImage(name: "addIconWhite")
        if #available(iOS 13.0, *), !sdkManager.isShopperApp {
            image = image.withTintColor(ApplicationTheme.currentTheme.newBlackColor)
        } else { }
        let menuButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        
        let size = self.navigationController?.navigationBar.frame.size.height
        if let height = size {
            let width = image.size.width + 25
            menuButton.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        menuButton.setImage(image, for: UIControl.State())
        menuButton.setImage(image, for: UIControl.State.highlighted)
        menuButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        menuButton.addTarget(self, action: #selector(SendBirdListViewController.createSupportTicket), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    @objc func createSupportTicket() {
        if let user = SendbirdChat.getCurrentUser() {
            let deskManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
            deskManager.logIn(isWithChat: false) {
                deskManager.getOpenedTicket { (isFound , openticket, ticketsCount) in
                    if isFound, let ticketUrl = openticket?.channel?.channelURL {
                        deskManager.callSendBirdChat(orderId: "0", controller: self, channelUrl: ticketUrl)
                    }else {
                        deskManager.createTicketWithCustomParams(orderId: "0", user: user.nickname, controller: self)
                    }
                }
            }
        }
    }
}


extension SendBirdListViewController : GroupChannelDelegate, BaseChannelDelegate, ConnectionDelegate, UserEventDelegate {
    
    func channel(_ sender: BaseChannel, didReceive message: BaseMessage) {
        if UIApplication.shared.applicationState == .active {
            self.tableView.reloadData()
        }
    }
}

