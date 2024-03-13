//
//  FAQViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Chatha on 2/7/18.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , NavigationBarProtocol {
    
    var searchBarView: FAQSearchView?
    var searchQuestionArray : [String] = []
    var filteredQuestionArray: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    
    var faqTitles: [String] = []//["faq_title_1", "faq_title_2", "faq_title_3","faq_title_4", "faq_title_5", "faq_title_6","faq_title_7", "faq_title_8", "faq_title_9","faq_title_10", "faq_title_11", "faq_title_12","faq_title_13", "faq_title_14", "faq_title_15","faq_title_16", "faq_title_17"]
    
    var faqDescriptions: [String] = [] //["faq_description_1", "faq_description_2", "faq_description_3", "faq_description_4", "faq_description_5", "faq_description_6", "faq_description_7", "faq_description_8", "faq_description_9", "faq_description_10", "faq_description_11", "faq_description_12", "faq_description_13", "faq_description_14", "faq_description_15", "faq_description_16", "faq_description_17"]

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
       // Do any additional setup after loading the view.
        
        self.title = localizedString("setting_faq", comment: "")
        
        let maxlimit =  sdkManager.isSmileSDK ? 46 : 55
        
        for index in (1..<maxlimit) {
            print(index)
            faqTitles.append("faq_title_\(index)")
            faqDescriptions.append("faq_description_\(index)")
        }
        
        
        //addBackButton()
        populateQuestionArray()
        
        self.registerTableCell()
        
    }
    
    func populateQuestionArray() {
        for title in self.faqTitles {
            self.searchQuestionArray.append(localizedString(title, comment: ""))
            self.filteredQuestionArray.append(localizedString(title, comment: ""))
        }
    }
                                
    func filterQuestionArray(searchText:String) {
        if searchText == "" {
            self.filteredQuestionArray = searchQuestionArray
        }else {
            self.filteredQuestionArray = searchQuestionArray.filter { term in
                return term.lowercased().contains(searchText.lowercased())
            }
        }
       
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController is ElGrocerNavigationController {

            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            //(self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        }
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.FAQ.rawValue, screenClass: String(describing: self.classForCoder))

        searchBarView = Bundle.resource.loadNibNamed("FAQSearchView", owner: self, options: nil)![0] as? FAQSearchView
        searchBarView?.delegate = self
        //self.tableView.tableHeaderView = searchBarView
    }
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    // MARK: UITableView
    
    func registerTableCell() {
        
        let cellNib = UINib(nibName: "FaqCell", bundle: Bundle.resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: kFAQCellIdentifier)
        self.tableView.backgroundColor = .textfieldBackgroundColor()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let title = localizedString(self.faqTitles[(indexPath as NSIndexPath).row], comment: "")
        var cellHeight = FaqCell.calculateCellHeight(title, cellWidth: tableView.frame.size.width)
        
        if title == localizedString("faq_title_11", comment: "") {
           cellHeight = cellHeight + 10
        }
        
        if cellHeight > kFAQCellHeight {
            return cellHeight
        }else{
            return kFAQCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.filteredQuestionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kFAQCellIdentifier, for: indexPath) as! FaqCell
        cell.backgroundColor = .navigationBarWhiteColor()
        //let title = localizedString(self.faqTitles[(indexPath as NSIndexPath).row], comment: "")
        let title = filteredQuestionArray[indexPath.row]
        cell.configureCellWithTitle(title)
        
        return cell
    }
    
    //MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var titleLocString = self.filteredQuestionArray[(indexPath as NSIndexPath).row]
        
       let titleFromFAQS =  faqTitles.filter { title in
            localizedString(title, comment: "") == titleLocString
        }
        titleLocString = titleFromFAQS[0]
        
        let title = localizedString(titleLocString, comment: "")
        
        let desciptionLocString = titleLocString.replacingOccurrences(of: "faq_title_", with: "faq_description_")
        let descritpon = localizedString(desciptionLocString, comment: "")
        
        let questionVC = ElGrocerViewControllers.questionViewController()
        questionVC.titleStr = title
        questionVC.descriptionStr = descritpon
        self.navigationController?.pushViewController(questionVC, animated: true)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBarView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 112
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FAQViewController: searchBarDelegate {
    
    func performSerach(searchString: String) {
        //print("searchString",searchString)
        filterQuestionArray(searchText: searchString)
    }
    
}
