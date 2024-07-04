//
//  FilterViewController.swift
//  
//
//  Created by saboor Khan on 05/06/2024.
//

import UIKit

extension UIFactory {
    static func makeFilterViewController(presenter: FilterViewControllerPresenterType)-> FilterViewController {
        let vc = ElGrocerViewControllers.getFilterViewController()
        vc.presenter = presenter
        return vc
    }
}

class FilterViewController: UIViewController {
    private let bgView: UIView = UIFactory.makeView()
    private let lblHeading: UILabel = UIFactory.makeLabel()
    private let btnCross: UIButton = UIFactory.makeButton(with: "cross", in: .resource)
    private var searchView: FilterSheetSearchView!
    private let tblView: UITableView = UIFactory.makeTableView()
    private var bottomButtonsView: FilterBottomButtonsView!
    private let dealsHeaderView = UIFactory.makeFilterSheetTableHeaderView()
    private let brandsHeaderView = UIFactory.makeFilterSheetTableHeaderView()
    private let dealsFooterView = UIFactory.makeFilterSheetTableFooterView()
    private let brandsFooterView = UIFactory.makeFilterSheetTableFooterView()

    private var cellViewModels: [[FiltersBrandTableViewCellPresenter]] = []
    var presenter: FilterViewControllerPresenterType!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter.delegateOutputs = self
        searchView = UIFactory.makeFilterSheetSearchViewView(delegate: self)
        bottomButtonsView = UIFactory.makeFilterBottomButtonsView(delegate: self)
        registerCells()
        addViewsAndSetConstraints()
        setInitialAppearance()
        presenter.inputs?.viewWillAppear()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    func registerCells() {
        self.tblView.delegate = self
        self.tblView.dataSource = self
        if #available(iOS 15.0, *) {
            tblView.sectionHeaderTopPadding = 0.0
        }
        self.tblView.register(FiltersBrandTableViewCell.self, forCellReuseIdentifier: FiltersBrandTableViewCell.defaultIdentifier)
    }
    
    func addViewsAndSetConstraints() {
        
        self.view.addSubviews([bgView])
        self.bgView.addSubviews([lblHeading, btnCross, searchView, tblView, bottomButtonsView])
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            //lbl heading
            lblHeading.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            lblHeading.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 16),
            // btn Cross
            btnCross.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 16),
            btnCross.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            btnCross.heightAnchor.constraint(equalToConstant: 24),
            btnCross.widthAnchor.constraint(equalToConstant: 24),
            // search view
            searchView.topAnchor.constraint(equalTo: lblHeading.bottomAnchor, constant: 24),
            searchView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            // table view
            tblView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            tblView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            tblView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            tblView.bottomAnchor.constraint(equalTo: bottomButtonsView.topAnchor),
            // bottom buttons view
            bottomButtonsView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            bottomButtonsView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            bottomButtonsView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor),
            
        ])
    }
    
    func setInitialAppearance() {
        
        bgView.roundTopWithTopShadow(radius: 12)
        bgView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        lblHeading.text = localizedString("btn_filter_title", comment: "")
        lblHeading.setHeadLine5BoldDarkStyle()
        dealsHeaderView.setTitle(title: localizedString("title_deals", comment: ""))
        brandsHeaderView.setTitle(title: localizedString("Brands", comment: ""))
        btnCross.addTarget(self, action: #selector(crossButtonHandler), for: .touchUpInside)
    }
    
    @objc
    func crossButtonHandler() {
        self.dismiss(animated: true)
    }
    
    
}
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let vm = cellViewModels[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: vm.reusableIdentifier, for: indexPath) as! FiltersBrandTableViewCell
        cell.configure(viewModel: vm)
        cell.checkBoxTapped = {[weak self] brand, isSelected in
            self?.presenter.inputs?.updateBrand(brand: brand, isSelected: isSelected)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? FiltersBrandTableViewCell {
            cell.btnCheckBoxHandler()
            cell.checkBoxTapped = {[weak self] brand, isSelected in
                self?.presenter.inputs?.updateBrand(brand: brand, isSelected: isSelected)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? dealsHeaderView : brandsHeaderView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 0 ? dealsFooterView : brandsFooterView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 37
    }
    
}
// apply and bottom buttons delegate
extension FilterViewController: FilterBottomButtonsViewDelegate {
    func applyButtonPressed() {
        self.presenter.inputs?.btnApplyPressed()
        self.crossButtonHandler()
    }
    func resetButtonPressed() {
        self.presenter.inputs?.btnResetPressed()
    }
}

extension FilterViewController: FilterSheetSearchViewDelegate {
    func searchDidEnd(text: String) {
        self.presenter.inputs?.updateText(text: text)
    }
}
extension FilterViewController: FilterViewControllerPresenterOutputs {
    func getSearchText(text: String) {
        searchView.setSearchText(text: text)
    }
    
    func getCellViewModels(_ value: [[FiltersBrandTableViewCellPresenter]]) {
        cellViewModels = value
        tblView.reloadDataOnMain()
    }
}
