//
//  User.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import DittoSwift
import Foundation

struct ChatUser: Identifiable, Hashable, Equatable {
    var id: String
    var firstName: String
    var lastName: String
    var fullName: String {
        firstName + " " + lastName
    }
}

extension ChatUser {
    init(document: DittoDocument) {
        id = document[dbIdKey].stringValue
        firstName = document[firstNameKey].stringValue
        lastName = document[lastNameKey].stringValue
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
