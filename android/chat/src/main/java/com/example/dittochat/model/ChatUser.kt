package com.example.dittochat.model

data class ChatUser(
    val id: String,
    val firstName: String,
    val lastName: String
) {
    val fullName: String get() = "$firstName $lastName"
}
