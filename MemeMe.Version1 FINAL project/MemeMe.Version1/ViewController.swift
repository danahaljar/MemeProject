//
//  ViewController.swift
//  MemeMe.Version1
//
//  Created by Dana AlJar on 25/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

struct Meme {
    var topText: String = ""
    var bottomText: String = ""
    var originalImage: UIImage?
    var memedImage: UIImage?
}
class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UITextFieldDelegate{

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!

    @IBOutlet var naviBar: UINavigationBar!
    @IBOutlet var shareButton: UIBarButtonItem!
    var isUsingBottomDefaultText:Bool = true
    var isUsingTopDefaultText:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
            setTextAttributes(textField: topText, str: "TOP")
            setTextAttributes(textField: bottomText, str: "BOTTOM")
        shareButton.isEnabled = false
        }
        // Do any additional setup after loading the view, typically from a nib.
    //setup when the view appears
    override func viewWillAppear(_ animated: Bool)
    {
        //To check if the camera is available
         cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()

    }
    //set when the view dissappears
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
   
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
        
    }

    
    
    //picking an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
            topText.isHidden = false
            bottomText.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
 
     // pick an image from album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
         chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    
   // pick an image from camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    
    }
  
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    // text attributes
    let memeTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 38)!,
        NSAttributedString.Key.strokeWidth : NSNumber(value: -3.0)
    ]

    func setTextAttributes(textField : UITextField, str : String) {
        textField.text = str
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self

    }
    
    
    // hiding the keyboard after clicking "Return"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // subscribing to keyboard notifications (event listener)
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // unsubscribing from keyboard notifications (event listener)
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // showing the keyboard and raising the view
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder{
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    }
    //keyboard is hidden when raising the view down
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomText.isFirstResponder{
        view.frame.origin.y = 0
        }
    }
    
    // accurate raising measurements of the keyboard
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    // generating the memed image
    func generateMemedImage() -> UIImage {
        toolBar.isHidden = true
        naviBar.isHidden = true

        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBar.isHidden = false
        naviBar.isHidden = false
        return memedImage
    }
    func save() {
        // Create the meme
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    // sharing the memed image
    @IBAction func shareImage(_ sender: Any) {
        //generate meme and present the activity view
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
        activityController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }else{
             print("cancelled")
                return 
                }
                
            }
            present(activityController,animated: true,completion: nil)
        }
  
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == bottomText && isUsingBottomDefaultText {
            textField.text = ""
            isUsingBottomDefaultText = false
        }
        
        if textField == topText && isUsingTopDefaultText {
            textField.text = ""
            isUsingTopDefaultText = false
        }
    }
    
    }
    


