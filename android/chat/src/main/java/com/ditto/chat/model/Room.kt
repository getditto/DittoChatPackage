package com.ditto.chat.model

data class Room(
    val id: String,
    val name: String,
    val messagesId: String = "messages_$id"
)
