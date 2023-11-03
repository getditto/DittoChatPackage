//
//  MessageWithUser.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import Foundation

// User messages
struct MessageWithUser: Identifiable, Hashable, Equatable {
    var message: Message
    var user: ChatUser
    var id: String {
        message.id
    }
}
