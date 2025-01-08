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
    func setup(withDitto ditto: Ditto)
    func roomView(id: String) throws -> ChatScreen
    func roomsView() -> RoomsListScreen
}

public class DittoChatUI: DittoChatViews {
    public var dittoChat: DittoChat

    public init() {
        dittoChat = DittoChat()
    }

    public func setup(withDitto ditto: Ditto) {
        dittoChat.setup(withDitto: ditto)
    }

    public func roomView(id: String) throws -> ChatScreen {
        let room = try dittoChat.readRoomById(id: id)

        return ChatScreen(room: room)
    }

    public func roomsView() -> RoomsListScreen {
        return RoomsListScreen()
    }
}
