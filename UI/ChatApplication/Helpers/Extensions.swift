//  Extensions.swift
//  ChatApplication
//
//  Created by Yash, Nitish, Nakia, Suraj and Krishna on 8/8/19.
//  Copyright © 2019 Yash, Nitish, Nakia, Suraj and Krishna. All rights reserved.
//

import UIKit
import Firebase

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageFromCache(withURLString urlString:String){
        self.image = nil
        //Check if the required image exists in the cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString){
            //Return the image from the cache
            self.image = cachedImage
            return
        }
        
        //The reqired image is not present in the cache -> download the required image
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                //Error while downloading the image
                print("Error while downlaoding the profile images of the users")
                print(error!)
                return
            }
            //Download successful
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
}

extension UICollectionView {
    func scrollToBottom() {
        var indexPath:IndexPath?
        if self.numberOfSections > 1 {
            let lastSection = self.numberOfSections - 1
            indexPath = IndexPath(item: numberOfItems(inSection: lastSection)-1, section: lastSection)
        } else if numberOfItems(inSection: 0) > 0 && numberOfSections == 1 {
            indexPath = IndexPath(item: numberOfItems(inSection: 0)-1, section: 0)
        }
        if let indexPath = indexPath {
            scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The username is already in use"
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again"
        case .userDisabled:
            return "Your account has been disabled."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid username that only contains alphabets and numbers"
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Your password is incorrect. Please try again."
        default:
            return "Unknown error occurred"
        }
    }
}


extension UIViewController{

    func handleError(_ error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            print(errorCode.errorMessage)
            let alert = UIAlertController(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //Custom Errors
    struct CustomError: Error {
        let message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        public var localizedDescription: String {
            return message
        }
    }
    
    func handleCustomError(_ error: CustomError) {
        print(error.message)
        
        let alert = UIAlertController(title: "Error", message: error.message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}



