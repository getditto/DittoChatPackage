package com.example.dittochat.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.dittochat.model.ChatUser
import com.example.dittochat.model.MessageWithUser
import com.example.dittochat.repository.ChatRepository
import com.example.dittochat.model.Room
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class ChatViewModel(
    private val repository: ChatRepository,
    val currentUser: ChatUser
) : ViewModel() {

    val messages: StateFlow<List<MessageWithUser>> = repository.messagesFlow

    fun observeMessages(room: Room) {
        repository.observeMessages(room)
    }

    fun sendMessage(room: Room, text: String) {
        viewModelScope.launch {
            repository.sendMessage(room, currentUser, text)
        }
    }
}
