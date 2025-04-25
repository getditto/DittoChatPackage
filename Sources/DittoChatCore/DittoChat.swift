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
    var dataManager: DataManager { get }
    // Create
    func createRoom(withConfig: RoomConfig) async throws -> String
    func createMessage(withConfig: MessageConfig) throws
    func setCurrentUser(withConfig: UserConfig)

    // Read
    var publicRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func readRoomById(id: String) throws -> Room
    func allUsersPublisher() -> AnyPublisher<[ChatUser], Never>

    // Update
    func updateRoom(room: Room) async throws

    func logout()
}

public struct RoomConfig {
    public let id: String?
    public let name: String

    public init(id: String? = nil, name: String) {
        self.id = id
        self.name = name
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

public struct ChatConfig {
    public var ditto: Ditto
    public var retentionPolicy: ChatRetentionPolicy
    public var takChatEnabled: Bool
    public var usersCollection: String
    public var userId: String?

    public init(
        ditto: Ditto, retentionPolicy: ChatRetentionPolicy = .init(days: 30), usersCollection: String = "users", 
        userId: String? = nil, takEnabled: Bool? = nil
    ) {
        self.ditto = ditto
        self.retentionPolicy = retentionPolicy
        self.usersCollection = usersCollection
        self.takChatEnabled = takEnabled ?? false
        self.userId = userId
    }
}

// TODO: Hook this up to actually work
public struct ChatRetentionPolicy {
    public var days: Int
    
    public init(days: Int) {
        self.days = days
    }
}

public class DittoChat: DittoSwiftChat {
    public var dataManager: DataManager

    public init(config: ChatConfig) {
        self.dataManager = DataManager(ditto: config.ditto, usersCollection: config.usersCollection)
        dataManager.retentionPolicy = config.retentionPolicy
        if let userId = config.userId {
            self.setCurrentUser(withConfig: UserConfig(id: userId))
        }
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

    // MARK: Create
    public func createRoom(withConfig config: RoomConfig) async throws -> String {
        guard let id = await dataManager.createRoom(id: config.id, name: config.name) else {
            throw AppError.unknown("room not found")
        }

        return id
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

    /// Clears references to Ditto and running subscritopns as well as observers.
    /// Note: Make sure that you call stop sync before calling this logout function.
    public func logout() {
        dataManager.logout()
    }
}
