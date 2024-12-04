//
//  File.swift
//  DittoChatPackage
//
//  Created by Erik Everson on 12/2/24.
//

import Foundation
import DittoSwift
import SwiftUI
import Combine

// MARK: Lives in the Chat Target In the package
public protocol DittoSwiftChat {
    init(ditto: Ditto)

    func enableNotifications() throws

    // Create
    func createRoom(name: String, isPrivate: Bool) throws -> String
    func createMessage(roomId: String, message: String) throws
    func saveCurrentUser(firstName: String, lastName: String)

    // Read
    var publicRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func readRoomById(id: String) throws -> Room
    func allUsersPublisher() -> AnyPublisher<[ChatUser], Never>

    // Update
    func updateRoom(room: Room) async throws

    // Delete
    func deleteRoom(id: String) throws
    func deleteRoom(_ room: Room)
}

public struct DittoChat: DittoSwiftChat {
    public var currentUserId: String? {
        get { DataManager.shared.currentUserId }
        set { DataManager.shared.currentUserId = newValue }
    }

    public var basicChat: Bool {
        get { DataManager.shared.basicChat }
        set { DataManager.shared.basicChat = newValue }
    }

    public var basicChatPublisher: AnyPublisher<Bool, Never> {
        get { DataManager.shared.basicChatPublisher }
    }

    public var publicRoomsPublisher: AnyPublisher<[Room], Never>

    public init(ditto: DittoSwift.Ditto) {
        DittoInstance.dittoShared = ditto

        self.publicRoomsPublisher = DataManager.shared.publicRoomsPublisher
    }

    public func enableNotifications() throws {
        // TODO: Implement
    }

    public func createRoom(name: String, isPrivate: Bool) throws -> String {
        guard let id = DataManager.shared.createRoom(name: name, isPrivate: isPrivate) else {
            throw AppError.unknown("error creating room")
        }

        return id.stringValue
    }

    public func createMessage(roomId: String, message: String) throws {
        let room = try readRoomById(id: roomId)

        DataManager.shared.createMessage(for: room, text: message)
    }

    public func saveCurrentUser(firstName: String, lastName: String) {
        DataManager.shared.saveCurrentUser(firstName: firstName, lastName: lastName)
    }


    public func readRoomById(id: String) throws -> Room {
        guard let room = DataManager.shared.findPublicRoomById(id: id) else {
            throw AppError.unknown("room not found")
        }

        return room
    }

    public func allUsersPublisher() -> AnyPublisher<[ChatUser], Never> {
        DataManager.shared.allUsersPublisher()
    }

    public func updateRoom(room: Room) throws {
        // TODO: Implement
    }

    public func deleteRoom(id: String) throws {
        let room = try readRoomById(id: id)

        DataManager.shared.deleteRoom(room)
    }

    public func deleteRoom(_ room: Room) {
        DataManager.shared.deleteRoom(room)
    }


}


// MARK: Lives in the ChatUI Target In the package which has a dependency on the Chat target
public protocol DittoSwiftUI {
    init(ditto: Ditto)

    func roomCardView(id: String) throws -> any View

    func roomView(id: String) throws -> ChatScreen
    func roomsView() -> RoomsListScreen
}

public struct DittoChatUI: DittoSwiftUI {
    public var dittoChat: DittoChat

    public init(ditto: DittoSwift.Ditto) {
        dittoChat = DittoChat(ditto: ditto)
    }

    public func roomCardView(id: String) throws -> any View {
        let room = try dittoChat.readRoomById(id: id)

        return EmptyView()
    }

    public func roomView(id: String) throws -> ChatScreen {
        let room = try dittoChat.readRoomById(id: id)

        return ChatScreen(room: room)
    }

    public func roomsView() -> RoomsListScreen {
        return RoomsListScreen()
    }
}
