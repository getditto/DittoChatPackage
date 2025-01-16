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
    func setup(withDitto: Ditto, usersCollection: String)

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

    func logout()
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
    public let id: String

    public init (id: String) {
        self.id = id
    }
}

public class DittoChat: DittoSwiftChat {
    private var dataManager: DataManager!

    public init() {
        self.dataManager = DataManager.shared
    }
    
    // MARK: Carry over from previous public things
    public var currentUserId: String? {
        get { dataManager.currentUserId }
        set { dataManager.currentUserId = newValue }
    }

    public var basicChat: Bool {
        get { dataManager.basicChat }
        set { dataManager.basicChat = newValue }
    }

    public var basicChatPublisher: AnyPublisher<Bool, Never> {
        get { dataManager.basicChatPublisher }
    }

    public var publicRoomsPublisher: AnyPublisher<[Room], Never> {
        get {dataManager.publicRoomsPublisher}
    }

    public func readRoomById(id: String) throws -> Room {
        guard let room = dataManager.findPublicRoomById(id: id) else {
            throw AppError.unknown("room not found")
        }

        return room
    }

    public func allUsersPublisher() -> AnyPublisher<[ChatUser], Never> {
        dataManager.allUsersPublisher()
    }

    // MARK: Public interface
    public func setup(withDitto ditto: DittoSwift.Ditto, usersCollection: String) {
        dataManager.setUp(ditto: ditto, usersCollection: usersCollection)
    }

    // MARK: Create
    public func createRoom(withConfig config: RoomConfig) throws -> String {
        guard let id = dataManager.createRoom(id: config.id, name: config.name, isPrivate: config.isPrivate) else {
            throw AppError.unknown("room not found")
        }

        return id.stringValue
    }

    public func createMessage(withConfig config: MessageConfig) throws {
        let room = try readRoomById(id: config.roomId)

        dataManager.createMessage(for: room, text: config.message)
    }

    public func setCurrentUser(withConfig config: UserConfig) {
        dataManager.setCurrentUser(id: config.id)
    }

    // MARK: Read
    public func read(messagesForRoom room: Room) throws {
        dataManager.readMessagesForRoom(room: room)
    }

    public func read(messagesForUser user: ChatUser) throws {
        dataManager.readMessagesForUser(user: user)
    }

    // MARK: Update
    public func updateRoom(room: Room) throws {
        dataManager.updateRoom(room)
    }

    // MARK: Delete
    public func delete(roomById id: String) throws {
        let room = try readRoomById(id: id)

        dataManager.deleteRoom(room)
    }

    public func delete(room: Room) {
        dataManager.deleteRoom(room)
    }

    /// Clears references to Ditto and running subscritopns as well as observers.
    /// Note: Make sure that you call stop sync before calling this logout function.
    public func logout() {
        dataManager.logout()
        dataManager = nil
    }
}
