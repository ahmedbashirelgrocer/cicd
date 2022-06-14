//
//  ShopByCategoriesViewController.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 31/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class ShopByCategoriesViewController: UIViewController {
    
    @IBOutlet var categoryCollectionView: UICollectionView!{
        didSet{
            categoryCollectionView.backgroundColor = .textfieldBackgroundColor()
        }
    }
    @IBOutlet var headerView: UIView!//GenericHyperMrketHeader!

    lazy var searchBarHeader : GenericHyperMarketHeader = {
        let searchHeader = GenericHyperMarketHeader.loadFromNib()
        return searchHeader!
    }()
    var storeCategoryA : [StoreType] = []
    override func viewWillLayoutSubviews() {
        setTableViewHeader()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegates()
        setNavigationBarAppearance()
        setDelegatesCollection()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarAppearance()
    }
    
    func setDelegates() {
        setNavigationBarAppearence()
        setTableViewHeader()
    }
    
    override func rightBackButtonClicked() {
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
       
    }
    
    func setDelegatesCollection(){
        
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        
        let HomeMainCategoryCollectionCell = UINib(nibName: "HomeMainCategoryCollectionCell", bundle: Bundle(for: HomeMainCategoryCollectionCell.self))
        self.categoryCollectionView.register(HomeMainCategoryCollectionCell, forCellWithReuseIdentifier: "HomeMainCategoryCollectionCell")
        
    }
  
    func setNavigationBarAppearance() {
        
        //self.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        hidetabbar()
        
        self.view.backgroundColor = .textfieldBackgroundColor()
        self.navigationItem.hidesBackButton = true
        self.title = NSLocalizedString("txt_Shop_by_store_category", comment: "")
        self.addRightCrossButton(true)
//        self.addBackButton(isGreen: false)
        
        if let controller = self.navigationController as? ElGrocerNavigationController {
            
            controller.setLogoHidden(true)
            controller.setGreenBackgroundColor()
            controller.setBackButtonHidden(true)
            controller.setLocationHidden(true)
            controller.setChatButtonHidden(true)
            controller.setNavBarHidden(false)
            controller.setWhiteTitleColor()
        }
    }

    func setNavigationBarAppearence(){
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setNavBarHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.setWhiteTitleColor()
            
            self.navigationItem.hidesBackButton = true
            self.title = "Shop by store category"
            self.addRightCrossButton(true)
        }
    }
    
    func setTableViewHeader() {
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            self.searchBarHeader.txtSearchBar.placeholder = NSLocalizedString("search_placeholder_view_allstore_categories", comment: "")
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            self.searchBarHeader.setInitialUI(type: .specialityStore)
            self.searchBarHeader.frame = CGRect(x: 0, y: 0, width: self.headerView.frame.width, height: self.searchBarHeader.headerMinimumHeight)
            self.headerView.addSubview(self.searchBarHeader)
        })
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
extension ShopByCategoriesViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storeCategoryA.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMainCategoryCollectionCell", for: indexPath) as! HomeMainCategoryCollectionCell
    
        let type = storeCategoryA[indexPath.item]
        cell.backgroundColor = .navigationBarWhiteColor()
        cell.configureCell(cellType: .Categories, title: type.name ?? "", image: type.imageUrl ?? "", false, data: type)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        let data = storeCategoryA[indexPath.item]
        let vc = ElGrocerViewControllers.getSpecialtyStoresGroceryViewController()
        vc.controllerTitle = data.name ?? ""
        vc.controllerType = .viewAllStoresWithBack
        vc.groceryArray = HomePageData.shared.storyTypeBaseDataDict[data.storeTypeid] ?? []
        vc.availableStoreTypeA = storeCategoryA
        // vc.selectStoreType = data // https://elgrocerdxb.atlassian.net/browse/EG-1408
        FireBaseEventsLogger.trackHomeTileClicked(tileId: "\(data.storeTypeid)", tileName: data.name!, tileType: "Store Category", nextScreen: vc)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
extension ShopByCategoriesViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = ScreenSize.SCREEN_WIDTH
        let spaceBetweenCells: CGFloat = 16
        let cellSize = (screenSize / 3) - 24 //- (spaceBetweenCells * 4)
        let finalCellSize = cellSize
        return CGSize(width: finalCellSize, height: finalCellSize)
    }
}
//extension ShopByCategoriesViewController: UIScrollViewDelegate{
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if scrollView.contentOffset.y > 0
//        {
//            scrollView.layoutIfNeeded()
//            if var headerFrame = headerView.layer.frame as? CGRect{
//                headerFrame.origin.y = scrollView.contentOffset.y
//                headerFrame.size.height = searchBarHeader.headerMinimumHeight
//
//                headerView.layer.frame = headerFrame
//            }
//        }
//    }
//}
