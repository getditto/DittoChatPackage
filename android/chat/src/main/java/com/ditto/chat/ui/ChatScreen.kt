package com.ditto.chat.ui

import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.core.net.toUri
import com.ditto.chat.model.ChatUser
import com.ditto.chat.model.MessageWithUser
import com.ditto.chat.model.Room

@Composable
fun ChatScreen(room: Room, viewModel: ChatViewModel) {
    LaunchedEffect(Unit) { viewModel.observeRooms() }
    var currentRoom by remember { mutableStateOf(room) }
    LaunchedEffect(currentRoom.id) { viewModel.observeMessages(currentRoom) }
    val rooms by viewModel.rooms.collectAsState()
    val messages by viewModel.messages.collectAsState()
    var text by remember { mutableStateOf("") }
    val scope = rememberCoroutineScope()
    val listState = rememberLazyListState()
    var expanded by remember { mutableStateOf(false) }
    var previewImage by remember { mutableStateOf<Uri?>(null) }
    val context = LocalContext.current
    val imageLauncher = rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        if (uri != null) {
            viewModel.sendImage(currentRoom, uri.toString())
        }
    }

    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) listState.animateScrollToItem(messages.lastIndex)
    }

    Column(modifier = Modifier.fillMaxSize()) {
        if (rooms.size > 1) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp)
                    .clickable { expanded = true }
            ) {
                Text(currentRoom.name, modifier = Modifier.weight(1f))
                DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                    rooms.forEach { r ->
                        DropdownMenuItem(text = { Text(r.name) }, onClick = {
                            currentRoom = r
                            expanded = false
                        })
                    }
                }
            }
        }

        LazyColumn(
            state = listState,
            modifier = Modifier
                .weight(1f)
                .border(1.dp, MaterialTheme.colorScheme.outline)
                .fillMaxWidth(),
            reverseLayout = true // Reverses the order of items
        ) {
            items(messages) { msg ->
                MessageBubble(msg, viewModel.currentUser) { uri ->
                    previewImage = uri.toUri()
                }
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
            IconButton(onClick = { imageLauncher.launch("image/*") }) {
                Icon(Icons.Default.Add, contentDescription = "Add")
            }
            IconButton(onClick = { viewModel.sendMessage(currentRoom, text); text = "" }) {
                Icon(Icons.AutoMirrored.Filled.Send, contentDescription = "Send")
            }
        }

        if (previewImage != null) {
            Dialog(onDismissRequest = { previewImage = null }) {
                val bitmap = remember(previewImage) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        val src = ImageDecoder.createSource(context.contentResolver, previewImage!!)
                        ImageDecoder.decodeBitmap(src)
                    } else {
                        val inputStream = context.contentResolver.openInputStream(previewImage!!)
                        BitmapFactory.decodeStream(inputStream)
                    }
                }
                Image(bitmap = bitmap.asImageBitmap(), contentDescription = null, modifier = Modifier.fillMaxWidth())
            }
        }
    }
}

@Composable
fun MessageBubble(
    messageWithUser: MessageWithUser,
    currentUser: ChatUser,
    onImageClick: (String) -> Unit = {}
) {
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
                if (messageWithUser.message.isImageMessage) {
                    val uri = messageWithUser.message.thumbnailImageToken?.get("path") as? String
                    if (uri != null) {
                        val context = LocalContext.current
                        val bitmap = remember(uri) {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                val src = ImageDecoder.createSource(context.contentResolver, uri.toUri())
                                ImageDecoder.decodeBitmap(src)
                            } else {
                                val inputStream = context.contentResolver.openInputStream(uri.toUri())
                                BitmapFactory.decodeStream(inputStream)
                            }
                        }
                        Image(
                            bitmap = bitmap.asImageBitmap(),
                            contentDescription = null,
                            modifier = Modifier
                                .clickable { onImageClick(uri) }
                        )
                    }
                } else {
                    Text(text = messageWithUser.message.text)
                }
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