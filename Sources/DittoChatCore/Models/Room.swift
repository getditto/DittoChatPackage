//
//  Room.swift
//  DittoChat
//
//  Created by Eric Turner on 1/12/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import DittoSwift
import Foundation

extension Room: Codable { /*Adding codable protocol*/ }

public struct Room: Identifiable, Hashable, Equatable {
    public let id: String
    public let name: String
    public let messagesId: String
    public let collectionId: String?
    public let createdBy: String
    public let createdOn: Date

    public init(id: String, name: String, messagesId: String, collectionId: String?, createdBy: String, createdOn: Date) {
        self.id = id
        self.name = name
        self.messagesId = messagesId
        self.collectionId = collectionId
        self.createdBy = createdBy
        self.createdOn = createdOn
    }
}

extension Room: DittoDecodable {
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.name = document[nameKey].stringValue
        self.messagesId = document[messagesIdKey].stringValue
        self.collectionId = document[collectionIdKey].string
        self.createdBy = document[createdByKey].stringValue
        self.createdOn = DateFormatter.isoDate.date(from: document[createdOnKey].stringValue) ?? Date()
    }

    init(value: [String : Any?]) {
        self.id = value[dbIdKey] as? String ?? ""
        self.name = value[nameKey] as? String ?? ""
        self.messagesId = value[messagesIdKey] as? String ?? ""
        self.collectionId = value[collectionIdKey] as? String
        self.createdBy = value[createdByKey] as? String ?? ""
        self.createdOn = DateFormatter.isoDate.date(from: value[createdOnKey] as? String ?? "") ?? Date()
    }
}

extension Room {
    init(
        id: String,
        name: String,
        messagesId: String,
        userId: String,
        collectionId: String? = nil,
        createdBy: String? = nil,
        createdOn: Date? = nil
    ) {
        //let userId = DataManager.shared.currentUserId ?? createdByUnknownKey
        self.id = id
        self.name = name
        self.messagesId = messagesId
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
            collectionIdKey: collectionId,
            createdByKey: createdBy,
            createdOnKey: DateFormatter.isoDate.string(from: createdOn),
        ]
    }
}

//public extension Room {
//    // This "dummy" object is a Room object used by DittoChatApp.swift
//    // to initialize a basic chat mode ChatScreen as root view
//    static var basicChatDummy: Room {
//        Room(
//            id: publicKey,
//            name: publicRoomTitleKey,
//            messagesId: publicMessagesIdKey,
//        )
//    }
//}
