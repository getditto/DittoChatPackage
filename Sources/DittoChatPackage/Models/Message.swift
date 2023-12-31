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

    var isImageMessage: Bool {
        thumbnailImageToken != nil || largeImageToken != nil
    }
}

extension Message {
    init(document: DittoDocument) {
        id = document[dbIdKey].stringValue
        createdOn = DateFormatter.isoDate.date(from: document[createdOnKey].stringValue) ?? Date()
        roomId = document[roomIdKey].stringValue
        text = document[textKey].stringValue
        userId = document[userIdKey].stringValue
        largeImageToken = document[largeImageTokenKey].attachmentToken
        thumbnailImageToken = document[thumbnailImageTokenKey].attachmentToken
    }
}

extension Message {
    init(
        id: String? = nil,
        createdOn: Date? = nil,
        roomId: String,
        text: String? = nil,
        userId _: String? = nil,
        largeImageToken: DittoAttachmentToken? = nil,
        thumbnailImageToken: DittoAttachmentToken? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.createdOn = createdOn ?? Date()
        self.roomId = roomId
        self.text = text ?? ""
        userId = DataManager.shared.currentUserId ?? createdByUnknownKey
        self.largeImageToken = largeImageToken
        self.thumbnailImageToken = thumbnailImageToken
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
        ]
    }
}
