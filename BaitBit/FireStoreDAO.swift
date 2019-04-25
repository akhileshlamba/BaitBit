//
//  FirestoreDAO.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import Firebase

class FirestoreDAO: NSObject {
    static let usersRef = Firestore.firestore().collection("users")
    static var user: [String: Any]?
    
    static let storageRef = Storage.storage().reference()
    
    
    
    static func getUserData(from userId: String, complete: (([String: Any]) -> Void)?) {
        let user = usersRef.document(userId)
        user.getDocument(completion: {(result, error) in
            if error != nil {
                
            } else {
                self.user = result?.data()
                self.user!["id"] = (result?.documentID)!
                if complete != nil {
                    complete!(self.user!)
                }
            }
        })
    }
    
    static func updateNotificationDetails(with id: String, details: [String: Any]) {
        let notificationsRef = Firestore.firestore().collection("notifications").document(details["id"] as! String)
        notificationsRef.updateData([
            "overDue" : details["overDue"],
            "dueSoon" : details["dueSoon"],
            "documentation" : details["documentation"]
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    static func updateLicenseImageAndData(of userWithId: [String: Any], image: UIImage, licenseDate: String, complete: @escaping (Bool) -> Void) {
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.1)!
        
        let imageRef = storageRef.child("\(userWithId["id"] ?? "")/License/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (metaData, error) in
            if error != nil {
                complete(false)
            } else {
                imageRef.downloadURL(completion: {(url, error) in
                    if error != nil {
                        complete(false)
                    }else{
                        if let imageURL = url?.absoluteString{
                            let userRef = usersRef.document(userWithId["id"] as! String)
                            userRef.updateData([
                                "licensePath": imageURL,
                                "licenseExpiryDate": licenseDate
                            ]) {
                                err in
                                if err != nil {
                                    complete(false)
                                } else {
                                    self.user = userWithId
                                    self.user!["licensePath"] = imageURL
                                    self.user!["licenseExpiryDate"] = licenseDate
                                    complete(true)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    static func updateImageAndData(for bait: Bait, image: UIImage, complete: @escaping (Bool) -> Void) {
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.1)!
        
        let imageRef = storageRef.child("\(self.user!["id"] ?? "")/Bait/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (metaData, error) in
            if error != nil {
                complete(false)
            } else {
                imageRef.downloadURL(completion: {(url, error) in
                    if error != nil {
                        complete(false)
                    } else {
                        if let imageURL = url?.absoluteString {
                            let userRef = usersRef.document(self.user!["id"] as! String)
                            userRef.updateData([
                                "programs": [
                                    bait.program!.id: [
                                        "baits": [
                                            bait.id: [
                                                "photoPath": "\(date)",
                                                "photoURL": imageURL
                                            ]
                                        ]
                                    ]
                                ]
                            ]) {
                                err in
                                if err != nil {
                                    complete(false)
                                } else {
                                    self.getUserData(from: self.user!["id"] as! String, complete: nil)
                                    complete(true)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    static func reloadUserDataFromFirebase(complete: @escaping ([String: Any]) -> Void) {
        let username = user!["username"] as! String
        let query = usersRef.whereField("username", isEqualTo: username)

        query.getDocuments(completion: {(document, error) in
            self.user = (document?.documents[0].data())!
            self.user!["id"] = (document?.documents[0].documentID)!
            complete(self.user!)
        })
    }
    
    static func getAllPrograms(complete: @escaping ([Program]) -> Void) {
        var programList = [Program]()
        if self.user == nil {
            reloadUserDataFromFirebase { (user) in
                if let programs = user["programs"] as? NSDictionary {
                    for elem in programs {
                        let id = elem.key as! String
                        let p = elem.value as! NSDictionary
                        let baitType = p["baitType"] as! String
                        let species = p["species"] as! String
                        let startDate = p["startDate"] as! String
                        let isActive = p["isActive"] as! Bool
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "MMM dd, yyyy"
                        let program:Program = Program(id: id,
                                                      baitType: baitType,
                                                      species: species,
                                                      startDate: dateformatter.date(from: startDate) as NSDate?,
                                                      isActive: isActive)
                        program.addToBaits(baits: getAllBaits(for: program))
                        programList.append(program)
                    }
                }
                complete(programList)
            }
        } else {
            if let programs = self.user!["programs"] as? NSDictionary {
                for elem in programs {
                    let id = elem.key as! String
                    let p = elem.value as! NSDictionary
                    let baitType = p["baitType"] as! String
                    let species = p["species"] as! String
                    let startDate = p["startDate"] as! String
                    let isActive = p["isActive"] as! Bool
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "MMM dd, yyyy"
                    let program:Program = Program(id: id,
                                                  baitType: baitType,
                                                  species: species,
                                                  startDate: dateformatter.date(from: startDate) as NSDate?,
                                                  isActive: isActive)
                    program.addToBaits(baits: getAllBaits(for: program))
                    programList.append(program)
                }
            }
            complete(programList)
        }
    }
    
    static func getAllBaits(for program: Program) -> [Bait] {
        var baitList = [Bait]()
        
        if let programs = user!["programs"] as? NSDictionary {
            let p = programs[program.id] as! NSDictionary
            if let baits = p["baits"] as? NSDictionary {
                for elem in baits {
                    let id = elem.key as! String
                    let b = elem.value as! NSDictionary
                    let laidDate = b["laidDate"] as! String
                    let latitude = b["latitude"] as! Double
                    let longitude = b["longitude"] as! Double
                    let photoPath = b["photoPath"] as! String
                    let isRemoved = b["isRemoved"] as! Bool
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "MMM dd, yyyy"
                    let bait = Bait(id: id,
                                    laidDate: dateformatter.date(from: laidDate)! as NSDate,
                                    latitude: latitude,
                                    longitude: longitude,
                                    photoPath: photoPath,
                                    program: program,
                                    isRemoved: isRemoved)
                    baitList.append(bait)
                }
            }
        }
        return baitList
    }
    
    static func createOrUpdate(program: Program) {
        let query = usersRef.whereField("username", isEqualTo: user!["username"] as! String)
        query.getDocuments(completion: {(document, error) in
            let docID = document?.documents[0].documentID
            print("docID: \(docID)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            
            usersRef.document(docID!).setData(
                [
                    "programs": [
                        program.id: [
                            "baitType": program.baitType,
                            "species": program.species,
                            "startDate": dateFormatter.string(from: program.startDate as Date),
                            "isActive": program.isActive,
                            "baits": [:]
                        ]
                    ]
                ]
                , merge: true, completion: { (err) in
                    if let err = err {
                        print("Error adding program: \(err)")
                    }
                    usersRef.document(docID!).getDocument(completion: { (document, error) in
                        self.user = document?.data()
                        self.user!["id"] = docID!
                    })
            })

//                ref = self.db.collection("users").addDocument(data: [
//                    "username": username,
//                    "password": password,
//                    "licenseExpiryDate": licenseExpiryDate
//                ]) { err in
//                    if let err = err {
//                        print("Error adding document: \(err)")
//                    } else {
//                        self.userId = ref.documentID
//                        print("Document added with ID: \(ref!.documentID)")
//                        let success = self.savePhoto(image)
//                        if success ?? false {
//                            self.navigationController?.popViewController(animated: true)
//                        }
//                    }
//                }
            
        })
    }
    
    static func createOrUpdate(bait: Bait, for program: Program) {
        program.addToBaits(bait: bait)
    }
    
    static func delete(program: Program) {
        
    }
    
    static func delete(bait: Bait, for program: Program) {
        
    }
}
