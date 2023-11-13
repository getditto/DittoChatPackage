//
//  User.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
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
