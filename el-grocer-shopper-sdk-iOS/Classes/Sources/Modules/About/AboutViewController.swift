//
//  AboutViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 17.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

enum AboutControllerMode : Int {
    
    case about = 0
}

class AboutViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var controllerMode:AboutControllerMode = .about {
        didSet {
            
            switch (self.controllerMode) {
                
            case .about:
                
                self.title = localizedString("side_menu_about", comment: "")
                self.menuItem = MenuItem(title: localizedString("side_menu_about", comment: ""))
            }
        }
    }
    
    var titlesDictionary = [Int : [String]]()
    var descriptionsDictionary = [Int : [String]]()
    
    let aboutTitles = ["about_title_1", "about_title_2", "about_title_3"]
    let aboutDescriptions = ["about_description_1", "about_description_2", "about_description_3"]
    
    // MARK: Life cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titlesDictionary[AboutControllerMode.about.rawValue] = self.aboutTitles
        self.descriptionsDictionary[AboutControllerMode.about.rawValue] = self.aboutDescriptions
        
       /* addMenuButton()
        updateMenuButtonRedDotState(nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.updateMenuButtonRedDotState(_:)), name:kHelpshiftChatResponseNotificationKey, object: nil)*/
        
        registerTableCell()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsAboutFaqScreen)
        //FireBaseEventsLogger.setScreenName( kGoogleAnalyticsAboutFaqScreen , screenClass: String(describing: self.classForCoder))
    }

    // MARK: UITableView
    
    func registerTableCell() {
        
        let cellNib = UINib(nibName: "AboutCell", bundle: .resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: kAboutCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 8))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let titlesArray = self.titlesDictionary[self.controllerMode.rawValue]!
        let descriptionsArray = self.descriptionsDictionary[self.controllerMode.rawValue]!
        
        let title = localizedString(titlesArray[(indexPath as NSIndexPath).row], comment: "")
        let description = localizedString(descriptionsArray[(indexPath as NSIndexPath).row], comment: "")
        
        return AboutCell.calculateCellHeight(title, description: description, cellWidth:tableView.frame.size.width)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let titlesArray = self.titlesDictionary[self.controllerMode.rawValue]!

        return titlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kAboutCellIdentifier, for: indexPath) as! AboutCell
        
        let titlesArray = self.titlesDictionary[self.controllerMode.rawValue]!
        let descriptionsArray = self.descriptionsDictionary[self.controllerMode.rawValue]!
        
        let title = localizedString(titlesArray[(indexPath as NSIndexPath).row], comment: "")
        let description = localizedString(descriptionsArray[(indexPath as NSIndexPath).row], comment: "")
        
        cell.configure(title, description: description, position: (indexPath as NSIndexPath).row + 1)
        
        return cell
    }

}
