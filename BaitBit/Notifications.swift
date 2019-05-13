//
//  Notifications.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 11/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class Notifications: NSObject {
    static var notifications: [String: Any] = [:]
    static func calculateTotalNotifications(of user: User, with notifications: [String: Any]) -> [String: Any]{
        
        let isDueSoon = notifications["dueSoon"] as? Bool
        let isOverDue = notifications["overDue"] as? Bool
        let isDocumentationPending = notifications["documentation"] as? Bool
        let isLicenseExpiring = notifications["license"] as? Bool
        let isScheduledProgramNotificationSet = notifications["scheduledPrograms"] as? Bool
        
        var overDueBaitsForProgram = [String: Int]()
        var dueSoonBaitsForProgram = [String: Int]()
        var scheduledPrograms = [String: Int]()
        var documentsPending = [String: Int]()
        var sections = [String]()
        if isOverDue! {
            for program in user.programs {
                if program.value.isActive {
                    var overDueBaits = 0
                    var dueSoonBaits = 0
                    for bait in program.value.baits {
                        if bait.value.isOverdue {
                            overDueBaits += 1
                        }
                    }
                    if overDueBaits != 0 {
                        overDueBaitsForProgram["\(program.value.id)%\(program.value.baitType as! String)"] = overDueBaits
                    }
                    
                }
            }
        }
        
        if isDueSoon! {
            for program in user.programs {
                if program.value.isActive {
                    var overDueBaits = 0
                    var dueSoonBaits = 0
                    for bait in program.value.baits {
                        if bait.value.isDueSoon {
                            dueSoonBaits += 1
                        }
                    }
                    if dueSoonBaits != 0 {
                        dueSoonBaitsForProgram["\(program.value.id)%\(program.value.baitType as! String)"] = dueSoonBaits
                    }
                }
            }
        }
        
        if isScheduledProgramNotificationSet! {
            for program in user.programs {
                var schProgram = 0
                if program.value.isActive && program.value.futureDate{
                    schProgram += 1
                }
                if schProgram != 0 {
                    scheduledPrograms["\(program.value.id)%\(program.value.baitType as! String)"] = schProgram
                }
            }
        }
        
        if isDocumentationPending! {
            for program in user.programs {
                if program.value.isActive {
                    if !program.value.documents.isEmpty {
                        if program.value.areDocumentsPending {
                            documentsPending["\(program.value.id)%\(program.value.baitType as! String)"] = 4 - program.value.documents.count
                        }
                    } else {
                        documentsPending["\(program.value.id)%\(program.value.baitType as! String)"] = 4
                    }
                }
            }
        }
        
        
        
        if dueSoonBaitsForProgram.count != 0 || overDueBaitsForProgram.count != 0{
            sections.append("Bait Status")
        }
        
        if user.licenseExpiryDate != nil {
            if isLicenseExpiring! && user.licenseExpiringSoon {
                sections.append("License")
            }
        } else {
            sections.append("License")
        }
        
        if !documentsPending.isEmpty {
            sections.append("Documentation")
        }
        
        if !scheduledPrograms.isEmpty {
            sections.append("Scheduled Programs")
        }
        
        print(scheduledPrograms)
        
        var response = [String: Any]()
        response["overDue"] = overDueBaitsForProgram
        response["dueSoon"] = dueSoonBaitsForProgram
        response["documents"] = documentsPending
        response["scheduledPrograms"] = scheduledPrograms
        response["sections"] = sections
        self.notifications = response
        return response
    }

}
