package com.example.dittochat.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.dittochat.model.ChatUser
import com.example.dittochat.model.MessageWithUser
import com.example.dittochat.model.Room
import com.example.dittochat.repository.ChatRepository
import live.ditto.Ditto

@Composable
fun ChatScreen(room: Room, viewModel: ChatViewModel) {
    LaunchedEffect(room.id) { viewModel.observeMessages(room) }
    val messages by viewModel.messages.collectAsState()
    var text by remember { mutableStateOf("") }

    Column(modifier = Modifier.fillMaxSize()) {
        LazyColumn(modifier = Modifier.weight(1f)) {
            items(messages) { msg ->
                MessageBubble(msg, viewModel.currentUser)
            }
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextField(
                value = text,
                onValueChange = { text = it },
                modifier = Modifier.weight(1f),
                placeholder = { Text("Message") }
            )
            IconButton(onClick = { viewModel.sendMessage(room, text); text = "" }) {
                Icon(Icons.Default.Send, contentDescription = "Send")
            }
        }
    }
}

@Composable
fun MessageBubble(messageWithUser: MessageWithUser, currentUser: ChatUser) {
    val isMe = messageWithUser.user.id == currentUser.id
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(4.dp),
        horizontalArrangement = if (isMe) Arrangement.End else Arrangement.Start
    ) {
        Surface(shape = MaterialTheme.shapes.medium, color = MaterialTheme.colorScheme.primaryContainer) {
            Column(modifier = Modifier.padding(8.dp)) {
                Text(text = messageWithUser.user.fullName, style = MaterialTheme.typography.labelSmall)
                Text(text = messageWithUser.message.text)
            }
        }
    }
}

@Preview
@Composable
private fun PreviewChat() {
    // Preview uses an empty UI as Ditto requires initialization
    MaterialTheme {
        Surface(modifier = Modifier.fillMaxSize()) {}
    }
}
