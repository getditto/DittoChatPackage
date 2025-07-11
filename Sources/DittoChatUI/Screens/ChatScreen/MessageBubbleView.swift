//
//  MessageBubbleView.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//
//  Credits to: https://prafullkumar77.medium.com/swiftui-creating-a-chat-bubble-like-imessage-using-path-and-shape-67cf23ccbf62
//

import Combine
import DittoSwift
import SwiftUI
import DittoChatCore

struct MessageBubbleView: View {
    @StateObject var errorHandler: ErrorHandler = ErrorHandler()
    @StateObject private var viewModel: MessageBubbleVM
    @State private var needsImageSync = true
    @Binding var isEditing: Bool
    let messageUser: MessageWithUser
    var messageOpCallback: ((MessageOperation, Message) -> Void)?
    private let dittoChat: DittoChat

    init(
        messageWithUser: MessageWithUser,
        messagesId: String,
        messageOpCallback: ((MessageOperation, Message) -> Void)? = nil,
        isEditing: Binding<Bool>,
        dittoChat: DittoChat
    ) {
        self._viewModel = StateObject(
            wrappedValue: MessageBubbleVM(messageWithUser.message, messagesId: messagesId, dittoChat: dittoChat)
        )
        self.messageUser = messageWithUser
        self._isEditing = isEditing
        self.needsImageSync = messageWithUser.message.thumbnailImageToken != nil
        self.messageOpCallback = messageOpCallback
        self.dittoChat = dittoChat
    }

    private var user: ChatUser {
        messageUser.user
    }

    private var message: Message {
        messageUser.message
    }

    private var hasThumbnail: Bool {
        message.thumbnailImageToken != nil
    }

    private var isImageMessage: Bool {
        message.isImageMessage
    }

    // large images sent by local user are always stored in Ditto db
    // and always available to local user to preview at full rez
    private var largeImageAvailable: Bool {
        if message.thumbnailImageToken != nil {
            if message.userId == dittoChat.currentUserId
                || dittoChat.acceptLargeImages
            {
                return true
            }
        }
        return false
    }

    private var side: MessageBubbleShape.Side {
        if forPreview {
            if user.id == previewUserId {
                return .right
            }
        } else {
            if user.id == dittoChat.currentUserId {
                return .right
            }
        }
        return .left
    }

    private var isSelfUser: Bool {
        if forPreview {
            return user.id == previewUserId
        }
        return user.id == dittoChat.currentUserId
    }

    private var backgroundColor: Color {
        #if !os(tvOS)
        if side == .left {
            return Color(.systemFill)
        }
        #endif
        return Color.accentColor
    }

    private var textColor: Color {
        if side == .left {
            return Color(.label)
        }
        return Color.white
    }

    private var rowInsets: EdgeInsets {
        let leftEdge: CGFloat = hasThumbnail && side == .right ? 80 : 20
        let rightEdge: CGFloat = hasThumbnail && side == .left ? 80 : 20
        return EdgeInsets(
            top: isSelfUser ? -4 : 16,
            leading: leftEdge,
            bottom: isSelfUser ? 8 : 0,
            trailing: rightEdge
        )
    }

    private var textInsets: EdgeInsets {
        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    }

    var body: some View {
        VStack(alignment: side == .right ? .trailing : .leading, spacing: 2) {
            Text(isSelfUser ? "" : user.name)
                .font(.caption2)
                .opacity(0.6)
                .padding(.leading, 15)

            HStack {
                switch side {
                case .left:
                    VStack(alignment: .leading, spacing: 2) {
                        VStack(alignment: .leading, spacing: 2) {
                            if hasThumbnail {
                                attachmentContentView()
                            }

                            textContentView()
                                .padding(textInsets)
                        }
                        .background(backgroundColor)
                        .foregroundColor(textColor)
                        .clipShape(MessageBubbleShape(side: side))
                        .contextMenu {
                            contextMenuContent()
                        }

                        Text(DateFormatter.shortTime.string(from: message.createdOn))
                            .font(.caption2)
                            .opacity(0.6)
                            .padding(.leading, 15)
                    }

                    Spacer()
                case .right:
                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        VStack(alignment: .trailing, spacing: 2) {
                            if hasThumbnail {
                                attachmentContentView()
                            }

                            textContentView()
                                .padding(textInsets)
                        }
                        .background(backgroundColor)
                        .foregroundColor(textColor)
                        .clipShape(MessageBubbleShape(side: side))
                        .contextMenu {
                            contextMenuContent()
                        }

                        Text(DateFormatter.shortTime.string(from: message.createdOn))
                            .font(.caption2)
                            .opacity(0.6)
                            .padding(.leading, 15)
                    }
                }
            }
            .alert(deleteMessageTitleKey, isPresented: $viewModel.presentDeleteAlert) {
                deleteAlertContent()
            }
        }
        .padding(rowInsets)
        .task {
            if needsImageSync {
                needsImageSync = false
                if let _ = message.thumbnailImageToken {
                    await viewModel.fetchAttachment(type: .thumbnailImage)
                }
            }
        }
    }
    
    @ViewBuilder
    func textContentView() -> some View {
        if !message.text.isEmpty {
            Text(message.text)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    func attachmentContentView() -> some View {
        if let image = viewModel.thumbnailImage {
            VStack(spacing: 0) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .edgesIgnoringSafeArea([.top, .horizontal])
        } else {
            DittoProgressView($viewModel.thumbnailProgress, side: 100)
                .frame(width: 140, height: 120, alignment: .center)
        }
    }

    @ViewBuilder
    func contextMenuContent() -> some View {
        // display full rez image if EnableLargeImages option is set in Settings, or if local user,
        // if not editing
        if canDisplayLargeImage() {
            Button {
                if let show = messageOpCallback {
                    show(.presentAttachment, message)
                } else {
                    errorHandler.handle(
                        error: AttachmentError.unknown(attachmentMessageErrorTextKey)
                    )
                }
            } label: {
                Text(viewImageTitleKey)
            }
        }
        // Only allow edit on local user text messages when not editing
        if canEdit() {
            if !isImageMessage {
                Button {
                    if let edit = messageOpCallback {
                        edit(.edit, message)
                    } else {
                        errorHandler.handle(
                            error: AppError.unknown(editMessageErrorTextKey)
                        )
                    }
                } label: {
                    Text(editTitleKey)
                }
            }
        }
        
        // Only allow delete on local user messages when not editing
        if canDelete() {
            Button {
                if let _ = messageOpCallback {
                    viewModel.presentDeleteAlert = true
                } else {
                    errorHandler.handle(
                        error: AppError.unknown(deleteMessageErrorTextKey)
                    )
                }
            } label: {
                Text(deleteTitleKey)
            }
        }
        
        EmptyView()
    }
    
    @ViewBuilder
    func deleteAlertContent() -> some View {
        VStack {
            Button(deleteEverywhereTitleKey, role: .destructive) {
                messageOpCallback?(
                    hasThumbnail ? .deleteImage : .deleteText,
                    message
                )
            }
            Button(cancelTitleKey, role: .cancel) { }
        }
    }

    private func canDisplayLargeImage() -> Bool {
        guard !isEditing else { return false }
        guard isImageMessage else { return false }
        guard let _ = message.largeImageToken else { return false }
        return isSelfUser || largeImageAvailable
    }

    private func canEdit() -> Bool {
        guard !isEditing else { return false }
        return isSelfUser && !isImageMessage
    }
        
    private func canDelete() -> Bool {
        guard !isEditing else { return false }
        return isSelfUser
    }

    // for previewing
    private var forPreview = false
    private var previewUserId = "me"
    fileprivate init(
        messageWithUser: MessageWithUser,
        messagesId: String = "xyz",
        preview: Bool,
        isEditing: Binding<Bool> = .constant(false)
    ) {
        let dittoChat =  DittoChat(config: ChatConfig(ditto: Ditto(), usersCollection: "users"))

        self._viewModel = StateObject(
            wrappedValue: MessageBubbleVM(
                Message(roomId: "abc", text: "Hello World!"),
                messagesId: messagesId,
                dittoChat: dittoChat
            )
        )
        self._isEditing = isEditing
        self.messageUser = messageWithUser
        self.forPreview = preview
        self.messageOpCallback = nil
        self.dittoChat = dittoChat
    }
}


struct MessageBubbleShape: Shape {
    enum Side {
        case left
        case right
    }

    let side: Side

    func path(in rect: CGRect) -> Path {
        return (side == .left) ? getLeftBubblePath(in: rect) : getRightBubblePath(in: rect)
    }

    private func getLeftBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x: width - 20, y: height))
            p.addCurve(to: CGPoint(x: width, y: height - 20),
                       control1: CGPoint(x: width - 8, y: height),
                       control2: CGPoint(x: width, y: height - 8))
            p.addLine(to: CGPoint(x: width, y: 20))
            p.addCurve(to: CGPoint(x: width - 20, y: 0),
                       control1: CGPoint(x: width, y: 8),
                       control2: CGPoint(x: width - 8, y: 0))
            p.addLine(to: CGPoint(x: 21, y: 0))
            p.addCurve(to: CGPoint(x: 4, y: 20),
                       control1: CGPoint(x: 12, y: 0),
                       control2: CGPoint(x: 4, y: 8))
            p.addLine(to: CGPoint(x: 4, y: height - 11))
            p.addCurve(to: CGPoint(x: 0, y: height),
                       control1: CGPoint(x: 4, y: height - 1),
                       control2: CGPoint(x: 0, y: height))
            p.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
            p.addCurve(to: CGPoint(x: 11.0, y: height - 4.0),
                       control1: CGPoint(x: 4.0, y: height + 0.5),
                       control2: CGPoint(x: 8, y: height - 1))
            p.addCurve(to: CGPoint(x: 25, y: height),
                       control1: CGPoint(x: 16, y: height),
                       control2: CGPoint(x: 20, y: height))

        }
        return path
    }

    private func getRightBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x:  20, y: height))
            p.addCurve(to: CGPoint(x: 0, y: height - 20),
                       control1: CGPoint(x: 8, y: height),
                       control2: CGPoint(x: 0, y: height - 8))
            p.addLine(to: CGPoint(x: 0, y: 20))
            p.addCurve(to: CGPoint(x: 20, y: 0),
                       control1: CGPoint(x: 0, y: 8),
                       control2: CGPoint(x: 8, y: 0))
            p.addLine(to: CGPoint(x: width - 21, y: 0))
            p.addCurve(to: CGPoint(x: width - 4, y: 20),
                       control1: CGPoint(x: width - 12, y: 0),
                       control2: CGPoint(x: width - 4, y: 8))
            p.addLine(to: CGPoint(x: width - 4, y: height - 11))
            p.addCurve(to: CGPoint(x: width, y: height),
                       control1: CGPoint(x: width - 4, y: height - 1),
                       control2: CGPoint(x: width, y: height))
            p.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
            p.addCurve(to: CGPoint(x: width - 11, y: height - 4),
                       control1: CGPoint(x: width - 4, y: height + 0.5),
                       control2: CGPoint(x: width - 8, y: height - 1))
            p.addCurve(to: CGPoint(x: width - 25, y: height),
                       control1: CGPoint(x: width - 16, y: height),
                       control2: CGPoint(x: width - 20, y: height))

        }
        return path
    }
}


#if DEBUG
import Fakery
struct MessageBubbleView_Previews: PreviewProvider {
    static let faker = Faker()

    static var messagesWithUsers: [MessageWithUser] = [
        MessageWithUser(
            message: Message(
                id: UUID().uuidString,
                createdOn: Date(),
                roomId: publicKey,
                text: Self.faker.lorem.sentence(),
                userId: "max"
            ),
            user: ChatUser(id: "max", name: "Maximilian Alexander", subscriptions: [:], mentions: [:])
        ),
        MessageWithUser(
            message: Message(
                id: UUID().uuidString,
                createdOn: Date(),
                roomId: publicKey,
                text: Self.faker.lorem.paragraph(sentencesAmount: 12),
                userId: "me"
            ),
            user: ChatUser(id: "me", name: "Me NotYou", subscriptions: [:], mentions: [:])
        ),
        MessageWithUser(
            message: Message(
                id: UUID().uuidString,
                createdOn: Date(),
                roomId: publicKey,
                text: Self.faker.lorem.sentence(),
                userId: "max"
            ),
            user: ChatUser(id: "max", name: "Maximilian Alexander", subscriptions: [:], mentions: [:])
        ),
        MessageWithUser(
            message: Message(
                id: UUID().uuidString,
                createdOn: Date(),
                roomId: publicKey,
                text: Self.faker.lorem.sentence(),
                userId: "me"
            ),
            user: ChatUser(id: "me", name: "Me NotYou", subscriptions: [:], mentions: [:])
        ),
    ]

    static var previews: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(messagesWithUsers) { message in
                    MessageBubbleView(messageWithUser: message, preview: true)
                }
            }
        }
    }
}
#endif
