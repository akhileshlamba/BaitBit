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
                            Reminder.setOrUpdateRemindersForAnimals(notifications: self.notificationDetails)
                            let flag = self.notificationDetails["scheduledPrograms"]
                            if flag != nil {
                                if flag as! Bool {
                                    var programsList = [Program]()
                                    let programs = self.authenticatedUser.programs
                                    if !programs.isEmpty {
                                        for program in programs as NSDictionary {
                                            let p = program.value as! Program
                                            let days = Calendar.current.dateComponents([.day], from: Date(), to: p.startDate as Date).day
                                            if days! >= 1 {
                                                programsList.append(p)
                                            }
                                        }
                                        print(programsList.count)
                                    }
                                    Reminder.scheduledProgramReminder(for: programsList)
                                }
                            }
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
                            "overDue" : true,
                            "dueSoon" : true,
                            "documentation" : true,
                            "notificationOfUser" : ref!.documentID,
                            "license" : true,
                            "scheduledPrograms" : true,
                            "dog" : true,
                            "pig" : true,
                            "fox" : true,
                            "rabbit" : true,
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

                if p["documents"] != nil {
                    let documents = p["documents"] as! NSDictionary
                    for document in documents {
                        let p = document.value as! NSDictionary
                        let name = p["documentName"] as! String
                        let localURL = p["photoPath"] as! String
                        let firebaseURL = p["photoURL"] as! String
                        let doc = Documents(name: name)
                        doc.imageLocalURL = localURL
                        doc.imageFirebaseURL = firebaseURL
                        program.addToDocuments(document: doc)
                    }

                }

                if p["baits"] != nil {
                    program.addToBaits(baits: getAllBaitsss(for: p["baits"] as! NSDictionary, program: program))
                } else {
                    program.baits = [:]
                }

                if p["endDate"] != nil {
                    program.endDate = dateformatter.date(from: p["endDate"] as! String)
                }
            }

            print(self.authenticatedUser)
        }
    }

    func getPrograms(from user: NSDictionary) {

    }

    static func getUserDataForBackgroundTask(from userId: String, complete: ((User?) -> Void)?) {
        let user = usersRef.document(userId)
        user.getDocument(completion: {(result, error) in
            if error != nil {
                print("Error")
            } else {

                setUserData(with: result?.data() as! NSDictionary, id: result!.documentID)
                let notificationsRef = Firestore.firestore().collection("notifications")
                let query = notificationsRef.whereField("notificationOfUser", isEqualTo: userId)

                query.getDocuments(completion: {(result, error) in
                    if ((result?.documents.isEmpty)!) {
                        complete!(nil)
                    } else {
                        self.notificationDetails = (result?.documents[0].data())!
                        self.notificationDetails["id"] = (result?.documents[0].documentID)!
                        Reminder.setOrUpdateRemindersForAnimals(notifications: self.notificationDetails)
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

    static func updateNotificationDetails(with id: String, updated: [String: Any], previous: [String: Any]) {
        self.notificationDetails = updated
        let notificationsRef = Firestore.firestore().collection("notifications").document(updated["id"] as! String)
        notificationsRef.updateData([
            "overDue" : updated["overDue"],
            "dueSoon" : updated["dueSoon"],
            "documentation" : updated["documentation"],
            "license" : updated["license"]!,
            "scheduledPrograms" : updated["scheduledPrograms"]!,
            "dog" : updated["dog"]!,
            "pig" : updated["pig"]!,
            "fox" : updated["fox"]!,
            "rabbit" : updated["rabbit"]!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                self.notificationDetails = updated

                if previous["scheduledPrograms"] != nil {
                    if updated["scheduledPrograms"] as! Bool != previous["scheduledPrograms"] as! Bool {
                        var programsList = [Program]()
                        let programs = self.authenticatedUser.programs
                        if !programs.isEmpty {
                            for program in programs as NSDictionary {
                                let p = program.value as! Program
                                let days = Calendar.current.dateComponents([.day], from: Date(), to: p.startDate as Date).day
                                if days! >= 1 {
                                    programsList.append(p)
                                }
                            }
                            print(programsList.count)
                        }
                        let bool = updated["scheduledPrograms"] as! Bool
                        if !bool {
                            Reminder.removePendingNotifications(for: "animal", programs: programsList)
                        } else {
                            Reminder.scheduledProgramReminder(for: programsList)
                        }
                    }
                }

                Reminder.removePendingNotifications(for: "animal", programs: nil)
                Reminder.setOrUpdateRemindersForAnimals(notifications: updated)
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

        // save the image to a local file
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }

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
                            bait.photoPath = "\(date)"
                            bait.photoURL = imageURL
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

//    static func getAllPrograms(programs: NSDictionary, complete: (([Program]) -> Void)?) {
//        var programList = [Program]()
//        for elem in programs {
//            let id = elem.key as! String
//            let p = elem.value as! NSDictionary
//            let baitType = p["baitType"] as! String
//            let species = p["species"] as! String
//            let startDate = p["startDate"] as! String
//            let isActive = p["isActive"] as! Bool
//            let dateformatter = DateFormatter()
//            dateformatter.dateFormat = "MMM dd, yyyy"
//            let program:Program = Program(id: id,
//                                          baitType: baitType,
//                                          species: species,
//                                          startDate: dateformatter.date(from: startDate) as NSDate?,
//                                          isActive: isActive)
//            program.addToBaits(baits: getAllBaits(for: program))
//            programList.append(program)
//        }
//        complete?(programList)
//    }

//    static func getAllPrograms(complete: @escaping ([Program]) -> Void) {
//        var programList = [Program]()
//        if self.user == nil {
//            reloadUserDataFromFirebase { (user) in
//                if let programs = user["programs"] as? NSDictionary {
//                    for elem in programs {
//                        let id = elem.key as! String
//                        let p = elem.value as! NSDictionary
//                        let baitType = p["baitType"] as! String
//                        let species = p["species"] as! String
//                        let startDate = p["startDate"] as! String
//                        let isActive = p["isActive"] as! Bool
//                        let dateformatter = DateFormatter()
//                        dateformatter.dateFormat = "MMM dd, yyyy"
//                        let program:Program = Program(id: id,
//                                                      baitType: baitType,
//                                                      species: species,
//                                                      startDate: dateformatter.date(from: startDate) as NSDate?,
//                                                      isActive: isActive)
//                        program.addToBaits(baits: getAllBaits(for: program))
//                        programList.append(program)
//                    }
//                }
//                complete(programList)
//            }
//        } else {
//            if let programs = self.user!["programs"] as? NSDictionary {
//                for elem in programs {
//                    let id = elem.key as! String
//                    let p = elem.value as! NSDictionary
//                    let baitType = p["baitType"] as! String
//                    let species = p["species"] as! String
//                    let startDate = p["startDate"] as! String
//                    let isActive = p["isActive"] as! Bool
//                    let dateformatter = DateFormatter()
//                    dateformatter.dateFormat = "MMM dd, yyyy"
//                    let program:Program = Program(id: id,
//                                                  baitType: baitType,
//                                                  species: species,
//                                                  startDate: dateformatter.date(from: startDate) as NSDate?,
//                                                  isActive: isActive)
//                    program.addToBaits(baits: getAllBaits(for: program))
//                    programList.append(program)
//                }
//            }
//            complete(programList)
//        }
//    }

    static func getAllBaitsss(for baits: NSDictionary, program: Program) -> [Bait] {
        var baitList = [Bait]()

        for elem in baits {
            let id = elem.key as! String
            let b = elem.value as! NSDictionary
            let laidDate = b["laidDate"] as! String
            let latitude = b["latitude"] as! Double
            let longitude = b["longitude"] as! Double
            var photoPath:String?
            var photoURL:String?
            if b["photoPath"] != nil {
                photoPath = b["photoPath"] as? String
            } else {
                photoPath = nil
            }
            if b["photoURL"] != nil {
                photoURL = b["photoURL"] as? String
            } else {
                photoURL = nil
            }

            let isRemoved = b["isRemoved"] as! Bool
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "MMM dd, yyyy"
            let bait = Bait(id: id,
                            laidDate: dateformatter.date(from: laidDate)! as NSDate,
                            latitude: latitude,
                            longitude: longitude,
                            photoPath: photoPath,
                            photoURL: photoURL,
                            program: program,
                            isRemoved: isRemoved)
            if let isTaken = b["isTaken"] as? Bool {
                bait.isTaken = isTaken
            }
            if let carcassFound = b["carcassFound"] as? Bool {
                bait.carcassFound = carcassFound
            }
            if let targetCarcassFound = b["targetCarcassFound"] as? Bool {
                bait.targetCarcassFound = targetCarcassFound
            }
            if let removedDate = b["removedDate"] as? String {
                bait.removedDate = Util.convertStringToDate(string: removedDate) as Date?
            }
            baitList.append(bait)
        }

        return baitList
    }

//    static func getAllBaits(for program: Program) -> [Bait] {
//        var baitList = [Bait]()
//
//        if let programs = user!["programs"] as? NSDictionary {
//            let p = programs[program.id] as! NSDictionary
//            if let baits = p["baits"] as? NSDictionary {
//                for elem in baits {
//                    let id = elem.key as! String
//                    let b = elem.value as! NSDictionary
//                    let laidDate = b["laidDate"] as! String
//                    let latitude = b["latitude"] as! Double
//                    let longitude = b["longitude"] as! Double
//                    var photoPath:String?
//                    var photoURL:String?
//                    if b["photPath"] != nil {
//                        photoPath = b["photoPath"] as! String
//                    } else {
//                        photoPath = nil
//                    }
//                    if b["photoURL"] != nil {
//                        photoURL = b["photoURL"] as? String
//                    } else {
//                        photoURL = nil
//                    }
//                    let isRemoved = b["isRemoved"] as! Bool
//                    let dateformatter = DateFormatter()
//                    dateformatter.dateFormat = "MMM dd, yyyy"
//                    let bait = Bait(id: id,
//                                    laidDate: dateformatter.date(from: laidDate)! as NSDate,
//                                    latitude: latitude,
//                                    longitude: longitude,
//                                    photoPath: photoPath,
//                                    photoURL: photoURL,
//                                    program: program,
//                                    isRemoved: isRemoved)
//                    baitList.append(bait)
//                }
//            }
//        }
//        return baitList
//    }

    static func createOrUpdate(program: Program, complete: @escaping (Bool) -> Void) {
        let document = usersRef.document("\(authenticatedUser.id )")
        if program.documents != nil || !program.documents.isEmpty {
            var doc : [String?: [String: String]] = [:]
            for document in program.documents {
                var tempDoc : [String: String] = [:]
                tempDoc["documentName"] = document?.name
                tempDoc["photoPath"] = document?.imageLocalURL
                tempDoc["photoURL"] = document?.imageFirebaseURL
                doc[document?.imageLocalURL] = tempDoc
            }

            document.setData([
                "programs": [
                    program.id: [
                        "baitType": program.baitType!,
                        "species": program.species!,
                        "startDate": Util.setDateAsString(date: program.startDate),
                        "isActive": program.isActive,
                        "baits": [:],
                        "documents": doc
                    ]
                ]
                ], merge: true, completion: {
                    err in
                    if err != nil {
                        complete(false)
                    } else {
                        self.getUserDataForBackgroundTask(from: self.authenticatedUser.id, complete: nil)
                        complete(true)
                    }
            })

        } else {
            document.setData([
                "programs": [
                    program.id: [
                        "baitType": program.baitType!,
                        "species": program.species!,
                        "startDate": Util.setDateAsString(date: program.startDate),
                        "isActive": program.isActive,
                        "baits": [:]
                    ]
                ]
                ], merge: true, completion: {
                    err in
                    if err != nil {
                        complete(false)
                    } else {
                        self.getUserDataForBackgroundTask(from: self.authenticatedUser.id, complete: nil)
                        complete(true)
                    }
            })
        }
//        self.setData(for: authenticatedUser, data: [
//                "programs": [
//                    program.id: [
//                        "baitType": program.baitType!,
//                        "species": program.species!,
//                        "startDate": Util.setDateAsString(date: program.startDate),
//                        "isActive": program.isActive,
//                        "baits": [:]
//                    ]
//                ]
//            ], complete: nil)
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
                                "isRemoved": true,
                                "isTaken": bait.isTaken,
                                "carcassFound": bait.carcassFound,
                                "targetCarcassFound": bait.targetCarcassFound,
                                "removedDate": Util.setDateAsString(date: bait.removedDate as! NSDate)
                            ]
                        ]
                    ]
                ]
            ], complete: complete)
    }

    static func end(program: Program, complete: ((Bool) -> Void)?) {
        self.setData(for: self.authenticatedUser,
                     data: ["programs": [program.id: ["isActive": false, "endDate": Util.setDateAsString(date: program.endDate as! NSDate)]]],
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

    static func fetchImage(for bait: Bait, complete: @escaping (UIImage) -> Void) {
        if let photoPath = bait.photoPath, let photoURL = bait.photoURL {
            self.fetchImage(from: bait.photoPath, otherwiseFrom: bait.photoURL, complete: complete)
        }
    }

    static private func fetchImage(from localPath: String?, otherwiseFrom photoURL: String?, complete: @escaping (UIImage) -> Void) {
        var image: UIImage?
        if let photoPath = localPath {

            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)

            if let pathComponent = url.appendingPathComponent(photoPath) {
                let filePath = pathComponent.path
                let fileManager = FileManager.default

                if fileManager.fileExists(atPath: filePath) {
                    guard let fileData = fileManager.contents(atPath: filePath) else {return}
                    image = UIImage(data: fileData)
                    complete(image!)
                    return
                } else {
                    Storage.storage().reference(forURL: photoURL!).getData(maxSize: 5 * 1024 * 1024) { (data, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        } else {
                            image = UIImage(data: data!)
                            complete(image!)
                            return
                        }
                    }
                }
            }
        }
    }


    static func uploadDocument(of userId: String,  programId: String, document: UIImage, name: String, complete: @escaping (Bool) -> Void) {
        let date = UInt(Date().timeIntervalSince1970) // This will be used as the photoPath of local storage
        var data = Data()
        data = UIImageJPEGRepresentation(document, 0.1)!

        // save image to firebase storage, get the photoURL, then save photoURL and photoPath(i.e. date)
        let imageRef = storageRef.child("\(userId)/Program/\(name)/\(date)")
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
                            let userRef = usersRef.document(userId)
                            userRef.setData([
                                "programs": [
                                    programId: [
                                        "documents" :[
                                            "\(date)": [
                                                "documentName": name,
                                                "photoPath": "\(date)",
                                                "photoURL": imageURL
                                            ]
                                        ]
                                    ]
                                ]
                                ]
                                , merge: true, completion: {
                                    err in
                                    if err != nil {
                                        complete(false)
                                    } else {
                                        self.getUserDataForBackgroundTask(from: userId, complete: nil)
                                        complete(true)
                                    }
                            })
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

    static func uploadDocument(of userId: String, document: UIImage, name: String, complete: @escaping (Documents?) -> Void) {
        let date = UInt(Date().timeIntervalSince1970) // This will be used as the photoPath of local storage
        var data = Data()
        data = UIImageJPEGRepresentation(document, 0.1)!

        // save image to firebase storage, get the photoURL, then save photoURL and photoPath(i.e. date)
        let imageRef = storageRef.child("\(userId)/Program/\(name)/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (metaData, error) in
            if error != nil {
                complete(nil)
            } else {
                imageRef.downloadURL(completion: {(url, error) in
                    if error != nil {
                        complete(nil)
                    } else {
                        if let imageURL = url?.absoluteString {
                            var document = Documents(name: name)
                            document.imageFirebaseURL = imageURL
                            document.imageLocalURL = "\(date)"
                            complete(document)
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

            let defaults = UserDefaults()
            var documentsUpload = defaults.dictionary(forKey: "documentsUpload")
            if documentsUpload == nil || documentsUpload!.isEmpty {
                documentsUpload = [String: String]()
                documentsUpload![name] = "\(date)"
            } else {
                documentsUpload![name] = "\(date)"
            }
            defaults.set(documentsUpload, forKey: "documentsUpload")
        }
    }

    static func getBaits(complete : @escaping ([Bait]) -> Void){
        var baitList = [Bait]()
        usersRef.getDocuments(completion: {(document, error) in
            if (document?.documents.isEmpty ?? nil)! {
                complete([])
            } else {
                for document in document!.documents {
//                    let programs = document["programs"] as? NSDictionary
                    if let programs = document["programs"] as? NSDictionary {
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

                            if p["baits"] != nil {
                                baitList.append(contentsOf: getAllBaitsss(for: p["baits"] as! NSDictionary, program: program))
                            }
                        }
                    }
                }
                complete(baitList)
            }
        })
    }

}
