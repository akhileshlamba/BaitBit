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
    
    static func reloadUserDataFromFirebase(complete: @escaping ([String: Any]) -> Void) {
        let username = user!["username"] as! String
        let query = usersRef.whereField("username", isEqualTo: username)

        query.getDocuments(completion: {(document, error) in
            self.user = (document?.documents[0].data())!
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
        
    }
    
    static func delete(program: Program) {
        
    }
    
    static func delete(bait: Bait, for program: Program) {
        
    }
}
