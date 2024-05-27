//
//  File.swift
//  
//
//  Created by M Abubaker Majeed on 25/05/2024.
//

import Foundation


extension ElGrocerApi {
    
   
    // MARK: Configuration
      
      func getMasterAppConfig( completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
          
          NetworkCall.get(ElGrocerApiEndpoint.GetConfiguationAndAdSlot.rawValue, parameters: nil , progress: { (progress) in
          }, success: { (operation  , response) in
              
              guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.parsingError()))
                  return
              }
              completionHandler(Either.success(response))
              
          }) { (operation  , error) in
              let errorToParse = ElGrocerError(error: error as NSError)
              if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                  completionHandler(Either.failure(errorToParse))
              }
              
          }
      }
    
    
    
    
    
}
