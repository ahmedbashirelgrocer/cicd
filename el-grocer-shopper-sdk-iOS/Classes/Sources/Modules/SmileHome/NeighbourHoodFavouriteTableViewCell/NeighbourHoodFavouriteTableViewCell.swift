//
//  NeighbourHoodFavouriteTableViewCell.swift
//  Adyen
//
//  Created by Abdul Saboor on 28/02/2024.
//

import UIKit

class NeighbourHoodFavouriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bGView: UIView!
    @IBOutlet var lblHeadingTopConstraint: NSLayoutConstraint!
    @IBOutlet var lblHeading: UILabel! {
        didSet {
            lblHeading.setHeadLine5MediumDarkStyle()
            lblHeading.text = localizedString("Neighborhood Favorites", comment: "")
        }
    }
    @IBOutlet var collectionView: UICollectionView!
    
    typealias tapped = (_ isForFavourite: Bool, _ grocery: Grocery,_ index: Int)-> Void
    var groceryTapped: tapped?
    var isForFavourite: Bool = false
    var groceryA: [Grocery] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpCollectionView()
        registerCells()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func registerCells() {
        let FavouriteGroceryCollectionCell = UINib(nibName: "NeighbourHoodFavouriteGroceryCollectionCell", bundle: Bundle.resource)
        self.collectionView.register(FavouriteGroceryCollectionCell, forCellWithReuseIdentifier: "NeighbourHoodFavouriteGroceryCollectionCell")
    }
    
    func setUpCollectionView() {
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 88, height: 88)
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            let edgeInset:CGFloat =  16
            layout.sectionInset = UIEdgeInsets(top: 0, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
        self.collectionView.semanticContentAttribute = ElGrocerUtility.sharedInstance.isArabicSelected() ? .forceRightToLeft : .forceLeftToRight
    }
    
    func setupUI (isForFavourite: Bool) {
        if isForFavourite {
            self.lblHeadingTopConstraint.constant = 16
            self.lblHeading.text = localizedString("lbl_title_neighborhood_fav", comment: "")
            self.bGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            self.contentView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            self.collectionView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        }else {
            self.lblHeadingTopConstraint.constant = 16
            self.lblHeading.text = localizedString("lbl_title_one_click_reorder", comment: "")
            self.bGView.backgroundColor = ApplicationTheme.currentTheme.oneClickReorderBGColor
            self.contentView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            self.collectionView.backgroundColor = ApplicationTheme.currentTheme.oneClickReorderBGColor
        }
    }
    
    func configureCell(groceryA: [Grocery], isForFavourite: Bool) {
        
        self.isForFavourite = isForFavourite
        self.groceryA = groceryA
        self.setupUI(isForFavourite: isForFavourite)
        self.collectionView.reloadData()
        
    }
}

extension NeighbourHoodFavouriteTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groceryA.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NeighbourHoodFavouriteGroceryCollectionCell", for: indexPath) as! NeighbourHoodFavouriteGroceryCollectionCell
        
        cell.configureCell(grocery: self.groceryA[indexPath.row], isForFavourite: self.isForFavourite)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let groceryTapped = self.groceryTapped {
            groceryTapped(isForFavourite, groceryA[indexPath.row], indexPath.row)
        }
    }
}
extension NeighbourHoodFavouriteTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 88, height: 88)
    }
}
