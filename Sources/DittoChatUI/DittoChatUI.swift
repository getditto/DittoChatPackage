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
    var dittoChat: DittoChat { get }
    func roomView(id: String) throws -> ChatScreen
    func roomsView() -> RoomsListScreen
    func logout()
    func setCurrentUser(withConfig config: UserConfig)
}

public class DittoChatUI: DittoChatViews {
    public var dittoChat: DittoChat

    public init(chatConfig: ChatConfig) {
        dittoChat = DittoChat(config: chatConfig)
    }

    public func roomView(id: String) throws -> ChatScreen {
        let room = try dittoChat.readRoomById(id: id)

        return ChatScreen(room: room, dataManager: dittoChat.dataManager)
    }

    public func roomsView() -> RoomsListScreen {
        return RoomsListScreen(dataManager: dittoChat.dataManager)
    }

    public func setCurrentUser(withConfig config: UserConfig) {
        dittoChat.setCurrentUser(withConfig: config)
    }

    public func logout() {
        dittoChat.logout()
    }
    
    public func cleanup() {
        dittoChat.cleanup()
    }
}
