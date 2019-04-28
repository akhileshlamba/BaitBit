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

    static var authenticatedUser: User!
    static var notificationDetails = [String: Any]()

    static let storageRef = Storage.storage().reference()


    static func authenticateUser (with username: String, password: String, complete: @escaping (String) -> Void) {
        var query = usersRef.whereField("username", isEqualTo: username)
        query.getDocuments(completion: {(document, error) in
            if (document?.documents.isEmpty ?? nil)! {
                complete("Invalid username")
            } else {
                if document?.documents[0].data()["password"] as! String != password {
                    complete("Invalid password")
                } else {
                    let userInfo = (document?.documents[0].data())!

                    FirestoreDAO.setUserData(with: userInfo as NSDictionary, id: document?.documents[0].documentID as! String)

                    let notificationsRef = Firestore.firestore().collection("notifications")
                    query = notificationsRef.whereField("notificationOfUser", isEqualTo: document?.documents[0].documentID)

                    query.getDocuments(completion: {(result, error) in
                        if ((result?.documents.isEmpty)!) {
                            complete("Fetch Notification")
                        } else {
                            self.notificationDetails = (result?.documents[0].data())!
                            self.notificationDetails["id"] = (result?.documents[0].documentID)!
                            
                            complete("Success")
                        }
                    })
                }
            }
        })
    }

    static func registerUser(with user: User, complete: @escaping ([String: User?]) -> Void) {
        let query = usersRef.whereField("username", isEqualTo: user.username)

        query.getDocuments(completion: {(document, error) in
            if (document?.documents.isEmpty ?? nil)! {
                var ref: DocumentReference!
                ref = usersRef.addDocument(data: [
                    "username": user.username,
                    "password": user.password
                ]) { err in
                    if err != nil {
                        let user : User!
                        user = nil
                        complete(["Save Error" : user])
                    } else {
                        self.authenticatedUser = user
                        self.authenticatedUser.setId(id: ref.documentID)

                        Firestore.firestore().collection("notifications").addDocument(data: [
                            "overDue" : false,
                            "dueSoon" : false,
                            "documentation" : false,
                            "notificationOfUser" : ref!.documentID,
                            "license" : false
                        ]) { err in
                            if err != nil {
                                let user : User!
                                user = nil
                                complete(["Error in saving notification details" : user])
                            } else {
                                complete(["Success" : self.authenticatedUser])
                            }
                        }
                    }
                }
            } else {
                
                complete(["Duplicate User" : nil])
            }
        })

    }

    static func setUserData(with userInfo: NSDictionary, id: String) {
        self.authenticatedUser = User(
            username: userInfo["username"] as! String,
            password: userInfo["password"] as! String
        )
        
        if userInfo["licensePath"] != nil {
            self.authenticatedUser.setLicensePath(path: (userInfo["licensePath"] as? String)!)
            self.authenticatedUser.setLicenseExpiryDate(date: Util.convertStringToDate(string: (userInfo["licenseExpiryDate"] as! String))!)
        }

        self.authenticatedUser.setId(id: id)

        let programs = userInfo["programs"] as? NSDictionary

        if programs != nil {
            for elem in programs! {
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
                self.authenticatedUser.addToPrograms(program: program)
                
                if p["baits"] != nil {
                    program.addToBaits(baits: getAllBaitsss(for: p["baits"] as! NSDictionary, program: program))
                } else {
                    program.baits = [:]
                }
            }

            print(self.authenticatedUser)
        }
    }

    func getPrograms(from user: NSDictionary) {

    }

    static func getUserDataForBackgroundTask(from userId: String, complete: ((User?) -> Void)?) {
        print("Insideds")
        let user = usersRef.document(userId)
        user.getDocument(completion: {(result, error) in
            if error != nil {
                print("Error")
            } else {
                print("There")
                setUserData(with: result?.data() as! NSDictionary, id: result!.documentID)
                let notificationsRef = Firestore.firestore().collection("notifications")
                let query = notificationsRef.whereField("notificationOfUser", isEqualTo: userId)
                
                query.getDocuments(completion: {(result, error) in
                    if ((result?.documents.isEmpty)!) {
                        complete!(nil)
                    } else {
                        self.notificationDetails = (result?.documents[0].data())!
                        self.notificationDetails["id"] = (result?.documents[0].documentID)!
                        
                        if complete != nil {
                            complete!(self.authenticatedUser)
                        }
                    }
                })
            }
        })
    }
    
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
        self.notificationDetails = details
        let notificationsRef = Firestore.firestore().collection("notifications").document(details["id"] as! String)
        notificationsRef.updateData([
            "overDue" : details["overDue"],
            "dueSoon" : details["dueSoon"],
            "documentation" : details["documentation"],
            "license" : details["license"]
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                self.notificationDetails = details
                print("Document successfully updated")
            }
        }
    }

    static func updateLicenseImageAndData(of userWithId: User, image: UIImage, licenseDate: String, complete: @escaping (Bool) -> Void) {
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.1)!

        let imageRef = storageRef.child("\(userWithId.id )/License/\(date)")
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
                            let userRef = usersRef.document(userWithId.id )
                            userRef.updateData([
                                "licensePath": imageURL,
                                "licenseExpiryDate": licenseDate
                            ]) {
                                err in
                                if err != nil {
                                    complete(false)
                                } else {
                                    self.authenticatedUser = userWithId
                                    self.authenticatedUser.setLicensePath(path: imageURL)
                                    self.authenticatedUser.setLicenseExpiryDate(date: Util.convertStringToDate(string: licenseDate)!)
                                    complete(true)
                                }
                            }
                        }
                    }
                })
            }
        }
    }

    static func updateImageAndData(for bait: Bait, image: UIImage, complete: ((Bool) -> Void)?) {
        let date = UInt(Date().timeIntervalSince1970) // This will be used as the photoPath of local storage
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.1)!

        // save image to firebase storage, get the photoURL, then save photoURL and photoPath(i.e. date)
        let imageRef = storageRef.child("\(self.authenticatedUser.id)/Bait/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (metaData, error) in
            if error != nil {
                complete?(false)
            } else {
                imageRef.downloadURL(completion: {(url, error) in
                    if error != nil {
                        complete?(false)
                    } else {
                        if let imageURL = url?.absoluteString {
                            self.setData(for: authenticatedUser, data: [
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
                                ], complete: complete)
                        }
                    }
                })
            }
        }

        // save the image to a local file
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
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

    static func getAllPrograms(programs: NSDictionary, complete: (([Program]) -> Void)?) {
        var programList = [Program]()
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
        complete?(programList)
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

    static func getAllBaitsss(for baits: NSDictionary, program: Program) -> [Bait] {
        var baitList = [Bait]()

        for elem in baits {
            let id = elem.key as! String
            let b = elem.value as! NSDictionary
            let laidDate = b["laidDate"] as! String
            let latitude = b["latitude"] as! Double
            let longitude = b["longitude"] as! Double
            var photoPath:String?
            if b["photPath"] != nil {
                photoPath = b["photoPath"] as? String
            } else {
                photoPath = nil
            }
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

        return baitList
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
                    var photoPath:String?
                    if b["photPath"] != nil {
                        photoPath = b["photoPath"] as! String
                    } else {
                        photoPath = nil
                    }
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
        self.setData(for: authenticatedUser, data: [
                "programs": [
                    program.id: [
                        "baitType": program.baitType!,
                        "species": program.species!,
                        "startDate": Util.setDateAsString(date: program.startDate),
                        "isActive": program.isActive,
                        "baits": [:]
                    ]
                ]
            ], complete: nil)
    }

    static func createOrUpdate(bait: Bait, for program: Program, complete: ((Bool) -> Void)?){
        self.setData(for: authenticatedUser, data: [
                "programs" :[
                    program.id : [
                        "baits" : [
                            bait.id : [
                                "laidDate" : Util.setDateAsString(date: bait.laidDate),
                                "latitude" : bait.latitude,
                                "longitude" : bait.longitude,
                                "isRemoved" : bait.isRemoved,
                                "photoPath" : bait.photoPath
                            ]
                        ]
                    ]
                ]
            ], complete: complete)
    }



    static func delete(program: Program, complete: ((Bool) -> Void)?) {
        self.setData(for: authenticatedUser, data: [
                "programs": [
                    program.id: FieldValue.delete()
                ]
            ], complete: complete)
    }

    static func delete(bait: Bait, for program: Program, complete: ((Bool) -> Void)?) {

    }
    
    static func remove(bait: Bait, from program: Program, complete: ((Bool) -> Void)?) {
        self.setData(for: authenticatedUser, data: [
                "programs": [
                    program.id: [
                        "baits": [
                            bait.id: [
                                "isRemoved": true
                            ]
                        ]
                    ]
                ]
            ], complete: complete)
    }
    
    static func end(program: Program, complete: ((Bool) -> Void)?) {
        self.setData(for: self.authenticatedUser,
                     data: ["programs": [program.id: ["isActive": false]]],
                     complete: complete)
    }
    
    static private func setData(for user: User, data: [String : Any], complete: ((Bool) -> Void)?) {
        let document = usersRef.document("\(user.id)")
        document.setData(data, merge: true) { (err) in
            if let err = err {
                print("Error: \(err)")
                complete?(false)
                return
            }
            usersRef.document(user.id).getDocument(completion: { (document, err) in
                if let err = err {
                    print("Error: \(err)")
                    complete?(false)
                    return
                }
                self.setUserData(with: document!.data()! as NSDictionary, id: document!.documentID)
                complete?(true)
            })
        }
    }
}
