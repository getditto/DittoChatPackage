//
//  ChatScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 02/24/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import PhotosUI
import SwiftUI

public struct ChatScreen: View {
    @StateObject var viewModel: ChatScreenVM
    @EnvironmentObject var errorHandler: ErrorHandler

    public init(room: Room) {
        _viewModel = StateObject(wrappedValue: ChatScreenVM(room: room))
    }

    var navBarTitle: String {
        if viewModel.isBasicChatScreen {
            return appTitleKey
        } else {
            return viewModel.roomName
        }
    }

    public var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messagesWithUsers) { usrMsg in
                            MessageBubbleView(
                                messageWithUser: usrMsg,
                                messagesId: viewModel.room.messagesId,
                                messageOpCallback: viewModel.messageOperationCallback,
                                isEditing: $viewModel.isEditing
                            )
                            .id(usrMsg.message.id)
                            .transition(.slide)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    DispatchQueue.main.async {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.messagesWithUsers.count) { _ in
                    DispatchQueue.main.async {
                        withAnimation {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
                .onChange(of: viewModel.keyboardStatus) { status in
                    guard !viewModel.presentEditingView else { return }
                    if status == .willShow || status == .willHide { return }
                    withAnimation {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            HStack(alignment: .top) {
                #if !os(tvOS)
                photosPickerButtonView
                    .padding(.top, 4)
                #endif

                ChatInputView(
                    text: $viewModel.inputText,
                    onSendButtonTappedCallback: viewModel.sendMessage
                )
            }
        }
        #if !os(tvOS)
        .listStyle(.inset)
        .navigationTitle(navBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(
            isPresented: $viewModel.presentAttachmentView,
            onDismiss: {
                viewModel.cleanupAttachmentAttribs()
            }
        ) {
            AttachmentPreview(
                vm: MessageBubbleVM(
                    viewModel.attachmentMessage!,
                    messagesId: viewModel.room.messagesId
                ),
                errorHandler: errorHandler
            )
        }
        #endif
        .sheet(isPresented: $viewModel.presentShareRoomScreen) {
            if let codeStr = viewModel.shareQRCode() {
                QRCodeView(
                    roomName: viewModel.roomName,
                    codeString: codeStr
                )
            } else {
                NavigationView {
                    GeneralErrorView(message: AppError.qrCodeFail.localizedDescription)
                }
            }
        }
        .sheet(isPresented: $viewModel.presentProfileScreen) { // basic chat mode
            ProfileScreen()
        }
        .sheet(isPresented: $viewModel.presentSettingsView) { // basic chat mode
            SettingsScreen()
        }
        .toolbar {
            // basic chat mode
            if viewModel.isBasicChatScreen {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        viewModel.presentProfileScreen = true
                    } label: {
                        Image(systemName: personCircleKey)
                    }
                    Button {
                        viewModel.presentSettingsView = true
                    } label: {
                        Image(systemName: gearShapeKey)
                    }
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if viewModel.room.isPrivate {
                    Button {
                        viewModel.presentShareRoomScreen = true
                    } label: {
                        Image(systemName: qrCodeKey)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.presentEditingView) {
            if let msgsUsers = try? viewModel.editMessagesWithUsers() {
                NavigationView {
                    MessageEditView(
                        msgsUsers,
                        roomName: viewModel.roomName,
                        saveEditCallback: viewModel.saveEditedTextMessage,
                        cancelEditCallback: viewModel.cancelEditCallback
                    )
                }
            } else {
                EmptyView()
            }
        }
    }
    #if !os(tvOS)
    var photosPickerButtonView: some View {
        PhotosPicker(selection: $viewModel.selectedItem,
                     matching: .images,
                     photoLibrary: .shared())
        {
            Image(systemName: cameraFillKey)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 28))
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.borderless)
        .onChange(of: viewModel.selectedItem) { newValue in
            Task {
                do {
                    let imageData = try await newValue?.loadTransferable(type: Data.self)

                    if let image = UIImage(data: imageData ?? Data()) {
                        viewModel.selectedImage = image

                        do {
                            try await viewModel.sendImageMessage()
                        } catch {
                            errorHandler.handle(error: error)
                        }
                    }
                } catch {
                    errorHandler.handle(error: AttachmentError.iCloudLibraryImageFail)
                }
            }
        }
    }
    #endif
    func scrollToBottom(proxy: ScrollViewProxy) {
        proxy.scrollTo(viewModel.messagesWithUsers.last?.id)
    }
}

#if DEBUG
struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatScreen(room: Room(id: "abc", name: "My Room", messagesId: "def", isPrivate: true))
    }
}
#endif
