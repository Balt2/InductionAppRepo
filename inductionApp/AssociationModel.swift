//
//  AssociationModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/22/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import Firebase
import PencilKit
import Combine

struct Association: Hashable{
    
    static func == (lhs: Association, rhs: Association) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    var uid: String
    var associationID: String
    var name: String
    var imagePath: String
    var image: UIImage?
}
