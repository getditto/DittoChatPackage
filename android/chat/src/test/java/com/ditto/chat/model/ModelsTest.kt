package com.ditto.chat.model

import org.junit.Assert
import org.junit.Test

class ModelsTest {
    @Test
    fun chatUserFullName() {
        val user = ChatUser("1", "Jane", "Doe")
        Assert.assertEquals("Jane Doe", user.fullName)
    }

    @Test
    fun roomDefaultMessagesId() {
        val room = Room(id = "abc", name = "General")
        Assert.assertEquals("messages_abc", room.messagesId)
    }
}