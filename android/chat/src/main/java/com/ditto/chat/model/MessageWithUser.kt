package com.ditto.chat.model

data class MessageWithUser(
    val message: Message,
    val user: ChatUser
)
