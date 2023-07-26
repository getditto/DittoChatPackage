//
//  RoomEditScreenViewModel.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import Combine
import Foundation

class RoomEditScreenViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var saveButtonDisabled = false
    @Published var roomIsPrivate = false

    init() {
        $name
            .map(\.isEmpty)
            .assign(to: &$saveButtonDisabled)
    }

    func createRoom() {
        DataManager.shared.createRoom(name: name, isPrivate: roomIsPrivate)
    }
}
