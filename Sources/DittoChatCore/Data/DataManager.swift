//
//  DataManager.swift
//  DittoChat
//
//  Created by Eric Turner on 1/19/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import Combine
import DittoSwift
import SwiftUI

protocol LocalDataInterface {
    var acceptLargeImages: Bool { get set }
    var acceptLargeImagesPublisher: AnyPublisher<Bool, Never> { get }

    var archivedPublicRoomIDs: [String] { get }
    var archivedPublicRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func archivePublicRoom(_ room: Room)
    func unarchivePublicRoom(_ room: Room)

    var currentUserId: String? { get set }
    var currentUserIdPublisher: AnyPublisher<String?, Never> { get }

    var basicChat: Bool { get set }
    var basicChatPublisher: AnyPublisher<Bool, Never> { get }
}

protocol ReplicatingDataInterface {
    var ditto: Ditto { get }
    var publicRoomsPublisher: CurrentValueSubject<[Room], Never> { get }
    var peerKeyString: String { get }
    var sdkVersion: String { get }

    func room(for room: Room) async -> Room?
    func findPublicRoomById(id: String) -> Room?
    func createRoom(id: String?, name: String) async -> String?

    func archiveRoom(_ room: Room)
    func unarchiveRoom(_ room: Room)

    func createMessage(for rooom: Room, text: String)
    func saveEditedTextMessage(_ message: Message, in room: Room)
    func saveDeletedImageMessage(_ message: Message, in room: Room)
    func createImageMessage(for room: Room, image: UIImage, text: String?) async throws
    func messagesPublisher(for room: Room, retentionDays: Int?) -> AnyPublisher<[Message], Never>
    func messagePublisher(for msgId: String, in collectionId: String) -> AnyPublisher<Message, Never>
    func attachmentPublisher(
        for token: DittoAttachmentToken,
        in collectionId: String
    ) -> DittoStore.FetchAttachmentPublisher
    func createUpdateMessage(document: [String: Any?])

    func addUser(_ usr: ChatUser)
    func findUserById(_ id: String, inCollection collection: String) async throws -> ChatUser
    func updateUser(withId id: String,
                    firstName: String?,
                    lastName: String?,
                    subscriptions: [String: Date?]?,
                    mentions: [String: [String]]?)
    func currentUserPublisher() -> AnyPublisher<ChatUser?, Never>
    func allUsersPublisher() -> AnyPublisher<[ChatUser], Never>

    func logout()
}

open class DataManager {
    @Published private(set) var publicRoomsPublisher: AnyPublisher<[Room], Never>
    var retentionPolicy: ChatRetentionPolicy = .init(days: 30)

    private var localStore: LocalDataInterface
    var p2pStore: ReplicatingDataInterface

    init(ditto: Ditto, usersCollection: String) {
        let localStore: LocalStoreService = LocalStoreService()
        self.localStore = localStore
        self.p2pStore = DittoService(privateStore: localStore, ditto: ditto, usersCollection: usersCollection, chatRetentionPolicy: retentionPolicy)
        self.publicRoomsPublisher = p2pStore.publicRoomsPublisher.eraseToAnyPublisher()
    }

    func logout() {
        p2pStore.logout()
    }
}

extension DataManager {
    // MARK: Ditto Public Rooms

    func room(for room: Room) async -> Room? {
        await p2pStore.room(for: room)
    }

    public func findPublicRoomById(id: String) -> Room? {
        p2pStore.findPublicRoomById(id: id)
    }

    public func createRoom(id: String? = UUID().uuidString, name: String) async -> String? {
        return await p2pStore.createRoom(id: id, name: name)
    }

    func archiveRoom(_ room: Room) {
        p2pStore.archiveRoom(room)
    }

    func unarchiveRoom(_ room: Room) {
        p2pStore.unarchiveRoom(room)
    }

    func archivedPublicRoomsPublisher() -> AnyPublisher<[Room], Never> {
        localStore.archivedPublicRoomsPublisher
    }

    func readMessagesForRoom(room: Room) {
        // TODO: Implement
    }

    func readMessagesForUser(user: ChatUser) {
        // TODO: Implement
    }
}

extension DataManager {
    // MARK: Messages

    func createMessage(for room: Room, text: String) {
        p2pStore.createMessage(for: room, text: text)
    }

    func createImageMessage(for room: Room, image: UIImage, text: String?) async throws {
        try await p2pStore.createImageMessage(for: room, image: image, text: text)
    }

    func saveEditedTextMessage(_ message: Message, in room: Room) {
        p2pStore.saveEditedTextMessage(message, in: room)
    }

    func saveDeletedImageMessage(_ message: Message, in room: Room) {
        p2pStore.saveDeletedImageMessage(message, in: room)
    }

    func messagePublisher(for msgId: String, in collectionId: String) -> AnyPublisher<Message, Never> {
        p2pStore.messagePublisher(for: msgId, in: collectionId)
    }

    func messagesPublisher(for room: Room, retentionDays: Int?) -> AnyPublisher<[Message], Never> {
        p2pStore.messagesPublisher(for: room, retentionDays: retentionDays)
    }

    func attachmentPublisher(
        for token: DittoAttachmentToken,
        in collectionId: String
    ) -> DittoSwift.DittoStore.FetchAttachmentPublisher {
        p2pStore.attachmentPublisher(for: token, in: collectionId)
    }

    func createUpdateMessage(document: [String: Any?]) {
        p2pStore.createUpdateMessage(document: document)
    }
}

extension DataManager {
    // MARK: Current User

    var currentUserId: String? {
        get { localStore.currentUserId }
        set { localStore.currentUserId = newValue }
    }

    var currentUserIdPublisher: AnyPublisher<String?, Never> {
        localStore.currentUserIdPublisher
    }

    func currentUserPublisher() -> AnyPublisher<ChatUser?, Never> {
        p2pStore.currentUserPublisher()
    }

    func allUsersPublisher() -> AnyPublisher<[ChatUser], Never> {
        p2pStore.allUsersPublisher()
    }

    func addUser(_ usr: ChatUser) {
        p2pStore.addUser(usr)
    }

    func updateUser(withId id: String, firstName: String?, lastName: String?, subscriptions: [String: Date?]?, mentions: [String: [String]]?) {
        p2pStore.updateUser(withId: id, firstName: firstName, lastName: lastName, subscriptions: subscriptions, mentions: mentions)
    }

    func updateRoom(_ room: Room) {
        // TODO: Implement
    }

    func saveCurrentUser(firstName: String, lastName: String) {
        if currentUserId == nil {
            let userId = UUID().uuidString
            currentUserId = userId
        }

        assert(currentUserId != nil, "Error: expected currentUserId to not be NIL")

        let user = ChatUser(id: currentUserId!, firstName: firstName, lastName: lastName, subscriptions: [:], mentions: [:])
        p2pStore.addUser(user)
    }

    func setCurrentUser(id: String) {
        currentUserId = id
    }
}

extension DataManager {
    var sdkVersion: String {
        p2pStore.sdkVersion
    }

    var appInfo: String {
        let name = Bundle.main.appName
        let version = Bundle.main.appVersion
        let build = Bundle.main.appBuild
        return "\(name) \(version) build \(build)"
    }

    var peerKeyString: String {
        p2pStore.peerKeyString
    }
}

extension DataManager {
    var acceptLargeImages: Bool {
        get { localStore.acceptLargeImages }
        set { localStore.acceptLargeImages = newValue }
    }

    var acceptLargeImagesPublisher: AnyPublisher<Bool, Never> {
        localStore.acceptLargeImagesPublisher
    }
}

extension DataManager {
    var basicChat: Bool {
        get { localStore.basicChat }
        set { localStore.basicChat = newValue }
    }

    var basicChatPublisher: AnyPublisher<Bool, Never> {
        get { localStore.basicChatPublisher }
    }
}
