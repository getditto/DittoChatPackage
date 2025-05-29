package com.ditto.chat.model

data class ChatUser(
    val id: String,
    val name: String? = null,
    @Deprecated("Replaced with 'name'") val firstName: String? = null,
    @Deprecated("Replaced with 'name'") val lastName: String? = null
) {
    val fullName: String get() = name ?: "$firstName $lastName"
}
