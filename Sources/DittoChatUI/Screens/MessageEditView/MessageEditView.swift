//
//  MessageEditView.swift
//  DittoChat
//
//  Created by Eric Turner on 3/30/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import Combine
import SwiftUI
import DittoChatCore

class MessageEditVM: ObservableObject {
    @Published var editText: String
    @Published var messagesWithUsers: ArraySlice<MessageWithUser>
    @Published var keyboardStatus: KeyboardChangeEvent = .unchanged
    var editUsrMsg: MessageWithUser
    let saveCallback: (Message) -> Void
    let cancelCallback: () -> Void

    init(
        _ msgsUsers: (editUsrMsg: MessageWithUser, chats: ArraySlice<MessageWithUser>),
        saveEditCallback: @escaping (Message) -> Void,
        cancelEditCallback: @escaping () -> Void
    ) {
        self.editUsrMsg = msgsUsers.editUsrMsg
        self.editText = editUsrMsg.message.text
        self.messagesWithUsers = msgsUsers.chats
        self.saveCallback = saveEditCallback
        self.cancelCallback = cancelEditCallback

        #if !os(tvOS)
        DispatchQueue.main.async {
            Publishers.keyboardStatus
                .assign(to: &self.$keyboardStatus)
        }
        #endif
    }

    var editMessage: Message {
        editUsrMsg.message
    }

    func editCallback() {
        editUsrMsg.message.text = editText
    }

    func saveEdit() {
        editUsrMsg.message.text = editText
        saveCallback(editUsrMsg.message)
    }
}

struct MessageEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: MessageEditVM
    private let dittoChat: DittoChat

    init(
        _ msgsUsers: (editUsrMsg: MessageWithUser, chats: ArraySlice<MessageWithUser>),
        saveEditCallback: @escaping (Message) -> Void,
        cancelEditCallback: @escaping () -> Void,
        dittoChat: DittoChat
    ) {
        self._viewModel = StateObject(
            wrappedValue: MessageEditVM(
                msgsUsers,
                saveEditCallback: saveEditCallback,
                cancelEditCallback: cancelEditCallback
            )
        )

        self.dittoChat = dittoChat
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messagesWithUsers) { usrMsg in
                            bubbleView(for: usrMsg)
                                .transition(.slide)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    DispatchQueue.main.async {
                        withAnimation {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
                .onChange(of: viewModel.editText) { value in
                    withAnimation {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.keyboardStatus) { status in
                    if status == .didShow || status == .didHide {
                        withAnimation {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
            }

            Spacer()

            ChatInputView(
                text: $viewModel.editText,
                onSendButtonTappedCallback: viewModel.saveEdit
            )
        }
        #if !os(tvOS)
        .listStyle(.inset)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.cancelCallback()
                    dismiss()
                } label: {
                    Text(cancelTitleKey)
                }
                .buttonStyle(.borderless)
            }
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(editingTitleKey).font(.subheadline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.saveEdit()
                } label: {
                    Text(saveTitleKey)
                }
                .buttonStyle(.borderless)
            }
        }
    }

    @ViewBuilder
    func bubbleView(for usrMsg: MessageWithUser) -> some View {
        if usrMsg.id != viewModel.editUsrMsg.id {
            MessageBubbleView(
                messageWithUser: usrMsg,
                messagesId: "placeholder_in_MessageEditView",
                isEditing: .constant(true),
                dittoChat: dittoChat
            )
            .id(usrMsg.id)
        } else {
            EditMessageBubbleView(viewModel: viewModel)
                .id(viewModel.editUsrMsg.id)
        }
    }

    func saveEditedText(_ text: String) {
        viewModel.editUsrMsg.message.text = text
    }

    func scrollToBottom(proxy: ScrollViewProxy) {
        proxy.scrollTo(viewModel.messagesWithUsers.last?.id)
    }
}
