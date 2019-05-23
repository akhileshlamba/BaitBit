//
//  DocumentUploadViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 28/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import FirebaseMLVision
import Firebase

protocol DocumentUploadDelegate {
    func documentData (data: Documents)
}

class DocumentUploadViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    
    var actionSheet: UIAlertController?
    var textRecognizer : VisionTextRecognizer!
    var userId : String!
    var program : Program!
    var documentName: String!
    var document : Documents? = nil
    var uploadDelegate: DocumentUploadDelegate!
    
    var databaseRef = Database.database().reference().child("images").child("users")
    var storageRef = Storage.storage()
    
    var fromCreateAdd : Bool! = false
    var imageURL : NSURL?
    
    var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var chooseCamers: UIButton!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    let defaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vision = Vision.vision()
        textRecognizer = vision.onDeviceTextRecognizer()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorView.Style.whiteLarge)
        
        if fromCreateAdd{
            chooseCamers.setTitle("Upload your Document", for: .normal)
        }
        
        loadImage()
        
        // Do any additional setup after loading the view.
    }
    
    func loadImage() {
        
        if document != nil {
            activityIndicator.center = self.view.center
            view.addSubview(activityIndicator)
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            if self.localFileExists(fileName: document!.imageLocalURL!) {
                if let localImage = self.loadImageData(fileName: document!.imageLocalURL!)
                {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.image.image = localImage
                }
            } else {
                self.storageRef.reference(forURL: document!.imageFirebaseURL!).getData(maxSize: 5 * 1024 * 1024, completion: { (data, error) in
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    if let error = error {
                        print(error.localizedDescription)
                    } else{
                        let image = UIImage(data: data!)!
                        self.saveLocalData(fileName: self.document!.imageLocalURL!, imageData: data!)
                        self.image.image = image
                    }
                })
            }
            uploadButton.isHidden = true
            
        } else {
            chooseCamers.setTitle("Upload your Document", for: .normal)
        }
        
//        if image.image == nil {
//            chooseCamers.setTitle("Upload your Document", for: .normal)
//        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if uploadDelegate != nil {
            
            // testing another method for
            //defaults.removeObject(forKey: "documentsUpload")
            if self.defaults.dictionary(forKey: "documentsUpload") != nil {
                var documentsUpload = self.defaults.dictionary(forKey: "documentsUpload") as! [String : String]
               
                if !documentsUpload.isEmpty{
                    if documentsUpload[documentName] != nil {
                        if self.localFileExists(fileName: documentsUpload[documentName]!) {
                            if let localImage = self.loadImageData(fileName: documentsUpload[documentName]!)
                            {
                                self.image.image = localImage
                                chooseCamers.setTitle("", for: .normal)
                            }
                        }
                        uploadButton.isHidden = true
                    }
                }
            }
            
        }
    }
    
    func localFileExists(fileName: String) -> Bool {
        var localFileExists = false
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            localFileExists = fileManager.fileExists(atPath: filePath)
        }
        return localFileExists
        
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        
        return image
    }
    
    func removeImageData(fileName: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var isRemoved: Bool = false
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: filePath)
                isRemoved = true
            } catch _ as NSError {
                isRemoved = false
            }
        }
        
        return isRemoved
    }
    
    func saveLocalData(fileName: String, imageData: Data) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: imageData,
                                   attributes: nil)
        }
    }
    
    @IBAction func upload(_ sender: Any) {
        if image.image == nil {
            displayErrorMessage("Please select document to upload", "Document Upload Error")
            return
        } else {
            savePhoto(image.image!)
        }
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        
        // create an actionSheet
        self.actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add a Take Photo option
        self.actionSheet!.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
            self.takePicture()
        }))
        
        // add a Choose from Album option
        self.actionSheet!.addAction(UIAlertAction(title: "Choose from Album", style: .default, handler: { (_) in
            self.chooseFromAlum()
        }))
        
        // add a Cancel option
        self.actionSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // display the actionSheet
        self.present(self.actionSheet!, animated: true, completion: nil)
        
//        if fromCreateAdd{
//            chooseCamers.setTitle("", for: .normal)
//        }
//        chooseCamers.setTitle("", for: .normal)
        
    }
    
    func displayErrorMessage(_ errorMessage: String, _ title: String){
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DocumentUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePicture() {
        let controller = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            self.displayErrorMessage("Camera unvailable", "Error")
            return
        }
        
        controller.sourceType = UIImagePickerController.SourceType.camera
        controller.allowsEditing = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func chooseFromAlum() {
        let controller = UIImagePickerController()
        
        controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        controller.allowsEditing = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let actionSheet = self.actionSheet {
            actionSheet.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - ImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking photo.")
        //imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            print("did get into the if statement")
            //            self.savePhoto(pickedImage)
            self.chooseCamers.setTitle("", for: .normal)
            self.image.image = pickedImage
            
            //            DocumentVerification.checkLicense(pickedImage: pickedImage, complete: {(result) in
            //                if result.keys.contains("Problem in recognising the image") {
            //                    self.displayErrorMessage("Problem in recognising the image", "Error")
            //                } else if result.keys.contains("Invalid License") {
            //                    self.displayErrorMessage("Invalid License", "Error")
            //                }else if result.keys.contains("Success") {
            //                    let date = result["Success"]
            //                    self.licenseExpiryDate.text = Util.setDateAsString(date: date as! NSDate)
            //                }
            //            })
            
//            let vision = Vision.vision()
//            textRecognizer = vision.onDeviceTextRecognizer()
//
//            let visionImage = VisionImage(image: pickedImage)
//            textRecognizer.process(visionImage) { result, error in
//
//                guard error == nil, let result = result else {
//                    self.displayErrorMessage("Problem in recognising the image", "Error")
//                    return
//                }
//
//                let range = NSRange(location: 0, length: result.text.utf16.count)
//                let regex = try! NSRegularExpression(pattern: "[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}")
//                
//                let matches = regex.firstMatch(in: result.text, options: [], range: range)
//
//                let substrings = result.text.split(separator: "\n")
//                if !substrings.contains("Agricultural Chemical User Permit") {
//                    self.displayErrorMessage("Invalid License", "Error")
//                    return
//                } else {
//
//                }
//            }
        }
        uploadButton.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayErrorMessage("There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePhoto(_ pickedImage: UIImage) -> Bool? {
        self.uploadButton.isEnabled = false
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // Preparing timestamp and image data
        
        if uploadDelegate != nil {
            
            // testing another method for
            
            FirestoreDAO.uploadDocument(of: FirestoreDAO.authenticatedUser.id, document: pickedImage, name: documentName, complete: {(result) in
                if result != nil {
                    self.uploadDelegate?.documentData(data: result!)
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.displayErrorMessage("Document uploaded Successfully", "Success")
                } else {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.displayErrorMessage("Problem in updating Document", "Error")
                    if self.defaults.dictionary(forKey: "documentsUpload") != nil {
                        var documentsUpload = self.defaults.dictionary(forKey: "documentsUpload") as! [String : String]
                        
                        if !documentsUpload.isEmpty{
                            if documentsUpload[self.documentName] != nil {
                                if self.localFileExists(fileName: documentsUpload[self.documentName]!) {
                                    let isRemoved = self.removeImageData(fileName: documentsUpload[self.documentName]!)
                                    print(isRemoved)
                                }
                            }
                        }
                    }
                }
                self.uploadButton.isEnabled = true
            })
//            var success : [String: [String]] = [:]
//            success["asd"] = ["asda","ewfe"]
//            self.uploadDelegate?.documentData(data: success)
        } else {
        
            FirestoreDAO.uploadDocument(of: userId, programId: program.id, document: pickedImage, name: documentName, complete: {(result) in
                self.uploadButton.isEnabled = true
                if result {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.displayErrorMessage("Document updated Successfully!", "Success")
                } else {
                    self.displayErrorMessage("Problem in updating Document", "Error")
                }
            })
        }
        
        return true
    }
    
}
