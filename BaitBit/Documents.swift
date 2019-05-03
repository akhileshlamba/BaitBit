//
//  Documents.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 28/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

enum documentType: String, CaseIterable {
    case Risk_Assessment = "Risk assessment"
    case Purchase_Record = "Purchase record"
    case Notification_Pest_Control = "Notification of pest control"
    case Neighbour_otification = "Neighbour notification"
    
    
}

class Documents: NSObject {
    
    var name: String!
    var imageFirebaseURL : String? = nil
    var imageLocalURL : String? = nil
    
    init(name: String) {
        self.name = name
    }

}
