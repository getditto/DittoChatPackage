//
//  RoomEditScreen.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import SwiftUI
import DittoChatCore

struct RoomEditScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RoomEditScreenViewModel

    init(dittoChat: DittoChat) {
        self.viewModel = RoomEditScreenViewModel(dittoChat: dittoChat)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Room Name", text: Binding(
                        get: { viewModel.name },
                        set: { newValue in
                            if newValue.isValidInput(newValue) {
                                viewModel.name = String(newValue.prefix(2500))
                                viewModel.isValid = true
                            } else {
                                viewModel.isValid = false
                            }
                        }
                    ))
                }
                Section {
                    HStack {
                        Spacer()

                        Button {
                            viewModel.createRoom()
                            dismiss()
                        } label: {
                            Text("Create Room")
                        }
                        .disabled(viewModel.saveButtonDisabled)

                        Spacer()
                    }
                }
            }
            .navigationTitle("Create Room")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

#if DEBUG
import DittoSwift
struct RoomEditScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoomEditScreen(dittoChat: DittoChat(config: ChatConfig(ditto: Ditto(), usersCollection: "users")))
        }
    }
}
#endif
