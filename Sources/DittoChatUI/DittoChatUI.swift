//
//  DittoSwiftUI.swift
//  DittoChatPackage
//
//  Created by Erik Everson on 1/7/25.
//

import Foundation
import DittoSwift
import SwiftUI
import Combine
import DittoChatCore

public protocol DittoChatViews {
    var dittoChat: DittoChat! { get }
    func setup(withDitto ditto: Ditto, usersCollection: String)
    func roomView(id: String) throws -> ChatScreen
    func roomsView() -> RoomsListScreen
    func logout()
    func setCurrentUser(withConfig config: UserConfig)
}

public class DittoChatUI: DittoChatViews {
    public var dittoChat: DittoChat!

    public init(chatConfig: ChatConfig? = nil) {
        dittoChat = DittoChat(config: chatConfig)
    }

    public func setup(withDitto ditto: Ditto, usersCollection: String) {
        dittoChat.setup(withDitto: ditto, usersCollection: usersCollection)
    }

    public func roomView(id: String) throws -> ChatScreen {
        let room = try dittoChat.readRoomById(id: id)

        return ChatScreen(room: room)
    }

    public func roomsView() -> RoomsListScreen {
        return RoomsListScreen()
    }

    public func logout() {
        dittoChat.logout()
        dittoChat = nil
    }

    public func setCurrentUser(withConfig config: UserConfig) {
        dittoChat.setCurrentUser(withConfig: config)
    }
}
