package com.example.dittochat.model

import java.util.UUID

data class Message(
    val id: String = UUID.randomUUID().toString(),
    val roomId: String,
    val userId: String,
    val text: String,
    val createdOn: Long = System.currentTimeMillis()
)
