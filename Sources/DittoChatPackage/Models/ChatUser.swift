//
//  User.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//

import DittoSwift
import Foundation

public struct ChatUser: Identifiable, Hashable, Equatable {
    public var id: String
    public var firstName: String
    public var lastName: String
    public var fullName: String {
        firstName + " " + lastName
    }
}

extension ChatUser: DittoDecodable {
    init(value: [String: Any?]) {
        
        self.id = value[dbIdKey] as? String ?? ""
        self.firstName = value[firstNameKey] as? String ?? ""
        self.lastName = value[lastNameKey] as? String ?? ""
    }
}

extension ChatUser {
    static func unknownUser() -> ChatUser {
        ChatUser(
            id: unknownUserIdKey,
            firstName: unknownUserNameKey,
            lastName: ""
        )
    }
}

extension ChatUser {    
    func docDictionary() -> [String: Any?] {
        [
            dbIdKey: id,
            firstNameKey: firstName,
            lastNameKey: lastName,
        ]
    }
}

//extension User: DittoDecodable {
//    init(value: [String: Any?]) {
//        self.id = value[dbIdKey] as? String ?? ""
//        self.firstName = value[firstNameKey] as? String ?? ""
//        self.lastName = value[lastNameKey] as? String ?? ""
//    }
//}
