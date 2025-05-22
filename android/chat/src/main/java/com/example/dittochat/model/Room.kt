package com.example.dittochat.model

data class Room(
    val id: String,
    val name: String,
    val messagesId: String = "messages_$id"
)
