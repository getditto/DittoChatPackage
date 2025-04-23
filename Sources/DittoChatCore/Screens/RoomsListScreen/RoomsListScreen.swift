//
//  RoomsListScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 2/17/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

public struct RoomsListScreen: View {
    @ObservedObject var viewModel: RoomsListScreenVM
    private let dataManager: DataManager

    public init(dataManager: DataManager) {
        self.dataManager = dataManager
        self.viewModel = RoomsListScreenVM(dataManager: dataManager)
    }

    public var body: some View {
        List {
            if let defaultPublicRoom = viewModel.defaultPublicRoom {
                Section(openPublicRoomTitleKey) {
                    NavigationLink(destination: ChatScreen(room: defaultPublicRoom, dataManager: dataManager)) {
                        RoomsListRowItem(room: defaultPublicRoom, dataManager: viewModel.dataManager)
                    }
                    #if !os(tvOS)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            viewModel.toggleSubscriptionFor(room: defaultPublicRoom)
                        }, label: {
                            Text("Sub")
                        })
                    }
                    #endif
                }
            }
            Section( viewModel.publicRooms.count > 0 ? publicRoomsTitleKey : "" ) {
                ForEach(viewModel.publicRooms) { room in
                    NavigationLink(destination: ChatScreen(room: room, dataManager: dataManager)) {
                        RoomsListRowItem(room: room, dataManager: viewModel.dataManager)
                    }
                    #if !os(tvOS)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(settingsHideTitleKey) {
                            viewModel.archiveRoom(room)
                        }
                        .tint(.red)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            viewModel.toggleSubscriptionFor(room: room)
                        }, label: {
                            Text("Sub")
                        })
                    }
                    #endif
                }
            }
        }
#if !os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Room.self) { room in
            ChatScreen(room: room, dataManager: viewModel.dataManager, retentionDays: nil)
                .withErrorHandling()
        }
#endif
        .sheet(isPresented: $viewModel.presentCreateRoomScreen) {
            RoomEditScreen(dataManager: viewModel.dataManager)
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Text(appTitleKey)
                    .fontWeight(.bold)
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.createRoomButtonAction()
                } label: {
                    Label(newRoomTitleKey, systemImage: plusMessageFillKey)
                }
            }
        }
    }
}

#if DEBUG
import DittoSwift
struct RoomsListScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoomsListScreen(dataManager: DataManager(ditto: Ditto(), usersCollection: "users"))
        }
    }
}
#endif
