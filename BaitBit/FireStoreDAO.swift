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
    static let ref = Firestore.firestore()
    
    static func getAllPrograms() {
        
    }
    
    static func getAllBaits(for: Program) {
        
    }
    
    static func createOrUpdate(program: Program) {
        
    }
    
    static func createOrUpdate(bait: Bait, for: Program) {
        
    }
    
    static func delete(program: Program) {
        
    }
    
    static func delete(bait: Bait, for: Program) {
        
    }
}
