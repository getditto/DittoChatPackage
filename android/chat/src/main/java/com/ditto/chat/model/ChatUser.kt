package com.ditto.chat.model

data class ChatUser(
    val id: String,
    val firstName: String,
    val lastName: String
) {
    val fullName: String get() = "$firstName $lastName"
}
