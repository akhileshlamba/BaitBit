//
//  BaitDetailsViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 25/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class BaitDetailsViewController: UIViewController {
    
    var bait: Bait!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var baitImageView: UIImageView!
    @IBOutlet weak var baitDetailsTitleView: UIView!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var baitImageContainerView: UIView!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var locationTableView: UITableView!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    
    var actionSheet: UIAlertController?
    
    let dataSource = ["Latitude", "Longitude"]
    let imageDataSource = ["latitude", "longitude"]
    var valueDataSource = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setFields()
        self.loadBaitImage()
        
        self.locationTableView.delegate = self
        self.locationTableView.dataSource = self
        self.locationTableView.tableFooterView = UIView(frame: .zero)
        
        self.valueDataSource.append("\(self.bait.latitude)")
        self.valueDataSource.append("\(self.bait.longitude)")

        // Do any additional setup after loading the view.
    }
    
    func setFields() {
        if self.bait.numberOfDaysBeforeDue > 1 {
            self.dueLabel.text = "Due in \(self.bait.numberOfDaysBeforeDue) days"
        } else if self.bait.numberOfDaysBeforeDue == 1 {
            self.dueLabel.text = "Due tomorrow"
        } else if self.bait.numberOfDaysBeforeDue == 0 {
            self.dueLabel.text = "Due today"
        } else {
            self.dueLabel.text = "\(-self.bait.numberOfDaysBeforeDue) day(s) overdue"
        }
        if self.bait.isRemoved {
            self.dueLabel.text = "This bait was removed."
            self.removeButton.isHidden = true
        }
        self.durationLabel.text = self.bait.durationFormatted
        self.startDateLabel.text = "Laid date: \(Util.setDateAsString(date: self.bait.laidDate))"
    }

    @IBAction func dragDownFromTop(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.edges == .top {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadBaitImage() {
        if self.bait.isRemoved {
            self.takePhotoButton.isHidden = true
        } else if self.bait.photoPath == nil {
            self.takePhotoButton.setTitle("Take a photo", for: .normal)
        } else {
            self.takePhotoButton.setTitle("", for: .normal)
            self.loading.startAnimating()
            FirestoreDAO.fetchImage(for: self.bait) { (image) in
                self.loading.stopAnimating()
                self.baitImageView.image = image
            }

        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "RemoveBaitSegue" {
            let controller = segue.destination as! RemoveBaitTableViewController
            controller.bait = self.bait
        }
    }
    

}

extension BaitDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddBaitCell", for: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.row]
        cell.detailTextLabel?.text = self.valueDataSource[indexPath.row]
        cell.imageView?.image = UIImage(named: self.imageDataSource[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension BaitDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func displayPhotoOptions(_ sender: Any) {
    // create an actionSheet
    self.actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // add a Take Photo option
    self.actionSheet!.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
    self.takePhoto()
    }))
    
    // add a Choose from Album option
    self.actionSheet!.addAction(UIAlertAction(title: "Choose from Album", style: .default, handler: { (_) in
    self.chooseFromAlum()
    }))
    
    // add a Cancel option
    self.actionSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    // display the actionSheet
    self.present(self.actionSheet!, animated: true, completion: nil)
    }
    
    func takePhoto() {
        let controller = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            Util.displayErrorMessage(view: self, "Camera unvailable", "Error")
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
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.loading.startAnimating()
            FirestoreDAO.updateImageAndData(for: self.bait, image: pickedImage) { (success) in
                self.loading.stopAnimating()
                if success {
                    print("did get into the if statement")
                    self.baitImageView.image = pickedImage
                } else {
                    Util.displayErrorMessage(view: self, "Fail to update photo", "Error")
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Util.displayErrorMessage(view: self, "There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
}
