//
//  LocalDataInterface.swift
//  DittoChatPackage
//
//  Created by Erik Everson on 4/25/25.
//


import Combine
import DittoSwift

protocol LocalDataInterface {
    var archivedPublicRoomIDs: [String] { get }
    var archivedPublicRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func archivePublicRoom(_ room: Room)
    func unarchivePublicRoom(_ room: Room)

    var currentUserId: String? { get set }
    var currentUserIdPublisher: AnyPublisher<String?, Never> { get }
}
