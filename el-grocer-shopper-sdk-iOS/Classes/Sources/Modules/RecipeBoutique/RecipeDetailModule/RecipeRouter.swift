//
//  RecipeRouter.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 24/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class RecipeRouter: PresenterToRouterRecipeProtocol {
    
    
//    // MARK: Static methods
//    static func createModule() -> UINavigationController {
//
//       elDebugPrint("QuotesRouter creates the Quotes module.")
//        let viewController = QuotesViewController()
//        let navigationController = UINavigationController(rootViewController: viewController)
//
//        let presenter: ViewToPresenterQuotesProtocol & InteractorToPresenterQuotesProtocol = QuotesPresenter()
//
//        viewController.presenter = presenter
//        viewController.presenter?.router = QuotesRouter()
//        viewController.presenter?.view = viewController
//        viewController.presenter?.interactor = QuotesInteractor()
//        viewController.presenter?.interactor?.presenter = presenter
//        
//        return navigationController
//    }
//
//    // MARK: - Navigation
//    func pushToQuoteDetail(on view: PresenterToViewQuotesProtocol, with quote: Quote) {
//       elDebugPrint("QuotesRouter is instructed to push QuoteDetailViewController onto the navigation stack.")
//        let quoteDetailViewController = QuoteDetailRouter.createModule(with: quote)
//
//        let viewController = view as! QuotesViewController
//        viewController.navigationController?
//            .pushViewController(quoteDetailViewController, animated: true)
//
//    }
    
}
