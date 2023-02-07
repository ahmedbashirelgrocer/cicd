//
//  ElgrocerOpenOrdersView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 18/01/2023.
//

import UIKit

class ElgrocerOpenOrdersView: UIView {
    
    var ordersCollectionView: UICollectionView?
    var openOrders: [NSDictionary] = []
    private lazy var orderStatus : OrderStatusMedule = {
        return OrderStatusMedule()
    }()

    class func loadFromNib() -> ElgrocerOpenOrdersView? {
        return self.loadFromNib(withName: "ElgrocerOpenOrdersView")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCollectionView()

    }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    fileprivate func configureCollectionView() {
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(50, 50)
        ordersCollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), collectionViewLayout: layout)
        ordersCollectionView?.delegate = self
        ordersCollectionView?.dataSource = self
        
        let CurrentOrderCollectionCell = UINib(nibName: "CurrentOrderCollectionCell", bundle: Bundle.resource)
        self.ordersCollectionView!.register(CurrentOrderCollectionCell, forCellWithReuseIdentifier: "CurrentOrderCollectionCell")
        
        
        ordersCollectionView?.isPagingEnabled = true
        ordersCollectionView?.showsHorizontalScrollIndicator = false
        ordersCollectionView?.showsVerticalScrollIndicator = false
        ordersCollectionView?.backgroundColor = .clear
      
        
        self.addSubview(ordersCollectionView!)
        self.clipsToBounds = true
        
    }
    
    // SetUpMethods
    func setViewIn(addIn view: UIView, bottomAlignView: UIView, topAlignView: UIView) {
        view.addSubview(self)
        
        
        NSLayoutConstraint.activate([
            //self.topAnchor.constraint(equalTo: topAlignView.bottomAnchor),
            self.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.rightAnchor.constraint(equalTo: view.rightAnchor),
            self.bottomAnchor.constraint(equalTo: bottomAlignView.bottomAnchor, constant: -10),
            self.heightAnchor.constraint(equalToConstant: KCurrentOrderCollectionViewHeight),
          
            ordersCollectionView!.leftAnchor.constraint(equalTo: self.leftAnchor),
            ordersCollectionView!.rightAnchor.constraint(equalTo: self.rightAnchor),
            ordersCollectionView!.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ordersCollectionView!.heightAnchor.constraint(equalToConstant: KCurrentOrderCollectionViewHeight)
        ])
        
        Thread.OnMainThread { [weak self] in
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
        self.ordersCollectionView?.reloadDataOnMainThread()
    }
    
    
    func refreshOrders() {
        
        orderStatus.orderWorkItem  = DispatchWorkItem {
            self.orderStatus.getOpenOrders { [weak self] (data) in
                switch data {
                    case .success(let response):
                        if let dataA = response["data"] as? [NSDictionary]{
                            self?.openOrders = dataA
                            DispatchQueue.main.async {
                                self?.ordersCollectionView?.reloadDataOnMainThread()
                            }
                        }
                    case .failure(let error):
                        debugPrint(error.localizedMessage)
                }
                self?.updateFrameWithData()
            }
        }
        DispatchQueue.global(qos: .background).async(execute: orderStatus.orderWorkItem!)
        
    }
    

}

// UI Helpers
extension ElgrocerOpenOrdersView {
    
    fileprivate func updateFrameWithData() {
        
        Thread.OnMainThread { [weak self] in
            let constraintA = self?.constraints.filter({$0.firstAttribute == .height})
            if (constraintA?.count ?? 0) > 0 {
                for headerViewHeightConstraint in constraintA ?? [] {
                    let maxHeight = KCurrentOrderCollectionViewHeight
                    headerViewHeightConstraint.constant = (self?.openOrders.count ?? 0) > 0 ? maxHeight:0
                }
            }
            
            UIView.animate(withDuration: 0.2) {
                self?.setNeedsLayout()
                self?.layoutIfNeeded()
            }
        }
    }

    
}

extension ElgrocerOpenOrdersView : UICollectionViewDelegate , UICollectionViewDataSource {

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return openOrders.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentOrderCollectionCell", for: indexPath) as! CurrentOrderCollectionCell
    cell.ordersPageControl.numberOfPages = collectionView.numberOfItems(inSection: 0)
    if indexPath.row < openOrders.count {
        cell.loadOrderStatusLabel(status: indexPath.row  , orderDict: openOrders[indexPath.row])
    }
    return cell
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let order = openOrders[indexPath.row]
    let key = DynamicOrderStatus.getKeyFrom(status_id: order["status_id"] as? NSNumber ?? -1000, service_id: order["retailer_service_id"]  as? NSNumber ?? -1000 , delivery_type: order["delivery_type_id"]  as? NSNumber ?? -1000)
    if let orderNumber = order["id"] as? NSNumber {
        let statusId = order["status_id"] as? NSNumber ?? -1000
        ElGrocerEventsLogger.OrderStatusCardClick(orderId: orderNumber.stringValue, statusID: statusId.stringValue)
    }
    let status_id : DynamicOrderStatus? = ElGrocerUtility.sharedInstance.appConfigData.orderStatus[key]
    if status_id?.getStatusKeyLogic().status_id.intValue == OrderStatus.inEdit.rawValue {
        if let topVc = UIApplication.topViewController(){
            let navigator = OrderNavigationHandler.init(orderId: order["id"] as! NSNumber, topVc: topVc, processType: .editWithOutPopUp)
            navigator.startEditNavigationProcess { (isNavigationDone) in
                debugPrint("Navigation Completed")
            }
        }
        
        return
    }
    
    let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
    orderConfirmationController.orderDict = order
    orderConfirmationController.isNeedToRemoveActiveBasket = false
    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
    navigationController.hideSeparationLine()
    navigationController.viewControllers = [orderConfirmationController]
   // orderConfirmationController.modalPresentationStyle = .fullScreen
    navigationController.modalPresentationStyle = .fullScreen
    if let topVc = UIApplication.topViewController(){
        topVc.navigationController?.present(navigationController, animated: true, completion: {  })
    }
    
}

func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let currentCell = cell as? CurrentOrderCollectionCell {
        currentCell.ordersPageControl.currentPage = indexPath.row
    }
}
func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard indexPath.row < openOrders.count else {return}
    let order = openOrders[indexPath.row]
    if let orderNumber = order["id"] as? NSNumber {
        let statusID = order["status_id"] as? NSNumber ?? -1000
        ElGrocerEventsLogger.trackOrderStatusCardView(orderId: orderNumber.stringValue, statusID: statusID.stringValue)
    }
}

}
extension ElgrocerOpenOrdersView : UICollectionViewDelegateFlowLayout {

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    
    
    var cellSize = CGSize(width: collectionView.frame.size.width , height: collectionView.frame.height)
    
    
    if cellSize.width > self.frame.width {
        cellSize.width = self.frame.width
    }
    
    if cellSize.height > self.frame.height {
        cellSize.height = self.frame.height
    }
    debugPrint("cell Size is : \(cellSize)")
    return cellSize
}

}
