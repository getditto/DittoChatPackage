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
    public static func == (lhs: ChatUser, rhs: ChatUser) -> Bool {
        return lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.id == rhs.id
    }
    
    public var id: String
    public var firstName: String
    public var lastName: String
    public var fullName: String {
        firstName + " " + lastName
    }
    public var subscriptions: [String : Date?]
    public var mentions: [String: [String]]
}

extension ChatUser {
    init(document: DittoDocument) {
        id = document[dbIdKey].stringValue
        firstName = document[firstNameKey].stringValue
        lastName = document[lastNameKey].stringValue
        subscriptions = document[subscriptionsKey].dictionaryValue as? [String : Date] ?? [:]
        mentions = document[mentionsKey].dictionaryValue as? [String: [String]] ?? [:]
    }
}

extension ChatUser {
    static func unknownUser() -> ChatUser {
        ChatUser(
            id: unknownUserIdKey,
            firstName: noFirstNameKey,
            lastName: noLastNameKey,
            subscriptions: [:],
            mentions: [:]
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
