///
//  PrivateRoom.swift
//  DittoChat
//
//  Created by Eric Turner on 1/12/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation

extension Room: Codable {}

public struct Room: Identifiable, Hashable, Equatable {
    public let id: String
    public let name: String
    public let messagesId: String
    public private(set) var isPrivate: Bool
    public let collectionId: String?
    public let createdBy: String
    public let createdOn: Date

    public init(id: String, name: String, messagesId: String, isPrivate: Bool, collectionId: String?, createdBy: String, createdOn: Date) {
        self.id = id
        self.name = name
        self.messagesId = messagesId
        self.isPrivate = isPrivate
        self.collectionId = collectionId
        self.createdBy = createdBy
        self.createdOn = createdOn
    }
}

extension Room {
    init(
        id: String,
        name: String,
        messagesId: String,
        isPrivate: Bool,
        collectionId: String? = nil,
        createdBy: String? = nil,
        createdOn: Date? = nil
    ) {
        let userId = DataManager.shared.currentUserId ?? createdByUnknownKey
        self.id = id
        self.name = name
        self.messagesId = messagesId
        self.isPrivate = isPrivate
        self.collectionId = collectionId
        self.createdBy = createdBy ?? userId
        self.createdOn = createdOn ?? Date()
    }
}

extension Room {
    func docDictionary() -> [String: Any?] {
        [
            dbIdKey: id,
            nameKey: name,
            messagesIdKey: messagesId,
            isPrivateKey: isPrivate,
            collectionIdKey: collectionId,
            createdByKey: createdBy,
            createdOnKey: DateFormatter.isoDate.string(from: createdOn),
        ]
    }
}

public extension Room {
    // This "dummy" object is a Room object used by DittoChatApp.swift
    // to initialize a basic chat mode ChatScreen as root view
    static var basicChatDummy: Room {
        Room(
            id: publicKey,
            name: publicRoomTitleKey,
            messagesId: publicMessagesIdKey,
            isPrivate: false
        )
    }
}

extension Room: DittoDecodable {
    init(value: [String: Any?]) {
        self.id = value[dbIdKey] as? String ?? ""
        self.name = value[nameKey] as? String ?? ""
        self.messagesId = value[messagesIdKey] as? String ?? ""
        self.isPrivate = value[isPrivateKey] as? Bool ?? false
        self.collectionId = value[collectionIdKey] as? String
        self.createdBy = value[createdByKey] as? String ?? ""
        let dateString = value[createdOnKey] as? String ?? ""
        self.createdOn = DateFormatter.isoDate.date(from: dateString) ?? Date()
    }
}

