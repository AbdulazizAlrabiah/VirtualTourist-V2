//
//  CreateMemeViewController.swift
//  VirtualTourist
//
//  Created by aziz on 02/07/2019.
//  Copyright © 2019 Aziz. All rights reserved.
//

import UIKit

class CreateMemeVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -3.0
    ]
    
    var meme: UIImage!
    var image: UIImage!
    var createdMeme: ((UIImage) -> Void)?
    
    override var prefersStatusBarHidden: Bool { return true}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(textField: topLabel)
        setTitle(textField: bottomLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imagePickerView.image = image
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    func setTitle(textField: UITextField){
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    @IBAction func shareButton(_ sender: Any) {
        
        self.meme = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        activityView.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed){
                self.saveImageAndDismiss()
            }
        }
        present(activityView, animated: true)
    }
    
    @IBAction func saveImageButton(_ sender: Any) {
        
        self.meme = generateMemedImage()
        saveImageAndDismiss()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Keyboard setup
    func getKeyboardHieght(notification: Notification) -> CGFloat{
        
        let userInformation = notification.userInfo
        let keyboardSize = userInformation![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(notification: Notification){
        if (bottomLabel.isEditing){
            view.frame.origin.y -= getKeyboardHieght(notification: notification)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Save and generate the meme
    func generateMemedImage() -> UIImage {
        
        hideToolBars(hide: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideToolBars(hide: false)
        return memedImage
    }
    
    func saveImageAndDismiss() {
        
        self.createdMeme!(meme)
        self.dismiss(animated: true, completion: nil)
    }
    
    func hideToolBars(hide: Bool){
        
        navigationBar.isHidden = hide
        toolBar.isHidden = hide
    }
}

//MARK: Extension for the text field delegate
extension CreateMemeVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.clearsOnBeginEditing = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

