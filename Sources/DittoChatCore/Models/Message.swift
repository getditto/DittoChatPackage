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
    var largeImageToken: DittoAttachmentToken?
    var thumbnailImageToken: DittoAttachmentToken?

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
}

extension Message {
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.createdOn = DateFormatter.isoDate.date(from: document[createdOnKey].stringValue) ?? Date()
        self.roomId = document[roomIdKey].stringValue
        self.text = document[textKey].stringValue
        self.userId = document[userIdKey].stringValue
        self.largeImageToken = document[largeImageTokenKey].attachmentToken
        self.thumbnailImageToken = document[thumbnailImageTokenKey].attachmentToken
        self.archivedMessage = document[archivedMessageKey].string
        self.isArchived = document[isArchivedKey].bool ?? false

        // TAK related values
        self.authorCs = document[authorCsKey].stringValue
        self.authorId = document[authorIdKey].stringValue
        self.authorLoc = document[authorLocKey].stringValue
        self.authorType = document[authorTypeKey].stringValue
        self.msg = document[msgKey].stringValue
        self.parent = document[parentKey].stringValue
        self.pks = document[pksKey].stringValue
        self.room = document[roomKey].stringValue
        self.roomId = document[roomIdKey].stringValue
        self.schver = document[schverKey].intValue
        self.takUid = document[takUidKey].stringValue
        self.timeMs = Date(timeIntervalSince1970InMilliSeconds: document[timeMsKey].intValue)
        self.hasBeenConverted = document[hasBeenConvertedKey].bool

        if let hasBeenConverted, hasBeenConverted == true {
            return
        }

        self.convertToDittoChat()
    }

    func convertToDittoChat() {
        let message = Message(
            id: self.id,
            createdOn: self.timeMs,
            roomId: self.roomId,
            text: self.msg,
            userId: self.authorCs,
            largeImageToken: self.largeImageToken,
            thumbnailImageToken: self.thumbnailImageToken,
            archivedMessage: self.archivedMessage,
            isArchived: self.isArchived,
            authorCs: self.authorCs,
            authorId: self.authorId,
            authorLoc: self.authorLoc,
            authorType: self.authorType,
            msg: self.msg,
            parent: self.parent,
            pks: self.pks,
            room: self.room,
            schver: self.schver,
            takUid: self.takUid,
            timeMs: self.timeMs,
            hasBeenConverted: true
        ).docDictionary()

        // Update the currently existing TAK chat message with a Ditto Chat compatable one
        Task {
            try? await DataManager.shared.ditto?.store.execute(
                query: """
                    INSERT INTO chat
                    DOCUMENTS (:message)
                    ON ID CONFLICT DO UPDATE
                    """,
                arguments: ["message": message]
            )
        }
    }
}

extension Message {
    init(
        id: String? = nil,
        createdOn: Date? = nil,
        roomId: String,
        text: String? = nil,
        userId: String? = nil,
        largeImageToken: DittoAttachmentToken? = nil,
        thumbnailImageToken: DittoAttachmentToken? = nil,
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
        self.userId = DataManager.shared.currentUserId ?? createdByUnknownKey
        self.largeImageToken = largeImageToken
        self.thumbnailImageToken = thumbnailImageToken
        self.archivedMessage = archivedMessage
        self.isArchived = isArchived

        self.authorCs = authorCs ?? ""
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
        largeImageToken: DittoAttachmentToken? = nil,
        thumbnailImageToken: DittoAttachmentToken? = nil,
        archivedMessage: String? = nil,
        isArchived: Bool = false,
        parent: String = "RootContactGroup",
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
        let peerKey = DataManager.shared.ditto?.presence.graph.localPeer.peerKeyString ?? ""
        self.pks = peerKey
        self.room = room
        self.schver = schver
        self.takUid = UUID().uuidString
        self.timeMs = createdOn
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
