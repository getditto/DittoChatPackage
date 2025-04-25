//
//  Message.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import DittoSwift
import Foundation

extension Message: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Message: Identifiable, Equatable {
    var id: String
    var createdOn: Date
    var roomId: String
    var text: String
    var userId: String
    var largeImageToken: [String: Any]?
    var thumbnailImageToken: [String: Any]?

    var archivedMessage: String?
    var isArchived: Bool

    //TAK specific values
    var authorCs: String
    var authorId: String
    var authorLoc: String
    var authorType: String
    var msg: String
    var parent: String
    var pks: String
    var room: String
    var schver: Int
    var takUid: String
    var timeMs: Date

    var hasBeenConverted: Bool?

    var isImageMessage: Bool {
        thumbnailImageToken != nil || largeImageToken != nil
    }

    // FIXME: Excluding attachment tokens from equality because Any is not equatable
        static func == (lhs: Message, rhs: Message) -> Bool {
            return lhs.id == rhs.id &&
            lhs.createdOn == rhs.createdOn &&
            lhs.roomId == rhs.roomId &&
            lhs.text == rhs.text &&
            lhs.userId == rhs.userId &&
            lhs.isImageMessage == rhs.isImageMessage
        }
}

extension Message: DittoDecodable {
    init(value: [String: Any?]) {
        self.id = value[dbIdKey] as? String ?? ""
        self.createdOn = DateFormatter.isoDate.date(from: value[createdOnKey] as? String ?? "") ?? Date()
        self.roomId = value[roomIdKey] as? String ?? ""
        self.text = value[textKey] as? String ?? ""
        self.userId = value[userIdKey] as? String ?? ""
        self.largeImageToken = value[largeImageTokenKey] as? [String: Any]
        self.thumbnailImageToken = value[thumbnailImageTokenKey] as? [String: Any]
        self.archivedMessage = value[archivedMessageKey] as? String
        self.isArchived = value[isArchivedKey] as? Bool ?? false

        // TAK related values
        self.authorCs = value[authorCsKey] as? String ?? ""
        self.authorId = value[authorIdKey] as? String ?? ""
        self.authorLoc = value[authorLocKey] as? String ?? ""
        self.authorType = value[authorTypeKey] as? String ?? ""
        self.msg = value[msgKey] as? String ?? ""
        self.parent = value[parentKey] as? String ?? ""
        self.pks = value[pksKey] as? String ?? ""
        self.room = value[roomKey] as? String ?? ""
        self.roomId = value[roomIdKey] as? String ?? ""
        self.schver = value[schverKey] as? Int ?? 0
        self.takUid = value[takUidKey] as? String ?? ""
        self.timeMs = Date(timeIntervalSince1970InMilliSeconds: value[timeMsKey] as? Int ?? 0)
        self.hasBeenConverted = value[hasBeenConvertedKey] as? Bool
    }
}

extension Message {
    init(
        id: String? = nil,
        createdOn: Date? = nil,
        roomId: String,
        text: String? = nil,
        userId: String? = nil,
        largeImageToken: [String: Any]? = nil,
        thumbnailImageToken: [String: Any]? = nil,
        archivedMessage: String? = nil,
        isArchived: Bool = false,
        authorCs: String? = nil,
        authorId: String? = nil,
        authorLoc: String? = nil,
        authorType: String? = nil,
        msg: String? = nil,
        parent: String? = nil,
        pks: String? = nil,
        room: String? = nil,
        schver: Int? = nil,
        takUid: String? = nil,
        timeMs: Date? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.createdOn = createdOn ?? Date()
        self.roomId = roomId
        self.text = text ?? ""
        self.userId = userId ?? createdByUnknownKey
        self.largeImageToken = largeImageToken
        self.thumbnailImageToken = thumbnailImageToken
        self.archivedMessage = archivedMessage
        self.isArchived = isArchived

        self.authorCs = authorCs ?? userId ?? ""
        self.authorId = authorId ?? ""
        self.authorLoc = authorLoc ?? ""
        self.authorType = authorType ?? ""
        self.msg = msg ?? ""
        self.parent = parent ?? ""
        self.pks = pks ?? ""
        self.room = room ?? ""
        self.schver = schver ?? .zero
        self.takUid = takUid ?? ""
        self.timeMs = timeMs ?? Date()

    }

    // Used for creating new chat types for upload
    init(
        id: String? = nil,
        createdOn: Date = .now,
        roomId: String,
        message: String = "",
        userName: String,
        userId: String,
        largeImageToken: [String: Any]? = nil,
        thumbnailImageToken: [String: Any]? = nil,
        archivedMessage: String? = nil,
        isArchived: Bool = false,
        parent: String = "RootContactGroup",
        peerKey: String,
        room: String = "ditto",
        schver: Int = 1,
        hasBeenConverted: Bool = true
    ) {
        self.id = id ?? UUID().uuidString
        self.createdOn = createdOn
        self.roomId = roomId
        self.text = message
        self.userId = userId
        self.largeImageToken = largeImageToken
        self.thumbnailImageToken = thumbnailImageToken
        self.archivedMessage = archivedMessage
        self.isArchived = isArchived

        self.authorCs = userName
        self.authorId = userId
        self.authorLoc = "0.0,0.0,NaN,HAE,NaN,NaN"
        self.authorType = "a-f-G-U-C"
        self.msg = message
        self.parent = parent
        self.pks = peerKey
        self.room = room
        self.schver = schver
        self.takUid = UUID().uuidString
        self.timeMs = createdOn
        self.hasBeenConverted = hasBeenConverted
    }
}

extension Message {
    func docDictionary() -> [String: Any?] {
        [
            dbIdKey: id,
            createdOnKey: DateFormatter.isoDate.string(from: createdOn),
            roomIdKey: roomId,
            textKey: text,
            userIdKey: userId,
            largeImageTokenKey: largeImageToken,
            thumbnailImageTokenKey: thumbnailImageToken,
            archivedMessageKey: archivedMessage,
            isArchivedKey: isArchived,
            authorCsKey: authorCs,
            authorIdKey: authorId,
            authorLocKey: authorLoc,
            authorTypeKey: authorType,
            msgKey: msg,
            parentKey: parent,
            pksKey: pks,
            roomKey: room,
            schverKey: schver,
            takUidKey: takUid,
            timeMsKey: timeMs.timeIntervalSince1970InMilliSeconds,
            hasBeenConvertedKey: hasBeenConverted,
        ]
    }
}

extension Date {
    init(timeIntervalSince1970InMilliSeconds: Int) {
        self = Date(timeIntervalSince1970: Double(timeIntervalSince1970InMilliSeconds) / 1000)
    }

    var timeIntervalSince1970InMilliSeconds: Int {
        Int(self.timeIntervalSince1970 * 1000)
    }
}
