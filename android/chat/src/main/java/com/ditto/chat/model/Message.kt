package com.ditto.chat.model

import java.util.Date
import java.util.UUID

/**
 * Data model mirroring the Swift `Message` struct.
 */
data class Message(
    val id: String = UUID.randomUUID().toString(),
    val createdOn: Date = Date(),
    val roomId: String,
    val text: String = "",
    val userId: String,
    val largeImageToken: Map<String, Any>? = null,
    val thumbnailImageToken: Map<String, Any>? = null,
    val archivedMessage: String? = null,
    val isArchived: Boolean = false,
    val authorCs: String = "",
    val authorId: String = "",
    val authorLoc: String = "",
    val authorType: String = "",
    val msg: String = "",
    val parent: String = "",
    val pks: String = "",
    val room: String = "",
    val schver: Int = 0,
    val takUid: String = "",
    val timeMs: Date = Date(),
    val hasBeenConverted: Boolean? = null
) {
    val isImageMessage: Boolean
        get() = thumbnailImageToken != null || largeImageToken != null
}
