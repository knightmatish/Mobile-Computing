//
//  LoginController+handlers.swift
//  ChatApplication
//
//  Created by Yash on 7/8/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftOverlays

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleRegister(){
        SwiftOverlays.showBlockingWaitOverlayWithText("Regestering...")
        guard let name=nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else{
            SwiftOverlays.removeAllBlockingOverlays()
            handleCustomError(CustomError("The form contains invalid data"))
            return
        }
        if (name=="" || email=="" || password=="" || confirmPassword=="") {
            SwiftOverlays.removeAllBlockingOverlays()
            handleCustomError(CustomError("Please fill all the fields"))
            return
        }
        if (password != confirmPassword) {
            SwiftOverlays.removeAllBlockingOverlays()
            handleCustomError(CustomError("The two passwords do not match"))
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                SwiftOverlays.removeAllBlockingOverlays()
                print(error!._code)
                self.handleError(error!)
                return
            }
            
            guard let uid = authResult?.user.uid else {return}
            
            //User Autheticated Sucessfully
            print("User Autheticated Successfully")
            SwiftOverlays.removeAllBlockingOverlays()
            if let profileImage =  self.profileImageView.image, let data = profileImage.jpegData(compressionQuality: 0.1){
                let parameters: Parameters = ["access_token" : "file"]
                
                // Start Alamofire - Upload the users profile image
                Alamofire.upload(multipartFormData: { multipartFormData in
                    for (key,value) in parameters {
                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                    }
                    multipartFormData.append(data, withName: "file", fileName: "file",mimeType: "image/jpeg")
                },
                 usingThreshold: UInt64.init(),
                 to: "http://45.113.235.180:80/inceptionV3/test",
                 method: .post,
                 encodingCompletion: { encodingResult in
                    switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                if let jsonResponse = response.result.value as? [String: Any] {
                                    if let url = jsonResponse["url"] {
                                        //Sucessfully recieved and parsed response
                                        let values = ["name" : name,"email" : email,"profileImageURL" : url as! String]
                                        self.registerUserIntoDataBase(withUId: uid, values: values as [String : AnyObject])
                                    }
                                }
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                    }
                })
            }
        }
    }
    
    private func registerUserIntoDataBase(withUId uid: String, values: [String : AnyObject]){
        let ref = Database.database().reference()
        let usersRef = ref.child("users").child(uid)
        usersRef.updateChildValues(values, withCompletionBlock: { (err, dbref) in
            if err != nil {
                print(err!)
                return
            }
            print("Saved user successfully in the firebase database")
            let appUser = AppUser()
            appUser.name = values["name"] as? String
            appUser.email = values["email"] as? String
            appUser.profileImageURL = values["profileImageURL"] as? String
            self.messagesController?.setupNavBar(withAppUser: appUser)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleSelectProfileImageView(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController,animated: true)
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker =  editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker =  originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
            profileImageView.alpha = 1
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    
    
}
