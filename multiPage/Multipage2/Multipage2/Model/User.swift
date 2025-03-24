//
//  User.swift
//  Multipage2
//
//  Created by Troy Deminico on 2/13/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return "?"
    }
}

extension User {
    static var Mock_U = User(id: NSUUID().uuidString, fullname: "Troy Dem", email: "troydem@gmail.com")
}

