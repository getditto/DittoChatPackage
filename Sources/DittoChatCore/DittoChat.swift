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

public protocol DittoSwiftChat {
    func setup(withDitto: Ditto)

    // Create
    func createRoom(withConfig: RoomConfig) throws -> String
    func createMessage(withConfig: MessageConfig) throws
    func setCurrentUser(withConfig: UserConfig)

    // Read
    var publicRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func readRoomById(id: String) throws -> Room
    func allUsersPublisher() -> AnyPublisher<[ChatUser], Never>

    // Update
    func updateRoom(room: Room) async throws

    // Delete
    func delete(roomById: String) throws
    func delete(room: Room)
}

public struct RoomConfig {
    public let id: String?
    public let name: String
    public let isPrivate: Bool

    public init(id: String? = nil, name: String, isPrivate: Bool) {
        self.id = id
        self.name = name
        self.isPrivate = isPrivate
    }
}

public struct MessageConfig {
    public let roomId: String
    public let message: String

    public init(roomId: String, message: String) {
        self.roomId = roomId
        self.message = message
    }
}

public struct UserConfig {
    public let firstName: String
    public let lastName: String

    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}

public class DittoChat: DittoSwiftChat {
    public init() {}
    
    // MARK: Carry over from previous public things
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

    public var publicRoomsPublisher: AnyPublisher<[Room], Never> {
        get {DataManager.shared.publicRoomsPublisher}
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

    // MARK: Public interface
    public func setup(withDitto ditto: DittoSwift.Ditto) {
        DittoInstance.dittoShared = ditto
    }

    // MARK: Create
    public func createRoom(withConfig config: RoomConfig) throws -> String {
        guard let id = DataManager.shared.createRoom(id: config.id, name: config.name, isPrivate: config.isPrivate) else {
            throw AppError.unknown("room not found")
        }

        return id.stringValue
    }

    public func createMessage(withConfig config: MessageConfig) throws {
        let room = try readRoomById(id: config.roomId)

        DataManager.shared.createMessage(for: room, text: config.message)
    }

    public func setCurrentUser(withConfig config: UserConfig) {
        DataManager.shared.saveCurrentUser(firstName: config.firstName, lastName: config.lastName)
    }

    // MARK: Read
    public func read(messagesForRoom room: Room) throws {
        DataManager.shared.readMessagesForRoom(room: room)
    }

    public func read(messagesForUser user: ChatUser) throws {
        DataManager.shared.readMessagesForUser(user: user)
    }

    // MARK: Update
    public func updateRoom(room: Room) throws {
        DataManager.shared.updateRoom(room)
    }

    // MARK: Delete
    public func delete(roomById id: String) throws {
        let room = try readRoomById(id: id)

        DataManager.shared.deleteRoom(room)
    }

    public func delete(room: Room) {
        DataManager.shared.deleteRoom(room)
    }
}
