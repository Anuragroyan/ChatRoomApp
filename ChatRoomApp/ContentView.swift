//
//  ContentView.swift
//  ChatRoomApp
//
//  Created by Dungeon_master on 07/06/25.
//

import SwiftUI
import Combine

struct Message: Identifiable, Equatable {
    let id: UUID = UUID()
    let text: String
    let timestamp: Date
    let isCurrentUser: Bool
    
    static func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: ~daysAgo, to: Date()) ?? Date()
    }
}

class ChatService: ObservableObject {
    @Published var messages: [Message] = []
    
    init() {
        loadDummyMessages()
    }
    
    private func loadDummyMessages() {
        messages = [
                    Message(text: "Hey everyone! Welcome to the chatroom.", timestamp: Message.date(daysAgo: 2), isCurrentUser: false),
                    Message(text: "Hi! Glad to be here.", timestamp: Message.date(daysAgo: 2), isCurrentUser: true),
                    Message(text: "What's up, folks?", timestamp: Message.date(daysAgo: 1), isCurrentUser: false),
                    Message(text: "Not much, just chilling. How about you?", timestamp: Message.date(daysAgo: 1), isCurrentUser: true),
                    Message(text: "Thinking about dinner plans. Any suggestions?", timestamp: Message.date(daysAgo: 0), isCurrentUser: false),
                    Message(text: "Pizza is always a good idea!", timestamp: Message.date(daysAgo: 0), isCurrentUser: true),
                    Message(text: "Or maybe some tacos? 🌮", timestamp: Message.date(daysAgo: 0), isCurrentUser: true),
                    Message(text: "Tacos sound great!", timestamp: Message.date(daysAgo: 0), isCurrentUser: false),
                    Message(text: "What a lovely day today!", timestamp: Date(), isCurrentUser: false) // Latest message
                ].sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    func sendMessage(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newMessage = Message(text: text, timestamp: Date(), isCurrentUser: true)
        messages.append(newMessage)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let responseMessages = [
                "That's interesting!",
                "Tell me more.",
                "Sounds good!",
                "Haha, I agree!",
                "Cool!",
                "👍"
            ]
            if let randomResponse = responseMessages.randomElement() {
                let simulatedResponse = Message(text: randomResponse, timestamp: Date(), isCurrentUser: false)
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isCurrentUser { Spacer() }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading) {
                Text(message.text).padding(10).background(message.isCurrentUser ? Color.blue : Color.gray.opacity(0.2)).foregroundColor(message.isCurrentUser ? .white : .primary).cornerRadius(15)
                Text(message.timestamp, style: .time)
                    .font(.caption2).foregroundColor(.secondary)
            }
            if !message.isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

struct ChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var newMessageText: String = ""
    
    var body: some View {
        VStack{
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(chatService.messages) { message in MessageBubble(message: message).id(message.id)
                        }
                    }.padding(.vertical)
                }
                .onChange(of: chatService.messages) { _, _ in
                    if let lastMessage = chatService.messages.last {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
                .onAppear {
                    if let lastMessage = chatService.messages.last {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Type your message...", text: $newMessageText).textFieldStyle(
                    .roundedBorder)
                .padding(.horizontal).frame(height: 44)
                
                Button("Send") {
                    chatService.sendMessage(text: newMessageText)
                    newMessageText = ""
                }
                .buttonStyle(.borderedProminent)
                .padding(.trailing)
            }
            .padding(.bottom)
        }
        .navigationTitle("ChatRoom")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}


