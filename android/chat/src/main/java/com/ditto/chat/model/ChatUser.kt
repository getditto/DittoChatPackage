package com.ditto.chat.model

import java.util.Date

/**
 * Mirrors the structure used by the iOS implementation.
 */
data class ChatUser(
    val id: String,
    val name: String? = null,
    @Deprecated("Replaced with 'name'") val firstName: String? = null,
    @Deprecated("Replaced with 'name'") val lastName: String? = null,
    val subscriptions: Map<String, Date?> = emptyMap(),
    val mentions: Map<String, List<String>> = emptyMap()
) {
    val fullName: String get() = name ?: "$firstName $lastName"

    companion object {
        fun unknownUser(): ChatUser = ChatUser(
            id = "unknownUserId",
            name = "[no name]",
            firstName = "[no firstname]",
            lastName = "[no lastname]"
        )
    }
}
