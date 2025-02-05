//
//  RoomsListScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 2/17/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

public struct RoomsListScreen: View {
    @ObservedObject var viewModel = RoomsListScreenVM()

    public init() { /*Make init public access level*/ }

    public var body: some View {
        List {
            if let defaultPublicRoom = viewModel.defaultPublicRoom {
                Section(openPublicRoomTitleKey) {
                    NavigationLink(destination: ChatScreen(room: defaultPublicRoom)) {
                        RoomsListRowItem(room: defaultPublicRoom)
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
            if let defaultTAKPublicRoom = viewModel.defaultTAKPublicRoom {
                Section(takPublicRoomTitleKey) {
                    NavigationLink(destination: ChatScreen(room: defaultTAKPublicRoom)) {
                        RoomsListRowItem(room: defaultTAKPublicRoom)
                    }
                    #if !os(tvOS)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            viewModel.toggleSubscriptionFor(room: defaultTAKPublicRoom)
                        }, label: {
                            Text("Sub")
                        })
                    }
                    #endif
                }
            }
            Section( viewModel.publicRooms.count > 0 ? publicRoomsTitleKey : "" ) {
                ForEach(viewModel.publicRooms) { room in
                    NavigationLink(destination: ChatScreen(room: room)) {
                        RoomsListRowItem(room: room)
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
            
            Section( viewModel.privateRooms.count > 0 ? privateRoomsTitleKey : "" ) {
                ForEach(viewModel.privateRooms) { room in
                    NavigationLink(destination: ChatScreen(room: room)) {
                        RoomsListRowItem(room: room)
                    }
                    #if !os(tvOS)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(settingsLeaveTitleKey) {
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
            ChatScreen(room: room)
                .withErrorHandling()
        }
#endif
        .sheet(isPresented: $viewModel.presentCreateRoomScreen) {
            RoomEditScreen()
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
struct RoomsListScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoomsListScreen()
        }
    }
}
#endif
