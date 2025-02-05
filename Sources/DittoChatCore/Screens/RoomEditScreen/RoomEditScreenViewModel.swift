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
    @Published var isValid = true
    private let dataManager: DataManager

    init(dataManager: DataManager) {
        self.dataManager = dataManager

        $name
            .map { $0.isEmpty }
            .assign(to: &$saveButtonDisabled)
    }

    func createRoom() {
        let _ = dataManager.createRoom(name: name, isPrivate: false)
    }
}
