//
//  ContentView.swift
//  Sprioc
//
//  Created by Brad Root on 9/18/24.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import SwiftUI
import SwiftData

struct TodoDetail: View {
    let text: String
    var body: some View {
        Text(text)
    }
}

struct TodoItem: View {
    @State private var showingSheet = false
    @State private var showingDetail: Bool = false
    @State private var todoName: String = ""
    var todo: Todo
    var body: some View {
            HStack {
                Button(action: {
                    withAnimation {
                        todo.complete.toggle()
                        try? todo.modelContext?.save()
                    }
                }) {
                    Image(systemName: todo.complete ? "checkmark.circle" : "circle")
                }.buttonStyle(.borderless)
                VStack {
                    HStack {
                        if showingDetail {
                            TextField("Name", text: $todoName)
                        } else {
                            Text(todo.name)
                        }
                        Spacer()
                        Button(action: {
                            showingSheet.toggle()
                        }) {
                            Image(systemName: "info.circle")
                        }
                            .buttonStyle(.borderless)
                            .sheet(isPresented: $showingSheet) {
                                TodoDetail(text: todo.name)
                            }
                            .opacity(showingDetail ? 1 : 0)
                    }
                    if let date = todo.dueDate {
                        HStack {
                            Text(date.formatted()).font(.caption).foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }.background().onTapGesture {
                    todoName = todo.name
                    showingDetail.toggle()
                }

            }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Todo.complete), SortDescriptor(\Todo.name)]) private var todos: [Todo]

    @State private var showingAlert = false
    @State private var name = ""


    var body: some View {
        NavigationStack {
            List(todos) { todo in
                TodoItem(todo: todo)
            }
            .navigationBarTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addTodo) {
                        Label("Add Todo", systemImage: "plus")
                    }.alert("Add Todo", isPresented: $showingAlert) {
                        TextField("Buy groceries", text: $name)
                        Button("OK", action: submit)
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
        }
    }

    private func submit() {
        guard !name.isEmpty else { return }

        withAnimation {
            let todo = Todo(name: name)
            modelContext.insert(todo)
            try? modelContext.save()
            name = ""
        }
    }

    private func addTodo() {
        showingAlert.toggle()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Todo.self, configurations: config)

    for i in 1..<10 {
        let todo = Todo(name: "Example Todo \(i)")
        todo.complete = [true, false].randomElement() ?? false
        container.mainContext.insert(todo)
    }

    return ContentView()
        .modelContainer(container)
}
