package com.ditto.chat.model

import java.util.Date

/**
 * Kotlin representation of the iOS `Room` model.
 */
data class Room(
    val id: String,
    val name: String,
    val messagesId: String,
    val collectionId: String? = null,
    val createdBy: String,
    val createdOn: Date,
    val isGenerated: Boolean = false
)
