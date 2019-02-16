//
//  MemeEditorViewController.swift
//  MemeMe Virtual Tourist
//
//  Created by Hessa Mohamed on 05/02/2019.
//  Copyright © 2019 Hessa Mohamed. All rights reserved.
//

import UIKit
import CoreData

class MemeEditorViewController: UIViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var editPhoto: Photo!
    var memedImage: MemeModel?
    
    let memeTextAttributes:[NSAttributedString.Key : Any] = [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -6]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTextfieldSetting(textField: topText)
        setTextfieldSetting(textField: bottomText)
        
        if let editPhoto = editPhoto {
            imagePickerView.image = UIImage(data: editPhoto.image!)
        }
    }
    
    func setTextfieldSetting(textField: UITextField){
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = UITextField.BorderStyle.none
        textField.textAlignment = .center
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text=="TOP" || textField.text=="BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        shareButton.isEnabled = imagePickerView.image != nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancel(_ sender: Any) {
        imagePickerView.image = nil
        topText.text="TOP"
        bottomText.text="BOTTOM"
        shareButton.isEnabled=false
        self.navigationController?.popViewController(animated: true)
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func save() {
        memedImage = MemeModel(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let memedImage = memedImage {
            appDelegate.memes.append(memedImage)
        }
    }
    
    @IBAction func Share(_ sender: AnyObject) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            (activity, completed: Bool, items, error) ->Void
            in if completed {
                self.save()
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
            else{
                print("The image was not saved")
            }
        }
        
        self.present(controller, animated: true, completion: nil)
    }
}

